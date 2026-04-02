# Bash

## Quick Install

```sh
curl -LsSf https://brave-labs.github.io/dev10x-git/install.sh | sh -s bash
```

## What Gets Installed

| File | Destination | Source |
|------|-------------|--------|
| Functions + aliases | `~/.dev10x-git/git-utilities.bash` | [`git-utilities.bash`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/bash/git-utilities.bash) |
| Tab completions | `~/.dev10x-git/git-completions.bash` | [`git-completions.bash`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/bash/git-completions.bash) |

The installer adds source lines to `~/.bashrc` automatically (idempotent —
won't duplicate on re-run). Run `source ~/.bashrc` or open a new terminal
to activate.

## File Layout

```
~/
├── .bashrc                             # source lines added here
└── .dev10x-git/
    ├── git-utilities.bash              # functions + aliases
    └── git-completions.bash            # tab completions
```
