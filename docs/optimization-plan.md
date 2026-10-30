# Optimization plan: experiments run so far, and the plan per track

Status: exploratory evidence, gathered in a sibling scratch workspace, pre-harness.
Date (UTC): 2026-10-30, 16:14. This is not a HAR-01…HAR-05 acceptance ([progress.md](progress.md)):
the measurements below used an ad hoc `docker run` + self-reported `/proc/self/status`
`VmHWM`, not the official timer (`sd-timer`) or the official parent-cgroup
`memory.peak`. Treat every number here as a **directional, not comparable-to-board**
signal, same as [status.md](status.md)'s performance-snapshot caveat. Nothing below
is submission code — no project code lived in a `track-*` folder, matching the
competition rule that solution code is written during the 72-hour window
(Oct 30 15:00 UTC → Nov 2 15:00 UTC per [context.md](context.md)).

This doc complements, and does not replace, [research.md](research.md)'s experiment
table (`R-01`…`R-09`) and [architecture.md](architecture.md)'s candidate data flows —
cross-references are called out inline.

## Environment correction, upstream of everything else here

[problems.md](problems.md) P-01 and P-04 recorded Docker and `.git` as inaccessible
in the original preparation session. In a later session on the same host
(2026-10-30T16:14Z), `docker version --format '{{.Server.Version}}'` returned
`29.7.2` (the daemon, not just the client, was reachable), `docker info` succeeded,
and `touch .git/test_write_check` succeeded. Both blockers are session-dependent,
not fixed host properties — re-check at the start of each session. See problems.md
for the exact evidence and updated state.

## What was actually run

All of this happened in a separate scratch directory outside any `track-*` folder,
using the real public harness (`hackathon-raptors/speed-demon-2026`, cloned at
depth 1) and the real allowlisted toolchain images (`rust:1-slim-trixie`,
`debian:13-slim`, pinned by digest — see [resources.md](resources.md)'s preserved
`allowlist.json`), never the project's own future submission paths.

### Environment/mechanism check: does `/data` I/O method affect M?

[harness.md](harness.md)'s parity matrix already states the harness pre-warms
`/data` into the host page cache *before the run cgroup exists*, specifically so a
submission reading `/data` — by any method — doesn't get charged for those pages on
its own `memory.peak`. A throwaway FFI-only Rust benchmark (mmap-and-touch-every-page
vs. a reused fixed-size buffered read, against a 200MB synthetic file, in the real
images) measured the mechanism directly and confirms the direction implied by the
harness source: touching every page of an mmap'd region costs resident memory ~1:1
with bytes touched (`VmHWM` ≈ 202MB), while buffered reads keep self-reported RSS at
single-digit MB regardless of input size (`VmHWM` ≈ 2.9MB) — **when measured without
prewarming**. Once prewarming is accounted for (as the real harness does), this
difference should mostly disappear from the board's `memory.peak`: **the memory
that actually matters is our own allocated structures (index, CSR arrays, hash
maps, output buffers), not how `/data` itself is read.** This matches
[research.md](research.md) finding 5 and directly informs `R-03`: expect the real
differentiator on `R-03` to be small once run under the official harness, since the
harness is specifically designed to neutralize it — don't over-invest engineering
time here relative to the other experiments.

### Track A (Ingest) — scratch prototype, zero dependencies

- Generated seed-1 `full` `requests.log` locally — input hash matched the published
  calibration exactly.
- Ran the unmodified Python reference on the host (not sandboxed): 24.3s wall. (The
  pinned calibration's `T_ref` is 32.047276s, on the i5-13500 — not comparable to
  this Ryzen host directly, consistent with [harness.md](harness.md)'s parity
  caveats.)
- Rust candidate: hand-rolled space-delimited field scan (no generic
  `split()`/regex); the hour-group key is taken as a **literal 13-byte substring of
  the RFC3339 timestamp** (`ts[0..13] + ":00:00Z"`) rather than parsed through a
  date/time library — the reference's `datetime.strptime` call is most of its own
  cost, per [research.md](research.md) finding 1's harness-source basis, and this
  sidesteps it entirely rather than writing a faster date parser. Groups held in a
  `HashMap<(String, String), Group>`, each group holding a `Vec<u32>` of latencies,
  sorted at output time for nearest-rank percentiles — this is the "scalar baseline"
  shape [architecture.md](architecture.md)'s Track A candidate data flow describes,
  **not yet** the endpoint-interning / flat-array refinement that section also
  proposes.
- **Output hash matched the published calibration output hash exactly**, on the
  first attempt.
- Measured (self-reported, see caveat above): 0.78s parse+group, 0.90s total
  process time inside the container, `VmHWM` 288MB — of which ~238MB is the
  `fs::read` copy of the entire input into one `Vec<u8>`. Per the mechanism finding
  above, that copy is likely to cost far less on the real harness's
  `memory.peak` than it costs here; the real working-set cost is closer to the
  HashMap + per-group `Vec<u32>` storage, roughly in the tens of MB.
- Back-of-envelope K (local host reference ÷ local host candidate, **not** a local-K
  per [research.md](research.md)'s definition since it uses the organizer's
  calibration time rather than a same-machine reference run alongside the
  candidate) landed around 5–7, i.e. a speed score in the mid-30s to low-40s out of
  100 for this first, single-threaded, un-tuned cut. This is a lower bound, not a
  projection: no parallelism, no interning, no PGO applied yet.

### Track D (Traverse) — scratch prototype, zero dependencies

- Generated seed-1 `full` `graph.txt`/`queries.txt` locally — both hashes matched
  the published calibration.
- Ran the unmodified Python reference on the host: 60.2s wall (pinned calibration
  `T_ref` 72.692655s on the i5-13500).
- Rust candidate: CSR adjacency built via counting sort (tally out-degree per node,
  prefix-sum, scatter into flat `col_indices`/`weights` arrays) — matches
  [architecture.md](architecture.md)'s Track D baseline exactly. Queries split
  across a 12-thread `std::thread::scope` pool, each thread running early-exit
  Dijkstra with its own reused `dist: Vec<i64>` / `gen: Vec<u32>` generation-stamped
  buffers (reset is O(1) per query via a bumped generation counter, not an O(n)
  clear). `dist` is `i64`, matching `architecture.md`'s explicit requirement.
- **Output hash matched the published calibration output hash exactly.**
- Measured: 429ms parse+CSR, 1.76s for all 2,000 queries across 12 threads, 2.19s
  total process time. `VmHWM` 384MB: ~92MB is the `graph.txt` read (subject to the
  same "likely free on the real harness" caveat as Track A), but **~250MB is a real,
  identified cost**: 12 threads × (13.9MB `dist: Vec<i64>` + 7MB `gen: Vec<u32>`),
  each sized to the full node count `n = 1,740,512` regardless of how much of the
  graph any individual query's search actually touches. This is a concrete,
  measured input to `R-08` (worker-count sweep) that `research.md` didn't have
  before: more threads buys parallelism but each one pays this fixed `~21MB`
  up front, so the 1/2/4/6/12 sweep `R-08` already plans should report this
  specifically, not just wall time.
- Back-of-envelope K (same caveat as Track A) landed around 5.6–6.1, speed score
  roughly 37–39/100 for this first cut.

### Correctness findings worth carrying into `testing.md`'s track matrix

- **A silent `u32`→`i64` distance-overflow near-miss, Track D.** A path's summed
  weight can exceed `2^32` even though each edge weight is a `u32` (the official
  spec's own worked example answers `8589934594`, ≈2^33). An early scratch version
  of the Track D prototype used `u32` for the running distance and would have
  wrapped silently; it passed a hand-written differential test only because that
  test's synthetic weights were small (0–20) and never exercised the overflow path.
  [testing.md](testing.md)'s Track D row already lists "UINT32_MAX and longer path
  sums" — this is a concrete confirmation that row is load-bearing, not
  boilerplate: a differential test is only as strong as its input's coverage of the
  value range, and hand-written synthetic inputs are exactly where that coverage
  tends to be thin. Generated-seed testing (`testing.md` layer 4) is what actually
  catches this, since the real generator injects near-`u32::MAX` weights on
  purpose.
- **A BOM-placement miss, Track C (caught in the sibling repo's earlier prep, before
  this session).** An early scratch CSV state machine only stripped a BOM at the
  start of the whole file buffer and missed BOMs that the real generator places
  after *any* record terminator (~777 of them at full scale, not just at byte 0).
  Confirms [testing.md](testing.md)'s requirement to test "mid-record-boundary BOM
  after LF and CRLF" explicitly, and confirms the fix has to live inside the state
  machine's "start of a new record" transition itself, not a one-shot prefix strip
  before parsing begins.

## The plan: concrete refinements to the candidate data flows

These are proposed next steps against [architecture.md](architecture.md)'s existing
per-track candidate flows, grounded in the scratch evidence above. None of these are
accepted designs — they need their own `R-xx` experiment entries and measurement
before a decisions.md ADR, per [research.md](research.md)'s methodology section.

### Track A

- `architecture.md` already calls for "exact endpoint interning" — the scratch
  prototype above is a pre-interning baseline, confirming the un-interned shape
  works correctly but hasn't been spedup by the planned refinement yet. Next:
  intern the ≤1,842 distinct endpoints (per spec) to a small integer id once, then
  aggregate into a flat array indexed by `hour_index * n_endpoints + endpoint_id`
  instead of `HashMap<(String, String), Group>` — removes per-line string
  allocation and hashing entirely.
- Parallelize across newline-aligned byte-range chunks (per `architecture.md`'s
  "potential parallel unit") — the scratch prototype is single-threaded; given
  Track A is close to pure parse-and-group with little cross-line dependency, this
  is likely the largest remaining `T` lever untried so far.
- Percentile extraction: the scratch prototype fully sorts every group's `Vec<u32>`.
  `architecture.md` already flags comparing "selection and contiguous two-pass
  storage" after profiling — the scratch evidence doesn't yet show whether this
  matters, since most groups are small by spec (Zipf-tailed traffic); profile the
  heaviest few groups specifically before adding selection-based complexity.

### Track D

- The identified ~250MB of per-thread `dist`/`gen` buffers is the new, concrete
  input to `R-08`. Proposed experiment: measure wall time **and** peak memory
  together at 1/2/4/6/12 workers (not wall time alone, which is what a naive sweep
  would optimize for) — the fixed per-thread allocation means the T/M tradeoff
  curve isn't monotonic the way pure parallel speedup usually is.
- Query-cost-aware scheduling: the official reference's own timing breakdown shows
  the "settles the whole main body" query kind (no-in-target source queries) costs
  roughly 3s each in the naive Python version — disproportionate to the other 1,998
  queries. A flat 12-way chunk split (as in the scratch prototype) risks landing
  both such queries on the same thread while others idle. Proposed experiment: sort
  queries by an estimated-cost proxy (e.g. known query *kind*, if recoverable, or a
  cheap distance-to-target proxy) before chunking, or use a work-stealing queue
  instead of a static split.
- `architecture.md`'s bidirectional-CSR candidate (`R-05`) remains untried; the
  scratch prototype only validates the simpler forward-CSR-plus-parallelism
  baseline. Bidirectional search still needs the "proven stopping condition" and
  explicit zero-weight/asymmetric-direction tests `architecture.md` already calls
  for before it can be accepted.

### Track B and Track C

Not prototyped yet, even informally. `architecture.md`'s existing candidate flows
for both stand as the current plan: Track B's selective, query-driven positional
index (`R-07`), and Track C's correctness-first byte-level state machine validated
against the sample hash before any optimization pass (`R-06`). The one addition
from the sibling repo's earlier prep work is the BOM-placement finding logged above,
which is already reflected in `testing.md`'s Track C row — no new untested
hypothesis to add here yet.

## Cross-cutting items not yet in `research.md`'s experiment table

- **`target-cpu=native` / `-march=native` before hand-rolled SIMD.** The official
  harness builds a track requesting this flag on the scoring box itself (so
  "native" means the real i5-13500: AVX2, no AVX-512), per `context.md`'s
  Dockerfile-contract rule 4. This is free autovectorization from the compiler with
  zero added source lines — worth trying before any hand-written SIMD/intrinsics,
  which would also cost on `S`.
- **PGO ordering.** `R-09` already covers PGO; worth stating explicitly that PGO
  profiles are tied to a specific code shape, so it should run last, after the
  algorithm and data layout are stable — re-running PGO after every algorithmic
  change wastes the training step's own time budget (training happens at build
  time, capped at 600s per `context.md`).
- **No allocator dependency unless profiling demands it.** `research.md`'s
  `ADR-009`-adjacent preference for starting dependency-free already covers this;
  explicitly: a custom allocator (e.g. a jemalloc/mimalloc-style crate) is a `D`-axis
  cost for a problem that zero-copy parsing and key interning (above) should mostly
  solve for free, since most of these tracks' allocation pressure is self-inflicted
  per-line/per-field allocation, not fragmentation the allocator itself would fix.

## Open questions this plan doesn't answer

- Whether the ~250MB Track D per-thread buffer cost actually moves `memory.peak` on
  the official harness the way it moved self-reported `VmHWM` here — needs a real
  HAR-05 baseline run, not another ad hoc measurement.
- Whether Track A's endpoint-interning refinement changes the output byte-for-byte
  (it shouldn't, if the sort-by-original-string-value step at output time is kept
  correct) — needs its own differential test before being folded into a baseline,
  per `testing.md`'s discipline.
- Exact numbers above are **not directly comparable** to the pinned calibration or
  to any future official board run, for the same reasons `status.md`'s performance
  snapshot already states: different host, different measurement method
  (self-reported `VmHWM`, not the official timer/cgroup `memory.peak`), no sandbox
  resource limits applied identically to the official five-run protocol.
