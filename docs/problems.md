# Problems, risks, and open decisions

Updated: 2026-10-30 (P-01/P-04 refreshed 16:14 UTC with later-session evidence). Track work in [progress.md](progress.md); summarize current effects in [status.md](status.md). A planned mitigation is not a resolved problem.

## Environment blockers

| ID | Evidence / impact | Next action | State |
|---|---|---|---|
| P-01 | **Session-dependent, not a fixed host property.** The original session recorded `permission denied while trying to connect to the docker API at unix:///var/run/docker.sock` ([environment.json](../results/setup/environment.json)). A later session on the same host (2026-10-30T16:14Z) ran `docker version --format '{{.Server.Version}}'` → `29.7.2` (server reachable, not just the client) and `docker info` successfully, then built and ran images from the pinned allowlist end to end — see the `speed-demon` sibling workspace's exploratory Track A/D prototypes in [the optimization plan](optimization-plan.md), which compiled via `rust:1-slim-trixie@sha256:1a93...` and ran via `debian:13-slim@sha256:62bd...` under `--cpuset-cpus=0-11 --memory=8g --memory-swap=8g`, producing hash-exact output both times. | Re-verify Docker socket access at the start of each session before assuming either state; do not assume a prior session's "blocked" or a later session's "works" carries over. When accessible, proceed with HAR-01. | Partly mitigated — confirmed accessible in at least one later session; permission appears to vary by session/sandbox, not by host |
| P-02 | Shell network requests failed DNS resolution; direct website/S3 retrieval was unavailable. Registry images and the release hash manifest have not been downloaded. | Use the fetched pinned sources and hash-verified generated data now; retrieve release manifest/images when network access permits. | Partly mitigated |
| P-03 | Host is Ryzen 5 5600H/Fedora, with boost enabled and different caches from the i5-13500/Debian scoring machine. | Record deviations, control variance on a dedicated environment, compare against a local reference, confirm improvements on the board. | Known limitation |
| P-04 | The user initialized Git on `master`. The original session recorded `.git` mounted read-only (staging could not create `index.lock`). A later session (2026-10-30T16:14Z) confirmed `.git` writable (`touch .git/test_write_check` succeeded and was removed) on the same host. | Re-verify `.git` write access per session, same caveat as P-01. If writable, `bash tools/commit-setup.sh` still applies if its six-commit plan is wanted; otherwise commit normally on `master` only, per the user's standing instruction. | Partly mitigated — confirmed writable in at least one later session |
| P-05 | Static linux/amd64 timer and official static-tools image are not built. The ARM64 prebuilt timer was omitted by the text-only connector. | Build the included timer source for the execution architecture; prepare the official tools image outside offline submission builds. | Pending harness milestone |

Environment evidence: [environment.json](../results/setup/environment.json). Retrieval details: [resources.md](resources.md). None of these require guessing contest policy or changing the host blindly.

## Correctness and performance risks

| Risk | Consequence | Mitigation / acceptance evidence |
|---|---|---|
| Overfitting public seed 1 | Holdout fails or gains disappear | Additional generated seeds, exact differential comparisons, no input recognition or cached answers |
| CSV record splitting on LF | Track C misparses embedded newlines | Quote-aware boundaries and all spec §2.5 edge cases |
| Unicode-aware tokenizer / operator precedence | Track B gives plausible but wrong answers | Byte tokenizer and explicit left-to-right set evaluation |
| Chunk-local percentile or distinct counts | A/C merge produces incorrect totals | Merge underlying values/sets, not percentiles or distinct-count sums |
| uint32 path sum or first-meeting bidirectional exit | Track D wrong distances | 64-bit arithmetic and tested stopping condition |
| Host RSS used as memory score | Misleading K ranking | Genuine parent-cgroup `memory.peak`, maximum across runs |
| Too many workers or heavy preprocessing | Higher time, memory and source cost | Full-scale end-to-end experiments at 1/2/4/6/12 workers |
| Sample-only optimization | Different winner at full scale | Full dataset acceptance, particularly Track B |
| Documentation without board evidence | Unsupported PERF.md claims | Keep local run IDs distinct and cite real board IDs only |

## Open project decisions

- Team name, members, contact, registration and final repository URL are unknown. Preserve starter placeholders until real values are supplied.
- Final track selection is undecided. Preparing A–D does not register four entries. The overall title needs at least three; a single-track entry is allowed.
- Language is provisional. C++20 and Rust are candidates; implementation fluency and measured results decide.
- Benchmark host choice remains unresolved; no dedicated server has been purchased or provisioned. Docker permissions are session-dependent per P-01, not a fixed property of this host — re-check each session rather than assuming either prior state.

## Source discrepancies and authority

The context's introduction says: “the frozen track specs and harness … then the website pages, then the clarifications, then the video transcript.” Apply that order; keep exact sections when recording a decision.

| Observation | Treatment |
|---|---|
| Website cards round reference times and timeout values | Use exact values in pinned calibration/runner for local recipes; never derive caps from rounded cards. |
| Track B reference prose mentions a 4 GB ceiling | Official runner enforces `--memory=8g --memory-swap=8g`; use that executable contract. |
| Board description says “12 P + 8 E cores” | Runtime allocation is six physical P-cores / twelve hardware threads; do not copy the label as topology. |
| Track A says the span crosses “two midnights” but explicit timestamps run Oct 30 evening to Nov 2 evening | Use the explicit timestamp bounds and hour grouping, including all three date transitions. |
| Dataset release manifest could not be fetched | Input/output hashes currently come from pinned official calibration, corroborated by the supplied specs. Label provenance accurately. |

If the authoritative resources do not settle an eligibility question, the document does not answer it. Record the question and ask the organizers on [Discord](https://discord.com/invite/xfYPDZYqeh); do not invent an exemption. No organizer message has been sent by this setup.
