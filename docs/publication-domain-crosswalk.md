# Publication Domain Crosswalk

This note is the maintained formal crosswalk between the published AbTweak
sources and the domain families recovered in this repository.

It is intended to answer four questions in one place:

1. which domains are actually tied to the papers, thesis, or 1993 manual
2. which local files implement them now
3. which harness commands rerun the current restored experiments
4. whether the rerun surface is exact, strong, partial, manual-only, or still
   missing

Rerun labels:

- `Exact`: we have enough archived domain/control/output data to reproduce the
  reported run family closely, and current results match at the reported level
- `Strong`: we have the domain, abstraction data, and sample tasks, and can
  rerun the historically intended benchmark family, but not every published
  row is matched exactly
- `Partial`: we have a meaningful rerun path, but a key part of the published
  story is still incomplete
- `Manual-only`: the domain is clearly shipped in the 1993 distribution, but
  is not yet tied to a precise published table or figure
- `Missing`: the domain exists, but the runnable sample or framework support
  needed for faithful reruns is still absent

| Domain or family | Publication linkage | Local files | Current harness or script entry point | Verified regenerated data | Can we rerun it as shown? |
| --- | --- | --- | --- | --- | --- |
| `blocks` | `TR-91-65`, thesis, 1993 manual | [working/abtweak-1993/Domains/blocks.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/blocks.lisp#L1) | `run blocks-sussman-tweak`, `run blocks-sussman-abtweak` via [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh#L1) | Regenerated and verified: `blocks-sussman-tweak` and `blocks-sussman-abtweak` both solve with cost `3`, plan length `5`, `kval 0`; DFS and search-bound variants are also scripted. | `Strong` |
| `nils-blocks` | AAAI 1990 MP theme, `TR-91-65`, thesis, 1993 manual | [working/abtweak-1993/Domains/nils-blocks.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/nils-blocks.lisp#L1) | `run nils-blocks-tweak`, `run nils-blocks-abtweak`; broader effect summarized in `report benchmark-status` | Regenerated and verified: both modes solve with cost `6`, length `8`; MP-on vs MP-off effect is documented and reproduced. | `Strong` |
| `hanoi-2` | early experiment lineage in archived trees, not a main 1993 manual benchmark | [working/abtweak-1993/Domains/hanoi-2.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-2.lisp#L1), compatibility support in [working/abtweak-1993/historical-hanoi-compat.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/historical-hanoi-compat.lisp#L1), archival sources under [historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi2](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi2) | `run hanoi2-tweak`, `run hanoi2-abtweak`, `report hanoi2-historical` | Regenerated and verified: the recovered six-hierarchy family now matches the archived 1990 batch outputs exactly at the expanded/generated level, and the default `tweak` and `abtweak` smoke cases both solve with cost `3`, plan length `5`, `kval 0`. | `Exact` |
| `hanoi-3` | AAAI 1990, `TR-91-65`, thesis, 1993 manual | [working/abtweak-1993/Domains/hanoi-3.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L1), compatibility support in [working/abtweak-1993/historical-hanoi-compat.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/historical-hanoi-compat.lisp#L1) | `run hanoi3-tweak`, `run hanoi3-abtweak`, `report hanoi3-historical`, `report hanoi3-hierarchies`, `trace hanoi3` | Regenerated and verified: standard `tweak` and `abtweak` solves; a broad 1991 compatibility family now matches archived expanded/generated counts exactly, including weak-`NEC`, weak-`POS`, and crit-depth rows. | `Exact` |
| `hanoi-4` | `TR-91-65`, thesis, 1993 manual | [working/abtweak-1993/Domains/hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1), compatibility support in [working/abtweak-1993/historical-hanoi-compat.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/historical-hanoi-compat.lisp#L1) | `run hanoi4-tweak`, `run hanoi4-abtweak`, `report hanoi4-historical`, `report hanoi4-hierarchies`, `report hanoi4-frontier-replay`, `report hanoi4-score-sensitivity`, `trace hanoi4-isbm-weak-pos-lw` | Regenerated and verified: baseline `tweak` and `abtweak` bounded failures, hierarchy/control sweeps, historical-control wrapper, frontier replay, and score-sensitivity diagnostics all rerun cleanly; full published-style success still not reached. | `Partial` |
| `macro-hanoi` | shipped later-domain variant, not a paper-table focus | [working/abtweak-1993/Domains/macro-hanoi.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/macro-hanoi.lisp#L1) | `run macro-hanoi-tweak`, `run macro-hanoi-abtweak`, `run macro-hanoi4-tweak`, `run macro-hanoi4-abtweak` | Regenerated and verified: both small and larger macro variants solve in both modes. | `Manual-only` |
| `registers` | sample family in `TR-91-65`, thesis, 1993 manual | [working/abtweak-1993/Domains/registers.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/registers.lisp#L1) | `run registers-tweak`, `run registers-abtweak` | Regenerated and verified: both modes solve with cost `3`, plan length `5`, `kval 0`. | `Strong` |
| `robot` / `simple-robot` | strongest application story in `TR-91-65`, thesis, 1993 manual | [working/abtweak-1993/Domains/simple-robot-1.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/simple-robot-1.lisp#L1), [working/abtweak-1993/Domains/simple-robot-2.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/simple-robot-2.lisp#L1), [working/abtweak-1993/Domains/robot-heuristic.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/robot-heuristic.lisp#L1) | `run robot1-abtweak`, `run robot1-abtweak-no-lw`, `run robot2-abtweak`, `run robot2-abtweak-no-lw` | Regenerated and verified: both robot domains solve in AbTweak with user-defined heuristic and primary effects; corresponding no-left-wedge and `tweak` comparisons still fail at current bounds, which matches the published qualitative story. | `Strong` |
| `fly` / transportation | 1993 manual only | [working/abtweak-1993/Domains/fly.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/fly.lisp#L1) | `run fly-dc-tweak`, `run fly-dc-abtweak` | Regenerated and verified: Washington DC goal solves in AbTweak; the domain is part of the maintained smoke surface. | `Manual-only` |
| `computer` | 1993 manual only | [working/abtweak-1993/Domains/computer.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/computer.lisp#L1) | `run computer-tweak`, `run computer-abtweak` | Regenerated and verified: both modes solve with cost `6`, length `8`, `kval 0`. | `Manual-only` |
| `biology` | 1993 manual only | [working/abtweak-1993/Domains/biology.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/biology.lisp#L1) | `run biology-goal1-abtweak`, `run biology-goal2-abtweak`, `run biology-goal3-abtweak` | Regenerated and verified: multiple shipped goals solve under AbTweak; this is now part of the formal smoke set. | `Manual-only` |
| `database` | 1993 manual only | [working/abtweak-1993/Domains/database.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/database.lisp#L1) | `run database-goal0-tweak`, `run database-goal2-tweak`, `run database-goal2-abtweak`, `run database-goal4-tweak`, `run database-goal4-abtweak` | Regenerated and verified: several shipped SQL goals solve; the file itself still notes that the intended historical mode is `tweak`. | `Manual-only` |
| `stylistics` | 1993 manual only | [working/abtweak-1993/Domains/stylistics.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/stylistics.lisp#L1) | `run stylistics-tweak`, `run stylistics-abtweak` | Regenerated and verified: the commented historical sample task now runs in both modes with cost `4`, length `6`, `kval 0`; the working copy also now strips the preserved mail header so SBCL can load the file. | `Manual-only` |
| `driving` | not tied to the main published AbTweak result set | [working/abtweak-1993/Domains/driving.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/driving.lisp#L1) | No current harness entry | Verified surviving data: alternate `reset-domain` style definitions only. | `Missing` |
| `scheduling` / `newd` | not tied to the main published AbTweak result set | [working/abtweak-1993/Domains/scheduling.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/scheduling.lisp#L1), [working/abtweak-1993/Domains/newd.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/newd.lisp#L1) | No current harness entry | Verified surviving data: mixed alternate-framework workspace, including `scheduling-world-domain`, but not a restored standalone rerun path. | `Missing` |

## Current Interpretation

The repo is strongest where the historical record is strongest:

1. `hanoi-2` and `hanoi-3` now form a clean exact Hanoi lineage in the repo:
   archived-family exact for `hanoi-2`, publication-aligned exact for `hanoi-3`.
2. `blocks`, `nils-blocks`, `registers`, and `robot` are strong historically
   grounded reruns, even when not every exact paper row is reconstructed.
3. `hanoi-4` is the main remaining published benchmark gap.
4. `fly`, `computer`, `biology`, and `database` are best treated as
   1993-manual validation domains rather than as paper-table replications.
5. `stylistics` has now moved into the rerunnable 1993-manual set, while the
   alternate-framework files remain the clearest missing domain surface.

## Update Rule

This note should be updated whenever one of the following changes:

1. a domain moves from `Partial` to `Strong` or `Exact`
2. a new harness entry point is added for a historically relevant domain
3. new archived output data is mapped back to a published run family
4. a currently missing sample task or framework path is restored
