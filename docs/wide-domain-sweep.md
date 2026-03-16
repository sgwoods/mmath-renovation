# Wide Domain Sweep

This note records the first broader SBCL sweep across shipped
operator-representation domains beyond the original core smoke set.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical sample cases](/Users/stevenwoods/mmath-renovation/docs/historical-sample-cases.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)

## Summary

The wider sweep strengthens the restoration story considerably:

- additional `blocks` variants now solve in both `tweak` and `abtweak`
- `registers` solves in both modes
- the `fly` domain solves in both modes for both shipped goals tested
- `biology` goal 1 solves in both modes, and the full checked-in `biology`
  goal solves in `abtweak`
- `database` query 1 and query 3 solve in both modes after a small SBCL
  compatibility fix in `var-p`

The sweep also clarified the current project boundary:

- `driving.lisp`, `scheduling.lisp`, and parts of `newd.lisp` use a different
  `reset-domain` / `defstep` planner framework and should not yet be treated as
  direct AbTweak smoke cases
- `stylistics.lisp` does not currently ship an active benchmark pair to run
  directly

## Key Compatibility Finding

While widening the sweep, `database` exposed a real AbTweak-only SBCL bug:

- `tweak` query runs were fine
- `abtweak` crashed in abstraction handling on numeric constants such as
  `(NUM-EXPLICIT 2)`

The cause was [general.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/general.lisp#L115):

- `var-p` assumed every atom was a string designator
- numeric constants therefore crashed during `find-crit` / abstraction checks

The fix was to make `var-p` treat only symbols, strings, and characters as
candidate variable names. After that:

- `database-goal1-abtweak` solves with cost `2`, length `4`, `kval 0`
- `database-goal3-abtweak` solves with cost `2`, length `4`, `kval 0`

## Reproducible Sweep

Use:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/wide-domain-sweep-sbcl.sh
```

That script prints:

- a broader `tweak` / `abtweak` result table for compatible operator domains
- a short list of checked-in domain files that are currently out of scope for
  the restored AbTweak `plan` path
