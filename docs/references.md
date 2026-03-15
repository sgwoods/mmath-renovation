# Reference Documents

This page collects the core historical documents for the AbTweak work that this repository aims to recover and document.

Checked-in copies of these sources now live in [publications/README.md](/Users/stevenwoods/mmath-renovation/publications/README.md).

## Primary Sources

### 1. AAAI 1990 conference paper

- Title: "ABTWEAK: Abstracting a Nonlinear, Least Commitment Planner"
- Authors: Josh D. Tenenberg and Qiang Yang
- Venue: AAAI-90
- Local copy: [publications/1990-aaai-abtweak.pdf](/Users/stevenwoods/mmath-renovation/publications/1990-aaai-abtweak.pdf)
- URL: <https://cdn.aaai.org/AAAI/1990/AAAI90-031.pdf>

Why it matters:
This is the original paper-level introduction to ABTWEAK. It is the right place to recover the core terminology, the planning model inherited from TWEAK, and the main formal claim about monotonic abstraction.

### 2. University of Waterloo technical report CS-91-65

- Title: "Abstraction in Nonlinear Planning"
- Authors: Qiang Yang, Josh D. Tenenberg, and Steve Woods
- Institution: University of Waterloo, Cheriton School of Computer Science
- Date: December 1991
- Local copy: [publications/1991-uwaterloo-tr-65-abstraction-in-nonlinear-planning.pdf](/Users/stevenwoods/mmath-renovation/publications/1991-uwaterloo-tr-65-abstraction-in-nonlinear-planning.pdf)
- URL: <https://cs.uwaterloo.ca/research/tr/1991/65/final.pdf>

Why it matters:
This report appears to be the longer treatment of the ABTWEAK work. It expands the formal development, discusses criteria for good abstraction hierarchies, and documents the Left-Wedge search strategy and empirical evaluation.

### 3. CMU AI Repository package page

- Title: "abtweak"
- Source: CMU AI Repository, Planning Systems archive
- Local copy: [publications/cmu-ai-repository-abtweak.html](/Users/stevenwoods/mmath-renovation/publications/cmu-ai-repository-abtweak.html)
- URL: <https://www.cs.cmu.edu/afs/cs/project/ai-repository/ai/areas/planning/systems/abtweak/0.html>

Why it matters:
This is the historical package landing page for the implementation archive. It is a key provenance reference for any recovered code, packaging notes, or distribution metadata.

### 4. University of Waterloo technical report CS-91-17

- Title: "An Implementation and Evaluation of a Hierarchical Nonlinear Planner"
- Author: Steven G. Woods
- Institution: University of Waterloo, Cheriton School of Computer Science
- Date: March 1991
- Local copy: [publications/1991-uwaterloo-tr-17-thesis-report.pdf](/Users/stevenwoods/mmath-renovation/publications/1991-uwaterloo-tr-17-thesis-report.pdf)
- URL: <https://cs.uwaterloo.ca/research/tr/1991/17/report.pdf>

Why it matters:
This thesis-level report is especially important for implementation recovery. It should help connect the formal system to actual engineering choices, evaluation methodology, and any domain examples used in the historical code.

## Suggested Use In This Repository

When reconstructing the system, these documents should be used in roughly this order:

1. read the AAAI paper for the compact statement of the planning model and main claims
2. use the longer technical report for the detailed formalism and experimental framing
3. use the thesis to recover implementation details and evaluation setup
4. use the CMU AI Repository page to validate code provenance and packaging history

## Open Documentation Tasks

- add a chronology tying together the 1990 paper, the 1991 thesis, and the 1991 technical report
- extract any example planning domains or benchmark problems into repository fixtures
- note terminology differences such as `ABTWEAK` versus `AbTweak` where they appear
- document any mismatch between archived code behavior and the published descriptions
