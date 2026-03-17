#!/usr/bin/env python3
"""Simple retained baseline search harness for the Tower of Hanoi.

This is intentionally small and self-contained. It gives us a classical
state-space comparison point outside the restored Lisp planners so we can ask:

- can plain BFS/DFS/A* solve the same 3-disk and 4-disk transfer problems?
- what do the frontier and expansion counts look like under ordinary graph
  search?

The goal is not to mimic AbTweak. The goal is to keep a reproducible sanity
baseline in the repo for later comparison work.
"""

from __future__ import annotations

import argparse
import heapq
import json
from collections import deque
from dataclasses import dataclass
from itertools import count
from typing import Iterable

State = tuple[int, ...]
Move = tuple[int, int, int]


@dataclass(frozen=True)
class SearchResult:
    case: str
    algorithm: str
    solved: bool
    solution_depth: int | None
    solution_cost: int | None
    expanded: int
    generated: int
    frontier_peak: int
    visited: int
    moves: tuple[Move, ...]


def standard_start(disks: int, peg: int = 0) -> State:
    return tuple(peg for _ in range(disks))


def standard_goal(disks: int, peg: int = 2) -> State:
    return tuple(peg for _ in range(disks))


def top_disks(state: State) -> list[int | None]:
    top: list[int | None] = [None, None, None]
    for disk, peg in enumerate(state):
        if top[peg] is None:
            top[peg] = disk
    return top


def successors(state: State) -> Iterable[tuple[Move, State]]:
    tops = top_disks(state)
    for src, disk in enumerate(tops):
        if disk is None:
            continue
        for dst in range(3):
            if src == dst:
                continue
            target_disk = tops[dst]
            if target_disk is None or disk < target_disk:
                nxt = list(state)
                nxt[disk] = dst
                yield (disk, src, dst), tuple(nxt)


def reconstruct_moves(parents: dict[State, tuple[State | None, Move | None]], goal: State) -> tuple[Move, ...]:
    path: list[Move] = []
    current = goal
    while True:
        parent, move = parents[current]
        if parent is None or move is None:
            break
        path.append(move)
        current = parent
    path.reverse()
    return tuple(path)


def heuristic_misplaced(state: State, goal_peg: int = 2) -> int:
    return sum(1 for peg in state if peg != goal_peg)


def bfs(start: State, goal: State, case: str) -> SearchResult:
    frontier = deque([start])
    parents = {start: (None, None)}
    expanded = 0
    generated = 0
    frontier_peak = 1

    while frontier:
        state = frontier.popleft()
        expanded += 1
        if state == goal:
            moves = reconstruct_moves(parents, goal)
            return SearchResult(case, "bfs", True, len(moves), len(moves), expanded, generated, frontier_peak, len(parents), moves)

        for move, nxt in successors(state):
            generated += 1
            if nxt in parents:
                continue
            parents[nxt] = (state, move)
            frontier.append(nxt)
        frontier_peak = max(frontier_peak, len(frontier))

    return SearchResult(case, "bfs", False, None, None, expanded, generated, frontier_peak, len(parents), ())


def dfs(start: State, goal: State, case: str) -> SearchResult:
    frontier: list[State] = [start]
    parents = {start: (None, None)}
    expanded = 0
    generated = 0
    frontier_peak = 1

    while frontier:
        state = frontier.pop()
        expanded += 1
        if state == goal:
            moves = reconstruct_moves(parents, goal)
            return SearchResult(case, "dfs", True, len(moves), len(moves), expanded, generated, frontier_peak, len(parents), moves)

        next_states: list[tuple[Move, State]] = list(successors(state))
        next_states.reverse()
        for move, nxt in next_states:
            generated += 1
            if nxt in parents:
                continue
            parents[nxt] = (state, move)
            frontier.append(nxt)
        frontier_peak = max(frontier_peak, len(frontier))

    return SearchResult(case, "dfs", False, None, None, expanded, generated, frontier_peak, len(parents), ())


def astar(start: State, goal: State, case: str) -> SearchResult:
    order = count()
    frontier: list[tuple[int, int, State]] = []
    heapq.heappush(frontier, (heuristic_misplaced(start), next(order), start))
    parents = {start: (None, None)}
    g_score = {start: 0}
    expanded = 0
    generated = 0
    frontier_peak = 1

    while frontier:
        _, _, state = heapq.heappop(frontier)
        expanded += 1
        if state == goal:
            moves = reconstruct_moves(parents, goal)
            return SearchResult(case, "astar", True, len(moves), len(moves), expanded, generated, frontier_peak, len(g_score), moves)

        base_cost = g_score[state]
        for move, nxt in successors(state):
            generated += 1
            tentative = base_cost + 1
            if nxt in g_score and tentative >= g_score[nxt]:
                continue
            g_score[nxt] = tentative
            parents[nxt] = (state, move)
            priority = tentative + heuristic_misplaced(nxt)
            heapq.heappush(frontier, (priority, next(order), nxt))
        frontier_peak = max(frontier_peak, len(frontier))

    return SearchResult(case, "astar", False, None, None, expanded, generated, frontier_peak, len(g_score), ())


def run_suite(disks: int) -> list[SearchResult]:
    case = f"hanoi-{disks}-standard-transfer"
    start = standard_start(disks)
    goal = standard_goal(disks)
    return [
        bfs(start, goal, case),
        dfs(start, goal, case),
        astar(start, goal, case),
    ]


def to_markdown(results: list[SearchResult]) -> str:
    lines = [
        "# Hanoi Search Baselines",
        "",
        "This report records simple retained classical-search baselines for the",
        "standard 3-peg Tower of Hanoi transfer problem.",
        "",
        "| Case | Algorithm | Solved | Depth | Expanded | Generated | Frontier peak | Visited |",
        "| --- | --- | --- | --- | --- | --- | --- | --- |",
    ]
    for result in results:
        lines.append(
            "| {case} | {algorithm} | {solved} | {depth} | {expanded} | {generated} | {frontier_peak} | {visited} |".format(
                case=result.case,
                algorithm=result.algorithm,
                solved="yes" if result.solved else "no",
                depth=result.solution_depth if result.solution_depth is not None else "-",
                expanded=result.expanded,
                generated=result.generated,
                frontier_peak=result.frontier_peak,
                visited=result.visited,
            )
        )

    for result in results:
        move_text = ", ".join(f"d{disk + 1}:{src + 1}->{dst + 1}" for disk, src, dst in result.moves)
        lines.extend(
            [
                "",
                f"## {result.case} / {result.algorithm}",
                "",
                f"- solved: {'yes' if result.solved else 'no'}",
                f"- depth: {result.solution_depth if result.solution_depth is not None else '-'}",
                f"- expanded: {result.expanded}",
                f"- generated: {result.generated}",
                f"- frontier peak: {result.frontier_peak}",
                f"- visited: {result.visited}",
                f"- moves: {move_text if move_text else '-'}",
            ]
        )

    return "\n".join(lines) + "\n"


def to_json(results: list[SearchResult]) -> str:
    payload = {
        "kind": "hanoi-search-baselines",
        "results": [
            {
                "case": result.case,
                "algorithm": result.algorithm,
                "solved": result.solved,
                "solution_depth": result.solution_depth,
                "solution_cost": result.solution_cost,
                "expanded": result.expanded,
                "generated": result.generated,
                "frontier_peak": result.frontier_peak,
                "visited": result.visited,
                "moves": list(result.moves),
            }
            for result in results
        ],
    }
    return json.dumps(payload, indent=2) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--disks", nargs="+", type=int, default=[3, 4], help="Disk counts to run.")
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    results: list[SearchResult] = []
    for disks in args.disks:
        results.extend(run_suite(disks))

    if args.format == "json":
        print(to_json(results), end="")
    else:
        print(to_markdown(results), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
