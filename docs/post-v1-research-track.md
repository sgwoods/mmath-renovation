# Post-1.0 Research Track

This note captures work that is intentionally **outside** the historical
restoration baseline and should be treated as a later research/extension phase
after the main `1.0` historical checkpoint is secure.

The purpose of this track is not to rewrite the historical AbTweak baseline.
It is to create a disciplined place for asking:

- what later planning or encoding ideas might help explain the remaining open
  `hanoi-4` case?
- what problem-structure knowledge was not folded into the 1990-1994 work?
- which later ideas are generic enough to motivate new named extensions after
  the historical restoration is complete?

## First Planned Input

The first explicit post-`1.0` research input should be:

- Ruben Martins and Ines Lynce, *Effective CNF Encodings for the Towers of
  Hanoi* (2008)
  - [PDF](https://sat.inesc-id.pt/~ines/publications/lpar08-sp.pdf)

## Why This Matters

Although this paper is from a different solver tradition than AbTweak, it is
still useful for future `hanoi-4` thinking because it makes the structural
knowledge of the puzzle explicit.

From the paper, the main reusable ideas to analyze later are:

- the recursive move-sequence property
- the minimal-move bound structure
- disk-parity constraints
- disk-cycle constraints
- the claim that the puzzle becomes trivial once the encoding captures the
  right structural properties directly

That makes it a good future foil for our current `hanoi-4` diagnosis:

- today, the restored historical AbTweak line appears to keep rewarding dirty
  low-level partial plans
- later research may help us think about whether a different hierarchy design,
  problem encoding, or generic structural constraint layer would make the
  intended recursive solution shape more explicit

## Planned Post-1.0 Questions

Once the historical restoration baseline is stable enough for a true `1.0`
checkpoint, this later research track should ask:

1. Which structural properties of Tower of Hanoi should a hierarchy expose if
   the desired behavior is "move the next-largest disk into place, then
   recurse"?
2. Which of those properties are already latent in the historical domain but
   poorly surfaced by the current abstraction schemes?
3. Which later ideas belong to:
   - problem encoding
   - hierarchy design
   - heuristic shaping
   - generic non-domain-specific search control?
4. If a later generic strategy emerges, how should it be named and separated
   from `AbTweak-1993` under the repo's algorithm-strategy policy?

## Boundary

This note is explicitly for **post-1.0** work.

Until then:

- the historical baseline remains the priority
- `hanoi-4` is still judged in the historical-restoration frame first
- later literature should inform future extension planning, not be merged
  silently into the restored baseline
