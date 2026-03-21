# Next Steps

This document is the living short-list of recommended next work for the AbTweak renovation.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)
- [Unified restoration plan](/Users/stevenwoods/mmath-renovation/docs/unified-restoration-plan.md)
- [Experiment harness](/Users/stevenwoods/mmath-renovation/docs/experiment-harness.md)
- [Hanoi search baselines](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/README.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 frontier replay](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-replay.md)
- [Hanoi-4 score sensitivity](/Users/stevenwoods/mmath-renovation/docs/hanoi4-score-sensitivity.md)
- [Hanoi-4 insertion score trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-insertion-score-trace.md)
- [Hanoi-4 lineage trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-trace.md)
- [Hanoi-4 lineage divergence](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-divergence.md)
- [Hanoi-4 control comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md)
- [Hanoi-4b candidate hierarchies](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-candidate-hierarchies.md)
- [Hanoi-4b frontier comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-frontier-comparison.md)
- [Hanoi-3 versus Hanoi-4](/Users/stevenwoods/mmath-renovation/docs/hanoi3-vs-hanoi4.md)
- [Hanoi-3 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi3-hierarchy-comparison.md)
- [Hanoi-3 MSP correspondence](/Users/stevenwoods/mmath-renovation/docs/hanoi3-msp-correspondence.md)
- [Hanoi-3 1991 compatibility layer](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Hanoi-4 successful combination hypothesis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-successful-combination-hypothesis.md)
- [Hanoi-4 hierarchy experiment plan](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-experiment-plan.md)
- [Wide domain sweep](/Users/stevenwoods/mmath-renovation/docs/wide-domain-sweep.md)
- [Reset-domain assessment](/Users/stevenwoods/mmath-renovation/docs/reset-domain-assessment.md)

## Current Priorities

1. Continue unifying the main experiment infrastructure around one restored
   working environment:
   the repo now has a common front door at
   [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh),
   and the next step is to keep moving the current smoke,
   historical-control, comparison, and trace workflows toward one shared
   harness vocabulary and result shape. The new benchmark-family `status`
   surface and the named weak-`POS` Hanoi trace presets are the latest step in
   that direction.
2. Push the promising `hanoi-4` path further, but keep the focus on search quality rather than broad parameter churn:
   compare the current `hanoi-4` hierarchy/control pairings with the thesis's historically good and bad Hanoi hierarchy families, now that the raw Left-Wedge refinement bias appears to be intended. The new permutation follow-up suggests `isbm` is the best alternate "Hanoi-4b" comparison case for ranking quality, while `ismb` remains the main target for raw bounded performance.
   The `hanoi-3` compatibility layer now re-exposes a broader 1991 experiment slice, including multiple weak-`POS` hierarchies that match the archived runs exactly, and the first `hanoi-4` historical-control wrapper is now in place with the archived `legacy-1991-default` hierarchy.
   The newest harness-native deeper weak-`POS` runs now sharpen that further:
   `isbm` is no longer just the cleaner-frontier comparison case; by `50000`
   and `100000` it is also slightly ahead of `ismb` on raw generated nodes,
   and re-enabling Left-Wedge improves that stronger `isbm` line again.
   The next disciplined sub-step is now a hierarchy-design pass with clear
   restoration boundaries, starting with historically grounded analogue
   variants before any named non-historical strategy work. The first probe,
   `isbm-h1`, is now implemented and runs cleanly, but it is weaker than the
   current `isbm` path at the standard 20k bound, so the next candidate should
   move to `isbm-hb`.
   The new external Hanoi BFS/DFS/A* baseline also now solves standard
   `hanoi-4` immediately, which makes the remaining restored-planner gap look
   more like a planner-specific search/control problem than a generic puzzle
   difficulty issue.
3. Expand historically grounded sample coverage from the direct operator-style domains now that the validation matrix is labeled and the wider sweep looks healthy.
4. Treat the `reset-domain` / `defstep` material as a separate phase-2 track unless we decide to deliberately switch effort away from the core AbTweak/Tweak restoration.
5. Continue trimming the remaining non-fatal SBCL style/redefinition noise now that the major load-order and bogus type warnings are gone.

Within the current `hanoi-4` priority, the immediate sub-questions are now:

1. which current `hanoi-4` hierarchy/control combinations best match the historically good-versus-bad Hanoi hierarchy story in the thesis?
2. can the improved `isbm` weak-`POS` plus Left-Wedge path be pushed past the current `200000`-expansion bounded failure into a full solve?
3. should `isbm` now replace `ismb` as the main historical-control `hanoi-4` target, not just the main alternate comparison hierarchy?
4. why does plain state-space BFS solve `hanoi-4` immediately while the restored planner still fails cleanly at much higher bounds?
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

- at the original `20000` bound, `ismb` still wins slightly on raw generated-node count under the historical controls
- weak-`POS` helps `isbm` substantially more than it helps `ismb`
- crit-depth remains a worse control choice for both

That led to the next `hanoi-4` step:
compare `ismb` and `isbm` frontier quality again under weak-`POS`, not keep
investing effort in the archived four-disk default.

That weak-`POS` frontier comparison is now done too:

- at `20000`, `ismb` keeps the slight edge on raw generated-node count
- `isbm` has the clearly cleaner top frontier

The deeper harness-native weak-`POS` runs now sharpen that further:

- by `50000`, `isbm` is slightly ahead on raw generated-node count
- at `100000`, `isbm` is still slightly ahead
- `isbm` keeps the cleaner frontier while doing so

So the next recommended `hanoi-4` question is now narrower:
can we identify which part of the `isbm` weak-`POS` behavior is producing the
cleaner frontier and better scaling, and whether that can be pushed into a
full solve or explained more exactly if it still fails?

The latest answer is:

- the hierarchy itself is a big part of the cleaner `isbm` shape
- weak-`POS` is what materially cuts away many dirty concretized `isbm` states
- that improvement happens without changing the abstraction branching counts

So the next recommended `hanoi-4` step is no longer another broad comparison.
It is to inspect whether the current scorer can be nudged, instrumented, or
diagnosed in a way that explains why `isbm` weak-`POS` is now scaling better
despite `ismb` still pruning more aggressively.

The new trace tooling in [analysis/hanoi4-traces/README.md](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md#L1) should be part of that investigation whenever a run terminates without a solution.

The new optimal-versus-lineage comparison narrows the immediate `hanoi-4`
question again:

- the hierarchy itself still looks sensible under the retained optimal
  four-disk reference projection
- the unhealthy behavior appears when the current best `isbm` AbTweak run is
  rewarded for dropping below the natural early-progress `k2` band too soon
- so the best next question is now to inspect the exact goal/obligation picture
  at those `add-a-level` reinsertion points, not to keep broadening the search
  settings first

That reinsertion inspection is now done for the current best `isbm` branch:

- the branch is clean at `k2`
- it is then reintroduced at `k1` with visible goal `(G (ONB PEG3))`
- it is reintroduced again at `k0` with concrete blocker `(NOT ONM PEG1)`
- across those steps, the no-left-wedge score stays fixed while the actual
  score improves through stronger Left-Wedge reward

So the next best `hanoi-4` question is now even narrower:
why does the current visible-goal accounting let those lower-level
reintroductions beat the remaining healthy `k2` alternatives?

The answer is now partly established:

- the base heuristic counts full unsatisfied `G` goals only
- it does not directly count non-goal open obligations
- level-correctness and subgoal choice do work on the current visible
  obligations
- so lower-level blockers can appear without worsening the base goal heuristic

That means the next best `hanoi-4` question is now:
is this exact score/accounting split historically faithful for the published
good-Hanoi experiments, or is there still a fidelity mismatch in how the
restored path combines goal accounting with Left-Wedge?

That historical-fidelity check is now mostly answered:

- the same split exists in the archived `1991-05` and `1993` code
- the shipped manual describes the same broad heuristic and Left-Wedge shape
- so this now looks more like inherited baseline behavior than a restoration
  regression

The next best `hanoi-4` question is therefore no longer "did the port invent
this?" It is:
which historically successful hierarchy/control combinations avoid or overcome
this concretization trap, and which historically meaningful controls are still
missing from the reconstructed four-disk surface?

The new successful-combination note narrows that list:

- publication-side good Hanoi families are centered on `ILMS` / `IMLS`
- bad families include `ISML` / `ISLM`
- P-WMP and especially Left-Wedge are the main reported successful controls
- the current compatibility layer still does not expose:
  - a clean publication-to-code mapping for the good four-disk hierarchy family
  - a clear publication-side explanation of where tree goal ordering was meant
    to help, now that the control itself is restored but not yet outperforming
    `stack` on representative recovered cases

The newer wider determine-mode sweep now sharpens that tree question:

- tree is not uniformly worse on `hanoi-4`
- under weak-`POS` plus Left-Wedge at the 20k bound, it helps
  `legacy-1991-default` and `critical-list-2`
- it hurts `critical-list-1`, `ismb`, `isbm`, `ibsm`, and `imbs`
- the deeper follow-up now shows this is not just a hierarchy effect:
  - `legacy-1991-default` flips against `tree` by 50k
  - `critical-list-2` is split by control: weak-`NEC` slightly favors
    `stack`, while weak-`POS` still slightly favors `tree`

So the immediate question is no longer just "does tree help?" It is:
which hierarchy-and-control family was tree goal ordering historically meant
to help?

The newest archive-side evidence now constrains that further:

- tree is definitely part of the historical control surface
- but the preserved Hanoi batch scripts and result logs we have inspected are
  mostly stack/`FIRST` by default
- and there is no comparable preserved `hanoi-4` batcher corpus yet

So tree should remain a live comparison mode, but not the main working
hypothesis for the missing four-disk success unless stronger publication-side
evidence turns up.

The new frozen-frontier replay experiment now sharpens the immediate
`hanoi-4` hypothesis further:

- under a neutral continuation policy, all sampled `tweak` frontier nodes stay
  search-live to the replay bound
- under the same continuation idea, most sampled `abtweak` frontier nodes die
  quickly
- the healthiest sampled `abtweak` node comes from the closure-oriented cohort
  rather than the top-ranked cohort
- the replay-dead `abtweak` states are typically heavily concretized
  `kval 0` move skeletons with high unsatisfied-pair counts, while the
  healthiest sampled `abtweak` replay is a cleaner `kval 2` state
- the score-sensitivity pass now shows that the clean closure-oriented node is
  actual rank `1149`, but becomes rank `1` as soon as left-wedge is removed
- the new insertion-time trace now shows that the bias is already present when
  nodes are created, but much less extremely:
  - the best closure-oriented inserted node is still actual rank `4`
  - the later frontier distortion is therefore likely compounding over
    repeated refinement and continued expansion, not appearing all at once
- the new lineage trace now makes that compounding pattern explicit:
  - dirty priority leaders descend through long low-`kval` ancestry chains
  - their unsatisfied counts worsen steadily as refinement continues
  - healthy closure leaders keep much shorter and cleaner abstract ancestry
- the new divergence note now shows the first local crossover:
  - an abstract `kval 2` branch and a concretized `kval 1` branch have almost
    the same closure quality
  - the concretized branch wins immediately because Left-Wedge gets stronger
    at the lower level
  - the same branch is then reintroduced again at `kval 0`, where closure gets
    worse but actual score improves further

So the next best `hanoi-4` work is no longer another broad settings sweep
first. It is:

1. tighten the publication-to-code mapping for the historically good four-disk
   hierarchy families
2. determine whether the publication-side tree-ordering discussion points to a
   specific `critical-list-2`-like weak-`POS` family strongly enough to
   outweigh the archive-side evidence that the preserved Hanoi runs were mostly
   stack-first
3. only then return to deeper `hanoi-4` runtime pushes inside that recovered
   control surface

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
2. Push `hanoi-4` further with the now-stronger `isbm` weak-`POS` path.
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
