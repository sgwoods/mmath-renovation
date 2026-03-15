# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)

## Current Priorities

1. Map the tested `hanoi-4` hierarchies to the hierarchy descriptions and permutations in the report and thesis, especially now that `critical-list-2` and `ismb` show the historically expected MP-sensitive improvement.
2. Push the promising `hanoi-4` hierarchy settings further, starting with `ismb` plus MP and `critical-list-2` plus MP, to see whether one can reach a full solution under higher or better-tuned bounds.
3. Use the source-backed validation matrix to label the current benchmark set as matching, partially matching, or still untested against the historical claims.
4. Continue trimming the remaining non-fatal SBCL style/redefinition noise now that the major load-order and bogus type warnings are gone.

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

1. Record which tested `hanoi-4` hierarchies look like the historically “good” and “bad” ones.
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
