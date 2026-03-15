# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)

## Current Priorities

1. Extend the new [tweak-vs-abtweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md#L1) beyond the current `blocks`, `hanoi-3`, and `simple-robot-2` set.
2. Try one larger abstraction benchmark such as `hanoi-4` or `macro-hanoi`.
3. Reduce SBCL warning noise by declaring the main historical implicit-special globals explicitly.
4. Start mapping benchmark outcomes back to the thesis and technical reports rather than only checking whether cases run.
5. Decide whether `simple-robot-1` adds useful coverage beyond `simple-robot-2`.

## Suggested GitHub Issues

The issue tracker should stay focused on a few parallel tracks:

1. Benchmark validation
   Create or maintain issues for `hanoi-4`, `macro-hanoi`, Nilsson blocks, robot comparisons, and monotonic-property checks.
2. Runtime compatibility cleanup
   Track remaining implicit-special cleanup and any SBCL-specific semantic mismatches separately from benchmark work.
3. Historical comparison
   Track extraction of reported benchmark claims from the papers, thesis, and manual into the validation matrix.
4. Reproducibility
   Track smoke-runner improvements, status updates, and any command-line automation needed to keep regressions easy to rerun.

## Suggested Order

1. Add `hanoi-4` as the next benchmark target.
2. Use the comparison script to keep the `blocks`, `hanoi-3`, and `simple-robot-2` baselines stable.
3. Extract historical-results expectations from the thesis and reports into the validation matrix.
4. Tackle global-special declarations and warning reduction.

## Exit Criteria For The Next Milestone

The next milestone should be considered complete when:

- the robot left-wedge comparison is scripted and documented
- one larger abstraction benchmark runs successfully or fails in a well-understood way
- the issue tracker reflects the major technical and validation workstreams
- the status document can be updated from smoke-test output without rediscovering prior context
