# Publication Domain Crosswalk

This table summarizes the main domain families against the published AbTweak
sources and indicates whether the repository currently contains enough domain
and experiment data to rerun them in a way that matches the historical record.

Rerun labels:

- `Exact`: we have enough archived domain/control/output data to reproduce the
  reported run family closely, and current results match at the reported level
- `Strong`: we have the domain, abstraction data, and sample tasks, and can
  rerun the historically intended benchmark family, but not every published
  row is matched exactly
- `Partial`: we have a meaningful rerun path, but a key part of the published
  story is still incomplete
- `Manual-only`: the domain is clearly shipped in the 1993 distribution, but
  is not yet tied to a precise published table or figure
- `Missing`: the domain exists, but the runnable sample or framework support
  needed for faithful reruns is still absent

| Domain or family | AAAI 1990 | TR-91-65 | Thesis CS-91-17 | 1993 manual | What we have now | Can we rerun it as shown? |
| --- | --- | --- | --- | --- | --- | --- |
| `blocks` | background use | yes, baseline comparisons | yes, sample baseline | yes | domain, abstraction lists, shipped goals, working `tweak` and `abtweak` runs | `Strong` |
| `nils-blocks` | MP-related abstraction theme | yes | yes | yes | domain, abstraction lists, archived `nils/crit*` files, working SBCL runs | `Strong` |
| `hanoi-2` | not a main published focus | early experiment lineage only | not a main reported family | no | early domains plus hierarchy loaders and saved artifacts | `Partial` |
| `hanoi-3` | yes, abstraction benchmark family | yes | yes | yes | domain, hierarchy permutations, archived outputs, 1991 compatibility layer with exact row matches | `Exact` |
| `hanoi-4` | conceptually yes | yes | yes | yes | domain, hierarchy variants, historical-control wrapper, traces, replay/score diagnostics | `Partial` |
| `macro-hanoi` | no | no | no | indirect shipped variant | runnable later-domain variant with passing smoke tests | `Manual-only` |
| `registers` | background sample family | yes as sample domain family | yes as sample family | yes | domain and goals present; working `tweak` and `abtweak` runs | `Strong` |
| `robot` / `simple-robot` | application motivation | yes, strongest published application story | yes | yes | early robot artifacts, later split domains, heuristic and primary-effects support, strong qualitative reruns | `Strong` |
| `fly` / transportation | no clear paper table | not a main paper benchmark | not a main thesis benchmark | yes | domain, abstraction lists, shipped goals, working SBCL runs | `Manual-only` |
| `computer` | no clear paper table | not a main paper benchmark | not a main thesis benchmark | yes | domain, abstraction lists, shipped goal, working SBCL runs | `Manual-only` |
| `biology` | no clear paper table | not a main paper benchmark | not a main thesis benchmark | yes | domain, abstraction lists, multiple shipped goals, working SBCL runs | `Manual-only` |
| `database` | no clear paper table | not a main paper benchmark | not a main thesis benchmark | yes | domain and multiple shipped query goals; intended historically for `tweak` | `Manual-only` |
| `stylistics` | no clear paper table | not a main paper benchmark | not a main thesis benchmark | yes | domain operators and abstraction data survive | `Missing` |
| `driving` | no | no | no | no | alternate `reset-domain` framework only | `Missing` |
| `scheduling` / `newd` | no | no | no | no | mixed alternate-framework workspace only | `Missing` |

## Current Interpretation

The repo is strongest where the historical record is strongest:

1. `hanoi-3` is the cleanest exact publication rerun family.
2. `blocks`, `nils-blocks`, `registers`, and `robot` are strong historically
   grounded reruns, even when not every exact paper row is reconstructed.
3. `hanoi-4` is the main remaining published benchmark gap.
4. `fly`, `computer`, `biology`, and `database` are best treated as
   1993-manual validation domains rather than as paper-table replications.
5. `stylistics` is the clearest shipped-domain case where the surviving
   abstraction structures outlive the obvious runnable sample task.
