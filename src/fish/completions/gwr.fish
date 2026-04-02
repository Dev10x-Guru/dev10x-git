complete -c gwr -f \
    -a "(git worktree list 2>/dev/null | tail -n +2 | awk '{print \$1}' | awk -F/ '{print \$NF}')" \
    -d "worktree"
