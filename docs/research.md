# Research notes and experiment agenda

Status: initial specification and harness research complete. Language ranking, optimization gains, and final architecture remain unmeasured hypotheses. Contest-rule claims use the provided context and pinned official resources; external technical documentation informs engineering choices only.

## Findings that affect the plan

1. **Reuse the official harness.** Its README says “Everything that decides your number is in this directory.” Source inspection confirms a static in-container timer, parent-cgroup peak memory, exact output checks, and separate source/dependency measurement. The starter check cannot substitute for those measurements.
2. **The objective is total work.** Track B spec §3 allows “indexing only the terms the queries use”; Track D spec §3 says “Preprocessing is allowed and counted.” Optimize end-to-end time, including index construction and output.
3. **Exactness dominates.** Track C spec §3 compares names after unescaping and also counts unescaped bytes, so ignoring unescaping cannot pass by preserving only distinct-count cardinality. Track B spec §2.2 requires ASCII byte tokenization. Track A spec §2 promises no bound on disorder. These determine architecture before SIMD or threads.
4. **Full-scale testing is necessary.** Track B spec §5 explains that query and corpus counts both grow tenfold, and candidate posting lengths grow too. Sample-only rankings can choose the wrong index.
5. **Measure memory under the right accounting.** The clarification says “It is not `ru_maxrss`.” Prewarmed input mappings and newly allocated read buffers can have different cgroup charges. This motivates an I/O comparison; it does not guarantee mmap wins.

## Candidate stack

| Candidate | Why evaluate it | Main engineering tradeoff | Decision |
|---|---|---|---|
| C++20, allowlisted GCC 15 | Compact arrays, standard sorting/selection/heaps, direct byte processing; no package install needed for standard-library baseline | Memory safety and undefined behavior need debug/sanitizer checks; custom optimizations can expand S | Primary candidate for initial prototype, provisional |
| Rust, allowlisted pinned compiler | Owned buffers, slices, standard collections and threads; optional pinned LLVM tools for PGO | FFI/mmap choices and custom hashers require careful review; no assumed performance superiority | Alternative to compare if implementation fluency is comparable |
| Go | Standard-library parsing and concurrency; allowlisted toolchain | Allocation/GC behavior must be profiled on this workload | Secondary candidate if team fluency favors it |
| JVM / native-image | Explicitly allowed AOT/training route | Startup, build budget and image size must be measured | Consider only with strong team familiarity |
| Python | Official oracle and standard-library orchestration already supplied | Current reference overhead provides the baseline to beat | Use for tooling/oracle; no optimized Python plan selected |

The context does not answer which language will maximize our score. That requires actual implementation and measurements. Initial preference for C++ is project judgment, not an organizer claim or a measured result. Start without external runtime dependencies; add a library if its correctness or net K benefit justifies the D factor and offline vendoring.

Rust's [Vec documentation](https://doc.rust-lang.org/std/vec/struct.Vec.html) describes contiguous storage and capacity management, relevant to compact arrays and avoiding growth reallocations. GCC's [optimization options](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html) document optimization levels, LTO and profile use; those flags are experiment candidates rather than guaranteed improvements. Docker's [resource constraints](https://docs.docker.com/engine/containers/resource_constraints/) confirm that setting equal memory and memory-swap limits disables swap. Consult toolchain versions inside the pinned images before selecting flags.

## Score economics, derived from the published formula

With unchanged memory, source and dependencies, a 2× speedup multiplies K by sqrt(2), adding about 7.53 machine points (4.89 weighted track points) while below the clamp. Doubling source above the S cap costs a factor of `2^-0.15 ≈ 0.901`; to offset it solely with speed, time must fall below `2^-0.30 ≈ 0.812` of the old time. Adding the first runtime dependency has the same factor when D goes from 1 to 2. Doubling charged memory, while neither memory factor is capped, requires time below `2^-0.40 ≈ 0.758` to break even.

These comparisons assume other axes remain fixed and do not estimate judge scores. Once both memory ratios are capped, reducing memory further buys no K. Avoid allocating extra work solely to hit a vanity memory figure.

## Experiments, in priority order

| ID | Hypothesis and comparison | Observe | Decision criterion |
|---|---|---|---|
| R-01 | Official runner/reference first | Correct hashes, timer and cgroup evidence | Must pass before solution optimization |
| R-02 | Straightforward C++ vs Rust equivalent parser/data layout, if needed | Implementation complexity, full time, peak, formatted S | Choose reliable higher K; prefer team fluency for indistinguishable results |
| R-03 | Buffered reads vs whole-file read vs mmap | Parse time, allocation, faults, cgroup M | Lowest total cost under warm-input protocol |
| R-04 | A group sort vs exact selection; vectors vs contiguous latency storage | Parse/aggregate/percentile/output fractions | Exact hashes and K improvement across seeds |
| R-05 | D forward CSR Dijkstra vs bidirectional CSR search | Build time, search work, reverse-array cost | End-to-end improvement including unreachable cases |
| R-06 | C direct lookup vs hash lookup; name interning strategy | Lookup, CSV parse and distinct-set costs | Exact bytes preserved; memory cost recovered in time |
| R-07 | B selective postings; rare-anchor retokenization vs positions | Index bytes/build time/query latency by kind | Full-scale total K, including repeated common phrases |
| R-08 | 1/2/4/6/12 workers only where profiling justifies it | Scaling, merge cost, peak memory | Measured K; never assume twelve workers is optimal |
| R-09 | Compiler O2/O3, LTO, then PGO using generated training seeds | Runtime, build time, formatted source changes | All seeds pass; offline build <600 s; repeatable gain |

## Exploratory pre-harness evidence

[optimization-plan.md](optimization-plan.md) records exploratory (not harness-gated,
self-reported-memory) evidence from a sibling scratch workspace: a direct mechanism
check for `R-03` (confirms the prewarm-based "`/data` I/O method shouldn't move
`memory.peak` much" expectation in finding 5), and working Track A/D scratch
prototypes that hash-matched the published calibration output on the first attempt.
It also surfaces a concrete new input to `R-08`: Track D's per-thread `dist`/`gen`
buffers cost roughly 21MB per worker regardless of how much of the graph that
worker's queries actually touch, so the worker-count sweep should report peak
memory alongside wall time, not wall time alone. None of this substitutes for
`R-01` through `R-09` run under the real harness.

## Methodology

One hypothesis per experiment. Establish a baseline, profile the largest cost, make one change, verify correctness, measure under the same protocol, calculate K with all axes, and retain or revert. Save failed experiments with an explanation. Test assumptions against fresh generated seeds rather than recognizing seed-1 bytes. For PGO, train on generated data and validate on different seeds; never ship cached answers. Use board slots for meaningful candidates after local checks, and preserve the measured commit and run ID before changing more code.

Further research after harness readiness: standard-library selection complexity and hash behavior for the chosen compiler; correct bidirectional termination with nonnegative weights; sparse/dense posting operations; quote-state partitioning if C parsing is a demonstrated bottleneck. Implement only the experiment whose expected benefit is supported by the current profile.
