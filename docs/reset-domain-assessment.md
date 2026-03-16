# Reset-Domain Assessment

This note records the current recommendation for the `reset-domain` /
`defstep` material found in the recovered `Abtweak-1993` tree.

It complements:

- [Wide domain sweep](/Users/stevenwoods/mmath-renovation/docs/wide-domain-sweep.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)

## What Was Checked

The current tree contains two distinct domain styles:

1. the direct AbTweak/Tweak operator style used by the main smoke suite
   (`make-operator`, `create-operator-instance`)
2. an alternate DSL built around `reset-domain` and `defstep`

The strongest examples of the second style are:

- [driving.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/driving.lisp#L1)
- [newd.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/newd.lisp#L1)

## Key Findings

1. `driving.lisp` is not a direct AbTweak smoke case.
   It defines domains through `reset-domain` and `defstep`, then calls `plan`
   in that alternate representation.
2. `newd.lisp` is even stronger evidence of a different planner track.
   It switches to `(in-package 'snlp)`, uses `reset-domain` / `defstep`
   repeatedly, and includes mail-header provenance and `system::gc` calls that
   look imported from a different code lineage.
3. No implementation of `reset-domain` or `defstep` currently exists in the
   active `working/abtweak-1993` port tree.
   That means these files are not just “unexercised domains”; they depend on
   missing framework support.
4. `scheduling.lisp` should not be grouped blindly with the direct operator
   domains.
   Although it uses `make-operator`, its checked-in entry point calls
   `scheduling-world-domain`, which is only defined in the alternate
   `defstep`-based material inside [newd.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/newd.lisp#L345).

## Recommendation

The project should treat this material as a separate phase-2 restoration track,
not as part of the core AbTweak/Tweak SBCL smoke suite.

That means:

- keep the main restoration target focused on the direct AbTweak/Tweak planner
  and its historically central sample domains
- preserve `driving.lisp` and `newd.lisp` as important historical artifacts
- do not count `reset-domain` / `defstep` examples as failures of the current
  core planner port
- only open a dedicated restoration effort for that framework after the main
  AbTweak validation story is stronger

## Practical Next Step

If and when this phase-2 track is taken on, the first job should be to recover
the missing `reset-domain` / `defstep` support layer and identify whether it
belongs to a local historical extension, an SNLP-derived codebase, or a mixed
experimental workspace.
