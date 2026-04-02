# `gw [name]` — Switch to a Worktree

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

[Back to Worktree Management](index.md)
