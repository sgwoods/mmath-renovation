# Hanoi-4 Scaling Graphic

This note keeps the current checked-in scaling graphic for the strongest
measured `hanoi-4` historical-control strategies.

It complements:

- [Hanoi-4 strategy crosswalk](/Users/stevenwoods/mmath-renovation/docs/hanoi4-strategy-crosswalk.md)
- [Hanoi-4 solve candidate comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-solve-candidate-comparison.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)

Generated artifact:

- [analysis/hanoi4-scaling-strategies.svg](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-strategies.svg)
- [analysis/hanoi4-scaling-strategies.png](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-strategies.png)

Generation command:

```sh
python3 /Users/stevenwoods/mmath-renovation/scripts/generate-hanoi4-scaling-svg.py
```

## Current Read

The current graphic tracks four strategy lines across the measured bound ladder:

- `ISBM + weak-POS + Left-Wedge`
- `Legacy-1991 ISBM + weak-POS + Left-Wedge`
- `ISBM + weak-POS`
- `ISMB + weak-POS`

The important reading rule is still binary:

- lower generated counts are useful diagnostics
- but no line counts as benchmark progress until it solves classic three-peg
  `hanoi-4`

At the current measured bounds, the graphic shows:

- `ISBM + weak-POS + Left-Wedge` remains the strongest live candidate
- `Legacy-1991 ISBM + weak-POS + Left-Wedge` is the strongest grouped-top
  analogue, but stays clearly behind
- `ISBM + weak-POS` edges past `ISMB + weak-POS` at deeper bounds
- none of the lines closes the benchmark yet
