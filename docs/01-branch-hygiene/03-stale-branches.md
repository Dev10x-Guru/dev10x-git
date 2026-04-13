# `stale-branches` — List Remote Branches by Age

Shows all remote branches sorted by last commit date, oldest first.
Useful for identifying abandoned work that should be cleaned up on the remote.

**Why?** Stale remote branches slow down fetches, clutter CI dashboards, and
hide which work is actually active. This gives you a quick audit list to share
with the team.

```fish
# Fish
function stale-branches
    git for-each-ref --sort=-committerdate \
        --format='%(committerdate:short) %(refname)' refs/remotes \
        | sed 's|refs/remotes/origin/||'
end
```

```bash
# Bash / Zsh
stale-branches() {
    git for-each-ref --sort=-committerdate \
        --format='%(committerdate:short) %(refname)' refs/remotes \
        | sed 's|refs/remotes/origin/||'
}
```

---

[Back to Branch Hygiene](index.md)
