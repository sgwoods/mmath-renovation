# Hanoi Publication Alignment

This report aligns the original published Hanoi figure rows with the current
SBCL restoration on the original three-disk Hanoi predicate family.

Important scope note:

- these exact publication rows correspond to the original `hanoi-3` style
  domain (`onb`, `onm`, `ons`)
- they do not directly correspond to the later shipped four-disk
  [hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1)
  extension with added `onh`

Publication source for the numeric rows:

- checked-in thesis PDF:
  [1991-uwaterloo-tr-17-thesis-report.pdf](/Users/stevenwoods/mmath-renovation/publications/1991-uwaterloo-tr-17-thesis-report.pdf)
- locally extracted from the thesis figure block labelled
  `BF Expansions: IBMS IMBS IBSM IMSB ISBM ISMB`

Restoration settings used here:

- planner: `abtweak`
- determine mode: `stack`
- expand bound: 6000
- generate bound: 24000
- open bound: 24000
- CPU seconds: 30

| Hierarchy | Thesis BF | Current BF | Thesis BF + P-WMP | Current BF + P-WMP | Thesis LW | Current LW | Thesis LW + P-WMP | Current LW + P-WMP |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `IBMS` | `471` | `471` | `471` | `471` | `57` | `57` | `57` | `57` |
|  |  |  |  |  |  |  | publication match | `Exact / Exact / Exact / Exact` |
| `IMBS` | `550` | `550` | `149` | `149` | `1009` | `1009` | `78` | `78` |
|  |  |  |  |  |  |  | publication match | `Exact / Exact / Exact / Exact` |
| `IBSM` | `1112` | `1112` | `729` | `729` | `828` | `828` | `531` | `531` |
|  |  |  |  |  |  |  | publication match | `Exact / Exact / Exact / Exact` |
| `IMSB` | `918` | `918` | `636` | `636` | `5170` | `5170` | `2672` | `2672` |
|  |  |  |  |  |  |  | publication match | `Exact / Exact / Exact / Exact` |
| `ISBM` | `1771` | `1771` | `904` | `904` | `168` | `168` | `5232` | `5232` |
|  |  |  |  |  |  |  | publication match | `Exact / Exact / Exact / Exact` |
| `ISMB` | `3142` | `3142` | `>6000` | `EXPAND-LIMIT-EXCEEDED` | `963` | `963` | `>6000` | `EXPAND-LIMIT-EXCEEDED` |
|  |  |  |  |  |  |  | publication match | `Exact / Qualitative / Exact / Qualitative` |

Interpretation:

- `IBMS`, `IMBS`, `IBSM`, `IMSB`, and `ISBM` now reproduce the thesis
  figure rows exactly at the expanded-node level across all four strategy
  columns.
- `ISMB` reproduces the solvable columns exactly and matches the two thesis
  `>6000` entries qualitatively by exceeding the same 6000-node figure scale.
- This is the strongest exact publication-side Hanoi validation surface in the
  current repo.
- The later four-disk [hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1)
  benchmark should therefore be treated as a historically grounded extension,
  not as a figure-for-figure publication rerun.
