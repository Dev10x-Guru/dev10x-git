# `grma` — Autosquash Rebase onto origin/main

Same as `grda` but for repos where `main` is the base branch.

```fish
# Fish
alias grma "GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash origin/main"
```

```bash
# Bash / Zsh
alias grma='GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash origin/main'
```

---

[Back to Rebase & Autosquash](index.md)
