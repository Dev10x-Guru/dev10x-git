# Helper Functions

`gw`, `gwa`, and `gwr` all share two utility functions. Define these first.

## `__worktree_resolve_path` — Resolve Short Name to Full Path

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

## `__worktree_show_context` — Display Worktree Status on Entry

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

[Back to Worktree Management](index.md)
