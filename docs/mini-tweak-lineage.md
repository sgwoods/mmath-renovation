# Mini-Tweak Lineage Note

This note records what the newly imported
[historical/Mini-Tweak](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak)
workspace contributes to the broader AbTweak restoration story.

`Mini-Tweak` is not part of the AbTweak code line, but it is the closest newly
recovered adjacent planner artifact because it is explicitly a simplified
implementation of TWEAK.

## What Survives

The main preserved files are:

- [historical/Mini-Tweak/Original/minitweak.lsp](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/Original/minitweak.lsp#L1)
- [historical/Mini-Tweak/Original/author.note](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/Original/author.note#L1)
- [historical/Mini-Tweak/Original/example.prob](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/Original/example.prob#L1)
- [historical/Mini-Tweak/m-tweak.l](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/m-tweak.l#L1)
- [historical/Mini-Tweak/lens-domain.l](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/lens-domain.l#L1)
- [historical/Mini-Tweak/modify.lsp](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/modify.lsp#L1)

The provenance is unusually clear:

- the preserved mail headers identify the original code as Jude Shavlik's
  `MINI-TWEAK.LSP`
- the local copies under `historical/Mini-Tweak/` point at Steve Woods'
  own file paths such as `/u/sgwoods/Plan/Mini-Tweak/example`
- the preserved domain/example material includes a lens-maker task

## Main Planner Characteristics

From the source itself, `Mini-Tweak` makes several explicit simplifying
assumptions:

- propositional rules only
- no variables
- no separation machinery
- no full backtracking
- repeated randomized retries when stuck

The planner still preserves a recognizably TWEAK-like partial-order structure:

- states are the temporal points around steps
- ordering constraints include `BEFORE`, `AFTER`, `CONTIGUOUS`,
  `INITIAL-STATE`, and `FINAL-STATE`
- goals are active obligations attached to states
- clobber handling is explicit

So this is not a toy state-space planner. It is a compact, educational, or
assignment-oriented nonlinear planner with a deliberately reduced control
surface.

## Relationship To Restored AbTweak

Compared with the active restored baseline in
[working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993),
`Mini-Tweak` differs in several important ways:

| Aspect | `Mini-Tweak` | Restored `Abtweak-1993` |
| --- | --- | --- |
| Variables | none | full variable-based operator/planning machinery |
| Abstraction | none | explicit abstraction via criticality levels and `kval` |
| Backtracking | no full backtracking; retries when stuck | full search over partial plans |
| Heuristics | lightweight/randomized choice | historical Tweak/AbTweak heuristic and Left-Wedge machinery |
| Goal structure | active goals on states | open preconditions and plan-level search states |
| Intended use | simplified TWEAK teaching/research artifact | research planner baseline tied to thesis and reports |

This means `Mini-Tweak` should not be treated as a direct precursor version of
the code we are restoring. But it is historically relevant in two ways:

1. it shows a nearby explicit TWEAK implementation surface from early 1990
2. it gives us a compact control planner that could be useful later for
   conceptual comparison when explaining what AbTweak adds beyond basic
   nonlinear planning

## Preserved Sample Domain

The lens-maker domain survives twice:

- in the original mailed [example.prob](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/Original/example.prob#L1)
- in the local working copy [lens-domain.l](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/lens-domain.l#L1)

That is useful because it gives us a concrete, small domain for future
comparison if we decide to run or port `Mini-Tweak`.

## Recommended Role In This Repo

For now, `Mini-Tweak` should be treated as:

- preserved historical context
- the closest adjacent TWEAK-lineage comparison system
- a possible future side experiment if we want a compact nonlinear-planner
  baseline outside AbTweak

It should not be folded into the main AbTweak restoration milestone unless we
explicitly open a separate comparison track.
