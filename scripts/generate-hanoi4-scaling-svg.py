#!/usr/bin/env python3
from __future__ import annotations

import csv
import math
import os
from pathlib import Path

os.environ.setdefault("MPLBACKEND", "Agg")

import matplotlib.pyplot as plt


REPO = Path(__file__).resolve().parent.parent
DATA = REPO / "analysis" / "hanoi4-strategy-performance.csv"
OUT = REPO / "analysis" / "hanoi4-scaling-strategies.svg"
PNG_OUT = REPO / "analysis" / "hanoi4-scaling-strategies.png"

STRATEGIES = [
    ("isbm-weak-pos-lw", "ISBM + weak-POS + LW", "#7dd3fc"),
    ("legacy1991-isbm-weak-pos-lw", "Legacy-1991 ISBM + weak-POS + LW", "#f59e0b"),
    ("isbm-weak-pos", "ISBM + weak-POS", "#34d399"),
    ("ismb-weak-pos", "ISMB + weak-POS", "#f472b6"),
]

BOUNDS = [20000, 50000, 100000, 200000]
WIDTH = 1180
HEIGHT = 760
LEFT = 120
RIGHT = 60
TOP = 80
BOTTOM = 150
PLOT_W = WIDTH - LEFT - RIGHT
PLOT_H = HEIGHT - TOP - BOTTOM


def load_rows() -> dict[tuple[str, int], int]:
    rows: dict[tuple[str, int], int] = {}
    with DATA.open(newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            key = row["strategy_key"]
            budget = int(row["budget_expanded"])
            value = int(row["value"])
            rows[(key.rsplit("-", 1)[0], budget)] = value
    return rows


def x_for(bound: int) -> float:
    idx = BOUNDS.index(bound)
    return LEFT + idx * (PLOT_W / (len(BOUNDS) - 1))


def y_for(value: int) -> float:
    min_v = 20000
    max_v = 300000
    log_min = math.log10(min_v)
    log_max = math.log10(max_v)
    ratio = (math.log10(value) - log_min) / (log_max - log_min)
    return TOP + PLOT_H - ratio * PLOT_H


def fmt(v: int) -> str:
    return f"{v:,}"


def build_svg(rows: dict[tuple[str, int], int]) -> str:
    bg = "#06121d"
    panel = "#0c2236"
    line = "#244761"
    text = "#eff7ff"
    muted = "#8fb3cc"
    grid = "#1b3950"

    parts: list[str] = []
    parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}">')
    parts.append(
        f'<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">'
        f'<stop offset="0%" stop-color="{bg}"/>'
        f'<stop offset="100%" stop-color="#14304a"/></linearGradient></defs>'
    )
    parts.append(f'<rect width="{WIDTH}" height="{HEIGHT}" fill="url(#bg)"/>')
    parts.append(f'<rect x="24" y="24" width="{WIDTH-48}" height="{HEIGHT-48}" rx="28" fill="{panel}" stroke="{line}" stroke-width="1.5" opacity="0.94"/>')
    parts.append(f'<text x="{LEFT}" y="62" fill="{text}" font-family="Avenir Next, Segoe UI, sans-serif" font-size="34" font-weight="700">Hanoi-4 strategy scaling</text>')
    parts.append(f'<text x="{LEFT}" y="92" fill="{muted}" font-family="Avenir Next, Segoe UI, sans-serif" font-size="16">Generated nodes vs expand bound, current strongest historical-control candidates (log scale). Lower is better, but all lines remain unsolved.</text>')

    y_ticks = [20000, 30000, 50000, 80000, 120000, 200000, 300000]
    for tick in y_ticks:
        y = y_for(tick)
        parts.append(f'<line x1="{LEFT}" y1="{y:.1f}" x2="{WIDTH-RIGHT}" y2="{y:.1f}" stroke="{grid}" stroke-width="1"/>')
        parts.append(f'<text x="{LEFT-14}" y="{y+5:.1f}" text-anchor="end" fill="{muted}" font-family="Avenir Next, Segoe UI, sans-serif" font-size="13">{fmt(tick)}</text>')

    for bound in BOUNDS:
        x = x_for(bound)
        parts.append(f'<line x1="{x:.1f}" y1="{TOP}" x2="{x:.1f}" y2="{TOP+PLOT_H}" stroke="{grid}" stroke-width="1"/>')
        label = f"{bound//1000}k"
        parts.append(f'<text x="{x:.1f}" y="{TOP+PLOT_H+28}" text-anchor="middle" fill="{muted}" font-family="Avenir Next, Segoe UI, sans-serif" font-size="14">{label}</text>')

    for key, label, color in STRATEGIES:
        points = []
        for bound in BOUNDS:
            value = rows.get((key, bound))
            if value is None:
                continue
            points.append((x_for(bound), y_for(value), value))

        if not points:
            continue

        path = " ".join(("M" if i == 0 else "L") + f" {x:.1f} {y:.1f}" for i, (x, y, _) in enumerate(points))
        parts.append(f'<path d="{path}" fill="none" stroke="{color}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>')

        for x, y, value in points:
            parts.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="5.5" fill="{color}" stroke="{panel}" stroke-width="2"/>')
            parts.append(f'<text x="{x:.1f}" y="{y-12:.1f}" text-anchor="middle" fill="{color}" font-family="Avenir Next, Segoe UI, sans-serif" font-size="12" font-weight="600">{value//1000}k</text>')

    legend_x = LEFT
    legend_y = HEIGHT - 96
    for i, (_, label, color) in enumerate(STRATEGIES):
        y = legend_y + i * 24
        parts.append(f'<line x1="{legend_x}" y1="{y}" x2="{legend_x+28}" y2="{y}" stroke="{color}" stroke-width="4" stroke-linecap="round"/>')
        parts.append(f'<circle cx="{legend_x+14}" cy="{y}" r="5" fill="{color}" stroke="{panel}" stroke-width="2"/>')
        parts.append(f'<text x="{legend_x+40}" y="{y+5}" fill="{text}" font-family="Avenir Next, Segoe UI, sans-serif" font-size="15">{label}</text>')

    note_x = 760
    note_y = HEIGHT - 116
    parts.append(f'<text x="{note_x}" y="{note_y}" fill="{muted}" font-family="Avenir Next, Segoe UI, sans-serif" font-size="14">Current read:</text>')
    notes = [
        "ISBM + weak-POS + Left-Wedge stays ahead at every measured bound.",
        "Legacy-1991 ISBM is the strongest grouped-top analogue, but still secondary.",
        "None of these lines solve classic 3-peg Hanoi-4 yet.",
    ]
    for i, note in enumerate(notes, start=1):
        parts.append(f'<text x="{note_x}" y="{note_y + i*22}" fill="{text}" font-family="Avenir Next, Segoe UI, sans-serif" font-size="14">{note}</text>')

    parts.append("</svg>")
    return "".join(parts)


def write_png(rows: dict[tuple[str, int], int]) -> None:
    fig, ax = plt.subplots(figsize=(11.8, 7.6), dpi=150)
    fig.patch.set_facecolor("#06121d")
    ax.set_facecolor("#0c2236")

    for key, label, color in STRATEGIES:
        xs = []
        ys = []
        for bound in BOUNDS:
            value = rows.get((key, bound))
            if value is None:
                continue
            xs.append(bound)
            ys.append(value)
        if not xs:
            continue
        ax.plot(xs, ys, marker="o", linewidth=2.8, markersize=6.5, color=color, label=label)
        for x, y in zip(xs, ys):
            ax.annotate(f"{y//1000}k", (x, y), textcoords="offset points", xytext=(0, -14), ha="center", color=color, fontsize=8, weight="bold")

    ax.set_xscale("linear")
    ax.set_yscale("log")
    ax.set_xticks(BOUNDS)
    ax.set_xticklabels(["20k", "50k", "100k", "200k"], color="#8fb3cc", fontsize=10)
    ax.tick_params(axis="y", colors="#8fb3cc", labelsize=9)
    ax.grid(True, which="major", color="#1b3950", linewidth=0.8)
    for spine in ax.spines.values():
        spine.set_color("#244761")
    ax.set_title("Hanoi-4 strategy scaling", loc="left", color="#eff7ff", fontsize=20, fontweight="bold", pad=18)
    ax.text(0.0, 1.02, "Generated nodes vs expand bound, strongest current historical-control candidates. Lower is better, but all lines remain unsolved.", transform=ax.transAxes, color="#8fb3cc", fontsize=10)
    ax.set_xlabel("Expand bound", color="#8fb3cc", fontsize=11)
    ax.set_ylabel("Generated nodes (log scale)", color="#8fb3cc", fontsize=11)
    leg = ax.legend(loc="lower right", facecolor="#0c2236", edgecolor="#244761", framealpha=1.0)
    for text in leg.get_texts():
        text.set_color("#eff7ff")
    fig.tight_layout()
    fig.savefig(PNG_OUT, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    rows = load_rows()
    svg = build_svg(rows)
    OUT.write_text(svg)
    write_png(rows)


if __name__ == "__main__":
    main()
