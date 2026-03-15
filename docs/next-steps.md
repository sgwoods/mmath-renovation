# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)

## Current Priorities

1. Investigate the `hanoi-4` monotonic-property / ordering blow-up under SBCL, now that higher-bound `abtweak` runs point at that path instead of just hitting the old exploratory bound.
2. Use the source-backed validation matrix to label the current benchmark set as matching, partially matching, or still untested against the historical claims.
3. Continue trimming the remaining non-fatal SBCL style/redefinition noise now that the major load-order and bogus type warnings are gone.
4. Deepen the robot comparison story by using both `simple-robot-1` and `simple-robot-2` as left-wedge and heuristic validation cases.

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

1. Isolate the `hanoi-4` MP-memory blow-up before widening further into larger abstraction cases.
2. Mark each benchmark row in the validation matrix as matched, partially matched, or still open.
3. Trim the remaining SBCL style/redefinition noise in the working tree.
4. Only then widen into more 1993 domains or larger robot/Hanoi variants.

## Exit Criteria For The Next Milestone

The next milestone should be considered complete when:

- the robot left-wedge comparison is scripted and documented
- one larger abstraction benchmark runs successfully or fails in a well-understood way, including the MP path if that is the blocker
- planner-level termination checks for open, generate, and DFS failure modes remain reproducible via the smoke runner
- the issue tracker reflects the major technical and validation workstreams
- the status document can be updated from smoke-test output without rediscovering prior context
