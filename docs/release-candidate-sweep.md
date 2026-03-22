# 1.0 Release Candidate Validation Sweep

Generated:

- UTC: '2026-03-22 22:20:25Z'
- checkpoint under test: '1.0.0-rc.1'

This sweep is the current repeatable RC-basis validation bundle for
the historical-restoration baseline.

## Command Set

~~~sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh status --json
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report benchmark-status
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi2-historical
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi3-historical
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi4-solve-candidates
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report wide-domain-sweep
~~~

## Verdict

- core restored operator-style baseline: ready
- historical validation surface: ready
- 'hanoi-4' status for RC: accepted as an explained-but-open extension
  benchmark
- next step after this sweep: release preparation and version/tag work, not
  another missing validation family

## Harness Family Snapshot

- reproduced families: '8'
- partially reproduced families: '1'
- open families: '1'

~~~json
{
  "kind": "status",
  "families": [
    {"family":"hanoi-2-lineage","status":"reproduced"},
    {"family":"blocks-baseline","status":"reproduced"},
    {"family":"hanoi-3","status":"reproduced"},
    {"family":"hanoi-4","status":"partially-reproduced"},
    {"family":"robot-with-user-heuristic","status":"reproduced"},
    {"family":"registers-and-tiny-regressions","status":"reproduced"},
    {"family":"macro-hanoi-variants","status":"reproduced"},
    {"family":"shipped-operator-style-sample-domains","status":"reproduced"},
    {"family":"1991-hanoi-msp-compatibility","status":"reproduced"},
    {"family":"alternate-reset-domain-framework","status":"open"}
  ]
}
~~~

## Historical Validation Checks

### Hanoi-2

- all six recovered hierarchy rows solve
- expanded/generated counts match the archived 1990 two-disk outputs exactly

~~~
| `ibs` | solves | 11 | 19 | 0 | 3 | `11 / 19 / 2` | `crit1-raw.out` |
| `sib` | solves | 25 | 47 | 0 | 3 | `25 / 47 / 4` | `crit2-raw.out` |
| `bsi` | solves | 11 | 20 | 0 | 3 | `11 / 20 / 2` | `crit3-raw.out` |
| `bis` | solves | 11 | 19 | 0 | 3 | `11 / 19 / 2` | `crit4-raw.out` |
| `sbi` | solves | 23 | 46 | 0 | 3 | `23 / 46 / 3` | `crit5-raw.out` |
| `isb` | solves | 24 | 46 | 0 | 3 | `24 / 46 / 3` | `crit6-raw.out` |
~~~

### Hanoi-3

- the representative 1991-style compatibility slice still solves cleanly
- the main weak-MSP rows match the archived expanded/generated counts

~~~
| `isbm` | `weak` | `nec` | `nil` | `stack` | solves | 1083 | 1433 | 800 | 0 | `1083 / 1433` | `isbm-ab-WN.1126` |
| `imbs` | `weak` | `nec` | `nil` | `stack` | solves | 166 | 233 | 65 | 0 | `166 / 233` | `imbs-ab-Wn.1129` |
| `imbs` | `weak` | `pos` | `nil` | `stack` | solves | 149 | 206 | 64 | 0 | `149 / 206` | `imbs2-raw.out` |
| `sbim` | `weak` | `pos` | `nil` | `stack` | solves | 332 | 490 | 242 | 0 | `332 / 490` | `sbim-raw.out` |
| `sbmi` | `weak` | `pos` | `nil` | `stack` | solves | 573 | 1071 | 349 | 0 | `573 / 1071` | `sbmi-raw.out` |
| `simb` | `weak` | `pos` | `nil` | `stack` | solves | 785 | 995 | 671 | 0 | `785 / 995` | `simb-raw.out` |
| `sibm` | `weak` | `pos` | `nil` | `stack` | solves | 482 | 620 | 359 | 0 | `482 / 620` | `sibm-raw.out` |
| `smib` | `weak` | `pos` | `nil` | `stack` | solves | 899 | 1236 | 763 | 0 | `899 / 1236` | `smib-raw.out` |
| `misb` | `weak` | `pos` | `nil` | `stack` | solves | 682 | 1040 | 310 | 0 | `682 / 1040` | `misb-raw.out` |
| `isbm` | `nil` | `nec` | `t` | `stack` | solves | 168 | 284 | 0 | 0 | `168 / 284` | `isbmK-raw.out` |
| `ibsm` | `nil` | `nec` | `t` | `stack` | solves | 828 | 1471 | 0 | 0 | `828 / 1471` | `ibsmK-raw.out` |
| `ismb` | `nil` | `nec` | `t` | `stack` | solves | 963 | 1771 | 0 | 0 | `963 / 1771` | `ismbK-raw.out` |
| `isbm` | `strong` | `nec` | `nil` | `stack` | solves | 1083 | 1433 | 0 | 800 | `- / -` | `no direct archived row isolated yet` |
| `isbm` | `weak` | `nec` | `nil` | `tree` | solves | 2630 | 3779 | 1983 | 0 | `- / -` | `no direct archived row isolated yet` |
~~~

## Open Benchmark Disposition

The RC interpretation now assumes that 'hanoi-4' does not block '1.0.0-rc.1'
if it remains clearly documented as a historically grounded extension benchmark
with an evidence-backed "explained but open" status.

Current narrow solve-candidate ladder:

~~~
| `isbm` | `20000` | EXPAND-LIMIT-EXCEEDED | 20001 | 23272 | 21286 |
| `legacy-1991-isbm` | `20000` | EXPAND-LIMIT-EXCEEDED | 20001 | 26215 | 15791 |
| `isbm` | `50000` | EXPAND-LIMIT-EXCEEDED | 50001 | 58817 | 54466 |
| `legacy-1991-isbm` | `50000` | EXPAND-LIMIT-EXCEEDED | 50001 | 66327 | 41518 |
| `isbm` | `100000` | EXPAND-LIMIT-EXCEEDED | 100001 | 116646 | 110674 |
| `legacy-1991-isbm` | `100000` | EXPAND-LIMIT-EXCEEDED | 100001 | 132286 | 83535 |
| `isbm` | `200000` | EXPAND-LIMIT-EXCEEDED | 200001 | 234872 | 224678 |
| `legacy-1991-isbm` | `200000` | EXPAND-LIMIT-EXCEEDED | 200001 | 265691 | 167921 |
~~~

Current read:

- the strongest live line remains 'isbm + weak-POS + stack + Left-Wedge'
- the strongest grouped-top comparison line remains 'legacy-1991-isbm'
- neither solves at '20000', '50000', '100000', or '200000'
- 'isbm' stays clearly ahead at every tested bound

## Wide Domain Sweep

- solved rows in the current wide operator-style sweep: '26'
- intentionally excluded alternate/helper rows: '6'

The main wide-sweep result remains stable:

- the shipped operator-style sample domains are healthy under the restored
  SBCL path
- the excluded cases remain the alternate 'reset-domain' / 'defstep' track
  or helper-only files, not silent failures inside the main baseline

## Family Summary

| Family | Status | Main evidence | Next step |
| --- | --- | --- | --- |
| Hanoi-2 lineage | reproduced | the restored six-hierarchy family now matches the archived 1990 two-disk batch outputs exactly, and both default `tweak` and `abtweak` smoke cases solve | keep as a fast historical regression for the Hanoi compatibility surface |
| Blocks baseline | reproduced | `blocks-sussman` solves in `tweak` and `abtweak`; Nilsson blocks also solves in both modes | keep as stable regression baseline |
| Hanoi-3 | reproduced | `hanoi-3` solves in both modes and the 1991 compatibility layer now reproduces a broad historical control slice exactly | widen historical comparison only when useful |
| Hanoi-4 | partially reproduced | hierarchy sensitivity, MP effects, historical-control vocabulary, and frontier traces are all restored enough to explain much of the behavior, but a full solve is still missing | keep `ismb` and `isbm` as the main open comparison path |
| Robot with user heuristic | reproduced | both robot benchmarks show the historically important AbTweak plus left-wedge advantage over the comparable bounded runs | keep as application benchmark and left-wedge validation case |
| Registers and tiny regressions | reproduced | `registers` solves in both modes and the tiny sanity cases are usable as quick regressions | preserve as fast smoke checks |
| Macro-Hanoi variants | reproduced | `macro-hanoi` and `macro-hanoi4` solve in both modes | keep as compact later-1993 success cases |
| Shipped operator-style sample domains | reproduced | `computer`, `biology`, `fly`, `stylistics`, and multiple `database` queries now run correctly under the restored planner path | continue widening where it improves validation coverage |
| 1991 Hanoi MSP compatibility | reproduced | weak-`NEC`, weak-`POS`, and critical-depth representative runs now match archived `hanoi-3` outputs exactly | decide how far to extend this beyond Hanoi |
| Alternate `reset-domain` framework | open | `driving`, `newd`, and parts of `scheduling` still sit outside the restored operator-style experiment path | treat as separate phase-2 restoration track |

## Labels

- `reproduced`: strong evidence that the family behaves as expected in the restored environment
- `partially reproduced`: important behavior is restored and explained, but a key historical result is still incomplete
- `open`: still outside the main restored environment

## Detailed Sources

- `docs/historical-validation-matrix.md`
- `docs/current-status.md`
- `docs/hanoi4-diagnosis.md`
- `docs/hanoi3-1991-compatibility.md`
- `docs/wide-domain-sweep.md`

## Raw Report References

- 'report benchmark-status'
- 'report hanoi2-historical'
- 'report hanoi3-historical'
- 'report hanoi4-solve-candidates'
- 'report wide-domain-sweep'
