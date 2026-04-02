# dev10x-git

Git workflow utilities for keeping repositories clean, history readable,
and parallel work manageable. Functions and tab completions for
**Fish**, **Bash**, and **Zsh**.

## What's Included

| Category | Functions | Purpose |
|----------|-----------|---------|
| Branch Hygiene | `gpb`, `gf`, `stale-branches` | Sync bases, prune dead branches, audit remotes |
| Worktrees | `gw`, `gwa`, `gwr` | Create, switch, remove parallel workspaces |
| Rebase | `grd`, `grda`, `grma`, `gria`, `gri` | Interactive & autosquash rebase shortcuts |
| Safety | `gpf`, `grhu`, `gra`, `grc` | Force-push with lease, reset, abort/continue |
| Cleanup | `clean-orig`, `clean-pyc`, `commit-requirements` | Remove artifacts, commit lock files |

## Quick Start

Pick your shell and follow the README in the corresponding directory:

```
src/
├── fish/          # Fish shell functions + completions
│   ├── README.md  # Installation instructions
│   ├── functions/
│   └── completions/
├── bash/          # Bash functions + completions
│   └── README.md
└── zsh/           # Zsh functions + completions
    ├── README.md
    ├── functions/
    └── completions/
```

### Fish (recommended — auto-discovery)

```fish
cp src/fish/functions/git.fish ~/.config/fish/conf.d/git.fish
cp src/fish/completions/*.fish ~/.config/fish/completions/
```

### Bash

```bash
echo 'source /path/to/src/bash/git-utilities.bash' >> ~/.bashrc
echo 'source /path/to/src/bash/git-completions.bash' >> ~/.bashrc
source ~/.bashrc
```

### Zsh

```zsh
echo 'source /path/to/src/zsh/functions/git-utilities.zsh' >> ~/.zshrc
mkdir -p ~/.zsh/completions
cp src/zsh/completions/_g* ~/.zsh/completions/
# Ensure ~/.zshrc has: fpath=(~/.zsh/completions $fpath) before compinit
exec zsh
```

## Documentation

See [docs/course.md](docs/course.md) for a 4-module walkthrough covering
each function family with rationale, usage examples, and workflows.

## Customization

The `gs` function creates branches with a `janusz/` prefix. Edit the function
to use your own username:

```
git checkout -b yourname/$argv develop
```

The `gpb` function tries `master`, `main`, and `develop`. Remove branches
your repos don't use to silence harmless errors.

## License

MIT
