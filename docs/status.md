# Current project status

Updated: **2026-10-30**. Phase: **documentation and resource preparation complete; local harness implementation is next**.

No optimized solution has been implemented or benchmarked. There is no local K, official board run, or submission result to report. The starter remains preserved under `resources/upstream/`; root submission folders have not been created.

## What is ready

- Full supplied organizer context, PRD, architecture, test/harness plans, initial research, decision/problem logs and progress tracker.
- Starter and official repository snapshots: **162 source files**, all verified against pinned Git blob hashes. Licenses retained. The text-only retrieval omitted one ARM64 timer binary; source is available.
- **12 datasets**: A–D at tiny, sample and full seed 1. All seven full input files match published calibration hashes; full inputs total **790,519,861 bytes**.
- **12 successful host reference executions**. All four full output hashes match the official calibration. Tiny/sample outputs were generated as oracles; this report does not claim a published-hash comparison for those outputs.
- Upstream suite: **235 tests, 213 passed, 22 skipped, zero failures**. Skips cover Docker end-to-end/contract checks and static-tools-dependent source measurement.

Evidence: [source integrity](../results/setup/source-integrity.json), [datasets](../results/setup/datasets.json), [reference checks](../results/setup/reference-checks.json), [test log](../results/setup/upstream-tests.log), [environment](../results/setup/environment.json).

## Performance snapshot

The following figures are **organizer public calibration**, not our results. Time and memory come from [calibration-seed1.json](../resources/upstream/speed-demon-2026/harness/calibration-seed1.json), and source counts from [reference_axes.json](../resources/upstream/speed-demon-2026/harness/reference_axes.json); reference D is 1 on every track.

| Track | Official reference T (s) | Official reference M (bytes) | Reference S | Our full host oracle hash | Our candidate T / M / S / D / K |
|---|---:|---:|---:|---|---|
| A | 32.047276 | 227,983,360 | 56 | Matches | Not measured |
| B | 56.352376 | 2,199,961,600 | 91 | Matches | Not measured |
| C | 14.444059 | 367,435,776 | 108 | Matches | Not measured |
| D | 72.692655 | 892,915,712 | 43 | Matches | Not measured |

Do not combine these organizer timing/memory anchors with host candidate measurements and call the result comparable. Local K requires matched local reference/candidate execution. The context, **Home → One machine, and you know its name**, says: “Ours are the ones on the board.”

## Readiness and blockers

| Capability | State |
|---|---|
| Specs, source and input integrity | Verified |
| Host reference correctness | Verified for all four full output hashes |
| Docker sandbox / container builds | Blocked: socket inaccessible in this session |
| Official timer / cgroup peak / S measurement | Pending actual container/tooling setup |
| Hardware equivalence | Partial: Ryzen 5 5600H, Fedora 43, different caches and boost state |
| Direct S3 downloads / registry preparation | Unavailable through shell network; generated inputs verified instead |
| Git history / team registration / board app | User initialized `master`; all current commits must stay on `master`. Agent staging is blocked by read-only `.git`; six-commit script prepared at `tools/commit-setup.sh`. Team/account state unverified. |

The next work is **HAR-01 → HAR-05** in [progress.md](progress.md): accessible benchmark environment, pinned tooling, thin official-harness integration, run-contract tests, then reference baselines. After that, measure the C++/Rust and data-layout candidates in [research.md](research.md). No claimed architecture win precedes those measurements.

## Maintaining this page

After each completed experiment, replace the candidate cells with the latest validated values and link its source commit, dataset identity, raw run report and board ID if present. Keep official and local results in separate columns. Include correctness failures, regressions and missing checks; a fast failed run does not become a performance best.
