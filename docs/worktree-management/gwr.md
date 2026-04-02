# `gwr [name]` — Remove a Worktree and Its Branch

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

[Back to Worktree Management](index.md)
