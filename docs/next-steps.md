# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)

## Current Priorities

1. Start mapping benchmark outcomes back to the thesis and technical reports rather than only checking whether cases run.
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
   Track extraction of reported benchmark claims from the papers, thesis, and manual into the validation matrix.
4. Reproducibility
   Track smoke-runner improvements, status updates, and any command-line automation needed to keep regressions easy to rerun.

## Suggested Order

1. Extract historical-results expectations from the thesis and reports into the validation matrix.
2. Decide whether `simple-robot-1` adds useful extra historical coverage.
3. Tackle the remaining non-special SBCL warning reduction work.
4. Revisit `hanoi-4` after the current benchmark-comparison story is tighter.

## Exit Criteria For The Next Milestone

The next milestone should be considered complete when:

- the robot left-wedge comparison is scripted and documented
- one larger abstraction benchmark runs successfully or fails in a well-understood way
- planner-level termination checks for open, generate, and DFS failure modes remain reproducible via the smoke runner
- the issue tracker reflects the major technical and validation workstreams
- the status document can be updated from smoke-test output without rediscovering prior context
