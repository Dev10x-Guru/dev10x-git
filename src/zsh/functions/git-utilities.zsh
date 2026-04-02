# Git Workflow Utilities for Zsh
# Source: ~/.zshrc or ~/.zsh_git_aliases

# ── Simple Aliases ──────────────────────────────────────────────
alias g='git'
alias gf='git fetch -vv -p'
alias gpf='git push origin --force-with-lease'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase --interactive'
alias grd='git rebase --interactive origin/develop'
alias grda='GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash origin/develop'
alias grma='GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash origin/main'
alias gria='GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash'
alias grhu='git reset --hard @{upstream}'
alias gsw='git switch'
alias gwl='git worktree list'
alias clean-pyc='find . -type f -name "*.py[co]" -delete'

# ── Branch Hygiene ──────────────────────────────────────────────

gpb() {
    git fetch -vv -p
    git checkout master && git pull
    git checkout main && git pull
    git checkout develop && git pull
    git branch -vv
    git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d
}

stale-branches() {
    git for-each-ref --sort=-committerdate \
        --format='%(committerdate:short) %(refname)' refs/remotes \
        | sed 's|refs/remotes/origin/||'
}

gs() {
    git checkout -b "janusz/$1" develop
}

# ── Worktree Helpers ────────────────────────────────────────────

__worktree_resolve_path() {
    local input="$1"
    if [ -d "$input" ]; then
        realpath "$input"
        return
    fi
    local main_wt
    main_wt=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    [ -z "$main_wt" ] && { echo "$input"; return 1; }
    local candidate
    candidate="$(dirname "$main_wt")/.worktrees/$input"
    if [ -d "$candidate" ]; then
        echo "$candidate"
        return
    fi
    echo "$input"
    return 1
}

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

# ── Worktree Management ────────────────────────────────────────

gw() {
    local main_worktree
    main_worktree=$(git worktree list | head -1 | awk '{print $1}')
    if [ -z "$1" ]; then
        cd "$main_worktree" || return 1
    else
        local target
        target=$(__worktree_resolve_path "$1") || {
            echo "gw: worktree '$1' not found"
            return 1
        }
        cd "$target" || return 1
        __worktree_show_context "$target"
    fi
}

gwa() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "gwa: not in a git repository"
        return 1
    fi
    [ $# -lt 1 ] && { echo "gwa: usage: gwa <name> [branch-name]"; return 1; }

    local dir_name="$1"
    local branch_name="${2:-$1}"
    local main_worktree reset_ref
    main_worktree=$(git worktree list | head -1 | awk '{print $1}')
    local worktrees_dir="$(dirname "$main_worktree")/.worktrees"
    local target_path="$worktrees_dir/$dir_name"

    # Stale directory check
    if [ -e "$target_path" ]; then
        local active_paths
        active_paths=$(git worktree list | awk '{print $1}')
        if echo "$active_paths" | grep -qx "$target_path"; then
            echo "gwa: '$dir_name' is an active worktree — use: cd $target_path"
            return 1
        fi
        read "confirm?gwa: stale directory '$dir_name' exists. Remove and recreate? [y/N] "
        [[ "$confirm" =~ ^[Yy]$ ]] || { echo "gwa: aborted"; return 1; }
        rm -rf "$target_path"
    fi

    # Auto-detect base branch
    local current_branch
    current_branch=$(git branch --show-current)
    local known_bases=(develop development trunk main master)

    for base in "${known_bases[@]}"; do
        if [ "$current_branch" = "$base" ]; then
            reset_ref="origin/$base"
            break
        fi
    done
    if [ -z "$reset_ref" ]; then
        for base in "${known_bases[@]}"; do
            if git rev-parse --verify --quiet "origin/$base" >/dev/null 2>&1; then
                reset_ref="origin/$base"
                break
            fi
        done
    fi
    [ -z "$reset_ref" ] && { echo "gwa: no known base branch found"; return 1; }

    # Create or reset branch
    if git rev-parse --verify --quiet "$branch_name" >/dev/null 2>&1; then
        local ahead
        ahead=$(git rev-list --count "$reset_ref".."$branch_name")
        if [ "$ahead" -gt 0 ]; then
            echo "gwa: branch '$branch_name' has $ahead unmerged commit(s):"
            git log --oneline "$reset_ref".."$branch_name"
            echo ""
            echo "To reuse:  git branch -D $branch_name && gwa $dir_name"
            echo "To resume: git worktree add $target_path $branch_name"
            return 1
        fi
        git branch -f "$branch_name" "$reset_ref"
        git worktree add "$target_path" "$branch_name"
    else
        git worktree add -b "$branch_name" "$target_path" "$reset_ref"
    fi || return 1

    cd "$target_path" || return 1
}

gwr() {
    local worktree_path
    if [ -z "$1" ]; then
        worktree_path="$(pwd)"
    else
        worktree_path=$(__worktree_resolve_path "$1") || {
            echo "gwr: worktree '$1' not found"
            return 1
        }
    fi

    local main_worktree
    main_worktree=$(git -C "$worktree_path" worktree list 2>/dev/null | head -1 | awk '{print $1}')
    if [ -z "$main_worktree" ]; then
        echo "gwr: '$worktree_path' is not inside a git repository"
        return 1
    fi
    if [ "$worktree_path" = "$main_worktree" ]; then
        echo "gwr: refusing to remove the main worktree '$main_worktree'"
        return 1
    fi

    local branch
    branch=$(git -C "$worktree_path" branch --show-current)
    local protected=(main master develop development)
    for p in "${protected[@]}"; do
        if [ "$branch" = "$p" ]; then
            echo "gwr: refusing to remove protected branch '$branch'"
            return 1
        fi
    done
    if [[ "$branch" == origin/* ]]; then
        echo "gwr: refusing to remove remote-tracking branch '$branch'"
        return 1
    fi

    echo "── Worktree: $worktree_path ──"
    echo "Branch: $branch"
    echo ""
    echo "Last 5 commits:"
    git -C "$worktree_path" log --oneline -5
    echo ""
    echo "Status:"
    git -C "$worktree_path" status --short
    echo ""

    read "confirm?Remove this worktree and delete branch '$branch'? [y/N] "
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "gwr: aborted"; return 1; }

    cd "$main_worktree" || return 1
    git worktree remove "$worktree_path"
    git branch -D "$branch"
}

# ── Cleanup Utilities ───────────────────────────────────────────

clean-orig() {
    find . -type f -name "*.orig" -exec rm {} +
    find . -type f -name "*.orig" -exec git rm --ignore-unmatch {} +
}

commit-requirements() {
    git add requirements/lock/*.txt
    git diff-index HEAD
    git diff-index --quiet HEAD || git commit -m "Requirements compiled by pip-compile"
}
