# Hanoi-4b Candidate Hierarchies

This note records the first direct attempt to derive a better `hanoi-4`
alternate hierarchy from the historical experiment material rather than from
ad hoc tuning.

## Why Revisit The Hierarchy

The current restored `hanoi-4` story already shows that hierarchy choice matters:

- `*critical-list-1*` behaves like a poor hierarchy
- `*critical-list-2*` is better
- `*ismb*` is the best current four-disk setting

But the archival `hanoi3` experiment tree contains a much richer permutation
family than the active `hanoi-4` file exposes. That makes it reasonable to ask
whether the missing permutations point to a better four-disk "Hanoi-4b" style
hierarchy.

## Historical Evidence

The 1991-08 archival experiment tree includes 24 named `hanoi3` hierarchy
loaders in
[historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3),
including:

- `ibsm`
- `imbs`
- `isbm`
- `ismb`

Those are explicitly listed in
[load-tests.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3/load-tests.lsp#L1).

The historically checked-in `hanoi3` hierarchy files are:

- [imbs](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3/imbs)
- [ibsm](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3/ibsm)
- [isbm](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3/isbm)
- [ismb](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3/ismb)

The archived result files suggest that `imbs`, `isbm`, and `ibsm` were all
plausible experiment choices, not dead ends:

| Historical `hanoi3` file | Expanded | Generated | Depth | Notes |
| --- | --- | --- | --- | --- |
| `imbs2-raw.out` | `149` | `206` | `25` | very strong archived run |
| `imbs3-raw.out` | `166` | `233` | `25` | also strong |
| `ibsmK-raw.out` | `828` | `1471` | `26` | healthy archived run |
| `isbmK-raw.out` | `168` | `284` | `28` | very strong archived run |
| `ismbK-raw.out` | `963` | `1771` | `31` | healthy, but not clearly dominant |

These result files live in
[historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results).

## Four-Disk Reconstruction

The active four-disk domain originally exposed only:

- `*critical-list-1*`
- `*critical-list-2*`
- `*ismb*`

To test historically motivated alternatives, the working tree now also includes:

- `*imbs*`
- `*ibsm*`
- `*isbm*`

in [working/abtweak-1993/Domains/hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L100).

These are direct four-disk extensions of the archived `hanoi3` permutation
family, with omitted `onh` still falling to criticality `0` by the historical
`find-crit` behavior documented in
[docs/algorithm-correspondence.md](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md#L41).

## Current Four-Disk Results

All runs below use:

- planner mode `abtweak`
- `:mp-mode t`
- `:left-wedge-mode t`
- left-wedge list `(0 1 3 7)` for the permutation-style hierarchies

### Standard 20k Bound

| Hierarchy | Expanded | Generated | MP pruned | Outcome |
| --- | --- | --- | --- | --- |
| `ismb` | `20001` | `24228` | `22746` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm` | `20001` | `25235` | `18434` | `EXPAND-LIMIT-EXCEEDED` |
| `ibsm` | `20001` | `26172` | `16154` | `EXPAND-LIMIT-EXCEEDED` |
| `critical-list-2` | `20001` | `32461` | `8957` | `EXPAND-LIMIT-EXCEEDED` |
| `imbs` | `20001` | `34836` | `2909` | `EXPAND-LIMIT-EXCEEDED` |
| `critical-list-1` | `20001` | `35175` | `0` | `EXPAND-LIMIT-EXCEEDED` |

### Higher 100k Bound

| Hierarchy | Expanded | Generated | MP pruned | Outcome |
| --- | --- | --- | --- | --- |
| `ismb` | `100001` | `121238` | `119916` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm` | `100001` | `129865` | `95575` | `EXPAND-LIMIT-EXCEEDED` |
| `ibsm` | `100001` | `133751` | `82787` | `EXPAND-LIMIT-EXCEEDED` |
| `imbs` | `100001` | `178178` | `10340` | `EXPAND-LIMIT-EXCEEDED` |

## Interpretation

The historical archive does support trying additional four-disk permutation
hierarchies. That part is real.

But the current SBCL results say something subtler than "the missing historical
variant was obviously better":

1. `imbs` was strong in the archived `hanoi3` runs, but its direct four-disk
   extension is weak in the current `hanoi-4` benchmark.
2. `isbm` and `ibsm` are both credible alternatives. They are much closer to
   `ismb` than `imbs` is, at both 20k and 100k.
3. `ismb` still remains the best current four-disk hierarchy overall.

So if we want a distinct historically motivated "Hanoi-4b" candidate, the best
current choice is:

- `isbm` first
- `ibsm` second

If we want the single strongest current four-disk hierarchy, that remains:

- `ismb`

## Current Recommendation

Use the hierarchy family this way:

1. Keep `ismb` as the primary `hanoi-4` restoration target.
2. Treat `isbm` as the best alternate "Hanoi-4b" candidate for future
   comparison traces.
3. Keep `ibsm` as a secondary comparison hierarchy.
4. Do not prioritize `imbs` for `hanoi-4` follow-up work unless new historical
   evidence suggests the four-disk extension should include `onh` differently.

## Reproducibility

The hierarchy sweep is now scriptable via
[scripts/compare-hanoi4-hierarchies-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-hierarchies-sbcl.sh#L1).

Representative commands:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-hierarchies-sbcl.sh
HIERARCHIES="ismb isbm ibsm imbs" EXPAND_BOUND=100000 GENERATE_BOUND=400000 OPEN_BOUND=400000 CPU_SEC_LIMIT=60 \
  sh /Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-hierarchies-sbcl.sh
```
