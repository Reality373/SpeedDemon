# Project progress

Updated: 2026-10-30. This is the canonical task tracker. [Status](status.md) is the current summary; [problems](problems.md) records blockers. Use `Done`, `Next`, `Planned`, or `Blocked`; mark Done only with evidence.

## Preparation

| ID | Work item | State | Completion evidence / remaining work |
|---|---|---|---|
| PREP-01 | Save organizer context and project brief | Done | `context.md` and `project-brief.md`; context hash in source-integrity report |
| PREP-02 | Retrieve and pin starter/specs/generators/reference/harness | Done | 162 exact source blobs; one unneeded ARM64 binary omission recorded in manifest |
| PREP-03 | Define folder structure, PRD, architecture and test plan | Done | Root README, PRD, architecture, harness and testing documents |
| PREP-04 | Prepare public seed-1 data at tiny/sample/full scales | Done | 12 generated datasets; all seven full input hashes verified |
| PREP-05 | Validate upstream unit tests and host reference outputs | Done | 235 tests: 213 passed, 22 skipped; all four full output hashes matched; 12 host reference executions succeeded |
| PREP-06 | Record host capabilities and parity gaps | Done | Environment report; Docker socket unavailable, Ryzen/Fedora deviations documented |
| PREP-07 | Document initial stack/design research and experiment agenda | Done | Research, architecture and decisions; choices explicitly provisional |
| PREP-08 | Establish status, problem and experiment tracking | Done | Status/progress/problem documents, experiment template and empty ledger |
| PREP-09 | Download release hash manifest and needed Docker images | Blocked | Network/daemon prerequisites; pinned calibration and generated data are available |

## First implementation milestone: harness

| ID | Work item | State | Acceptance |
|---|---|---|---|
| HAR-01 | Establish accessible Docker/cgroup benchmark environment | Next; environment blocked | Daemon info, mount visibility and parent-cgroup access verified; deviations recorded |
| HAR-02 | Prepare pinned reference/static-tools images and amd64 timer | Planned | Image/platform identities and timer hash recorded; offline reference build succeeds |
| HAR-03 | Add thin local orchestration around official runner | Planned | Mandatory expected hash, preflight, source/data identities, structured report validation, fresh run directories |
| HAR-04 | Validate positive and negative run-contract cases | Planned | Correctness, timeout, nonzero exit, filesystem/output and memory-accounting checks produce expected reports |
| HAR-05 | Establish all-track reference baselines | Planned | Full input/output hashes, five serialized timer measurements, maximum cgroup peak, S/D and drift/spread checks |

Harness is ready only when HAR-01 through HAR-05 pass. Host reference correctness is preparation evidence, not completion of this milestone.

## Research and solutions after harness readiness

| ID | Work item | State | Acceptance |
|---|---|---|---|
| RES-01 | Select final stack and initial track priorities | Planned | Team fluency considered; any performance claims supported by equivalent measured prototypes |
| RES-02 | Profile baseline and select first optimization | Planned | Full-scale phase costs and hypothesis recorded |
| SOL-A | Implement and optimize Track A | Planned | Test matrix and multi-seed exactness, sandbox run, measured experiment history |
| SOL-B | Implement and optimize Track B if selected | Planned | Same, including full-scale index/query tradeoff and left-associative semantics |
| SOL-C | Implement and optimize Track C | Planned | Same, including every CSV edge case and exact unescaped bytes |
| SOL-D | Implement and optimize Track D | Planned | Same, including uint64 distances and unreachable/zero-weight cases |
| REL-01 | Establish Git repository and initial history | Initialized; commits blocked in this session | User initialized `master`; keep all current commits on `master`. Staging fails on read-only `.git`. Ignore rules and `tools/commit-setup.sh` prepare six focused commits. No workspace commits created yet. Submission branch setup is deferred. |
| REL-02 | Confirm registration, team form, repo and board app | Planned | Actual team details and account state verified; no inferred completion |
| REL-03 | Use board feedback and maintain per-track PERF.md | Planned | Genuine run IDs linked to measured commits and changes |
| REL-04 | Freeze candidate and complete packaging/publication checks | Planned | Correct recorded commit, offline builds, independent folders, required docs and OSI license |

## Update discipline

After each milestone or accepted/rejected experiment, update this table and `status.md` together. Add evidence links and any new issue to `problems.md`. Do not overwrite raw reports to make a failed experiment disappear. Record deliberate scope changes, including dropping a track, in `decisions.md`.
