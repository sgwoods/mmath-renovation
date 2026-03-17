# Hanoi Search Baselines

This directory keeps the retained side-experiment baselines for classical
state-space Hanoi search.

The purpose is not to replicate AbTweak. The purpose is to keep a small,
re-runnable external comparison point for:

- plain BFS
- plain DFS
- plain A*

on the same standard 3-peg transfer problems that we care about in the AbTweak
restoration story.

Current entry point:

- [run-hanoi-search-baselines.sh](/Users/stevenwoods/mmath-renovation/scripts/run-hanoi-search-baselines.sh)

Retained code:

- [hanoi_search_baselines.py](/Users/stevenwoods/mmath-renovation/experiments/hanoi-baselines/hanoi_search_baselines.py)

Current checked-in report:

- [standard-transfer.md](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/standard-transfer.md)
