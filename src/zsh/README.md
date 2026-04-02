# Zsh Installation

## Functions & Aliases

Source `functions/git-utilities.zsh` from your `~/.zshrc`:

```zsh
# Add to ~/.zshrc
source /path/to/dev10x-git/src/zsh/functions/git-utilities.zsh
```

Or copy to a dedicated location:

```zsh
cp functions/git-utilities.zsh ~/.zsh_git_aliases
echo 'source ~/.zsh_git_aliases' >> ~/.zshrc
```

## Completions

Copy completion files to a directory in your `fpath`:

```zsh
mkdir -p ~/.zsh/completions
cp completions/_gw  ~/.zsh/completions/_gw
cp completions/_gwa ~/.zsh/completions/_gwa
cp completions/_gwr ~/.zsh/completions/_gwr
```

Ensure your `~/.zshrc` includes the completions directory **before** `compinit`:

```zsh
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
```

After updating, run `exec zsh` or open a new terminal to pick up completions.

## File Layout

```
~/
├── .zshrc                     # source functions + set fpath
├── .zsh_git_aliases           # git-utilities.zsh (functions + aliases)
└── .zsh/
    └── completions/
        ├── _gw                # tab-complete worktree names for gw
        ├── _gwa               # tab-complete names + branches for gwa
        └── _gwr               # tab-complete worktree names for gwr
```

## Notes

- Zsh completion files are named `_commandname` (underscore prefix, no extension)
- The `#compdef` header on line 1 tells Zsh which command the file completes
- Zsh caches completions in `~/.zcompdump` — delete it and restart if
  completions don't appear after installation
