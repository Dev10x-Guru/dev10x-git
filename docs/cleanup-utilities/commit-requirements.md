# `commit-requirements` — Stage & Commit Lock Files

Stages pip-compile output and commits only if there are changes. Prevents
empty commits when requirements didn't actually change.

```fish
# Fish
function commit-requirements
    git add requirements/lock/*.txt
    git diff-index HEAD
    git diff-index --quiet HEAD || git commit -m "Requirements compiled by pip-compile"
end
```

```bash
# Bash / Zsh
commit-requirements() {
    git add requirements/lock/*.txt
    git diff-index HEAD
    git diff-index --quiet HEAD || git commit -m "Requirements compiled by pip-compile"
}
```

> **Note:** The `git diff-index --quiet HEAD` check returns non-zero when there
> are staged changes — the `||` ensures the commit only runs when there's
> something to commit.

---

[Back to Cleanup Utilities](index.md)
