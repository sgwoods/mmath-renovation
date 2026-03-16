# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 control comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md)
- [Hanoi-4b candidate hierarchies](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-candidate-hierarchies.md)
- [Hanoi-4b frontier comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-frontier-comparison.md)
- [Hanoi-3 versus Hanoi-4](/Users/stevenwoods/mmath-renovation/docs/hanoi3-vs-hanoi4.md)
- [Hanoi-3 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi3-hierarchy-comparison.md)
- [Hanoi-3 MSP correspondence](/Users/stevenwoods/mmath-renovation/docs/hanoi3-msp-correspondence.md)
- [Wide domain sweep](/Users/stevenwoods/mmath-renovation/docs/wide-domain-sweep.md)
- [Reset-domain assessment](/Users/stevenwoods/mmath-renovation/docs/reset-domain-assessment.md)

## Current Priorities

1. Push the promising `hanoi-4` `ismb` path further, but keep the focus on search quality rather than broad parameter churn:
   compare the current `hanoi-4` hierarchy/control pairings with the thesis's historically good and bad Hanoi hierarchy families, now that the raw Left-Wedge refinement bias appears to be intended. The new permutation follow-up suggests `isbm` is the best alternate "Hanoi-4b" comparison case for ranking quality, while `ismb` remains the main target for raw bounded performance.
   The new `hanoi-3` correspondence note narrows that control question: several hierarchy families already line up with archived runs once the right 1991 control family is chosen, so the remaining validation target is whether we want to re-expose weak-`NEC`, weak-`POS`, and critical-depth behavior explicitly on top of the 1993 baseline.
2. Expand historically grounded sample coverage from the direct operator-style domains now that the validation matrix is labeled and the wider sweep looks healthy.
3. Treat the `reset-domain` / `defstep` material as a separate phase-2 track unless we decide to deliberately switch effort away from the core AbTweak/Tweak restoration.
4. Continue trimming the remaining non-fatal SBCL style/redefinition noise now that the major load-order and bogus type warnings are gone.

Within the current `hanoi-4` priority, the immediate sub-questions are now:

1. which current `hanoi-4` hierarchy/control combinations best match the historically good-versus-bad Hanoi hierarchy story in the thesis?
2. can the improved `ismb` plus MP path be pushed from clean `200000`-expansion termination to a full solve?
3. should `isbm` now replace `critical-list-2` as the main alternate `hanoi-4b` comparison hierarchy?
4. why does `ismb` prune much more aggressively than `isbm` even though `isbm` appears to rank frontier quality better?
5. can we combine what now looks like the two winning properties:
   `ismb`-style pruning and `isbm`-style frontier ranking?
6. how much of the remaining `hanoi-3` mismatch is a real planner issue versus the fact that `Abtweak-1993` no longer exposes the full 1991 MSP control surface?
7. should we add a compatibility layer for weak-`NEC`, weak-`POS`, and critical-depth mode so the paper-era Hanoi matrix can be reproduced more directly?

The new trace tooling in [analysis/hanoi4-traces/README.md](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md#L1) should be part of that investigation whenever a run terminates without a solution.

The recommended order now is:

1. `#14`
2. `#13`
3. `#16`
4. `#12`

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

1. Push `hanoi-4` further with the now-better-understood `ismb` settings.
2. Widen the smoke suite into more 1993 shipped operator-style sample domains.
3. Decide whether to open a separate phase-2 restoration track for the `reset-domain` framework.
4. Trim the remaining SBCL style/redefinition noise in the working tree.

## Exit Criteria For The Next Milestone

The next milestone should be considered complete when:

- the robot left-wedge comparison is scripted and documented
- `hanoi-4` has either a successful run or a hierarchy-by-hierarchy explanation that is grounded in the historical abstractions, published hierarchy discussion, and current frontier-quality evidence
- planner-level termination checks for open, generate, and DFS failure modes remain reproducible via the smoke runner
- the issue tracker reflects the major technical and validation workstreams
- the status document can be updated from smoke-test output without rediscovering prior context
