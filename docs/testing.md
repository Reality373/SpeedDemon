# Correctness and measurement plan

Organizer basis, **Home → Correctness** in [context.md](context.md): “If your submission produces the right answer four times out of five, it fails.” All acceptance requires deterministic output.

## Layers

1. Verify official resource blob hashes and dataset SHA-256 values.
2. Run upstream unit tests to validate the retrieved generators, references, and harness logic on this host.
3. Run worked examples and tiny seeds against candidate and unchanged reference.
4. Differential-test at least seeds 1, 2, 7 and 42 at tiny/sample scales (project policy, not an organizer requirement).
5. Verify full seed 1 against published input and output hashes, plus at least one additional generated full seed before release.
6. Run the actual sandbox on the exact release image five times. Repeat after any parsing, algorithm, compiler or concurrency change.

Generated edge cases, hand-crafted spec cases and multi-seed comparisons complement one another. Tiny-only success is not proof of full-scale correctness or performance. Host reference checks establish oracle outputs but do not validate Docker or memory accounting.

## Track matrix

| Track | Required cases before optimization acceptance |
|---|---|
| A | Empty input; one request; percentile ranks at n=1,2,100,101; duplicate lines/latencies; 0 and UINT32_MAX; statuses 499/500/599 and any legal status; hour/day/month rollover; disordered timestamps; prefix/case byte order; long endpoint |
| B | ASCII capitals; multibyte UTF-8 separators and normalization traps; empty/tokenless docs; zero-padded numbers; single term/absent terms; operator words as terms; all mixed left-associative operations; repeated phrases; punctuation/sentence crossing; no cross-document match; duplicate queries; 64-bit ID sums; exact top ten |
| C | Every spec 2.5 case; initial/mid-record-boundary BOM after LF and CRLF; embedded LF; escaped quote at field ends; empty quoted/unquoted equivalence; unescaped lengths; trailing spaces; unknown region holes/high IDs; all-negative sub-unit money; zero min/max; absent country; 64-bit sums; EOF behavior from spec 2.1 |
| D | Directed asymmetry; parallel edges in both weight orders; duplicates; self-loops; zero edges/zero paths; isolated same-node; no-in/no-out; disconnected islands; UINT32_MAX and longer path sums; duplicate queries; heap stale entries; bidirectional stopping if added |

Use exact equality for hash-table keys; probabilistic hash-only equality is not sufficient for names, endpoints, or terms. Verify partition boundaries and merges separately before introducing threading. Sanitizer/debug runs can find native-code faults, but their timings must never enter performance comparisons.

## Benchmark discipline

- Serialize measured runs and finish downloads, data generation and tests before timing.
- Warm inputs and record identical process-start timing on reference and candidate.
- Capture raw times, maximum cgroup memory, source lines, dependency count, hashes and exit conditions.
- Use the official trimmed-mean/spread logic and before/after reference drift check.
- Profile separately from scoring measurements; instrumentation changes runtime.
- Keep baseline and candidate on the same seed, scale, flags, thread count and host state.
- A failed gate ends the optimization's acceptance regardless of speed.
- Unknown measurement fields remain empty; do not replace missing memory with RSS or invent a score.

## Results record

Each run directory should include `metadata.json`, the official runner report, build logs, output hash, static-axis report, and optional profile artifacts. Metadata includes UTC time, track, seed/scale, input hashes, source commit/tree digest and dirty state, harness commit, image ID/digest, compiler flags, host configuration, run mode and baseline run ID. A local UUID is not an official live-board run ID.

Use [experiment-template.md](experiment-template.md) for interpretation and [benchmarks/experiments.csv](../benchmarks/experiments.csv) as the compact index. Only genuine board measurements justify board-based `PERF.md` claims.
