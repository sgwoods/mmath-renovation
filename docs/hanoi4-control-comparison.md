# Hanoi-4 Control Comparison

This note records the current control-setting comparison for the restored
`hanoi-4` benchmark.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)

## What Was Compared

The comparison focused on the strongest current hierarchy families:

- `ismb`
- `critical-list-2`

For each one, the working SBCL port was compared under:

- the default `num-of-unsat-goals` heuristic versus a zero heuristic
- `:abstract-goal-mode t` versus `nil`
- `:existing-only nil` versus `t`

The same heuristic comparison was also repeated for plain `tweak`.

## Standard 20k-Bound Results

At the standard exploratory larger-Hanoi bounds:

| Case | Generated | MP pruned | Interpretation |
| --- | --- | --- | --- |
| `tweak`, default heuristic | `34234` | `0` | baseline |
| `tweak`, zero heuristic | `34169` | `0` | slightly better than default, but only marginally |
| `abtweak`, `ismb`, default heuristic | `24228` | `22746` | best current result |
| `abtweak`, `ismb`, zero heuristic | `25071` | `22570` | worse than the default heuristic |
| `abtweak`, `ismb`, no abstract goal | `30358` | `7882` | much worse, with far less MP pruning |
| `abtweak`, `ismb`, existing-only | `24228` | `22746` | identical to default at this bound |
| `abtweak`, `critical-list-2`, default heuristic | `32461` | `8957` | better than `tweak`, but weaker than `ismb` |
| `abtweak`, `critical-list-2`, zero heuristic | `33540` | `5047` | worse than the default heuristic |
| `abtweak`, `critical-list-2`, no abstract goal | `31463` | `7801` | a little better than default here, but still well behind `ismb` |
| `abtweak`, `critical-list-2`, existing-only | `32461` | `8957` | identical to default at this bound |

## Higher 100k-Bound Follow-Up

The higher-bound follow-up was limited to the most informative heuristic cases:

| Case | Generated | MP pruned | Interpretation |
| --- | --- | --- | --- |
| `tweak`, default heuristic | `175268` | `0` | baseline |
| `tweak`, zero heuristic | `174698` | `0` | still only a very small improvement |
| `abtweak`, `ismb`, default heuristic | `121238` | `119916` | strongest current high-bound configuration |
| `abtweak`, `ismb`, zero heuristic | `124236` | `118916` | worse than the default heuristic again |

## Main Findings

1. The default unsatisfied-goals heuristic is not the reason `hanoi-4` still
   fails on the best hierarchy.
   On `ismb`, it is consistently better than a zero heuristic at both 20k and
   100k.
2. Goal abstraction matters a lot on the strongest hierarchy.
   Turning off `:abstract-goal-mode` on `ismb` makes the run materially worse
   and sharply reduces MP pruning.
3. `existing-only` is not currently changing the search on the tested
   `hanoi-4` configurations.
4. The current best overall setting remains:
   `abtweak` + `ismb` + MP + left-wedge + `:abstract-goal-mode t` +
   `:heuristic-mode 'num-of-unsat-goals`.
5. `critical-list-2` is still a useful comparison hierarchy, but it is no
   longer the main restoration target for `hanoi-4`.

## Current Conclusion

The control comparison pushes the diagnosis one step further:

- the remaining `hanoi-4` gap is not explained by a simply bad default
  heuristic
- the restored system is already benefiting from the historically motivated
  abstraction controls on the strongest hierarchy
- the best remaining investigation target is now search quality among valid
  partial plans on `ismb`, not a broad parameter sweep across all controls

## Reproducible Command

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-controls-sbcl.sh
```
