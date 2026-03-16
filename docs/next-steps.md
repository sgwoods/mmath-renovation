# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)
- [Unified restoration plan](/Users/stevenwoods/mmath-renovation/docs/unified-restoration-plan.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 control comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md)
- [Hanoi-4b candidate hierarchies](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-candidate-hierarchies.md)
- [Hanoi-4b frontier comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-frontier-comparison.md)
- [Hanoi-3 versus Hanoi-4](/Users/stevenwoods/mmath-renovation/docs/hanoi3-vs-hanoi4.md)
- [Hanoi-3 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi3-hierarchy-comparison.md)
- [Hanoi-3 MSP correspondence](/Users/stevenwoods/mmath-renovation/docs/hanoi3-msp-correspondence.md)
- [Hanoi-3 1991 compatibility layer](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Wide domain sweep](/Users/stevenwoods/mmath-renovation/docs/wide-domain-sweep.md)
- [Reset-domain assessment](/Users/stevenwoods/mmath-renovation/docs/reset-domain-assessment.md)

## Current Priorities

1. Unify the main experiment infrastructure around one restored working
   environment:
   standardize the current smoke, historical-control, comparison, and trace
   workflows so the repo behaves like one restored experimental system instead
   of a collection of separate probes.
2. Push the promising `hanoi-4` path further, but keep the focus on search quality rather than broad parameter churn:
   compare the current `hanoi-4` hierarchy/control pairings with the thesis's historically good and bad Hanoi hierarchy families, now that the raw Left-Wedge refinement bias appears to be intended. The new permutation follow-up suggests `isbm` is the best alternate "Hanoi-4b" comparison case for ranking quality, while `ismb` remains the main target for raw bounded performance.
   The `hanoi-3` compatibility layer now re-exposes a broader 1991 experiment slice, including multiple weak-`POS` hierarchies that match the archived runs exactly, and the first `hanoi-4` historical-control wrapper is now in place with the archived `legacy-1991-default` hierarchy.
3. Expand historically grounded sample coverage from the direct operator-style domains now that the validation matrix is labeled and the wider sweep looks healthy.
4. Treat the `reset-domain` / `defstep` material as a separate phase-2 track unless we decide to deliberately switch effort away from the core AbTweak/Tweak restoration.
5. Continue trimming the remaining non-fatal SBCL style/redefinition noise now that the major load-order and bogus type warnings are gone.

Within the current `hanoi-4` priority, the immediate sub-questions are now:

1. which current `hanoi-4` hierarchy/control combinations best match the historically good-versus-bad Hanoi hierarchy story in the thesis?
2. can the improved `ismb` plus MP path be pushed from clean `200000`-expansion termination to a full solve?
3. should `isbm` now replace `critical-list-2` as the main alternate `hanoi-4b` comparison hierarchy?
4. why does `ismb` prune much more aggressively than `isbm` even though `isbm` appears to rank frontier quality better?
5. can we combine what now looks like the two winning properties:
   `ismb`-style pruning and `isbm`-style frontier ranking?
6. how do the `legacy-1991-default` `hanoi-4` runs compare to the stronger later `ismb` and `isbm` families under the same historical-control vocabulary?
7. should the `hanoi-3` compatibility layer be widened again to include the remaining archived weak-`POS` and critical-depth families beyond the now-verified representative slice?

Right now, the first answer to question 6 is already leaning in one direction:
the archived 1991 four-disk default hierarchy is a useful baseline, but it is
not currently competitive with `ismb`. That makes the next `hanoi-4`
compatibility question more specific: whether the historical-control vocabulary
helps clarify the difference between `ismb` and `isbm`, not whether the older
default itself is the missing good hierarchy.

The latest comparison now gives a first answer to that too:

- `ismb` still wins on raw generated-node count under the historical controls
- weak-`POS` helps `isbm` substantially more than it helps `ismb`
- crit-depth remains a worse control choice for both

That suggests the next `hanoi-4` step should be to compare `ismb` and `isbm`
frontier quality again under weak-`POS`, not to keep investing effort in the
archived four-disk default.

That weak-`POS` frontier comparison is now done too:

- `ismb` keeps the slight edge on raw generated-node count
- `isbm` has the clearly cleaner top frontier

So the next recommended `hanoi-4` question is now narrower:
can we identify which part of the `isbm` weak-`POS` behavior is producing the
cleaner frontier, and whether that can be carried over without losing the
pruning strength that still makes `ismb` the best raw bounded path?

The latest answer is:

- the hierarchy itself is a big part of the cleaner `isbm` shape
- weak-`POS` is what materially cuts away many dirty concretized `isbm` states
- that improvement happens without changing the abstraction branching counts

So the next recommended `hanoi-4` step is no longer another broad comparison.
It is to inspect whether the current scorer can be nudged, instrumented, or
diagnosed in a way that borrows `isbm`'s cleaner weak-`POS` frontier behavior
without giving up the stronger overall pruning that still favors `ismb`.

The new trace tooling in [analysis/hanoi4-traces/README.md](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md#L1) should be part of that investigation whenever a run terminates without a solution.

The recommended order now is:

1. unify the experiment infrastructure
2. `#14`
3. `#13`
4. `#16`
5. `#12`

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

1. Unify the current runners and historical-control surfaces into one restored
   experiment environment.
2. Push `hanoi-4` further with the now-better-understood `ismb` settings.
3. Widen the smoke suite into more 1993 shipped operator-style sample domains.
4. Decide whether to open a separate phase-2 restoration track for the `reset-domain` framework.
5. Trim the remaining SBCL style/redefinition noise in the working tree.

## Exit Criteria For The Next Milestone

The next milestone should be considered complete when:

- the robot left-wedge comparison is scripted and documented
- `hanoi-4` has either a successful run or a hierarchy-by-hierarchy explanation that is grounded in the historical abstractions, published hierarchy discussion, and current frontier-quality evidence
- planner-level termination checks for open, generate, and DFS failure modes remain reproducible via the smoke runner
- the issue tracker reflects the major technical and validation workstreams
- the status document can be updated from smoke-test output without rediscovering prior context
