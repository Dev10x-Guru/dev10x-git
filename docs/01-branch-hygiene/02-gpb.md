# `gpb` — Sync Base Branches & Prune Stale Locals

The "start of day" command. Does everything in one shot:

1. Fetches all remotes (with prune)
2. Pulls `master`, `main`, and `develop` to keep them current
3. Lists all local branches with tracking info
4. Finds branches whose upstream was deleted ("gone") and removes them

**Why?** After a PR merges, GitHub deletes the remote branch — but your local
copy stays. Over weeks you accumulate dozens of dead branches. `gpb` is a
one-command cleanup that's safe because `git branch -d` (lowercase) refuses
to delete unmerged work.

```fish
# Fish
function gpb
    git fetch -vv -p
    git checkout master; git pull
    git checkout main; git pull
    git checkout develop; git pull
    git branch -vv
    git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d
end
```

```bash
# Bash / Zsh
gpb() {
    git fetch -vv -p
    git checkout master && git pull
    git checkout main && git pull
    git checkout develop && git pull
    git branch -vv
    git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d
}
```

> **Safety net:** `git branch -d` (lowercase d) only deletes fully-merged
> branches. If you have unmerged work, git refuses and tells you. Use
> `-D` (uppercase) only when you're certain.

> **Tip:** Errors like `error: pathspec 'master' did not match` are harmless —
> not every repo has all three base branches. The function continues regardless.

---

[Back to Branch Hygiene](index.md)
