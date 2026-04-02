# `grda` — Autosquash Rebase onto origin/develop (Non-Interactive)

Same as `grd` but skips the editor — `GIT_SEQUENCE_EDITOR=true` accepts the
autosquash reordering automatically. **This is the workhorse** for absorbing
fixup commits before a PR merge.

**Why non-interactive?** When your only goal is to squash fixups, opening an
editor is friction. `GIT_SEQUENCE_EDITOR=true` tells git to accept the
auto-generated todo list as-is.

```fish
# Fish
alias grda "GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash origin/develop"
```

```bash
# Bash / Zsh
alias grda='GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash origin/develop'
```

---

[Back to Rebase & Autosquash](index.md)
