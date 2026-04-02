# Git Workflow Utilities for Fish Shell
# Source: ~/.config/fish/conf.d/git.fish (auto-loaded by Fish)

# ── Simple Aliases ──────────────────────────────────────────────
alias g     git
alias gf    "git fetch -vv -p"
alias gpf   "git push origin --force-with-lease"
alias gra   "git rebase --abort"
alias grc   "git rebase --continue"
alias gri   "git rebase --interactive"
alias grd   "git rebase --interactive origin/develop"
alias grda  "GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash origin/develop"
alias grma  "GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash origin/main"
alias gria  "GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash"
alias grhu  "git reset --hard @{upstream}"
alias gsw   "git switch"
alias gwl   "git worktree list"

# ── Branch Hygiene ──────────────────────────────────────────────

function gpb --description 'Sync base branches and prune stale locals'
    git fetch -vv -p
    git checkout master; git pull
    git checkout main; git pull
    git checkout develop; git pull
    git branch -vv
    git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d
end

function stale-branches --description 'List remote branches sorted by last commit date'
    git for-each-ref --sort=-committerdate \
        --format='%(committerdate:short) %(refname)' refs/remotes \
        | sed 's|refs/remotes/origin/||'
end

function gs --wraps='git checkout' --description 'Create a prefixed branch from develop'
    git checkout -b janusz/$argv develop
end

# ── Worktree Helpers ────────────────────────────────────────────

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

# ── Worktree Management ────────────────────────────────────────

function gw --description 'cd into a worktree of the current project'
    set main_worktree (git worktree list | head -1 | awk '{print $1}')
    if test -z "$argv[1]"
        cd $main_worktree
    else
        set -l target (__worktree_resolve_path $argv[1])
        or begin
            echo "gw: worktree '$argv[1]' not found"
            return 1
        end
        cd $target
        __worktree_show_context $target
    end
end

function gwa --description 'Add worktree in project .worktrees/'
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "gwa: not in a git repository"
        return 1
    end

    if test (count $argv) -lt 1
        echo "gwa: usage: gwa <name> [branch-name]"
        return 1
    end

    set dir_name $argv[1]
    set branch_name $argv[2]
    set main_worktree (git worktree list | head -1 | awk '{print $1}')
    set worktrees_dir (dirname $main_worktree)/.worktrees
    set target_path $worktrees_dir/$dir_name

    if test -e $target_path
        set active_paths (git worktree list | awk '{print $1}')
        if contains -- $target_path $active_paths
            echo "gwa: '$dir_name' is an active worktree — use: cd $target_path"
            return 1
        end
        read -P "gwa: stale directory '$dir_name' exists. Remove and recreate? [y/N] " confirm
        if not string match --quiet --ignore-case 'y' $confirm
            echo "gwa: aborted"
            return 1
        end
        rm -rf $target_path
    end

    set -l reset_ref
    set -l known_bases develop development trunk main master
    set -l current_branch (git branch --show-current)

    if contains -- $current_branch $known_bases
        set reset_ref origin/$current_branch
    else
        for base in $known_bases
            if git rev-parse --verify --quiet origin/$base >/dev/null 2>&1
                set reset_ref origin/$base
                break
            end
        end
    end

    if test -z "$reset_ref"
        echo "gwa: no known base branch found (tried: $known_bases)"
        return 1
    end

    if test -z "$branch_name"
        set branch_name $dir_name
    end
    if git rev-parse --verify --quiet $branch_name >/dev/null 2>&1
        set -l ahead (git rev-list --count $reset_ref..$branch_name)
        if test "$ahead" -gt 0
            echo "gwa: branch '$branch_name' has $ahead unmerged commit(s):"
            git log --oneline $reset_ref..$branch_name
            echo ""
            echo "To reuse:  git branch -D $branch_name && gwa $dir_name"
            echo "To resume: git worktree add $target_path $branch_name"
            return 1
        end
        git branch -f $branch_name $reset_ref
        git worktree add $target_path $branch_name
    else
        git worktree add -b $branch_name $target_path $reset_ref
    end
    or return 1

    cd $target_path
end

function gwr --wraps='git worktree remove' --description 'Remove worktree and branch'
    if test -z "$argv[1]"
        set worktree_path (pwd)
    else
        set worktree_path (__worktree_resolve_path $argv[1])
        or begin
            echo "gwr: worktree '$argv[1]' not found"
            return 1
        end
    end

    set main_worktree (git -C $worktree_path worktree list 2>/dev/null | head -1 | awk '{print $1}')
    if test -z "$main_worktree"
        echo "gwr: '$worktree_path' is not inside a git repository"
        return 1
    end

    if test "$worktree_path" = "$main_worktree"
        echo "gwr: refusing to remove the main worktree '$main_worktree'"
        return 1
    end

    set worktree_paths (git -C $worktree_path worktree list | tail -n +2 | awk '{print $1}')
    if not contains -- $worktree_path $worktree_paths
        echo "gwr: '$worktree_path' is not a known worktree"
        echo "Known worktrees:"
        for wt in $worktree_paths
            echo "  $wt"
        end
        return 1
    end

    set branch (git -C $worktree_path branch --show-current)
    set protected main master develop development
    if contains -- $branch $protected
        echo "gwr: refusing to remove protected branch '$branch'"
        return 1
    end
    if string match --quiet 'origin/*' $branch
        echo "gwr: refusing to remove remote-tracking branch '$branch'"
        return 1
    end

    echo "── Worktree: $worktree_path ──"
    echo "Branch: $branch"
    echo ""
    echo "Last 5 commits:"
    git -C $worktree_path log --oneline -5
    echo ""
    echo "Status:"
    git -C $worktree_path status --short
    echo ""

    read -P "Remove this worktree and delete branch '$branch'? [y/N] " confirm
    if not string match --quiet --ignore-case 'y' $confirm
        echo "gwr: aborted"
        return 1
    end

    cd $main_worktree
    git worktree remove $worktree_path
    git branch -D $branch
end

# ── Cleanup Utilities ───────────────────────────────────────────

function clean-orig --description 'Remove .orig merge conflict artifacts'
    find . -type f -name "*.orig" | xargs rm
    find . -type f -name "*.orig" | xargs git rm
end

alias clean-pyc "find . -type f -name '*.py[co]' --delete"

function commit-requirements --description 'Stage and commit pip-compile lock files'
    git add requirements/lock/*.txt
    git diff-index HEAD
    git diff-index --quiet HEAD || git commit -m "Requirements compiled by pip-compile"
end
