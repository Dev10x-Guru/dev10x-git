# dev10x-git

Git workflow utilities for keeping repositories clean, history readable,
and parallel work manageable. Functions and tab completions for
**Fish**, **Bash**, and **Zsh**.

## Installation

```sh
curl -LsSf https://brave-labs.github.io/dev10x-git/install.sh | sh
```

The installer auto-detects your shell and places functions + tab completions
in the right locations. To target a specific shell:

```sh
curl -LsSf https://brave-labs.github.io/dev10x-git/install.sh | sh -s fish
curl -LsSf https://brave-labs.github.io/dev10x-git/install.sh | sh -s bash
curl -LsSf https://brave-labs.github.io/dev10x-git/install.sh | sh -s zsh
```

Re-run any time to update.

## What's Included

| Category | Functions | Purpose |
|----------|-----------|---------|
| Branch Hygiene | `gpb`, `gf`, `stale-branches` | Sync bases, prune dead branches, audit remotes |
| Worktrees | `gw`, `gwa`, `gwr` | Create, switch, remove parallel workspaces |
| Rebase | `grd`, `grda`, `grma`, `gria`, `gri` | Interactive & autosquash rebase shortcuts |
| Safety | `gpf`, `grhu`, `gra`, `grc` | Force-push with lease, reset, abort/continue |
| Cleanup | `clean-orig`, `clean-pyc`, `commit-requirements` | Remove artifacts, commit lock files |

## Where Files Go

| Shell | Functions | Completions |
|-------|-----------|-------------|
| [Fish](src/fish/) | [`~/.config/fish/conf.d/dev10x-git.fish`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/fish/functions/git.fish) | [`~/.config/fish/completions/`](https://github.com/Brave-Labs/dev10x-git/tree/main/src/fish/completions) |
| [Bash](src/bash/) | [`~/.dev10x-git/git-utilities.bash`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/bash/git-utilities.bash) | [`~/.dev10x-git/git-completions.bash`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/bash/git-completions.bash) |
| [Zsh](src/zsh/) | [`~/.dev10x-git/git-utilities.zsh`](https://github.com/Brave-Labs/dev10x-git/blob/main/src/zsh/functions/git-utilities.zsh) | [`~/.zsh/completions/`](https://github.com/Brave-Labs/dev10x-git/tree/main/src/zsh/completions) |

## Documentation

See [docs/course.md](docs/course.md) for a 4-module walkthrough covering
each function family with rationale, usage examples, and workflows.

Website: [brave-labs.github.io/dev10x-git](https://brave-labs.github.io/dev10x-git)

## Customization

The `gs` function creates branches with a `janusz/` prefix. Edit the
installed file to use your own username:

```
git checkout -b yourname/$argv develop
```

The `gpb` function tries `master`, `main`, and `develop`. Remove branches
your repos don't use to silence harmless errors.

## License

MIT
