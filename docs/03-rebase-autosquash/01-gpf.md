# `gpf` — Safe Force Push

Force-pushes with `--force-with-lease` instead of raw `--force`. This
refuses to overwrite commits that someone else pushed since your last fetch.

**Why?** Raw `--force` can destroy teammates' work. `--force-with-lease`
gives you the "I rebased, let me push" workflow without the danger of
silently overwriting someone else's commits.

```fish
# Fish
alias gpf "git push origin --force-with-lease"
```

```bash
# Bash / Zsh
alias gpf='git push origin --force-with-lease'
```

---

[Back to Rebase & Autosquash](index.md)
