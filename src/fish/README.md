# Fish Shell

## Quick Install

```sh
curl -LsSf https://brave-labs.github.io/dev10x-git/install.sh | sh -s fish
```

## What Gets Installed

| File | Destination | Source |
|------|-------------|--------|
| Functions + aliases | `~/.config/fish/conf.d/dev10x-git.fish` | [`git.fish`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/fish/functions/git.fish) |
| `gw` completion | `~/.config/fish/completions/gw.fish` | [`gw.fish`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/fish/completions/gw.fish) |
| `gwa` completion | `~/.config/fish/completions/gwa.fish` | [`gwa.fish`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/fish/completions/gwa.fish) |
| `gwr` completion | `~/.config/fish/completions/gwr.fish` | [`gwr.fish`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/fish/completions/gwr.fish) |

Fish auto-loads files from `conf.d/` and `completions/` — open a new
terminal tab to activate. No manual sourcing needed.

## File Layout

```
~/.config/fish/
├── conf.d/
│   └── dev10x-git.fish    # all functions + aliases
└── completions/
    ├── gw.fish            # tab-complete worktree names for gw
    ├── gwa.fish           # tab-complete names + branches for gwa
    └── gwr.fish           # tab-complete worktree names for gwr
```
