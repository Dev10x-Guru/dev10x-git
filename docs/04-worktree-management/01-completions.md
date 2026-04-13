# Tab Completion Scripts

Completions make these functions practical — you don't need to remember
worktree names, the shell suggests them for you.

## Fish

Save each file to `~/.config/fish/completions/`.

**`gw.fish`** — completes with non-main worktree short names:

```fish
# ~/.config/fish/completions/gw.fish
complete -c gw -f \
    -a "(git worktree list 2>/dev/null | tail -n +2 | awk '{print \$1}' | awk -F/ '{print \$NF}')" \
    -d "worktree"
```

**`gwa.fish`** — arg 1: next sequential name + existing worktrees; arg 2: branch names:

```fish
# ~/.config/fish/completions/gwa.fish
function __gwa_next_name
    set main (git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    test -z "$main"; and return
    set project (basename $main)
    set worktrees_dir (dirname $main)/.worktrees
    set nums (ls $worktrees_dir 2>/dev/null | string match --groups-only -r -- "^$project-(\d+)\$")
    if test (count $nums) -gt 0
        set max (printf '%s\n' $nums | sort -n | tail -1)
    else
        set max 0
    end
    echo "$project-"(math $max + 1)
end

function __gwa_worktrees_reversed
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}' | tac
end

function __gwa_branches
    git branch --format='%(refname:short)' 2>/dev/null
end

# Arg 1: worktree directory name
complete -c gwa -f \
    -n "__fish_is_nth_token 1" \
    -a "(__gwa_next_name)" \
    -d "next worktree"

complete -c gwa -f \
    -n "__fish_is_nth_token 1" \
    -a "(__gwa_worktrees_reversed)" \
    -d "worktree"

# Arg 2: branch name (optional)
complete -c gwa -f \
    -n "__fish_is_nth_token 2" \
    -a "(__gwa_branches)" \
    -d "branch"
```

**`gwr.fish`** — completes with non-main worktree short names:

```fish
# ~/.config/fish/completions/gwr.fish
complete -c gwr -f \
    -a "(git worktree list 2>/dev/null | tail -n +2 | awk '{print \$1}' | awk -F/ '{print \$NF}')" \
    -d "worktree"
```

## Bash

Add to `~/.bash_completion` or source from `~/.bashrc`. Uses the same
`git worktree list` parsing as the Fish versions.

```bash
# ~/.bash_completion.d/git-worktree-completions.bash

__worktree_short_names() {
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}'
}

__gwa_next_name() {
    local main project worktrees_dir max
    main=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    [ -z "$main" ] && return
    project=$(basename "$main")
    worktrees_dir="$(dirname "$main")/.worktrees"
    max=$(ls "$worktrees_dir" 2>/dev/null \
        | grep -oP "^${project}-\K\d+$" \
        | sort -n | tail -1)
    echo "${project}-$(( ${max:-0} + 1 ))"
}

_gw_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(__worktree_short_names)" -- "$cur") )
}

_gwa_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    case "$COMP_CWORD" in
        1)
            COMPREPLY=( $(compgen -W "$(__gwa_next_name) $(__worktree_short_names)" -- "$cur") )
            ;;
        2)
            local branches
            branches=$(git branch --format='%(refname:short)' 2>/dev/null)
            COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
            ;;
    esac
}

_gwr_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(__worktree_short_names)" -- "$cur") )
}

complete -F _gw_completions gw
complete -F _gwa_completions gwa
complete -F _gwr_completions gwr
```

## Zsh

Add to `~/.zsh/completions/` and ensure `fpath` includes that directory.
Uses Zsh's `compadd` for completion.

```zsh
# ~/.zsh/completions/_gw
#compdef gw

__worktree_short_names() {
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}'
}

_gw() {
    local -a worktrees
    worktrees=( ${(f)"$(__worktree_short_names)"} )
    _describe 'worktree' worktrees
}

_gw "$@"
```

```zsh
# ~/.zsh/completions/_gwa
#compdef gwa

__worktree_short_names() {
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}'
}

__gwa_next_name() {
    local main project worktrees_dir max
    main=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    [ -z "$main" ] && return
    project=$(basename "$main")
    worktrees_dir="$(dirname "$main")/.worktrees"
    max=$(ls "$worktrees_dir" 2>/dev/null \
        | grep -oP "^${project}-\K\d+$" \
        | sort -n | tail -1)
    echo "${project}-$(( ${max:-0} + 1 ))"
}

_gwa() {
    case "$CURRENT" in
        2)
            local -a names worktrees
            names=( "$(__gwa_next_name)" )
            worktrees=( ${(f)"$(__worktree_short_names)"} )
            _describe 'worktree name' names worktrees
            ;;
        3)
            local -a branches
            branches=( ${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"} )
            _describe 'branch' branches
            ;;
    esac
}

_gwa "$@"
```

```zsh
# ~/.zsh/completions/_gwr
#compdef gwr

__worktree_short_names() {
    git worktree list 2>/dev/null | tail -n +2 | awk '{print $1}' | awk -F/ '{print $NF}'
}

_gwr() {
    local -a worktrees
    worktrees=( ${(f)"$(__worktree_short_names)"} )
    _describe 'worktree' worktrees
}

_gwr "$@"
```

> **Zsh setup:** Ensure your `fpath` includes the completions directory and
> `compinit` is called:
> ```zsh
> fpath=(~/.zsh/completions $fpath)
> autoload -Uz compinit && compinit
> ```

---

[Back to Worktree Management](index.md)
