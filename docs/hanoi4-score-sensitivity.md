# Hanoi-4 Score Sensitivity

This note records the next diagnostic step after the frozen-frontier replay
experiment: compare how the same `hanoi-4` frontier states rank under the
actual restored score and under a few simpler diagnostic alternatives.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 frontier replay](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-replay.md)
- [Experiment harness](/Users/stevenwoods/mmath-renovation/docs/experiment-harness.md)

## Question

The replay result suggested that many sampled `abtweak` frontier states are
locally brittle. The next question was:

- are those states still winning because the current score shape strongly
  favors refinement?
- or are they still best even under simpler alternative rankings?

## Probe Setup

The standardized entry point is:

- `sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi4-score-sensitivity`

The source run is the current best `hanoi-4` AbTweak path:

- `abtweak + isbm + weak-POS + left-wedge`
- source bound: `10000` expansions

The report compares the frontier under three rankings:

1. actual restored score
2. score without left-wedge
3. score with an added unsatisfied-pair term

Representative generated report:

- [score sensitivity report](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-score-sensitivity/hanoi4-score-sensitivity-20260318-103436/report.md)

## Main Result

The best closure-oriented node is being buried almost entirely by score shape.

For the top actual node:

- actual rank: `1`
- rank without left-wedge: `71`
- rank with unsat-aware score: `724`

For the best closure-oriented node:

- actual rank: `1149`
- rank without left-wedge: `1`
- rank with unsat-aware score: `1`

So the same frontier gives a very sharp answer:

- under the current restored score, the cleaner node is nowhere near the top
- as soon as left-wedge is removed, it becomes the best node in the frontier
- if unresolved obligations are charged explicitly, it also becomes the best
  node in the frontier

## Frontier Shape Shift

The top-20 frontier averages make the change even clearer.

Under the actual score, the top 20 nodes are:

- average `kval`: `0.00`
- average plan cost: `13.65`
- average plan length: `15.65`
- average unsatisfied pairs: `15.75`

Without left-wedge, the top 20 become:

- average `kval`: `1.05`
- average plan cost: `9.90`
- average plan length: `11.90`
- average unsatisfied pairs: `5.05`

With an unsat-aware score, the top 20 become:

- average `kval`: `1.05`
- average plan cost: `10.10`
- average plan length: `12.10`
- average unsatisfied pairs: `4.25`

And the overlap is extreme:

- actual vs no-left-wedge top-20 overlap: `0 / 20`
- actual vs unsat-aware top-20 overlap: `0 / 20`

That means this is not a tiny tie-breaking effect. The score shape is selecting
an almost completely different frontier.

## Current Conclusion

This is the strongest evidence so far about why the restored `abtweak`
`hanoi-4` behavior diverges so much.

The current score:

- strongly prefers very concrete `kval 0` plans
- rewards them heavily through left-wedge
- does not directly charge the large unresolved user/precondition burden they
  still carry

So the current best working diagnosis is:

- the main live problem is not just "Hanoi-4 is expensive"
- it is that the restored `abtweak` score is aggressively selecting dirty
  concrete move skeletons over cleaner higher-level states

That makes the next best work very specific: inspect whether the current
left-wedge application and goal-only heuristic match the intended historical
experiment setup for this four-disk case, or whether the restored path is now
over-applying refinement pressure relative to the original system.
