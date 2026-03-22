# Hanoi-4 Convergence Check

This note records the current solve-oriented convergence judgment for the
strongest live classic three-peg `hanoi-4` path:

- `abtweak`
- `isbm`
- weak-`POS`
- stack determine mode
- Left-Wedge enabled

It complements:

- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 solve candidate comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-solve-candidate-comparison.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)

## Question

Is the current strongest `isbm + weak-POS + stack + Left-Wedge` line actually
converging toward solution as the bound increases, or is it repeating the same
pathology at larger scale?

## Evidence Used

### 100k trace

Fresh trace directory:

- [analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260322-171206](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260322-171206)

Key summary:

- expanded: `100001`
- generated: `116646`
- MP pruned: `110674`
- open length: `16645`
- top priority bucket: `(8 6598)`

Top displayed frontier nodes at this point are still:

- `kval 0`
- cost `16`
- length `18`
- driven by partial support for `ONS PEG3` and `ONB PEG3`

The top displayed nodes do not yet show a broader closure pattern for the full
four-disk transfer.

### 200k trace

Current retained comparison trace:

- [analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260321-155348](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260321-155348)

Key summary:

- expanded: `200001`
- generated: `234872`
- MP pruned: `224678`
- open length: `34871`
- top priority bucket: `(9 20379)`

Top displayed frontier nodes at this point are still:

- `kval 0`
- cost `18`
- length `20`
- still dominated by partial support for `ONS PEG3` and `ONB PEG3`

The top frontier has become longer and more expensive, but it has not become
qualitatively cleaner.

## Current Judgment

The strongest current `hanoi-4` line is scaling, but it is not yet converging
in the benchmark sense.

What changes between `100000` and `200000`:

- the open list gets larger
- the top-priority plans get longer
- the top-priority plans get slightly more expensive

What does **not** change enough:

- the frontier is still led by dirty `kval 0` move skeletons
- the dominant visible progress is still the same `ONS PEG3` / `ONB PEG3`
  slice
- the strongest closure-oriented alternatives still exist, but they are not
  taking over the frontier

So the current best interpretation is:

- the restored planner is not simply "almost there"
- it is reproducing the same ranking pathology at a larger search scale
- the current live `isbm` line remains the best candidate, but the present
  evidence supports **explained bounded failure**, not clear convergence toward
  a solve

## Practical Meaning

For planning work, this means:

1. `isbm + weak-POS + stack + Left-Wedge` remains the right primary line.
2. `legacy-1991-isbm` remains the best grouped-top comparison line.
3. New work should now be judged by one of two standards:
   - actual solve progress
   - materially tighter explanation of why the frontier still does not close

Cheaper unsolved runs remain diagnostic only.
