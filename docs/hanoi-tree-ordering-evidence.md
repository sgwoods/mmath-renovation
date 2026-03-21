# Hanoi Tree-Ordering Evidence

This note records the current evidence for how important tree goal ordering
actually was in the historical Hanoi experiment line.

It complements:

- [Hanoi-3 1991 compatibility layer](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Hanoi-4 successful combination hypothesis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-successful-combination-hypothesis.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)

## Main Finding

Tree goal ordering is clearly part of the historical control surface, but the
best local evidence we currently have suggests it was not the default or
dominant setting in the preserved Hanoi experiment batches.

That does not prove tree was unimportant. It does mean we should treat it as a
secondary historical comparison surface until stronger publication-side or
batch-side evidence says otherwise.

## What The Historical Code Shows

### 1. Tree ordering was explicitly implemented

The early control path clearly supports three goal-selection modes:

- `stack`
- `tree`
- `random`

The 1990 users manual says:

- stack, tree, and random are all available
- stack is the default

See
[historical/Abtweak/Abtweak-1990-12/users-manual.tex](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1990-12/users-manual.tex#L220).

The early AbTweak successor code also defines tree mode directly as preorder
traversal over the plan operator tree:

- [historical/Abtweak/Abtweak-1991-08/AbTweak2/ab-succ.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/AbTweak2/ab-succ.lsp#L108)

So tree ordering is absolutely real historical behavior, not a modern guess.

### 2. The preserved planner defaults still point to stack

The 1991 code line keeps `subgoal-determine-mode` / `determine-mode` as a live
control, but the planner defaults remain stack-oriented:

- [historical/Abtweak/Abtweak-1991-05/plan.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-05/plan.lsp#L12)
- [historical/Abtweak/Abtweak-1991-05/Tw-routines/successors.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-05/Tw-routines/successors.lsp#L99)

That matches the earlier users manual.

## What The Preserved Hanoi Experiment Drivers Show

### 1. The archived batcher trees are rich for Hanoi-2 and Hanoi-3, not Hanoi-4

The recovered 1991-08 batcher tree has substantial preserved experiment
material for:

- `hanoi2`
- `hanoi3`

but no corresponding `hanoi4` batcher directory.

See:

- [historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi2](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi2)
- [historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3)

So for four-disk tree ordering, we do not currently have the same kind of
archived batch-level confirmation that we do for the lower Hanoi families.

### 2. The preserved Hanoi batch scripts do not currently show explicit tree selection

The batcher scripts we inspected vary:

- hierarchy
- `msp-mode`
- `msp-weak-mode`
- `crit-depth-mode`
- Left-Wedge-related figure groupings

but the preserved Hanoi drivers we checked do not explicitly set
`:determine-mode 'tree`.

Representative examples:

- [historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/isbmK.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/isbmK.lsp#L1)
- [historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/fig7e-imsb-LW.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/fig7e-imsb-LW.lsp#L1)

That means the preserved batch corpus appears to inherit the default determine
mode rather than override it.

### 3. The preserved result logs we inspected explicitly show `FIRST`

Representative archived Hanoi result logs show:

- `determine mode  : FIRST`

For example:

- [historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results/isbm-ab-WN.1126](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results/isbm-ab-WN.1126#L20)

That is exactly what we would expect if the batch scripts are using the
default stack-first goal determination rather than tree ordering.

## What This Means For The Current Hanoi-4 Investigation

The current restored tree experiments are still valuable:

- they are historically defensible
- tree mode definitely existed
- they help test whether the missing four-disk behavior could depend on
  goal-ordering

But the weight of the preserved local evidence now suggests:

1. stack ordering should still be treated as the default historical Hanoi path
2. tree ordering should be treated as a recovered comparison surface, not the
   leading explanation for the missing `hanoi-4` success
3. the strongest current tree-related signal is narrow:
   `critical-list-2` plus weak-`POS`
4. the strongest current overall four-disk runtime path is still stack-based:
   `isbm + weak-POS + Left-Wedge`

So the most historically grounded next question is no longer:

- "maybe tree mode is the missing ingredient"

It is:

- "is there stronger publication-side evidence that tree ordering was central
  to the successful four-disk story, or does the preserved local experiment
  corpus instead point us back to stack-based hierarchy/control combinations?"
