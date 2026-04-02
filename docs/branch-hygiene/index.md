# Module 1: Branch Hygiene — The Morning Routine

Your local repo accumulates stale branches as PRs merge and remote branches
get deleted. These functions keep your local state in sync with reality.

## Functions

| Function | Description |
|----------|-------------|
| [`gf`](gf.md) | Verbose fetch with prune |
| [`gpb`](gpb.md) | Sync base branches & prune stale locals |
| [`stale-branches`](stale-branches.md) | List remote branches by age |

## Workflow: Start of Day

```
$ gpb                    # sync everything, prune dead branches
$ stale-branches | tail  # check if any ancient branches need remote cleanup
$ gs my-feature          # start fresh work (see Module 4)
```

---

[Back to course overview](../index.md)
