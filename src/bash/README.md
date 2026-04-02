# Bash Installation

## Functions & Aliases

Source `git-utilities.bash` from your `~/.bashrc`:

```bash
# Add to ~/.bashrc
source /path/to/dev10x-git/src/bash/git-utilities.bash
```

Or copy it to a dedicated location and source from there:

```bash
cp git-utilities.bash ~/.bash_git_aliases
echo 'source ~/.bash_git_aliases' >> ~/.bashrc
```

Run `source ~/.bashrc` or open a new terminal to activate.

## Completions

Source `git-completions.bash` from your `~/.bashrc` (after the functions):

```bash
# Add to ~/.bashrc (after sourcing git-utilities.bash)
source /path/to/dev10x-git/src/bash/git-completions.bash
```

Or copy to the system completion directory if available:

```bash
cp git-completions.bash ~/.bash_completion.d/git-worktree-completions.bash
```

Bash loads files from `~/.bash_completion.d/` automatically if
`bash-completion` is installed. Check with `type _init_completion`.

## File Layout

```
~/
├── .bashrc                    # source both files here
├── .bash_git_aliases          # git-utilities.bash (functions + aliases)
└── .bash_completion.d/
    └── git-worktree-completions.bash  # tab completions
```
