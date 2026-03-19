#!/usr/bin/env python3
"""Generate an abstraction-projection view of the optimal hanoi-4 baseline."""

from __future__ import annotations

import argparse
import importlib.util
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parent
BASELINE_PATH = ROOT / "hanoi_search_baselines.py"


def load_baseline_module():
    spec = importlib.util.spec_from_file_location("hanoi_search_baselines", BASELINE_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load baseline module from {BASELINE_PATH}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


baseline = load_baseline_module()

State = tuple[int, ...]
Move = tuple[int, int, int]

DISK_ORDER = ("S", "M", "B", "H")
PEG_NAMES = ("peg1", "peg2", "peg3")
PEG_SHORT = ("1", "2", "3")


@dataclass(frozen=True)
class Hierarchy:
    name: str
    levels: tuple[tuple[int, tuple[str, ...]], ...]

    def crit(self, disk: str) -> int:
        for kval, disks in self.levels:
            if disk in disks:
                return kval
        return 0

    def visible_disks(self, kval: int) -> tuple[str, ...]:
        return tuple(disk for disk in ("H", "B", "M", "S") if self.crit(disk) >= kval)


HIERARCHIES = (
    Hierarchy("critical-list-1", ((4, ()), (3, ("H",)), (2, ("B",)), (1, ("M",)), (0, ("S",)))),
    Hierarchy("ismb", ((3, ()), (2, ("S",)), (1, ("M",)), (0, ("B", "H")))),
    Hierarchy("isbm", ((3, ()), (2, ("S",)), (1, ("B",)), (0, ("M", "H")))),
)


def state_label(state: State) -> str:
    parts = []
    for disk, peg in zip(DISK_ORDER, state):
        parts.append(f"{disk}{PEG_SHORT[peg]}")
    return " ".join(parts)


def move_label(move: Move) -> str:
    disk, src, dst = move
    return f"{DISK_ORDER[disk]}:{src + 1}->{dst + 1}"


def apply_moves(start: State, moves: Iterable[Move]) -> list[State]:
    states = [start]
    current = start
    for disk, _, dst in moves:
        nxt = list(current)
        nxt[disk] = dst
        current = tuple(nxt)
        states.append(current)
    return states


def projected_signature(state: State, hierarchy: Hierarchy, kval: int) -> str:
    disks = hierarchy.visible_disks(kval)
    if not disks:
        return "-"
    parts = []
    for disk in disks:
        idx = DISK_ORDER.index(disk)
        parts.append(f"{disk}{PEG_SHORT[state[idx]]}")
    return " ".join(parts)


def projected_goal_signature(goal: State, hierarchy: Hierarchy, kval: int) -> str:
    return projected_signature(goal, hierarchy, kval)


def first_goal_steps(states: list[State], goal: State, hierarchy: Hierarchy) -> list[tuple[int, str, int | None]]:
    rows: list[tuple[int, str, int | None]] = []
    max_k = max(k for k, _ in hierarchy.levels)
    for kval in range(max_k, -1, -1):
        goal_sig = projected_goal_signature(goal, hierarchy, kval)
        if goal_sig == "-":
            rows.append((kval, goal_sig, 0))
            continue
        step = None
        for i, state in enumerate(states):
            if projected_signature(state, hierarchy, kval) == goal_sig:
                step = i
                break
        rows.append((kval, goal_sig, step))
    return rows


def distinct_projection_count(states: list[State], hierarchy: Hierarchy, kval: int) -> int:
    return len({projected_signature(state, hierarchy, kval) for state in states})


def render_markdown() -> str:
    result = baseline.astar(baseline.standard_start(4), baseline.standard_goal(4), "hanoi-4-standard-transfer")
    start = baseline.standard_start(4)
    goal = baseline.standard_goal(4)
    states = apply_moves(start, result.moves)

    lines = [
        "# Hanoi-4 Optimal Projection Report",
        "",
        "This report projects the retained optimal reference `hanoi-4` A* path",
        "through the active abstraction families used in the restored planner.",
        "",
        "It is meant as a comparison aid for the ongoing `hanoi-4` AbTweak",
        "investigation: what should a healthy branch look like when viewed",
        "through `critical-list-1`, `ismb`, and `isbm`?",
        "",
        f"- reference algorithm: `{result.algorithm}`",
        f"- solved: `{'yes' if result.solved else 'no'}`",
        f"- optimal depth: `{result.solution_depth}`",
        f"- expanded: `{result.expanded}`",
        f"- generated: `{result.generated}`",
        "",
        "## Optimal Move Sequence",
        "",
        "| Step | Move | Full state |",
        "| --- | --- | --- |",
    ]

    lines.append(f"| 0 | start | {state_label(states[0])} |")
    for step, (move, state) in enumerate(zip(result.moves, states[1:]), start=1):
        lines.append(f"| {step} | `{move_label(move)}` | `{state_label(state)}` |")

    for hierarchy in HIERARCHIES:
        max_k = max(k for k, _ in hierarchy.levels)
        lines.extend(
            [
                "",
                f"## {hierarchy.name}",
                "",
                "| Kval | Visible goal slice | First optimal-path step reaching that slice | Distinct projected states on optimal path |",
                "| --- | --- | --- | --- |",
            ]
        )
        for kval, goal_sig, step in first_goal_steps(states, goal, hierarchy):
            step_text = str(step) if step is not None else "never"
            lines.append(
                f"| {kval} | `{goal_sig}` | {step_text} | {distinct_projection_count(states, hierarchy, kval)} |"
            )

        lines.extend(
            [
                "",
                "| Step | Projection |",
                "| --- | --- |",
            ]
        )
        for step, state in enumerate(states):
            projections = []
            for kval in range(max_k, -1, -1):
                projections.append(f"k{kval}: {projected_signature(state, hierarchy, kval)}")
            lines.append(f"| {step} | `{' ; '.join(projections)}` |")

    lines.extend(
        [
            "",
            "## Notes",
            "",
            "- `critical-list-1` is a large-disk-first hierarchy: the optimal path",
            "  does not first satisfy the top visible goal slice until the `H` move",
            "  in the middle of the plan.",
            "- `ismb` and `isbm` delay `H` to the concrete layer, so their earlier",
            "  abstraction levels can match smaller-disk slices much sooner.",
            "- This report does not prove which hierarchy AbTweak should prefer,",
            "  but it gives a concrete standard-transfer sequence to compare against",
            "  the traced `hanoi-4` lineages in the planner.",
        ]
    )
    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", help="Write markdown to this path instead of stdout.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    text = render_markdown()
    if args.output:
        Path(args.output).write_text(text, encoding="utf-8")
    else:
        print(text, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
