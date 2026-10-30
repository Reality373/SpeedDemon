# Speed Demon 2026 workspace

Preparation, reproducible tests, and measured optimization for Tracks A–D. Start with [current status](docs/status.md), then [progress](docs/progress.md).

The next implementation milestone is the local test harness. Solution code starts after the harness has a verified reference baseline. The selected solution folders will be created at the repository root when solution work begins.

## Documentation

| Document | Purpose |
|---|---|
| [Context](docs/context.md) | Full organizer context supplied by the user, preserved as a snapshot |
| [PRD](docs/PRD.md) | Scope, requirements, success criteria, and deadlines |
| [Architecture](docs/architecture.md) | Directory structure, runtime boundaries, and candidate designs |
| [Harness design](docs/harness.md) | First implementation milestone and hardware parity limits |
| [Testing](docs/testing.md) | Correctness matrix and benchmark acceptance criteria |
| [Research](docs/research.md) | Initial findings, technology shortlist, and experiment agenda |
| [Optimization plan](docs/optimization-plan.md) | Exploratory pre-harness experiments actually run, per-track findings, and the concrete refinement plan |
| [Problems](docs/problems.md) | Blockers, correctness risks, and unresolved decisions |
| [Progress](docs/progress.md) | Work items and completion evidence |
| [Status](docs/status.md) | Current readiness and performance summary |
| [Resources](docs/resources.md) | Provenance, dataset inventory, and reproduction commands |
| [Decisions](docs/decisions.md) | Accepted and provisional engineering choices |
| [Experiment template](docs/experiment-template.md) | Record one hypothesis and its measurements |

## Layout

```text
docs/                         Requirements, design, research, status, and original context
resources/
  upstream/speed-demon-starter/  Preserved starter code, including check.py and all four tracks
  upstream/speed-demon-2026/     Preserved specs, generators, references, harness, tests, board
  upstream-manifest.json        Upstream commits, file hashes, and retrieval exceptions
  datasets.json                Dataset URLs and expected hashes from official calibration
data/generated/track-*/        Generated tiny/sample/full datasets, outside build contexts
results/setup/                 Setup evidence and data integrity reports
benchmarks/                    Compact experiment ledger; raw runs go under results/
tools/                         Future local harness entrypoints
tests/                         Future integration and regression fixtures
track-a/ … track-d/            Future independent submission build contexts
```

Do not put datasets, benchmark reports, or tooling in a track folder. Each track must build from its own folder alone. All competition claims defer to the pinned official specs and harness. Proposed optimizations are hypotheses until measured.
