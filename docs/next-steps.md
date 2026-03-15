# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)

## Current Priorities

1. Improve the newly restored DFS control-strategy path so it gives meaningful comparisons instead of mostly `solution-limit` or CPU-time termination.
2. Exercise Nilsson blocks and monotonic-property-related checks so the benchmark set reflects more of the historical claims.
3. Start mapping benchmark outcomes back to the thesis and technical reports rather than only checking whether cases run.
4. Reduce SBCL warning noise by declaring the main historical implicit-special globals explicitly.
5. Decide whether `simple-robot-1` adds useful coverage beyond `simple-robot-2`.

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

1. Investigate why DFS now runs with honest failure signaling but still tends to hit `CPU-TIME-LIMIT-EXCEEDED` before producing useful comparisons.
2. Exercise Nilsson blocks plus monotonic-property validation.
3. Extract historical-results expectations from the thesis and reports into the validation matrix.
4. Tackle global-special declarations and warning reduction.

## Exit Criteria For The Next Milestone

The next milestone should be considered complete when:

- the robot left-wedge comparison is scripted and documented
- one larger abstraction benchmark runs successfully or fails in a well-understood way
- planner-level termination checks for open, generate, and DFS failure modes remain reproducible via the smoke runner
- the issue tracker reflects the major technical and validation workstreams
- the status document can be updated from smoke-test output without rediscovering prior context
