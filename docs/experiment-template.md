# Experiment EXP-000: descriptive title

Status: planned / running / accepted / rejected / invalid. Date (UTC): pending.

## Hypothesis

State one bottleneck, one proposed change, and the observable result that would support it. Link the profile or baseline evidence. Identify assumptions from the spec separately from assumptions about performance.

## Reproduction

| Field | Value |
|---|---|
| Track / seed / scale / input hashes | |
| Baseline and candidate commits or source hashes | |
| Harness commit / timer hash | |
| Image digests / compiler / flags / workers | |
| Host ID / CPU allocation / clocks / cgroup configuration | |
| Mode: host correctness / local sandbox / official board | |
| Commands and raw evidence directories | |
| Genuine official board run IDs, if any | |

## Correctness and measurements

Record exact output hashes, all gate results, tested seeds, and any failed or skipped checks. A failed gate prevents acceptance. Keep missing values blank; zero is a measurement.

| Metric | Baseline | Candidate |
|---|---|---|
| Five raw wall times (s) | | |
| Trimmed-mean T (s) | | |
| Five peak-memory values (bytes) | | |
| Maximum M (bytes) | | |
| Formatted S / D | | |
| Reference anchors and calibration ID | | |
| K / machine points (only if all axes valid) | | |
| Spread / before-after reference drift | | |
| Build time / image bytes | | |

## Interpretation and decision

Explain whether the hypothesis held, whether the result survived full scale and fresh seeds, and any source/memory tradeoff. Separate diagnostic phase timings from scored end-to-end time. Explain rejected or noisy results as carefully as accepted ones. Record rollback commit/patch where relevant.

Update `benchmarks/experiments.csv`, `docs/status.md`, and `docs/progress.md`. Update the affected track's `PERF.md` with real board evidence when available. Never replace a missing board ID with a local run ID.
