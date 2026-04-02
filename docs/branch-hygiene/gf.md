# `gf` — Verbose Fetch with Prune

Fetches all remotes, shows what changed, and removes local references to
deleted remote branches.

**Why?** Without `-p` (prune), your local repo still "sees" branches that were
deleted on the remote after merge. This pollutes `git branch -r` output and
tab-completion. The `-vv` flag shows exactly what moved, so you notice force-
pushes or unexpected updates.

```fish
# Fish
alias gf "git fetch -vv -p"
```

```bash
# Bash / Zsh
alias gf='git fetch -vv -p'
```

---

[Back to Branch Hygiene](index.md)
