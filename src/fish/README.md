# Fish Shell Installation

## Functions

Copy `functions/git.fish` to Fish's auto-load config directory:

```
cp functions/git.fish ~/.config/fish/conf.d/git.fish
```

Fish automatically sources all files in `~/.config/fish/conf.d/` on startup.
No manual sourcing or shell restart needed — open a new terminal tab.

## Completions

Copy completion files to Fish's completions directory:

```
cp completions/gw.fish  ~/.config/fish/completions/gw.fish
cp completions/gwa.fish ~/.config/fish/completions/gwa.fish
cp completions/gwr.fish ~/.config/fish/completions/gwr.fish
```

Fish auto-discovers completions from `~/.config/fish/completions/`.
Completions are loaded lazily when you first type the command and press Tab.

## File Layout

```
~/.config/fish/
├── conf.d/
│   └── git.fish          # all functions + aliases
└── completions/
    ├── gw.fish           # tab-complete worktree names for gw
    ├── gwa.fish          # tab-complete names + branches for gwa
    └── gwr.fish          # tab-complete worktree names for gwr
```
