# Decision log

Date: 2026-10-30. Accepted means a project engineering choice, not organizer approval. Revisit provisional choices using measurements.

| ID | Decision | State | Reason / revisit trigger |
|---|---|---|---|
| ADR-001 | Preserve upstream code under `resources/upstream/`, pin commits and verify blob hashes | Accepted | Keeps original oracle/harness available and changes auditable. Refresh only deliberately, recording a new version. |
| ADR-002 | Keep tools, tests, docs, datasets and measurements outside `track-*` build contexts | Accepted | Context clarification: “Each folder is its own build context.” Our solution cannot depend on root files at build/run time. |
| ADR-003 | Build the local test harness before any optimized solution | Accepted | User-requested sequence; correctness and measurement infrastructure must precede optimization claims. |
| ADR-004 | Reuse official execution, timer, scoring and static-axis tools; add only a thin orchestration layer | Accepted | Reduces differences from the referee. Any local deviation must appear in metadata. |
| ADR-005 | Generate public seed-1 data when download access fails, checking published hashes | Accepted fallback | Official generators are provided for this purpose. Data is marked generated, never described as directly downloaded. |
| ADR-006 | Keep host checks, local sandbox benchmarks and official board results distinct | Accepted | The context says “Your laptop's numbers are for your own iteration.” Missing axes remain unknown. |
| ADR-007 | C++20/GCC 15 is the first candidate; pinned Rust is the alternative | Provisional | Both fit offline native batch execution. No language performance comparison has run. Team fluency or measurements can change the choice. |
| ADR-008 | Prepare all four tracks; consider A → D → C, then B for implementation | Provisional | Start with the parsing baseline, then graph layout; allocate explicit correctness time to C. Final priorities depend on time, skills and measured opportunity. No entry has been registered. |
| ADR-009 | Start with standard-library solutions and scalar parsing | Provisional | Establish a readable baseline with D=1. Add dependencies/SIMD/PGO only with correctness evidence and net benefit. |
| ADR-010 | Keep current development commits on `master` | Accepted, user instruction | User initialized Git and explicitly requested master-only commits. Defer any submission branch until requested. |

For a changed decision, append its date, evidence, consequence and replacement. Preserve why a rejected experiment failed in the experiment log; do not rewrite the history as though the final approach was obvious.
