# Hanoi-4 Traces

This directory holds timestamped diagnostic traces for larger `hanoi-4` runs.

The main runner is:

- [scripts/trace-hanoi4-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/trace-hanoi4-sbcl.sh)

Each trace directory contains:

- `planner-output.txt`: the planner's normal historical text output
- `summary.txt`: a compact machine-readable run summary
- `open-frontier.txt`: a snapshot of the top remaining open states after termination
- `frontier-quality.txt`: frontier summaries ranked by search priority and by unsatisfied-precondition count
- `insertion-score-trace.txt`: inserted-node score summaries ranked by actual, no-left-wedge, and unsat-aware score
- `insertion-score-report.md`: short insertion-time interpretation report for the same run
- `solution.txt`: the final `*solution*` value, with plan details if it is a real plan
- `drp-stack.txt`: a snapshot of the DRP stack at termination
- `trace-run.lisp`: the exact SBCL script used to produce the trace

Suggested first use:

```sh
PLANNER_MODE=abtweak \
HIERARCHY=ismb \
EXPAND_BOUND=50000 \
GENERATE_BOUND=200000 \
OPEN_BOUND=200000 \
/Users/stevenwoods/mmath-renovation/scripts/trace-hanoi4-sbcl.sh
```

This tracing workflow is intended to help answer whether the planner is making obviously bad search decisions, getting stuck in a suspicious abstraction/refinement pattern, or simply exhausting a large but reasonable search frontier.

Useful variants:

```sh
PLANNER_MODE=tweak \
HIERARCHY=ismb \
EXPAND_BOUND=20000 \
GENERATE_BOUND=80000 \
OPEN_BOUND=80000 \
/Users/stevenwoods/mmath-renovation/scripts/trace-hanoi4-sbcl.sh
```

Historical-control comparison example:

```sh
HISTORICAL_MODE=t \
HIERARCHY=isbm \
MSP_MODE=weak \
MP_WEAK_MODE=pos \
LEFT_WEDGE_MODE=nil \
EXPAND_BOUND=20000 \
GENERATE_BOUND=80000 \
OPEN_BOUND=80000 \
/Users/stevenwoods/mmath-renovation/scripts/trace-hanoi4-sbcl.sh
```
