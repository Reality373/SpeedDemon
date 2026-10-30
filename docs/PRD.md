# Product requirements: Speed Demon entry

Status: preparation approved by the project request; solution language and entered tracks remain provisional. Date: 2026-10-30.

## Objective

Deliver correct, reproducible, efficient implementations for Speed Demon 2026, supported by trustworthy local measurements and an honest optimization history. Prepare all four tracks now; choose final coverage based on correctness, measured opportunity, and available time. Targeting the overall title requires at least three entered tracks. Winning is an aspiration, not an acceptance criterion we can guarantee.

Organizer basis, **Home → The overall championship** in [context.md](context.md): “geometric mean of your best three track totals.” The fourth track provides an optional discarded result.

## Deliverables and sequence

1. Preserve context and official resources, establish this documentation, record current machine capabilities.
2. Build and validate a local harness around the official runner, timer, scoring, and static-axis tools.
3. Run reference baselines; complete targeted architecture and technology experiments.
4. Implement one correct baseline per selected track, then optimize measured bottlenecks.
5. Verify generated seeds and full datasets, obtain board runs, complete per-track documentation and submission checks.

This phase delivers items in step 1 and the designs for steps 2–3. It does not silently select a final language or count an unrun sandbox as passing.

## Functional requirements

| ID | Requirement | Acceptance evidence |
|---|---|---|
| FR-01 | Each entered track is an independent root `track-*` build context | Clean offline build using only that directory |
| FR-02 | Read only specified input files, write exactly one specified output, exit zero | Official runner reports all gates passing |
| FR-03 | Exact output bytes on every run | Published hashes and differential oracle checks across seeds |
| FR-04 | Reproducible local benchmarks | Commit/source digest, image digest, input hashes, host facts, commands, raw runs |
| FR-05 | Document every retained or rejected optimization | Experiment entry with measurements; genuine board IDs in `PERF.md` |
| FR-06 | Preserve original resources | Upstream commit and Git blob checks, retained license notices |
| FR-07 | Show current performance and blockers | `status.md` updated after every milestone and accepted experiment |

| Track | Inputs under `/data` | Output under `/out` | Core contract |
|---|---|---|---|
| A | `requests.log` | `summary.txt` | Hour/endpoint groups, nearest-rank percentiles, integer error ppm |
| B | `docs.txt`, `queries.txt` | `results.txt` | ASCII byte tokenizer; left-to-right boolean sets; exact token phrases |
| C | `records.csv`, `regions.csv` | `aggregates.txt` | CSV unescaping and BOM rules; exact money; exact distinct names |
| D | `graph.txt`, `queries.txt` | `distances.txt` | Directed shortest paths; uint32 weights, 64-bit distances; `-1` unreachable |

See each official `specs/*` file, sections 2–4, in [the resource snapshot](../resources/upstream/speed-demon-2026/specs/).

## Runtime and packaging requirements

Use the pinned harness for exact semantics: six physical P-cores/twelve hardware threads on the scoring box, 8 GiB container memory with swap disabled, 512 pids, 1 GiB `/tmp` tmpfs, no network, read-only root and `/data`, uid 65534 for the solution, and default Docker seccomp. The build is offline, at most 600 seconds; image cap is exactly `2 * 1024**3` bytes in the runner. Every external base image must be allowlisted and digest-pinned. Do not use a library prohibited by the relevant spec.

Organizer basis, **Kickstart → The contract your program meets**: “writes exactly one file to /out, then exits 0.” Exact flags are in [run_submission.py](../resources/upstream/speed-demon-2026/harness/run_submission.py).

## Optimization objective

```text
K = (Tref/T)^0.50
  × min(Mref/M, 50)^0.20
  × min(Sref/S, 1)^0.15
  × min(Dref/D, 1)^0.15
machine_points = clamp(50 × log10(K), 0, 100)
track_total = 0.65 × machine_points + 0.35 × judge_score
overall = geometric mean of the best three track totals
```

`D = 1 + direct non-stdlib runtime dependencies`; `S` is measured after organizer formatting. The official implementation handles zero counted source lines as the capped factor. Do not divide by zero in local reporting. Judges cover code quality (15% of total), technique (12%), and the optimization log (8%).

Targets: zero known correctness failures; all required sandbox checks pass; stable five-run measurements; improvements accepted on measured K and engineering clarity. No speculative target time is represented as achieved performance. Local K must use a local reference on the same dataset/machine/protocol; board K must be identified separately. Final holdout scores are unknown until organizer evaluation.

## Dates and submission

| Event | UTC | India time (UTC+05:30) |
|---|---|---|
| Kickoff | October 30, 2026 15:00 | October 30, 20:30 |
| Code freeze | November 2, 2026 15:00 | November 2, 20:30 |
| Public repository deadline | November 2, 2026 16:00 | November 2, 21:30 |

Use one GitHub repository, `speed-demon` branch, an OSI-approved license, individual registrations, team submission form, and installed board app through freeze. Team identity, registration, repository URL, and app installation are currently unverified. Do not infer them from this local workspace. The write-up side quest closes November 10; the document does not specify its exact cutoff time.

## Out of scope for preparation

Remote submission or publication, buying a server, changing host-wide Docker/governor settings, fabricating board runs, and optimization code before reference/harness validation. These are separate work items, not prerequisites to writing useful documentation.
