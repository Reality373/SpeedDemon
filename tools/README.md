# Local tooling

`bash tools/commit-setup.sh` creates six focused setup commits on `master`, as requested. Run it from a terminal with writable `.git` metadata. It uses the configured Git author, refuses an existing commit history, a different branch, or staged changes, and does not configure a remote or push. The script is checked in an isolated temporary repository; execution in this agent session is blocked by the read-only `.git` mount.

The next implementation goes here: a small entrypoint around the pinned official harness with environment preflight, verified dataset selection, result validation and an immutable run directory. See [harness.md](../docs/harness.md) for its contract.

No custom runner is implemented yet. Official code is available under `resources/upstream/speed-demon-2026/harness/`; the starter smoke check is under `resources/upstream/speed-demon-starter/check.py`. Compiled helper binaries will live under ignored `tools/bin/`.
