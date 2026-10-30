# Evidence and outputs

- `setup/`: compact tracked environment, retrieval, dataset and upstream-test evidence.
- `reference-outputs/`: generated oracle outputs; ignored by Git and excluded from solution images.
- `runs/`: future raw benchmark directories with commands, identities, official reports and outputs; ignored by Git.
- `work/`: disposable future harness build/run working space; ignored by Git.

Only a validated sandbox report establishes local benchmark results. Setup reports establish resource integrity and host correctness, with skipped checks and missing capabilities explicitly recorded. The current performance summary lives in [status.md](../docs/status.md).
