# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [Wide domain sweep](/Users/stevenwoods/mmath-renovation/docs/wide-domain-sweep.md)

## Current Priorities

1. Push the promising `hanoi-4` hierarchy settings further, but shift the immediate diagnostic toward frontier quality under `ismb` plus MP:
   compare heuristic priority against unsatisfied-precondition count, and check whether search is overvaluing move skeletons that still leave many necessary conditions open.
2. Use the source-backed validation matrix to label the current benchmark set as matching, partially matching, or still untested against the historical claims.
3. Continue trimming the remaining non-fatal SBCL style/redefinition noise now that the major load-order and bogus type warnings are gone.
4. Decide whether the `reset-domain` / `defstep` files (`driving`, `scheduling`, parts of `newd`) should become a separate restoration track, since the wider operator-domain sweep now looks healthy.

Within the current `hanoi-4` priority, the immediate sub-questions are now:

1. can the improved `ismb` plus MP path be pushed from clean `200000`-expansion termination to a full solve?
2. are the best `hanoi-4` frontier nodes being ranked too highly even though they still carry many unsatisfied necessary preconditions?
3. should `critical-list-2` now be treated mainly as a comparison hierarchy while `ismb` becomes the primary `hanoi-4` restoration target?

The new trace tooling in [analysis/hanoi4-traces/README.md](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md#L1) should be part of that investigation whenever a run terminates without a solution.

The recommended order remains:

1. `#14`
2. `#11`
3. `#12`
4. `#13`

The rationale and alternatives are recorded in [docs/refreshed-plan.md](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md#L1).

## Suggested GitHub Issues

The issue tracker should stay focused on a few parallel tracks:

1. Benchmark validation
   Create or maintain issues for larger Hanoi cases, Nilsson blocks, robot comparisons, and monotonic-property checks.
2. Runtime compatibility cleanup
   Track remaining implicit-special cleanup, DFS/control-strategy behavior, and any SBCL-specific semantic mismatches separately from benchmark work.
3. Historical comparison
   Track claim-by-claim comparison between the source-backed validation matrix and current SBCL results.
4. Reproducibility
   Track smoke-runner improvements, status updates, and any command-line automation needed to keep regressions easy to rerun.

## Suggested Order

1. Push `hanoi-4` further with the now-better-understood `ismb` and `critical-list-2` settings.
2. Mark each benchmark row in the validation matrix as matched, partially matched, or still open.
3. Trim the remaining SBCL style/redefinition noise in the working tree.
4. Widen the smoke suite into more 1993 shipped sample domains.

## Exit Criteria For The Next Milestone

The next milestone should be considered complete when:

- the robot left-wedge comparison is scripted and documented
- `hanoi-4` has either a successful run or a hierarchy-by-hierarchy explanation that is grounded in the historical abstractions and published hierarchy discussion
- planner-level termination checks for open, generate, and DFS failure modes remain reproducible via the smoke runner
- the issue tracker reflects the major technical and validation workstreams
- the status document can be updated from smoke-test output without rediscovering prior context
