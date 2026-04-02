# Git Workflow Utilities — A Short Course

A 4-module guide to the custom git functions that keep repositories clean,
history readable, and parallel work manageable. Each module is self-contained
and takes ~5 minutes to read.

Shell definitions are provided in **Fish**, **Bash**, and **Zsh**.

## Modules

1. [**Branch Hygiene — The Morning Routine**](branch-hygiene/index.md)
   `gpb`, `gf`, `stale-branches` — sync your local state with reality.

2. [**Worktree Management — Parallel Workspaces**](worktree-management/index.md)
   `gw`, `gwa`, `gwr` — check out multiple branches simultaneously with smart defaults.

3. [**Rebase & Autosquash — Clean History**](rebase-autosquash/index.md)
   `grda`, `grma`, `gria`, `gpf` — the fixup workflow that makes history rewriting painless.

4. [**Cleanup Utilities — Repo Hygiene**](cleanup-utilities/index.md)
   `clean-orig`, `clean-pyc`, `commit-requirements` — remove artifacts that clutter your tree.

## Quick Reference Card

| Alias | What it does | When to use |
|-------|-------------|-------------|
| `gf` | Fetch + prune | Before any branch operation |
| `gpb` | Sync bases + delete stale branches | Start of day |
| `stale-branches` | List remote branches by age | Monthly remote cleanup |
| `gw [name]` | Switch to worktree with context | Switching between parallel work |
| `gwa <name>` | Create worktree from base branch | Starting new feature work |
| `gwr [name]` | Remove worktree + branch | After PR merge |
| `grd` | Interactive rebase onto develop | Manual history editing |
| `grda` | Autosquash onto develop | Absorbing fixup commits |
| `grma` | Autosquash onto main | Same, for main-based repos |
| `gria <ref>` | Autosquash onto any ref | Stacked branches |
| `gra` / `grc` | Rebase abort / continue | During conflict resolution |
| `grhu` | Reset to upstream | Discard local, match remote |
| `gpf` | Force push with lease | After rebase |
| `clean-orig` | Remove .orig files | After merge conflict resolution |
| `clean-pyc` | Remove .pyc/.pyo files | Stale bytecode issues |

## Installation

### Fish

Save functions to `~/.config/fish/conf.d/git.fish` — Fish auto-loads
files from `conf.d/` on shell startup.

### Bash

Add functions and aliases to `~/.bashrc` or a dedicated `~/.bash_git_aliases`
that you source from `.bashrc`:

```bash
# In ~/.bashrc
source ~/.bash_git_aliases
```

### Zsh

Add to `~/.zshrc` or a dedicated file sourced from it:

```zsh
# In ~/.zshrc
source ~/.zsh_git_aliases
```

> **Note on Fish vs Bash/Zsh syntax:** Fish uses `function name ... end` and
> `set` for variables. Bash/Zsh use `name() { ... }` and standard variable
> assignment. The git commands inside are identical — only the shell wrapper
> differs.
