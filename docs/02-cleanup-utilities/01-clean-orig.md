# `clean-orig` — Remove Merge Conflict Leftovers

After resolving merge conflicts, tools like `git mergetool` leave `.orig`
backup files. This removes them from both the filesystem and git tracking.

```fish
# Fish
function clean-orig
    find . -type f -name "*.orig" | xargs rm
    find . -type f -name "*.orig" | xargs git rm
end
```

```bash
# Bash / Zsh
clean-orig() {
    find . -type f -name "*.orig" -exec rm {} +
    find . -type f -name "*.orig" -exec git rm --ignore-unmatch {} +
}
```

---

[Back to Cleanup Utilities](index.md)
