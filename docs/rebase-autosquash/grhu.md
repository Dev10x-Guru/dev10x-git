# `grhu` — Reset to Upstream

Hard-resets the current branch to match its upstream tracking branch.
Useful when you want to discard local changes and match the remote exactly.

**Warning:** This is destructive — uncommitted work is lost.

```fish
# Fish
alias grhu "git reset --hard @{upstream}"
```

```bash
# Bash / Zsh
alias grhu='git reset --hard @{upstream}'
```

---

[Back to Rebase & Autosquash](index.md)
