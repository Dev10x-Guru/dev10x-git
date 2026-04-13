# `grd` — Interactive Rebase onto origin/develop

Opens the rebase editor with all commits since `origin/develop`. Use this
when you want to manually reorder, edit, or squash commits.

```fish
# Fish
alias grd "git rebase --interactive origin/develop"
```

```bash
# Bash / Zsh
alias grd='git rebase --interactive origin/develop'
```

---

[Back to Rebase & Autosquash](index.md)
