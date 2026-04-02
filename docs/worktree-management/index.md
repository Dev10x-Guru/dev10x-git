# Module 2: Worktree Management — Parallel Workspaces

Git worktrees let you check out multiple branches simultaneously in separate
directories — no stashing, no context-switching. These functions wrap
`git worktree` with smart defaults and safety checks.

## Layout

```
/work/tt/
├── tt-pos/              # main worktree (develop)
└── .worktrees/
    ├── pay-123/         # feature branch worktree
    └── hotfix-456/      # another parallel branch
```

## Functions

| Function | Description |
|----------|-------------|
| [Helper functions](helpers.md) | `__worktree_resolve_path` and `__worktree_show_context` |
| [`gw`](gw.md) | Switch to a worktree |
| [`gwa`](gwa.md) | Add a worktree |
| [`gwr`](gwr.md) | Remove a worktree and its branch |
| [Tab completions](completions.md) | Shell completions for Fish, Bash, and Zsh |

## Workflow: Parallel Feature Work

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

[Back to course overview](../index.md)
