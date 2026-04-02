# Git Workflow Utilities — A Short Course

A 4-module guide to the custom git functions that keep repositories clean,
history readable, and parallel work manageable. Each module is self-contained
and takes ~5 minutes to read.

Shell definitions are provided in **Fish**, **Bash**, and **Zsh**.

---

## Module 1: Branch Hygiene — The Morning Routine

Your local repo accumulates stale branches as PRs merge and remote branches
get deleted. These functions keep your local state in sync with reality.

### `gf` — Verbose Fetch with Prune

Fetches all remotes, shows what changed, and removes local references to
deleted remote branches.

**Why?** Without `-p` (prune), your local repo still "sees" branches that were
deleted on the remote after merge. This pollutes `git branch -r` output and
tab-completion. The `-vv` flag shows exactly what moved, so you notice force-
pushes or unexpected updates.

```fish
# Fish
alias gf "git fetch -vv -p"
```

```bash
# Bash / Zsh
alias gf='git fetch -vv -p'
```

---

### `gpb` — Sync Base Branches & Prune Stale Locals

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

### `stale-branches` — List Remote Branches by Age

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

### Workflow: Start of Day

```
$ gpb                    # sync everything, prune dead branches
$ stale-branches | tail  # check if any ancient branches need remote cleanup
$ gs my-feature          # start fresh work (see Module 4)
```

---

## Module 2: Worktree Management — Parallel Workspaces

Git worktrees let you check out multiple branches simultaneously in separate
directories — no stashing, no context-switching. These functions wrap
`git worktree` with smart defaults and safety checks.

### Layout

```
/work/tt/
├── tt-pos/              # main worktree (develop)
└── .worktrees/
    ├── pay-123/         # feature branch worktree
    └── hotfix-456/      # another parallel branch
```

---

### Helper Functions

`gw`, `gwa`, and `gwr` all share two utility functions. Define these first.

#### `__worktree_resolve_path` — Resolve Short Name to Full Path

Takes a worktree short name (e.g., `pay-123`) and resolves it to the full
filesystem path under `.worktrees/`. Also accepts absolute paths directly.

```fish
# Fish
function __worktree_resolve_path --description 'Resolve a worktree short name or path to a full path'
    set -l input $argv[1]
    if test -d "$input"
        realpath "$input"
        return
    end
    set -l main_worktree (git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    if test -z "$main_worktree"
        echo "$input"
        return 1
    end
    set -l candidate (dirname $main_worktree)/.worktrees/$input
    if test -d "$candidate"
        echo $candidate
        return
    end
    echo "$input"
    return 1
end
```

```bash
# Bash / Zsh
__worktree_resolve_path() {
    local input="$1"
    if [ -d "$input" ]; then realpath "$input"; return; fi
    local main_wt
    main_wt=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    [ -z "$main_wt" ] && { echo "$input"; return 1; }
    local candidate
    candidate="$(dirname "$main_wt")/.worktrees/$input"
    if [ -d "$candidate" ]; then echo "$candidate"; return; fi
    echo "$input"; return 1
}
```

#### `__worktree_show_context` — Display Worktree Status on Entry

Shows recent commits, working tree status, and any Claude TODO file when
switching into a worktree. Gives you immediate situational awareness.

```fish
# Fish
function __worktree_show_context --description 'Show recent commits, status, and TODO for a worktree'
    set -l wt_path $argv[1]
    echo "── Recent commits ──"
    git -C $wt_path log --oneline -5 2>/dev/null
    echo ""
    echo "── Status ──"
    git -C $wt_path status --short
    set -l todo_path $wt_path/.claude/TODO.md
    if test -f $todo_path
        echo ""
        echo "── TODO ──"
        if command -q bat
            bat --style=plain --paging=never $todo_path
        else
            cat $todo_path
        end
    end
end
```

```bash
# Bash / Zsh
__worktree_show_context() {
    local wt_path="$1"
    echo "── Recent commits ──"
    git -C "$wt_path" log --oneline -5 2>/dev/null
    echo ""
    echo "── Status ──"
    git -C "$wt_path" status --short
    local todo_path="$wt_path/.claude/TODO.md"
    if [ -f "$todo_path" ]; then
        echo ""
        echo "── TODO ──"
        cat "$todo_path"
    fi
}
```

---

### `gw [name]` — Switch to a Worktree

Without arguments, returns to the main worktree. With a name, resolves the
short name to the `.worktrees/` directory and shows context (recent commits,
status, TODO).

**Why?** Navigating between worktrees is just `cd`, but you lose context.
`gw` adds a brief status report so you immediately know where the branch
stands.

```fish
# Fish
function gw --description 'cd into a worktree of the current project'
    set main_worktree (git worktree list | head -1 | awk '{print $1}')
    if test -z "$argv[1]"
        cd $main_worktree
    else
        set -l target (__worktree_resolve_path $argv[1])
        or begin; echo "gw: worktree '$argv[1]' not found"; return 1; end
        cd $target
        __worktree_show_context $target
    end
end
```

```bash
# Bash / Zsh
gw() {
    local main_worktree
    main_worktree=$(git worktree list | head -1 | awk '{print $1}')
    if [ -z "$1" ]; then
        cd "$main_worktree"
    else
        local target
        target=$(__worktree_resolve_path "$1") || {
            echo "gw: worktree '$1' not found"; return 1
        }
        cd "$target"
        __worktree_show_context "$target"
    fi
}
```

---

### `gwa <name> [branch]` — Add a Worktree

Creates a worktree under `.worktrees/<name>` based on the latest base branch
(auto-detects develop/main/master). Includes safety checks:

- Detects stale directories from previous worktrees and offers cleanup
- Warns if a branch has unmerged commits before resetting it
- Auto-detects the correct base branch from a priority list

**Why?** Raw `git worktree add` requires remembering paths and base refs.
`gwa` standardizes the layout, prevents accidental data loss, and drops you
into the new worktree ready to work.

```fish
# Fish (abbreviated — full version is ~70 lines with all safety checks)
function gwa --description 'Add worktree in project .worktrees/'
    # See full implementation in git.fish
    # Key logic:
    #   1. Resolve main worktree path
    #   2. Check for stale dirs, prompt cleanup
    #   3. Auto-detect base: develop > main > master
    #   4. Create or reset branch at base ref
    #   5. git worktree add + cd into it
end
```

```bash
# Bash / Zsh
gwa() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "gwa: not in a git repository"; return 1
    fi
    [ $# -lt 1 ] && { echo "gwa: usage: gwa <name> [branch-name]"; return 1; }

    local dir_name="$1" branch_name="${2:-$1}"
    local main_worktree reset_ref
    main_worktree=$(git worktree list | head -1 | awk '{print $1}')
    local worktrees_dir="$(dirname "$main_worktree")/.worktrees"
    local target_path="$worktrees_dir/$dir_name"

    # Stale directory check
    if [ -e "$target_path" ]; then
        read -rp "gwa: stale directory '$dir_name' exists. Remove? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || { echo "gwa: aborted"; return 1; }
        rm -rf "$target_path"
    fi

    # Auto-detect base branch
    local current_branch
    current_branch=$(git branch --show-current)
    local known_bases=(develop development trunk main master)

    for base in "${known_bases[@]}"; do
        if [ "$current_branch" = "$base" ]; then
            reset_ref="origin/$base"; break
        fi
    done
    if [ -z "$reset_ref" ]; then
        for base in "${known_bases[@]}"; do
            if git rev-parse --verify --quiet "origin/$base" >/dev/null 2>&1; then
                reset_ref="origin/$base"; break
            fi
        done
    fi
    [ -z "$reset_ref" ] && { echo "gwa: no known base branch found"; return 1; }

    # Create or reset branch
    if git rev-parse --verify --quiet "$branch_name" >/dev/null 2>&1; then
        local ahead
        ahead=$(git rev-list --count "$reset_ref".."$branch_name")
        if [ "$ahead" -gt 0 ]; then
            echo "gwa: branch '$branch_name' has $ahead unmerged commit(s)"
            git log --oneline "$reset_ref".."$branch_name"
            return 1
        fi
        git branch -f "$branch_name" "$reset_ref"
        git worktree add "$target_path" "$branch_name"
    else
        git worktree add -b "$branch_name" "$target_path" "$reset_ref"
    fi || return 1

    cd "$target_path"
}
```

---

### `gwr [name]` — Remove a Worktree and Its Branch

Removes a worktree and deletes its branch. Shows context (commits, status)
before prompting for confirmation. Refuses to remove:
- The main worktree
- Protected branches (main, master, develop)
- Remote-tracking branches

**Why?** `git worktree remove` doesn't delete the branch, leaving ghosts.
`gwr` does both in one step with safety rails to prevent accidents.

```fish
# Fish (abbreviated)
function gwr --description 'Remove worktree and branch'
    # Resolves path, shows context, confirms, then:
    #   git worktree remove <path>
    #   git branch -D <branch>
end
```

```bash
# Bash / Zsh
gwr() {
    local worktree_path
    if [ -z "$1" ]; then
        worktree_path="$(pwd)"
    else
        worktree_path=$(__worktree_resolve_path "$1") || {
            echo "gwr: worktree '$1' not found"; return 1
        }
    fi

    local main_worktree
    main_worktree=$(git -C "$worktree_path" worktree list 2>/dev/null | head -1 | awk '{print $1}')
    [ "$worktree_path" = "$main_worktree" ] && {
        echo "gwr: refusing to remove the main worktree"; return 1
    }

    local branch
    branch=$(git -C "$worktree_path" branch --show-current)
    local protected=(main master develop development)
    for p in "${protected[@]}"; do
        [ "$branch" = "$p" ] && {
            echo "gwr: refusing to remove protected branch '$branch'"; return 1
        }
    done

    echo "── Worktree: $worktree_path ──"
    echo "Branch: $branch"
    git -C "$worktree_path" log --oneline -5
    git -C "$worktree_path" status --short

    read -rp "Remove this worktree and delete branch '$branch'? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "gwr: aborted"; return 1; }

    cd "$main_worktree"
    git worktree remove "$worktree_path"
    git branch -D "$branch"
}
```

---

### Workflow: Parallel Feature Work

```
$ gwa pay-789                  # create worktree + branch from develop
$ gw pay-789                   # switch to it (from anywhere)
  ── Recent commits ──         # automatic context shown
  abc1234 Initial scaffold
  ── Status ──
  M src/payments/service.py
# ... do work ...
$ gw                           # back to main worktree
$ gwr pay-789                  # done — clean up worktree + branch
```

---

### Tab Completion Scripts

Completions make these functions practical — you don't need to remember
worktree names, the shell suggests them for you.

#### Fish

Save each file to `~/.config/fish/completions/`.

**`gw.fish`** — completes with non-main worktree short names:

```fish
# ~/.config/fish/completions/gw.fish
complete -c gw -f \
    -a "(git worktree list 2>/dev/null | tail -n +2 | awk '{print \$1}' | awk -F/ '{print \$NF}')" \
    -d "worktree"
```

**`gwa.fish`** — arg 1: next sequential name + existing worktrees; arg 2: branch names:

```fish
# ~/.config/fish/completions/gwa.fish
function __gwa_next_name
    set main (git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    test -z "$main"; and return
    set project (basename $main)
    set worktrees_dir (dirname $main)/.worktrees
    set nums (ls $worktrees_dir 2>/dev/null | string match --groups-only -r -- "^$project-(\d+)\$")
    if test (count $nums) -gt 0
        set max (printf '%s\n' $nums | sort -n | tail -1)
    else
        set max 0
    end
    echo "$project-"(math $max + 1)
end

function __gwa_worktrees_reversed
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}' | tac
end

function __gwa_branches
    git branch --format='%(refname:short)' 2>/dev/null
end

# Arg 1: worktree directory name
complete -c gwa -f \
    -n "__fish_is_nth_token 1" \
    -a "(__gwa_next_name)" \
    -d "next worktree"

complete -c gwa -f \
    -n "__fish_is_nth_token 1" \
    -a "(__gwa_worktrees_reversed)" \
    -d "worktree"

# Arg 2: branch name (optional)
complete -c gwa -f \
    -n "__fish_is_nth_token 2" \
    -a "(__gwa_branches)" \
    -d "branch"
```

**`gwr.fish`** — completes with non-main worktree short names:

```fish
# ~/.config/fish/completions/gwr.fish
complete -c gwr -f \
    -a "(git worktree list 2>/dev/null | tail -n +2 | awk '{print \$1}' | awk -F/ '{print \$NF}')" \
    -d "worktree"
```

#### Bash

Add to `~/.bash_completion` or source from `~/.bashrc`. Uses the same
`git worktree list` parsing as the Fish versions.

```bash
# ~/.bash_completion.d/git-worktree-completions.bash

__worktree_short_names() {
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}'
}

__gwa_next_name() {
    local main project worktrees_dir max
    main=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    [ -z "$main" ] && return
    project=$(basename "$main")
    worktrees_dir="$(dirname "$main")/.worktrees"
    max=$(ls "$worktrees_dir" 2>/dev/null \
        | grep -oP "^${project}-\K\d+$" \
        | sort -n | tail -1)
    echo "${project}-$(( ${max:-0} + 1 ))"
}

_gw_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(__worktree_short_names)" -- "$cur") )
}

_gwa_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    case "$COMP_CWORD" in
        1)
            COMPREPLY=( $(compgen -W "$(__gwa_next_name) $(__worktree_short_names)" -- "$cur") )
            ;;
        2)
            local branches
            branches=$(git branch --format='%(refname:short)' 2>/dev/null)
            COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
            ;;
    esac
}

_gwr_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(__worktree_short_names)" -- "$cur") )
}

complete -F _gw_completions gw
complete -F _gwa_completions gwa
complete -F _gwr_completions gwr
```

#### Zsh

Add to `~/.zsh/completions/` and ensure `fpath` includes that directory.
Uses Zsh's `compadd` for completion.

```zsh
# ~/.zsh/completions/_gw
#compdef gw

__worktree_short_names() {
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}'
}

_gw() {
    local -a worktrees
    worktrees=( ${(f)"$(__worktree_short_names)"} )
    _describe 'worktree' worktrees
}

_gw "$@"
```

```zsh
# ~/.zsh/completions/_gwa
#compdef gwa

__worktree_short_names() {
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}'
}

__gwa_next_name() {
    local main project worktrees_dir max
    main=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    [ -z "$main" ] && return
    project=$(basename "$main")
    worktrees_dir="$(dirname "$main")/.worktrees"
    max=$(ls "$worktrees_dir" 2>/dev/null \
        | grep -oP "^${project}-\K\d+$" \
        | sort -n | tail -1)
    echo "${project}-$(( ${max:-0} + 1 ))"
}

_gwa() {
    case "$CURRENT" in
        2)
            local -a names worktrees
            names=( "$(__gwa_next_name)" )
            worktrees=( ${(f)"$(__worktree_short_names)"} )
            _describe 'worktree name' names worktrees
            ;;
        3)
            local -a branches
            branches=( ${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"} )
            _describe 'branch' branches
            ;;
    esac
}

_gwa "$@"
```

```zsh
# ~/.zsh/completions/_gwr
#compdef gwr

__worktree_short_names() {
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}'
}

_gwr() {
    local -a worktrees
    worktrees=( ${(f)"$(__worktree_short_names)"} )
    _describe 'worktree' worktrees
}

_gwr "$@"
```

> **Zsh setup:** Ensure your `fpath` includes the completions directory and
> `compinit` is called:
> ```zsh
> fpath=(~/.zsh/completions $fpath)
> autoload -Uz compinit && compinit
> ```

---

## Module 3: Rebase & Autosquash — Clean History

These functions make interactive rebase a daily habit instead of a
scary pre-merge chore. The key insight: **`fixup!` commits + autosquash
= painless history rewriting**.

### The Fixup Workflow

```
$ git commit -m "Enable payment routing"       # original commit
$ git commit -m "fixup! Enable payment routing" # fix for that commit
$ grda                                          # autosquash — fixup is absorbed
```

Git's `--autosquash` flag automatically reorders and squashes `fixup!` and
`squash!` commits into their targets. These aliases make that one keystroke.

---

### `grd` — Interactive Rebase onto origin/develop

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

### `grda` — Autosquash Rebase onto origin/develop (Non-Interactive)

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

### `grma` — Autosquash Rebase onto origin/main

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

### `gria` — Generic Autosquash Rebase

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

### `gri` — Bare Interactive Rebase

Plain interactive rebase — you provide the base. Use for full manual control.

```fish
# Fish
alias gri "git rebase --interactive"
```

```bash
# Bash / Zsh
alias gri='git rebase --interactive'
```

---

### `gra` / `grc` — Rebase Abort & Continue

When a rebase hits conflicts:

```fish
# Fish
alias gra "git rebase --abort"
alias grc "git rebase --continue"
```

```bash
# Bash / Zsh
alias gra='git rebase --abort'
alias grc='git rebase --continue'
```

---

### `grhu` — Reset to Upstream

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

### `gpf` — Safe Force Push

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

### Workflow: Clean Up Before Merge

```
$ gf                  # fetch latest
$ grda                # autosquash fixups onto develop
# resolve any conflicts...
$ grc                 # continue after resolving
$ gpf                 # force-push the clean history
```

---

## Module 4: Cleanup Utilities — Repo Hygiene

Small helpers for removing artifacts that clutter your working tree.

### `clean-orig` — Remove Merge Conflict Leftovers

After resolving merge conflicts, tools like `git mergetool` leave `.orig`
backup files. This removes them from both the filesystem and git tracking.

```fish
# Fish
function clean-orig
    find . -type f -name "*.orig" | xargs rm
    find . -type f -name "*.orig" | xargs git rm
end
```

```bash
# Bash / Zsh
clean-orig() {
    find . -type f -name "*.orig" -exec rm {} +
    find . -type f -name "*.orig" -exec git rm --ignore-unmatch {} +
}
```

---

### `clean-pyc` — Remove Compiled Python Files

Removes `.pyc` and `.pyo` bytecode files that can cause stale import issues.

```fish
# Fish
alias clean-pyc "find . -type f -name '*.py[co]' --delete"
```

```bash
# Bash / Zsh
alias clean-pyc="find . -type f -name '*.py[co]' -delete"
```

> **Tip:** Modern Python projects should have `__pycache__/` in `.gitignore`.
> This command is a safety net for when bytecode sneaks in.

---

### `commit-requirements` — Stage & Commit Lock Files

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

---

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
