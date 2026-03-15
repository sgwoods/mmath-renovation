# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)

## Current Priorities

1. Use the source-backed validation matrix to label the current benchmark set as matching, partially matching, or still untested against the historical claims.
2. Decide whether `simple-robot-1` adds useful coverage beyond `simple-robot-2`.
3. Continue reducing non-special SBCL warning noise, especially load-order style warnings and dubious type declarations.
4. Revisit `hanoi-4` with the better-understood DFS tuning and current Nilsson/MP baseline in hand.

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

1. Decide whether `simple-robot-1` adds useful extra historical coverage.
2. Tackle the remaining non-special SBCL warning reduction work.
3. Revisit `hanoi-4` after the current benchmark-comparison story is tighter.
4. Start marking each benchmark row in the validation matrix as matched, partially matched, or still open.

## Exit Criteria For The Next Milestone

The next milestone should be considered complete when:

- the robot left-wedge comparison is scripted and documented
- one larger abstraction benchmark runs successfully or fails in a well-understood way
- planner-level termination checks for open, generate, and DFS failure modes remain reproducible via the smoke runner
- the issue tracker reflects the major technical and validation workstreams
- the status document can be updated from smoke-test output without rediscovering prior context
