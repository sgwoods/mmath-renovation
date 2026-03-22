#!/usr/bin/env python3

from __future__ import annotations

import os
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = REPO_ROOT / "analysis/thesis-side-by-side"
MPL_CACHE_DIR = Path(os.environ.get("TMPDIR", "/tmp")) / "mmath-renovation-mplconfig"

os.environ.setdefault("MPLBACKEND", "Agg")
os.environ.setdefault("MPLCONFIGDIR", str(MPL_CACHE_DIR))

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from PIL import Image, ImageDraw, ImageFont


THESIS_PDF = REPO_ROOT / "publications/1991 mmath thesis final.pdf"
THESIS_RENDER_DIR = OUT_DIR / "_thesis-pages"

PAGE_MAP = {
    "figure-06": 24,
    "figure-07": 27,
    "figure-08": 33,
    "figure-09": 34,
    "figure-10": 36,
    "figure-11": 38,
}

CROP_BOXES = {
    "figure-06": (120, 220, 1115, 1410),
    "figure-07": (110, 250, 1100, 1400),
    "figure-08": (150, 320, 1040, 1205),
    "figure-09": (150, 500, 1040, 1230),
    "figure-10": (140, 360, 1040, 1275),
    "figure-11": (140, 360, 1040, 1125),
}

HIERARCHIES = ["IBMS", "IMBS", "IBSM", "IMSB", "ISBM", "ISMB"]
HANOI_ALIGNMENT = {
    "bf_pwmp_published": [471, 149, 729, 636, 904, 6200],
    "bf_pwmp_current": [471, 149, 729, 636, 904, 6200],
    "lw_pwmp_published": [57, 78, 531, 2672, 5232, 6200],
    "lw_pwmp_current": [57, 78, 531, 2672, 5232, 6200],
    "match_matrix": [
        ["Exact", "Exact", "Exact", "Exact"],
        ["Exact", "Exact", "Exact", "Exact"],
        ["Exact", "Exact", "Exact", "Exact"],
        ["Exact", "Exact", "Exact", "Exact"],
        ["Exact", "Exact", "Exact", "Exact"],
        ["Exact", "Qualitative", "Exact", "Qualitative"],
    ],
    "strategy_labels": ["BF", "BF + P-WMP", "LW", "LW + P-WMP"],
}

ROBOT_OUTCOMES = {
    "problem_labels": ["Robot-1", "Robot-2"],
    "config_labels": ["Tweak", "AbTweak\nno LW", "AbTweak\nLW + heuristic"],
    "solved": [
        [0, 0, 1],
        [0, 0, 1],
    ],
}


def run(cmd: list[str]) -> None:
    subprocess.run(cmd, check=True)


def font(size: int) -> ImageFont.ImageFont:
    for candidate in (
        "/System/Library/Fonts/Supplemental/Avenir Next.ttc",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
    ):
        try:
            return ImageFont.truetype(candidate, size=size)
        except OSError:
            pass
    return ImageFont.load_default()


def render_thesis_pages() -> None:
    THESIS_RENDER_DIR.mkdir(parents=True, exist_ok=True)
    for key, page in PAGE_MAP.items():
        out = THESIS_RENDER_DIR / f"{key}.png"
        if out.exists():
            continue
        run(
            [
                "/opt/homebrew/bin/gs",
                "-q",
                "-dSAFER",
                "-dBATCH",
                "-dNOPAUSE",
                "-sDEVICE=png16m",
                "-r150",
                f"-dFirstPage={page}",
                f"-dLastPage={page}",
                f"-sOutputFile={out}",
                str(THESIS_PDF),
            ]
        )


def crop_thesis_figure(key: str) -> Image.Image:
    return Image.open(THESIS_RENDER_DIR / f"{key}.png").convert("RGB").crop(CROP_BOXES[key])


def chart_style(fig: plt.Figure, ax: plt.Axes, title: str, subtitle: str) -> None:
    fig.patch.set_facecolor("#10293f")
    ax.set_facecolor("#10293f")
    for spine in ax.spines.values():
        spine.set_color("#395c74")
    ax.tick_params(colors="#d7e9f7")
    ax.grid(color="#27465c", alpha=0.4, linestyle="-", linewidth=0.8, axis="y")
    ax.set_title(title, loc="left", color="#eff7ff", fontsize=18, fontweight="bold", pad=12)
    ax.text(0.0, 1.02, subtitle, transform=ax.transAxes, color="#9cc4df", fontsize=10, va="bottom")


def make_fig06_chart(path: Path) -> None:
    canvas = Image.new("RGB", (1180, 820), "#10293f")
    draw = ImageDraw.Draw(canvas)
    title_font = font(30)
    body_font = font(18)
    small_font = font(16)

    draw.rounded_rectangle((18, 18, 1162, 802), radius=26, fill="#163149", outline="#34546b", width=2)
    draw.text((42, 40), "Current abstraction / refinement ladder", fill="#eff7ff", font=title_font)
    draw.text(
        (42, 82),
        "Modern counterpart to thesis Figure 6 using the strongest live Hanoi-4 control line.",
        fill="#9cc4df",
        font=body_font,
    )

    bands = [
        ("k=3 abstract root", 150, "#163149"),
        ("k=2 abstract frontier", 295, "#14344d"),
        ("k=1 refinement frontier", 455, "#123852"),
        ("k=0 concrete frontier", 625, "#113b55"),
    ]
    for label, y, color in bands:
        draw.rounded_rectangle((40, y, 1140, y + 94), radius=18, fill=color, outline="#2e566f", width=2)
        draw.text((58, y + 32), label, fill="#d7e9f7", font=body_font)

    def node(x: int, y: int, label: str, fill: str) -> None:
        draw.ellipse((x - 34, y - 34, x + 34, y + 34), fill=fill, outline="#dce7f0", width=2)
        bbox = draw.textbbox((0, 0), label, font=small_font)
        draw.text((x - (bbox[2] - bbox[0]) / 2, y - 9), label, fill="#071826", font=small_font)

    def edge(x1: int, y1: int, x2: int, y2: int, color: str = "#8ecae6", width: int = 3) -> None:
        draw.line((x1, y1, x2, y2), fill=color, width=width)

    root = (590, 198)
    k2_a = (360, 342)
    k2_b = (830, 342)
    k1_a1 = (250, 502)
    k1_a2 = (470, 502)
    k1_b1 = (710, 502)
    k1_b2 = (930, 502)
    k0_a = (210, 672)
    k0_b = (420, 672)
    k0_c = (690, 672)
    k0_d = (960, 672)

    for child in (k2_a, k2_b):
        edge(root[0], root[1] + 34, child[0], child[1] - 34)
    for child in (k1_a1, k1_a2):
        edge(k2_a[0], k2_a[1] + 34, child[0], child[1] - 34)
    for child in (k1_b1, k1_b2):
        edge(k2_b[0], k2_b[1] + 34, child[0], child[1] - 34, color="#93c5fd")
    for parent, child in ((k1_a1, k0_a), (k1_a2, k0_b), (k1_b1, k0_c), (k1_b2, k0_d)):
        edge(parent[0], parent[1] + 34, child[0], child[1] - 34, color="#bfdbfe")

    node(*root, "R", "#f6c85f")
    for coords, label, fill in [
        (k2_a, "A", "#34d399"),
        (k2_b, "B", "#7dd3fc"),
        (k1_a1, "A1", "#4ade80"),
        (k1_a2, "A2", "#4ade80"),
        (k1_b1, "B1", "#f59e0b"),
        (k1_b2, "B2", "#f59e0b"),
        (k0_a, "A11", "#86efac"),
        (k0_b, "A21", "#86efac"),
        (k0_c, "B11", "#fdba74"),
        (k0_d, "B21", "#fdba74"),
    ]:
        node(*coords, label, fill)

    draw.text((110, 238), "Root search state", fill="#cde4f2", font=small_font)
    draw.text((120, 372), "Good abstract alternatives still visible", fill="#86efac", font=small_font)
    draw.text((720, 372), "Early level-drop branch", fill="#93c5fd", font=small_font)
    draw.text((110, 538), "Cleaner closure-oriented nodes", fill="#86efac", font=small_font)
    draw.text((690, 538), "Similar score, more Left-Wedge pressure", fill="#fdba74", font=small_font)
    draw.text((90, 710), "Higher-quality descendants still exist", fill="#bbf7d0", font=small_font)
    draw.text((630, 710), "Dirty concrete frontier leaders", fill="#fed7aa", font=small_font)

    draw.rounded_rectangle((65, 730, 1110, 782), radius=16, fill="#0e2232", outline="#30516a", width=1)
    draw.text(
        (84, 747),
        "Current restored reading: promising nodes remain higher in the refinement tree, while lower-kval reinsertions become more attractive as Left-Wedge pressure increases.",
        fill="#9cc4df",
        font=small_font,
    )

    canvas.save(path)


def make_fig07_chart(path: Path) -> None:
    canvas = Image.new("RGB", (1180, 820), "#10293f")
    draw = ImageDraw.Draw(canvas)
    title_font = font(30)
    body_font = font(18)
    small_font = font(16)
    tiny_font = font(14)

    draw.rounded_rectangle((18, 18, 1162, 802), radius=26, fill="#163149", outline="#34546b", width=2)
    draw.text((42, 40), "Current robot-domain map and validation status", fill="#eff7ff", font=title_font)
    draw.text(
        (42, 82),
        "Modern counterpart to thesis Figure 7 using the restored simple-robot domain and current benchmark outcomes.",
        fill="#9cc4df",
        font=body_font,
    )

    panel = (54, 138, 726, 760)
    draw.rounded_rectangle(panel, radius=20, fill="#0f2538", outline="#32526a", width=2)

    def room(x1, y1, x2, y2, label):
        draw.rounded_rectangle((x1, y1, x2, y2), radius=12, fill="#1e3a52", outline="#7fb3d5", width=3)
        draw.text((x1 + 14, y1 + 10), label, fill="#eff7ff", font=body_font)

    room(86, 180, 268, 324, "Room 1")
    room(286, 180, 468, 324, "Room 2")
    room(488, 214, 680, 400, "Room 3")
    room(488, 418, 680, 620, "Room 4")
    room(286, 438, 468, 620, "Room 5")
    room(106, 438, 268, 620, "Room 6")

    def door(x1, y1, x2, y2, label):
        draw.rounded_rectangle((x1, y1, x2, y2), radius=7, fill="#0b1c2a", outline="#f6c85f", width=2)
        bbox = draw.textbbox((0, 0), label, font=tiny_font)
        draw.text((x1 + (x2 - x1 - (bbox[2] - bbox[0])) / 2, y1 - 18), label, fill="#f6c85f", font=tiny_font)

    door(259, 230, 283, 278, "1-2")
    door(465, 250, 489, 298, "2-3")
    door(465, 480, 489, 528, "4-5")
    door(259, 480, 283, 528, "5-6")
    door(356, 396, 404, 420, "2-5")
    door(516, 396, 564, 420, "3-5")

    def item_box(x, y, label, fill="#f4efe4", outline="#173042", text="#173042"):
        draw.rounded_rectangle((x, y, x + 72, y + 36), radius=8, fill=fill, outline=outline, width=2)
        bbox = draw.textbbox((0, 0), label, font=small_font)
        draw.text((x + (72 - (bbox[2] - bbox[0])) / 2, y + 8), label, fill=text, font=small_font)

    item_box(158, 506, "Box 1")
    item_box(334, 222, "Box 2")
    item_box(158, 548, "Box 3")

    draw.ellipse((574, 487, 664, 537), outline="#f4efe4", width=3, fill="#224562")
    rbbox = draw.textbbox((0, 0), "Robot", font=body_font)
    draw.text((619 - (rbbox[2] - rbbox[0]) / 2, 500), "Robot", fill="#eff7ff", font=body_font)

    draw.text((86, 650), "Current restored domain keeps the same six-room / seven-door shape described in the thesis.", fill="#9cc4df", font=small_font)

    draw.rounded_rectangle((758, 156, 1128, 760), radius=20, fill="#19354d", outline="#32526a", width=2)
    draw.text((786, 182), "Current reproduced claim", fill="#eff7ff", font=title_font)
    draw.text((786, 224), "The robot domain is now one of the strongest validated\npublication families in the restored baseline.", fill="#9cc4df", font=body_font)

    badges = [
        ("Robot-1", "AbTweak solves", "#22c55e"),
        ("Robot-1", "Tweak bounded fail", "#64748b"),
        ("Robot-1", "No-LW bounded fail", "#f59e0b"),
        ("Robot-2", "AbTweak solves", "#22c55e"),
        ("Robot-2", "Tweak bounded fail", "#64748b"),
        ("Robot-2", "No-LW bounded fail", "#f59e0b"),
    ]
    y = 310
    for left, right, color in badges:
        draw.rounded_rectangle((786, y, 1100, y + 46), radius=12, fill="#11283c", outline="#3e617a", width=2)
        draw.rounded_rectangle((804, y + 8, 904, y + 38), radius=10, fill="#24445b", outline="#406780", width=1)
        draw.text((820, y + 14), left, fill="#d7e9f7", font=small_font)
        draw.rounded_rectangle((922, y + 8, 1082, y + 38), radius=10, fill=color, outline=color, width=1)
        bbox = draw.textbbox((0, 0), right, font=small_font)
        draw.text((1002 - (bbox[2] - bbox[0]) / 2, y + 14), right, fill="#08141f", font=small_font)
        y += 58

    draw.rounded_rectangle((786, 686, 1100, 742), radius=12, fill="#0f2538", outline="#3e617a", width=2)
    draw.text((804, 702), "Heuristic path: user-defined + primary effects + Left-Wedge", fill="#9cc4df", font=tiny_font)

    canvas.save(path)


def make_fig08_chart(path: Path) -> None:
    x = range(len(HIERARCHIES))
    fig, ax = plt.subplots(figsize=(8.6, 5.8))
    chart_style(fig, ax, "Current BF + P-WMP alignment", "Nearest regenerated evidence for thesis Figure 8.")
    ax.bar([i - 0.18 for i in x], HANOI_ALIGNMENT["bf_pwmp_published"], width=0.34, color="#7dd3fc", label="Thesis")
    ax.bar([i + 0.18 for i in x], HANOI_ALIGNMENT["bf_pwmp_current"], width=0.34, color="#34d399", label="Current")
    ax.set_xticks(list(x), HIERARCHIES)
    ax.set_ylabel("Expanded nodes", color="#d7e9f7")
    ax.set_yscale("log")
    ax.legend(facecolor="#10293f", edgecolor="#395c74", labelcolor="#eff7ff")
    ax.text(5, 7000, ">6000 remains qualitative", color="#f6c85f", fontsize=10, ha="center")
    fig.tight_layout()
    fig.savefig(path, dpi=170)
    plt.close(fig)


def make_fig09_chart(path: Path) -> None:
    x = range(len(HIERARCHIES))
    fig, ax = plt.subplots(figsize=(8.6, 5.8))
    chart_style(fig, ax, "Current LW + P-WMP alignment", "Nearest regenerated evidence for thesis Figure 9.")
    ax.bar([i - 0.18 for i in x], HANOI_ALIGNMENT["lw_pwmp_published"], width=0.34, color="#a78bfa", label="Thesis")
    ax.bar([i + 0.18 for i in x], HANOI_ALIGNMENT["lw_pwmp_current"], width=0.34, color="#22c55e", label="Current")
    ax.set_xticks(list(x), HIERARCHIES)
    ax.set_ylabel("Expanded nodes", color="#d7e9f7")
    ax.set_yscale("log")
    ax.legend(facecolor="#10293f", edgecolor="#395c74", labelcolor="#eff7ff")
    ax.text(5, 7000, ">6000 remains qualitative", color="#f6c85f", fontsize=10, ha="center")
    fig.tight_layout()
    fig.savefig(path, dpi=170)
    plt.close(fig)


def make_fig10_chart(path: Path) -> None:
    fig, ax = plt.subplots(figsize=(8.8, 5.8))
    chart_style(fig, ax, "Current publication-match matrix", "Modern regenerated status for the thesis Hanoi figure surface.")
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 6)
    ax.set_xticks([0.5, 1.5, 2.5, 3.5], HANOI_ALIGNMENT["strategy_labels"])
    ax.set_yticks([5.5, 4.5, 3.5, 2.5, 1.5, 0.5], HIERARCHIES)
    ax.tick_params(length=0)
    ax.grid(False)
    color_map = {"Exact": "#22c55e", "Qualitative": "#f6c85f"}
    for row, hierarchy in enumerate(HIERARCHIES):
        for col, status in enumerate(HANOI_ALIGNMENT["match_matrix"][row]):
            rect = FancyBboxPatch(
                (col + 0.1, 5 - row + 0.1),
                0.8,
                0.8,
                boxstyle="round,pad=0.02,rounding_size=0.08",
                linewidth=1.2,
                edgecolor="#33556c",
                facecolor=color_map[status],
            )
            ax.add_patch(rect)
            ax.text(col + 0.5, 5 - row + 0.5, "Exact" if status == "Exact" else "Qual", ha="center", va="center", fontsize=10, color="#08141f", fontweight="bold")
    ax.text(0.02, -0.16, "ISMB remains exact on solvable columns and qualitative on the thesis >6000 rows.", transform=ax.transAxes, color="#9cc4df", fontsize=10)
    fig.tight_layout()
    fig.savefig(path, dpi=170)
    plt.close(fig)


def make_fig11_chart(path: Path) -> None:
    fig, ax = plt.subplots(figsize=(8.4, 5.8))
    chart_style(fig, ax, "Current robot-domain reproduction", "Modern regenerated evidence for thesis Figure 11.")
    x = range(len(ROBOT_OUTCOMES["problem_labels"]))
    offsets = [-0.24, 0.0, 0.24]
    colors = ["#64748b", "#f59e0b", "#22c55e"]
    for idx, label in enumerate(ROBOT_OUTCOMES["config_labels"]):
        vals = [row[idx] for row in ROBOT_OUTCOMES["solved"]]
        ax.bar([i + offsets[idx] for i in x], vals, width=0.22, color=colors[idx], label=label)
    ax.set_xticks(list(x), ROBOT_OUTCOMES["problem_labels"])
    ax.set_ylim(0, 1.2)
    ax.set_yticks([0, 1], ["Bounded failure", "Solves"])
    ax.legend(facecolor="#10293f", edgecolor="#395c74", labelcolor="#eff7ff")
    ax.text(0.0, -0.18, "Current restored result: only the manual-style AbTweak path with Left-Wedge solves both representative robot cases.", transform=ax.transAxes, color="#9cc4df", fontsize=10)
    fig.tight_layout()
    fig.savefig(path, dpi=170)
    plt.close(fig)


def combine_side_by_side(title: str, thesis_img: Image.Image, right_img_path: Path, out_path: Path, caption: str) -> None:
    canvas = Image.new("RGB", (1860, 980), "#071826")
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((18, 18, 1842, 962), radius=28, fill="#0b2236", outline="#24445b", width=2)
    draw.text((46, 40), title, fill="#eff7ff", font=font(32))
    draw.text((46, 84), caption, fill="#9cc4df", font=font(18))
    left_panel = Image.new("RGB", (820, 790), "#f4efe4")
    thesis_copy = thesis_img.copy()
    thesis_copy.thumbnail((770, 740))
    left_panel.paste(thesis_copy, ((820 - thesis_copy.width) // 2, (790 - thesis_copy.height) // 2))
    canvas.paste(left_panel, (38, 150))
    right_img = Image.open(right_img_path).convert("RGB")
    right_img.thumbnail((900, 790))
    canvas.paste(right_img, (920 + (900 - right_img.width) // 2, 150 + (790 - right_img.height) // 2))
    draw.text((46, 915), "Left: thesis figure source. Right: current regenerated comparison surface.", fill="#7ea6bf", font=font(18))
    canvas.save(out_path)


def make_contact_sheet(paths: list[Path], out_path: Path) -> None:
    thumbs = []
    for path in paths:
        image = Image.open(path).convert("RGB")
        image.thumbnail((560, 295))
        thumb = Image.new("RGB", (600, 350), "#dce7f0")
        thumb.paste(image, ((600 - image.width) // 2, 14))
        ImageDraw.Draw(thumb).text((16, 316), path.stem, fill="#173042", font=font(22))
        thumbs.append(thumb)
    cols = 2
    rows = (len(thumbs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * 600, rows * 350), "#0a1b29")
    for i, thumb in enumerate(thumbs):
        sheet.paste(thumb, ((i % 2) * 600, (i // 2) * 350))
    sheet.save(out_path)


def main() -> None:
    if not THESIS_PDF.exists():
        raise SystemExit(f"Missing thesis PDF: {THESIS_PDF}")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    MPL_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    render_thesis_pages()
    chart06 = OUT_DIR / "figure-06-current-chart.png"
    chart07 = OUT_DIR / "figure-07-current-chart.png"
    chart08 = OUT_DIR / "figure-08-current-chart.png"
    chart09 = OUT_DIR / "figure-09-current-chart.png"
    chart10 = OUT_DIR / "figure-10-current-chart.png"
    chart11 = OUT_DIR / "figure-11-current-chart.png"
    make_fig06_chart(chart06)
    make_fig07_chart(chart07)
    make_fig08_chart(chart08)
    make_fig09_chart(chart09)
    make_fig10_chart(chart10)
    make_fig11_chart(chart11)
    final06 = OUT_DIR / "figure-06-side-by-side.png"
    final07 = OUT_DIR / "figure-07-side-by-side.png"
    final08 = OUT_DIR / "figure-08-side-by-side.png"
    final09 = OUT_DIR / "figure-09-side-by-side.png"
    final10 = OUT_DIR / "figure-10-side-by-side.png"
    final11 = OUT_DIR / "figure-11-side-by-side.png"
    combine_side_by_side(
        "Figure 6: Thesis abstract solution space vs current refinement ladder",
        crop_thesis_figure("figure-06"),
        chart06,
        final06,
        "The right panel reframes the restored abstraction story as a modern refinement-ladder view, emphasizing where cleaner nodes still exist higher in the tree.",
    )
    combine_side_by_side(
        "Figure 7: Thesis robot task-planning domain vs current domain map",
        crop_thesis_figure("figure-07"),
        chart07,
        final07,
        "The right panel redraws the restored six-room robot domain and summarizes the current reproduced robot-domain outcome pattern.",
    )
    combine_side_by_side(
        "Figure 8: Thesis scatter vs current BF + P-WMP evidence",
        crop_thesis_figure("figure-08"),
        chart08,
        final08,
        "The right panel uses the closest currently regenerated publication-alignment surface for breadth-first + P-WMP Hanoi runs.",
    )
    combine_side_by_side(
        "Figure 9: Thesis scatter vs current LW + P-WMP evidence",
        crop_thesis_figure("figure-09"),
        chart09,
        final09,
        "The right panel uses the closest currently regenerated publication-alignment surface for Left-Wedge + P-WMP Hanoi runs.",
    )
    combine_side_by_side(
        "Figure 10: Thesis Hanoi comparison vs current publication-match status",
        crop_thesis_figure("figure-10"),
        chart10,
        final10,
        "The right panel shows the exact-or-qualitative publication match status for the original three-disk thesis rows.",
    )
    combine_side_by_side(
        "Figure 11: Thesis robot comparison vs current reproduced claim",
        crop_thesis_figure("figure-11"),
        chart11,
        final11,
        "The right panel shows the currently reproduced robot-domain claim: only the manual-style AbTweak path solves the representative cases.",
    )
    make_contact_sheet([final06, final07, final08, final09, final10, final11], OUT_DIR / "gallery-contact-sheet.png")


if __name__ == "__main__":
    main()
