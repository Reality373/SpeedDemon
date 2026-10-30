# Local harness: first implementation milestone

Status: design and upstream code available; our wrapper and container validation are pending.

## Reuse the referee

Base execution on [official run_submission.py](../resources/upstream/speed-demon-2026/harness/run_submission.py), [sd-timer.c](../resources/upstream/speed-demon-2026/harness/timer/sd-timer.c), [static_axes.py](../resources/upstream/speed-demon-2026/harness/static_axes.py), and [scoring.py](../resources/upstream/speed-demon-2026/harness/scoring.py). Add a thin local entrypoint for preflight, dataset selection, run metadata, and comparison; do not independently reinvent measurement semantics.

The official harness README, **What a scored run does**, states: “M is the highest of the five peaks.” Its timing wrapper measures program execution, excluding container start/teardown. The starter `check.py` includes container startup, omits CPU pinning and full memory measurement, and may skip allowlist checks if its online fetch fails. Keep it as an upstream smoke tool, not the benchmark authority.

## Parity matrix

| Property | Official target | Local approach / current evidence |
|---|---|---|
| Architecture | x86-64, AVX2, no AVX-512 | Ryzen 5 5600H supports AVX2; instruction costs differ |
| CPU allocation | 6 P-cores / 12 threads, cpuset `0-11` | 6 homogeneous cores / 12 threads visible; detect allowed affinity before choosing cpuset |
| Clock | Performance governor, turbo disabled | Boost enabled at inspection; record deviations; dedicated benchmark host preferred |
| Cache | 11.5 MiB L2 / 24 MiB L3 | Local 3 MiB L2 / 16 MiB L3; cannot emulate cache by Docker limits |
| Host | Debian 13, cgroup v2 | Fedora 43, cgroup v2 controllers present |
| Docker | Accessible daemon; cgroupfs driver for official runner | Client 29.7.2 present; socket denied; server/driver unverified |
| Memory | 8 GiB, no swap | Use exact Docker flags; host has about 27 GiB RAM and swap, which must remain unavailable to the container |
| Scratch | 1 GiB tmpfs; counts in M | Use official mount; do not replace with host disk spill |
| Inputs | Read-only; host page cache prewarmed | Use official prewarm before run cgroup creation |
| Output | Exactly named regular file, exact hash | Fresh isolated output directory; always supply nonempty expected hash |
| Timing | Static timer, monotonic exec-to-exit, uid 65534 | Build included timer for linux/amd64; validate in actual container |
| Peak memory | Per-run parent cgroup `memory.peak` | Requires host permissions and compatible Docker cgroup driver; never silently substitute RSS |
| Security | No network, read-only root, seccomp, capability restrictions | Reuse exact run flags and filesystem/output checks |
| Source/dependencies | Pinned tools image and organizer defaults | Build/pull official static-tools once; unavailable axes stay unknown |

A local limit match is useful, but a Ryzen result is not an i5-13500 result. Do not add sleeps, CPU quotas, or clock scaling to manufacture comparable milliseconds. Measure the local reference and candidate together and use official board runs to confirm transfer.

## Required preflight

Record CPU model/topology/affinity, kernel/OS, RAM, available space, cgroup mode/driver, Docker versions, governor/boost, image platform/digests, timer hash, harness commit, source digest/commit and dirty state. Confirm Docker mounts can see the workspace's actual host path. On this setup the shell's logical path and mounted path differ; resolve and verify with a container rather than assuming either one.

Fail strict benchmarking when Docker, cgroup peak access, expected hash, timer, or necessary image is unavailable. An explicitly labeled host correctness check may run independently, but it must not report sandbox success, official T/M, or a comparable K.

Do not run upstream `setup-box.sh` or `bootstrap-box.sh` on the daily-use host automatically: they alter Docker configuration, system services, CPU settings and mounts. Review the minimum needed environment change when the harness milestone starts. A dedicated machine with Debian 13 is the closest software match; purchasing or provisioning one is not part of this setup.

## Execution protocol

1. Resolve a hash-verified dataset and matching reference output hash.
2. Validate Dockerfile with the local pinned allowlist, enforce a 600-second offline build and 2 GiB image cap.
3. Warm input files from the host before creating the run cgroup.
4. Run serially five times under the official timer and sandbox, verifying every run. Preserve failure evidence.
5. Compute T from the middle three wall times and M from the maximum peak. Preserve all five values.
6. Apply the official spread test: middle-three range no greater than `max(0.05 * middle_mean, 0.050)` seconds, at most two reruns.
7. Measure the reference before and after a comparison batch; invalidate comparisons with more than 2% drift. Keep the prior raw records, even when invalidated.
8. Measure S/D with the official static tools and compute local K only when all axes are known and all gates pass.

The official `run_submission.py` may exit normally while writing a failed report. A wrapper must inspect `build.ok`, all gates, run count, output hashes, and `spread_ok`; process return code alone is insufficient. A supplied empty expected hash is not an acceptable correctness test. Record unavailable checks as unknown, never as true.

Exact timeout values come from the calibration being used, not rounded website cards. Public calibration carries A/B/C/D final caps of 320.5/563.5/144.4/726.9 seconds and board caps 96.1/169.1/43.3/218.1. Local calibration and final holdout calibration are separate datasets and anchors.

## Implementation acceptance

- Official reference passes the container contract on all four tiny datasets, followed by full seed 1.
- Negative fixtures detect a wrong hash, extra output, nonzero exit, timeout and missing memory measurement. Resource-limit probes run only inside the constrained sandbox.
- A five-run result contains genuine timer and cgroup evidence, and source measurement is checked with the official tools.
- Reference/candidate comparison refuses mismatched data, execution mode, or incomplete axes.
- All generated reports identify host correctness, local sandbox benchmark, or official board provenance.
- One documented command selects track, dataset and mode and writes a fresh run directory; implementation remains pending.

## Upstream command template

After preflight and timer compilation, from the workspace root (replace paths/expected hash with verified values):

```bash
python3 resources/upstream/speed-demon-2026/harness/run_submission.py \
  --context resources/upstream/speed-demon-starter/track-a --track a \
  --data data/generated/track-a/full-seed1 --output summary.txt \
  --expected-sha256 495ca09682b9673ef836a506496177680bb4a3af54255174befddb1f83481cd3 \
  --timeout-s 320.5 --timer tools/bin/sd-timer --cpuset 0-11 \
  --work results/work --results results/reference-a.json
```

This is an execution recipe, not evidence of a completed run. `tools/bin/sd-timer` must exist and the runner needs host permissions. The static-tools image is prepared with network access outside submission builds; submission image builds remain offline.
