# Historical Validation Matrix

This matrix maps the historically important AbTweak experiment themes onto the recovered `Abtweak-1993` working tree.

It is intended to answer two questions:

1. what should we run to claim the 1993 system is restored?
2. how do we compare our modern runs with the results described in the papers, thesis, and manual?

## Source Basis

The benchmark themes below are drawn from the four reference documents already collected in [`docs/references.md`](/Users/stevenwoods/mmath-renovation/docs/references.md#L1), especially the AAAI 1990 paper, the 1991 technical report on abstraction in nonlinear planning, the 1991 thesis, and the 1993 users manual shipped with the recovered code.

## Matrix

| Historical theme | Local domain or entry point | Planner mode to verify | Why it matters | Current status |
| --- | --- | --- | --- | --- |
| Plain nonlinear planning on canonical blocks problems | [`working/abtweak-1993/Domains/blocks.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/blocks.lisp#L1), `(sussman)` | `tweak` | Establishes that the recovered TWEAK-style planning core can still solve a classic least-commitment planning problem | `tweak` currently returns a concrete plan under SBCL with cost `3` and plan length `5` |
| Abstraction on the same blocks benchmark | [`working/abtweak-1993/Domains/blocks.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/blocks.lisp#L1), `(sussman)` | `abtweak` | This is the cleanest apples-to-apples comparison point for `tweak` versus `abtweak` | `abtweak` now returns a concrete plan under SBCL with cost `3`, `kval 0`, and plan length `5` |
| Tower of Hanoi with explicit abstraction hierarchy | [`working/abtweak-1993/Domains/hanoi-3.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L1), [`working/abtweak-1993/Domains/hanoi-4.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1) | `tweak`, `abtweak`, left-wedge on/off | Hanoi is a historically central abstraction domain and is explicitly discussed in the shipped manual | `hanoi-3` now returns a concrete plan under SBCL in both `tweak` and `abtweak`, with cost `7`, plan length `9`, and final `kval 0` when run with larger bounds |
| Nilsson-style blocks world | [`working/abtweak-1993/Domains/nils-blocks.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/nils-blocks.lisp#L1) | `tweak`, `abtweak` | Useful cross-check against a standard planning domain referenced in the manual | Not yet exercised in the SBCL port |
| Robot domain with user heuristic and primary effects | [`working/abtweak-1993/Domains/simple-robot-1.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/simple-robot-1.lisp#L1), [`working/abtweak-1993/Domains/simple-robot-2.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/simple-robot-2.lisp#L1), [`working/abtweak-1993/Domains/robot-heuristic.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/robot-heuristic.lisp#L1) | `tweak`, `abtweak`, `:heuristic-mode 'user-defined`, optional primary effects | The manual calls out these domains as examples for user heuristics and primary effects, so they are important for feature-complete restoration | `simple-robot-2` now solves in `abtweak` under SBCL with the manual-style settings (`user-defined` heuristic, primary effects), returning cost `12`, length `14`, `kval 0`; the same `tweak` configuration still hits `EXPAND-LIMIT-EXCEEDED` at current bounds, and the same `abtweak` run with `:left-wedge-mode nil` also hits `EXPAND-LIMIT-EXCEEDED` |
| Macro or learned Hanoi variant | [`working/abtweak-1993/Domains/macro-hanoi.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/macro-hanoi.lisp#L1) | `tweak`, `abtweak` | Useful later-stage check that nontrivial domain variants still work after the core port stabilizes | Not yet exercised |
| Left-wedge strategy | Domains with `*left-wedge-list*`, especially [`working/abtweak-1993/Domains/hanoi-3.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L101), [`working/abtweak-1993/Domains/blocks.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/blocks.lisp#L65), and robot domains | `abtweak` with `:left-wedge-mode t` and `nil` | The manual and later work treat left-wedge as a meaningful control strategy worth evaluating separately | On `blocks` / `sussman`, left-wedge on versus off currently yields the same cost-`3`, length-`5`, `kval 0` solution; on `simple-robot-2`, left-wedge enabled solves with cost `12`, length `14`, `kval 0`, while disabling left-wedge hits `EXPAND-LIMIT-EXCEEDED` at the same bounds |
| Monotonic property pruning | AbTweak domains with meaningful critical lists and [`working/abtweak-1993/Ab-routines/ab-mp-check.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-mp-check.lisp#L1) | `abtweak` with monotonic-property-related settings | The technical report and thesis emphasize the monotonic property as a key formal and experimental claim | Not yet validated in a successful `abtweak` run |
| Tiny sanity and regression cases | [`working/abtweak-1993/Domains/loop.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/loop.lisp#L1), [`working/abtweak-1993/Domains/registers.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/registers.lisp#L1) | `tweak` | These are useful as fast regression checks even if they were not the headline historical experiments | `loop` currently reaches bounded search termination under SBCL; `registers` now returns a concrete `tweak` plan with cost `3` and plan length `5` |

## Immediate Benchmark Priorities

The next most valuable checks are:

1. keep `blocks` / `sussman` as the first passing `tweak` regression
2. compare `hanoi-3` and `simple-robot-2` in `tweak` versus `abtweak` with a tighter record of search outcomes and bounds
3. try one larger abstraction benchmark such as `hanoi-4` or macro-Hanoi
4. decide whether `simple-robot-1` adds useful coverage beyond `simple-robot-2`
5. only then widen into additional 1993 domains such as biology, computer, and scheduling

## Comparison Rules

When comparing with the historical documents, prefer this order:

1. same domain and planner mode
2. same qualitative outcome, such as solved versus unsolved
3. same plan shape or plan-size scale
4. same search trend when toggling abstraction or left-wedge
5. same raw counts if the implementation and settings are close enough

If a modern run differs, document whether the most likely cause is:

- an incomplete SBCL port
- a change in search bounds or defaults
- a historically implementation-dependent Lisp behavior
- a real disagreement between the recovered code and the reported result
