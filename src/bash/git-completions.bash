# Tab completions for git worktree utilities (Bash)
# Source: ~/.bash_completion.d/git-worktree-completions.bash

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
