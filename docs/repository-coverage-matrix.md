# Repository Coverage Matrix

This note is the maintained first-class coverage view for the repository as a
whole.

It is intended to answer, in one place:

1. what code and data families are present
2. which of them are integrated into the main restored environment
3. which are actually tested
4. which are validated against publications, manuals, or archived outputs
5. which remain cataloged but separate

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Project goal and roadmap](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [Publication domain crosswalk](/Users/stevenwoods/mmath-renovation/docs/publication-domain-crosswalk.md)
- [Domain inventory](/Users/stevenwoods/mmath-renovation/docs/domain-inventory.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Historical adjacent systems](/Users/stevenwoods/mmath-renovation/docs/historical-adjacent-systems.md)
- [Reset-domain assessment](/Users/stevenwoods/mmath-renovation/docs/reset-domain-assessment.md)

## Labels

- `Integrated`: part of the main runnable restored environment
- `Tested`: exercised through scripts, the harness, or checked-in probes
- `Publication-validated`: compared against papers, thesis, manual, or
  archived outputs
- `State`:
  - `Primary`: part of the main restored baseline
  - `Reference`: checked-in source basis or provenance material
  - `Separate`: cataloged but not part of the main restored execution path
  - `Open`: integrated enough to study, but not yet fully resolved

## Coverage Table

| Code or data family | Main locations | Integrated | Tested | Publication-validated | State | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Main operator-style planner baseline | [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993) | Yes | Yes | Yes, strong overall | `Primary` | Main restored SBCL execution base for `tweak` and `abtweak`. |
| Hanoi historical compatibility surface | [working/abtweak-1993/historical-hanoi-compat.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/historical-hanoi-compat.lisp#L1) | Yes | Yes | Yes, strong for Hanoi | `Primary` | Restored 1991-style controls, including weak/strong MSP and tree ordering. |
| Experiment harness | [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh#L1) | Yes | Yes | N/A | `Primary` | Standard front door for runs, reports, status, and traces. |
| Core operator-style domains | [working/abtweak-1993/Domains](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains) | Yes | Yes | Yes, broad but uneven | `Primary` | Includes blocks, Nilsson blocks, Hanoi, robot, registers, and 1993 manual domains. |
| `hanoi-2` family | [working/abtweak-1993/Domains/hanoi-2.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-2.lisp#L1) | Yes | Yes | Yes, exact | `Primary` | Exact archived-family rerun. |
| `hanoi-3` family | [working/abtweak-1993/Domains/hanoi-3.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L1) | Yes | Yes | Yes, exact/near-exact | `Primary` | Publication-aligned figure reproduction. |
| `hanoi-4` family | [working/abtweak-1993/Domains/hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1) | Yes | Yes | Partial | `Open` | Best-diagnosed remaining benchmark gap. |
| Baseline side experiments for explicit state-space Hanoi | [experiments/hanoi-baselines](/Users/stevenwoods/mmath-renovation/experiments/hanoi-baselines) | Yes | Yes | N/A | `Primary` | Sanity baseline, not part of historical AbTweak behavior. |
| Generated analysis outputs and raw trace/replay artifacts | [analysis](/Users/stevenwoods/mmath-renovation/analysis) | Yes | Yes | Supports validation | `Primary` | Holds generated reports, trace directories, replay logs, and numeric datasets. |
| Publications corpus | [publications](/Users/stevenwoods/mmath-renovation/publications/README.md) | N/A | N/A | Source basis | `Reference` | Checked-in papers, reports, and archival package references. |
| Release snapshots and changelog | [releases](/Users/stevenwoods/mmath-renovation/releases/README.md), [CHANGELOG.md](/Users/stevenwoods/mmath-renovation/CHANGELOG.md#L1) | Yes | Yes | N/A | `Primary` | Numbered restoration checkpoints. |
| Public-facing site sources | [site](/Users/stevenwoods/mmath-renovation/site) | Yes | Yes | N/A | `Primary` | Project page and release dashboard sources. |
| Historical AbTweak snapshots | [historical/Abtweak](/Users/stevenwoods/mmath-renovation/historical/Abtweak) | No | Partially mined | Yes, as provenance/comparison | `Reference` | Frozen source basis for lineage and comparison, not integrated as parallel runnable trees. |
| Alternate `reset-domain` / `defstep` framework | [working/abtweak-1993/Domains/driving.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/driving.lisp#L1), [working/abtweak-1993/Domains/newd.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/newd.lisp#L1), [working/abtweak-1993/Domains/scheduling.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/scheduling.lisp#L1) | No | Limited | No | `Separate` | Deliberately outside the main operator-style restoration path. |
| Adjacent historical systems | [historical/Mini-Tweak](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak), [historical/PlanMerge](/Users/stevenwoods/mmath-renovation/historical/PlanMerge), [historical/A-star](/Users/stevenwoods/mmath-renovation/historical/A-star), [historical/KautzPR](/Users/stevenwoods/mmath-renovation/historical/KautzPR), [historical/Mvl](/Users/stevenwoods/mmath-renovation/historical/Mvl) | No | Minimal/probe only | No | `Separate` | Cataloged context, not integrated into the main restored system. |
| Historical import noise / duplicate archival material | [historical/__MACOSX](/Users/stevenwoods/mmath-renovation/historical/__MACOSX), [historical/PlanMerge2](/Users/stevenwoods/mmath-renovation/historical/PlanMerge2) | No | No | No | `Reference` | Preserved for provenance; not part of the active restoration story. |

## Current Read

The repo is in a good state for the primary restoration goal:

- the main operator-style AbTweak/Tweak line is integrated, tested, and
  substantially validated
- the lower Hanoi families are the strongest exact publication-aligned slice
- the main remaining open primary-system gap is `hanoi-4`

The repo is not yet complete in the broader historical sense:

- the alternate framework is still separate
- adjacent systems are cataloged rather than integrated
- some archival imports are preserved as provenance rather than active assets

## Update Rule

Update this note when any of the following changes:

1. a separate family becomes integrated into the main runnable environment
2. a currently untested family gains a repeatable runner or probe
3. a validation label materially changes
4. a historical reference area moves from “cataloged only” to an active
   restoration track
