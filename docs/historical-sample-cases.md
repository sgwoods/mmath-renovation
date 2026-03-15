# Historical Sample Cases

This note tracks historically shipped AbTweak example domains that now have
repeatable SBCL smoke coverage in the working `Abtweak-1993` port.

The main source basis is the 1993 users manual, which explicitly lists these
sample domains as part of the distribution:

- simple blocks world
- Nilsson blocks world
- Towers of Hanoi
- registers
- robot planning
- transportation
- computer hardware
- biology
- database query optimization
- natural language style generation

See [historical/Abtweak/Abtweak-1993/Doc/users-manual.tex](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Doc/users-manual.tex#L448).

## Verified Historical Samples

| Case | Domain file | Planner mode | Outcome | Notes |
| --- | --- | --- | --- | --- |
| `blocks-sussman-tweak` | [working/abtweak-1993/Domains/blocks.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/blocks.lisp#L1) | `tweak` | Solves | Cost `3`, length `5`, `kval 0` |
| `blocks-sussman-abtweak` | [working/abtweak-1993/Domains/blocks.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/blocks.lisp#L1) | `abtweak` | Solves | Cost `3`, length `5`, `kval 0` |
| `nils-blocks-abtweak` | [working/abtweak-1993/Domains/nils-blocks.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/nils-blocks.lisp#L1) | `abtweak` | Solves | Cost `6`, length `8`, `kval 0` |
| `registers-tweak` | [working/abtweak-1993/Domains/registers.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/registers.lisp#L1) | `tweak` | Solves | Cost `3`, length `5`, `kval 0` |
| `hanoi3-abtweak` | [working/abtweak-1993/Domains/hanoi-3.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L1) | `abtweak` | Solves | Cost `7`, length `9`, `kval 0` |
| `macro-hanoi-abtweak` | [working/abtweak-1993/Domains/macro-hanoi.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/macro-hanoi.lisp#L1) | `abtweak` | Solves | Cost `1`, length `3`, `kval 0` |
| `robot1-abtweak` | [working/abtweak-1993/Domains/simple-robot-1.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/simple-robot-1.lisp#L1) | `abtweak` | Solves | Cost `16`, length `18`, `kval 0`, user heuristic plus primary effects |
| `robot2-abtweak` | [working/abtweak-1993/Domains/simple-robot-2.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/simple-robot-2.lisp#L1) | `abtweak` | Solves | Cost `12`, length `14`, `kval 0`, user heuristic plus primary effects |
| `computer-tweak` | [working/abtweak-1993/Domains/computer.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/computer.lisp#L1) | `tweak` | Solves | Cost `6`, length `8`, `kval 0`, with primary effects enabled |
| `computer-abtweak` | [working/abtweak-1993/Domains/computer.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/computer.lisp#L1) | `abtweak` | Solves | Cost `6`, length `8`, `kval 0`, with primary effects enabled |
| `biology-goal1-abtweak` | [working/abtweak-1993/Domains/biology.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/biology.lisp#L1) | `abtweak` | Solves | Cost `8`, length `10`, `kval 0` on the first shipped biology goal |
| `fly-dc-abtweak` | [working/abtweak-1993/Domains/fly.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/fly.lisp#L1) | `abtweak` | Solves | Cost `3`, length `5`, `kval 0`, with primary effects enabled |
| `database-goal0-tweak` | [working/abtweak-1993/Domains/database.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/database.lisp#L1) | `tweak` | Solves | Cost `2`, length `4`, `kval 0`; the domain file itself says to use `tweak`, not `abtweak` |

## Current Interpretation

These cases are good candidates for a historically grounded regression set
because they are not just modern inventions; they come from domains that the
1993 manual explicitly presented as part of the shipped example distribution.

The most useful near-term mix is:

1. small core baselines: `blocks`, `registers`, `hanoi-3`
2. abstraction and control comparisons: `Nilsson blocks`, `robot1`, `robot2`
3. broader shipped-domain coverage: `computer`, `biology`, `fly`, `database`

## Reproducible Commands

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh computer-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh computer-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh biology-goal1-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh fly-dc-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh database-goal0-tweak
```
