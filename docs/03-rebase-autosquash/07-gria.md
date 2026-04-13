# `gria` — Generic Autosquash Rebase

Autosquash rebase that takes a base ref as argument. Use when the base isn't
`develop` or `main` (e.g., stacked branches).

```fish
# Fish
alias gria "GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash"
# Usage: gria origin/feature-base
```

```bash
# Bash / Zsh
alias gria='GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash'
# Usage: gria origin/feature-base
```

---

[Back to Rebase & Autosquash](index.md)
