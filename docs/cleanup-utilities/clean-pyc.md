# `clean-pyc` — Remove Compiled Python Files

Removes `.pyc` and `.pyo` bytecode files that can cause stale import issues.

```fish
# Fish
alias clean-pyc "find . -type f -name '*.py[co]' --delete"
```

```bash
# Bash / Zsh
alias clean-pyc="find . -type f -name '*.py[co]' -delete"
```

> **Tip:** Modern Python projects should have `__pycache__/` in `.gitignore`.
> This command is a safety net for when bytecode sneaks in.

---

[Back to Cleanup Utilities](index.md)
