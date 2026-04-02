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
