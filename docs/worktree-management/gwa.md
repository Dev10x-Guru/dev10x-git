# `gwa <name> [branch]` — Add a Worktree

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

[Back to Worktree Management](index.md)
