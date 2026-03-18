# Domain Inventory

This note inventories the planning domains visible across the recovered
AbTweak snapshots and the current `working/abtweak-1993` restoration tree.

Its goals are:

1. show what domain definitions we actually have
2. distinguish operator-style AbTweak domains from the alternate
   `reset-domain` / `defstep` framework
3. record what abstraction data and sample goals are present
4. note which examples correspond to the manual, papers, thesis, or archived
   batch outputs
5. call out cases where test data appears to be missing, incomplete, or only
   recoverable indirectly

This complements:

- [Historical sample cases](./historical-sample-cases.md)
- [Historical validation matrix](./historical-validation-matrix.md)
- [Reset-domain assessment](./reset-domain-assessment.md)
- [Hanoi-4 formal state](./hanoi4-formal-state.md)

## Snapshot Legend

- `1990-12`: `historical/Abtweak/Abtweak-1990-12`
- `1990-12b`: `historical/Abtweak/Abtweak-1990-12b`
- `1991-05`: `historical/Abtweak/Abtweak-1991-05`
- `1991-08`: `historical/Abtweak/Abtweak-1991-08`
- `1992`: `historical/Abtweak/Abtweak-1992`
- `1993`: `historical/Abtweak/Abtweak-1993`

## Operator-Style Domains

These are the domains that fit the main `plan` / `tweak` / `abtweak` path.

| Domain or family | Snapshots | Domain definitions present | Abstraction definitions | Known test data we have | Publication or manual linkage | Missing or inferred missing |
| --- | --- | --- | --- | --- | --- | --- |
| `blocks` | `1990-12`, `1990-12b`, `1991-05`, `1991-08`, `1992`, `1993` | Main blocks world domain in every line; later files include extra goal helpers like `sussman`, `interchange`, and `flatten`. | Explicit `*critical-list*` and `*left-wedge-list*` in the main file. | Concrete `initial` and `goal` pairs in the file; current smoke coverage includes `blocks-sussman` in both `tweak` and `abtweak`. | Explicitly listed in the 1993 users manual as a shipped sample domain. | No major missing test data evident; more archived batch outputs would still be useful if found. |
| `nils-blocks` | `1990-12`, `1990-12b`, `1991-05`, `1991-08`, `1992`, `1993` | Nilsson-style blocks world persists across all lines. | Explicit criticality lists in the domain file; early trees also include `nils/crit1` through `crit6` and matching `*-out` artifacts. | File-level `initial` and `goal`; current SBCL smoke coverage solves the standard case; early `nils/crit*` files preserve alternate abstraction data and some outputs. | Explicitly listed in the 1993 users manual; useful for published MP comparisons. | We have several criticality variants, but not a fully labeled mapping from every `crit*` file to a published table row yet. |
| `hanoi-2` and `hanoi-2a` | `1990-12`, `1990-12b`, `1991-08` | Early-only two-disk Hanoi domains plus alternate saved variants like `hanoi-2a.lsp` and `hanoi-2-old.lsp`. | Main file has `*critical-list*`; early `hanoi2/` directories contain many named hierarchy files plus `load-tests.lsp`. | Concrete `initial` and `goal` in the main file; archived `hanoi2/` directories contain hierarchy permutations and test loaders; `Save/anomaly-hanoi2` is also preserved. | Not a headline manual domain in 1993, but clearly part of the earlier experimental Hanoi infrastructure. | No active working-tree restoration path yet; some saved outputs are unlabeled enough that exact experiment provenance is unclear. |
| `hanoi-3` family | `1990-12`, `1990-12b`, `1991-05`, `1991-08`, `1992`, `1993` | Core three-disk Hanoi domain in all lines; early trees also contain `hanoi-3a`, `jens-hanoi`, and many hierarchy files under `hanoi3/`. | Main files expose default critical lists and left-wedge lists; early `hanoi3/` directories preserve many named hierarchy permutations and test loaders. | Concrete `initial`, `goal`, `goals`, `goalm`, `goalb` in the main file; archived `hanoi3/` directories and `Save/*runs` data preserve historical control sweeps; current working tree reproduces a large part of the 1991 hierarchy/control family. | Strong publication linkage in the thesis and TR-91-65; one of the clearest historically validated benchmark families. | We still do not have every archived hierarchy/output pair mapped back to exact paper nomenclature, but the important published variation family is now largely represented. |
| `hanoi-4` family | `1990-12`, `1990-12b`, `1991-05`, `1991-08`, `1992`, `1993` | Four-disk Hanoi domain present from the earliest trees onward; archived `Save/hanoi-4-old.lsp` variants also survive. | Main files expose `*critical-list-1*`, `*critical-list-2*`, left-wedge lists, and later compatibility wrappers; current working tree now also carries historically motivated permutation variants. | Concrete `initial`, `goal`, `goals`, `goalm`, `goalb`; current harness includes deep historical-control reports, traces, and replay/score diagnostics. | Publication linkage is strong in the abstract-planning papers and thesis, but direct four-disk success replication remains open. | This is still the main open benchmark; we have rich diagnostics, but not yet a full restored solve. |
| `macro-hanoi` | `1991-05`, `1992`, `1993` | Later compact macro-style Hanoi variant. | No explicit abstraction lists in the file; acts more like a compact domain variant than a hierarchy testbed. | `initial`, `goal`, `initial-4`, and `goal-4` are all present; both small and larger macro cases are now scripted and passing under SBCL. | Shipped with the later domain sets and useful as a compact regression case. | No obvious missing sample data. |
| `loop` | `1991-05`, `1992`, `1993` | Tiny regression-style domain. | No abstraction structures in the file. | Simple `initial` and `goal` are present; current smoke coverage uses it as a bounded-search sanity case. | Mentioned as part of the sample distribution rather than a published flagship benchmark. | No obvious missing data; this is mainly a regression domain. |
| `registers` | `1991-05`, `1992`, `1993` | Register exchange domain added in the cleaner later line. | Contains a `*critical-list*`; no left-wedge list needed. | Concrete `initial` and `goal` are present; current smoke coverage solves it in both planning modes. | Explicitly listed in the 1993 users manual and mentioned in the thesis-era sample set. | No obvious missing data. |
| `robot` / `simple-robot` / `simple-robot-1` / `simple-robot-2` | Early `robot`: `1990-12`, `1990-12b`, `1991-08`; later `simple-robot`: `1991-05`, `1992`, `1993`; split variants `1993` | Early trees carry one large `robot.lsp`; later trees refactor into `simple-robot.lisp` and then `simple-robot-1.lisp` and `simple-robot-2.lisp`. | Explicit `*critical-list*` and `*left-wedge-list*`; `robot-heuristic.lisp` and `check-primary-effects.lisp` support the historically important heuristic path. | Main files define multiple initial states (`initial-fixed`, `initial5`, `initial6`, etc.) plus goal; early `1991-08` tree also preserves `robot.example`, `robot.example2`, `robot.output`, `robot.plans`, and `robot.work`; current SBCL smoke coverage solves both `simple-robot-1` and `simple-robot-2` in AbTweak with user heuristic and primary effects. | Strong linkage to TR-91-65 and the 1993 users manual; one of the clearest published “AbTweak helps” application domains. | We do not yet have a one-to-one mapping from every early robot artifact to the later split domains; some early examples may deserve a dedicated compatibility note. |
| `fly` / transportation | `1993` | Simple transportation domain in the final line. | Explicit `*critical-list*` and `*left-wedge-list*`. | Concrete `initial`, `goal-sf`, and `goal-dc` are present; current SBCL smoke coverage solves the shipped Washington DC goal and can also run the San Francisco variant. | Explicitly listed in the 1993 users manual as the transportation sample domain. | No obvious missing data. |
| `computer` | `1993` | Simple computer hardware domain in the final line. | Explicit `*critical-list*` and `*left-wedge-list*`. | `goal` is present in the file and current smoke coverage solves it in both `tweak` and `abtweak`; primary effects are relevant. | Explicitly listed in the 1993 users manual. | The file exposes the goal clearly, but does not present a large menu of named alternative tasks; more historical output files would be useful if they exist elsewhere. |
| `biology` | `1993` | Simple biology domain in the final line. | Explicit `*critical-list*` and `*left-wedge-list*`. | Concrete `initial`, `goal1`, `goal2`, `goal3`, and default `goal` are present; several shipped goals now solve under SBCL. | Explicitly listed in the 1993 users manual. | No obvious missing data beyond more archived output tables. |
| `database` | `1993` | SQL-world query optimization domain in the final line. | No AbTweak abstraction lists in the file; header explicitly says to use `tweak`, not `abtweak`. | The file contains `goal0` through `goal5`; current working tree can run several of them in `tweak`, and some also happen to work in `abtweak` despite the warning. | Explicitly listed in the 1993 users manual. | The historically intended mode is `tweak`, so missing abstraction data appears intentional rather than accidental. |
| `stylistics` | `1993` | Natural-language style generation domain in the final line. | Explicit `*critical-list*` and `*left-wedge-list*`. | The domain operators and abstraction data are present, but the obvious sample `initial` and `goal` forms are commented out rather than live definitions. | Explicitly listed in the 1993 users manual as a shipped sample domain. | This is the strongest current “inferred missing test data” case in the main operator-style line: the domain exists, but the runnable sample state/goal pair appears to be absent or only preserved in commented form. |

## Alternate Framework and Mixed Cases

These files are in the recovered repositories, but they do not fit the main
operator-style `plan` path cleanly.

| Domain or family | Snapshots | Domain definitions present | Abstraction definitions | Known test data we have | Publication or manual linkage | Missing or inferred missing |
| --- | --- | --- | --- | --- | --- | --- |
| `driving` | `1993` | Domain is defined through `(reset-domain)` and `find-path` style machinery, not plain operator lists for the current AbTweak smoke path. | Not expressed as the usual `*critical-list*` / `*left-wedge-list*` pair in the active file. | The file itself is present, but no direct current `plan`-style smoke case is wired. | Not one of the core manual sample domains listed in the 1993 overview paragraph. | The missing piece is framework support, not just one sample state; this belongs to the separate restoration track. |
| `scheduling` | `1993` | Calls `scheduling-world-domain`, so it depends on definitions outside the file itself. | Not exposed as the main operator-style abstraction interface. | The file is present, but the current runnable path depends on alternate support in `newd.lisp`. | Not part of the core operator-style manual list; mixed later experiment/workspace material. | Missing direct standalone harness support; likely needs the alternate framework restored. |
| `newd` / `scheduling-world-domain` | `1993` | Large mixed workspace with repeated `(reset-domain)` blocks and the definition of `scheduling-world-domain`. | Uses the alternate framework rather than the standard AbTweak domain interface. | The file preserves many world/domain fragments but not a clean single benchmark surface. | More of an experimental workspace than a clean shipped benchmark domain. | Needs a deliberate phase-2 restoration if we want its experiment infrastructure back in runnable form. |

## Support and Experiment Artifacts

These files are not primary domains, but they matter for reconstructing the
historical experiment surface.

| Artifact family | Snapshots | What it preserves | Why it matters |
| --- | --- | --- | --- |
| `robot-heuristic.lisp`, `check-primary-effects.lisp` | `1993` | User heuristic and primary-effects logic for the robot path. | Required for the historically important robot experiments. |
| `hanoi2/load-tests.lsp`, `hanoi3/load-tests.lsp`, named hierarchy files | `1990-12`, `1990-12b`, `1991-08` | Large hierarchy/control experiment surface for early Hanoi studies. | Basis for the restored 1991 Hanoi compatibility layer. |
| `nils/crit*` and `crit*-out` | `1990-12`, `1990-12b`, `1991-08` | Alternate Nilsson criticality definitions and some recorded outputs. | Useful for future MP and hierarchy-comparison restoration. |
| `Save/AbTweak-results.runs`, `Save/Tweak-results.runs`, `robot.output`, `robot.plans`, `robot.work` | early trees | Saved experiment outputs and workspace artifacts. | Important provenance for matching historical runs, even when the exact input script is not obvious. |
| `jens-hanoi.lsp`, `jens-ab-succ.lsp`, `hanoi-3a.lsp`, `hanoi-2a.lsp` | early trees | Variant successor logic or alternate Hanoi formulations. | Potentially valuable if the main restored line still misses some historically reported behavior. |

## Current Inventory Interpretation

The inventory currently suggests four practical conclusions:

1. The operator-style AbTweak line is broad and mostly well preserved.
   The main manual domains are all present in the recovered `1993` tree.
2. The strongest missing runnable sample in that main line is
   `stylistics`, where the abstraction data survives but the visible sample
   `initial` / `goal` pair does not.
3. The richest historical variation surface is in the early Hanoi and robot
   material from `1990-12`, `1990-12b`, and `1991-08`.
4. `driving`, `scheduling`, and much of `newd` should still be treated as a
   separate framework-restoration track rather than as failures of the main
   AbTweak port.
