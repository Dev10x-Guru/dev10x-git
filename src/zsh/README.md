# Zsh

## Quick Install

```sh
curl -LsSf https://brave-labs.github.io/dev10x-git/install.sh | sh -s zsh
```

## What Gets Installed

| File | Destination | Source |
|------|-------------|--------|
| Functions + aliases | `~/.dev10x-git/git-utilities.zsh` | [`git-utilities.zsh`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/zsh/functions/git-utilities.zsh) |
| `gw` completion | `~/.zsh/completions/_gw` | [`_gw`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/zsh/completions/_gw) |
| `gwa` completion | `~/.zsh/completions/_gwa` | [`_gwa`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/zsh/completions/_gwa) |
| `gwr` completion | `~/.zsh/completions/_gwr` | [`_gwr`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/zsh/completions/_gwr) |

The installer adds `fpath` and source lines to `~/.zshrc` automatically
(idempotent — won't duplicate on re-run). Run `exec zsh` or open a new
terminal to activate.

## File Layout

```
~/
├── .zshrc                       # fpath + source lines added here
├── .dev10x-git/
│   └── git-utilities.zsh        # functions + aliases
└── .zsh/
    └── completions/
        ├── _gw                  # tab-complete worktree names for gw
        ├── _gwa                 # tab-complete names + branches for gwa
        └── _gwr                # tab-complete worktree names for gwr
```

## Notes

- Zsh completion files use `_commandname` naming (underscore prefix, no extension)
- The `#compdef` header on line 1 tells Zsh which command the file completes
- Zsh caches completions in `~/.zcompdump` — delete it and restart if
  completions don't appear after installation
