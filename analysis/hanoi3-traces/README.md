# Hanoi-3 Traces

This directory holds timestamped diagnostic traces for `hanoi-3` runs.

The main runner is:

- [scripts/trace-hanoi3-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/trace-hanoi3-sbcl.sh)

The matching hierarchy comparison runner is:

- [scripts/compare-hanoi3-hierarchies-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi3-hierarchies-sbcl.sh)

Each trace directory contains:

- `planner-output.txt`: the planner's normal historical text output
- `summary.txt`: a compact machine-readable run summary
- `open-frontier.txt`: a snapshot of the top remaining open states after termination
- `frontier-quality.txt`: frontier summaries ranked by search priority and by unsatisfied-precondition count
- `solution.txt`: the final `*solution*` value, with plan details if it is a real plan
- `drp-stack.txt`: a snapshot of the DRP stack at termination
- `trace-run.lisp`: the exact SBCL script used to produce the trace

Suggested first use:

```sh
HIERARCHY=critical-list-1 \
EXPAND_BOUND=5000 \
GENERATE_BOUND=20000 \
OPEN_BOUND=20000 \
sh /Users/stevenwoods/mmath-renovation/scripts/trace-hanoi3-sbcl.sh
```

Useful comparison run:

```sh
HIERARCHY=ismb \
EXPAND_BOUND=20000 \
GENERATE_BOUND=80000 \
OPEN_BOUND=80000 \
sh /Users/stevenwoods/mmath-renovation/scripts/trace-hanoi3-sbcl.sh
```
