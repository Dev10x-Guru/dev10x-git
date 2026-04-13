# Module 3: Rebase & Autosquash — Clean History

These functions make interactive rebase a daily habit instead of a
scary pre-merge chore. The key insight: **`fixup!` commits + autosquash
= painless history rewriting**.

## The Fixup Workflow

```
$ git commit -m "Enable payment routing"       # original commit
$ git commit -m "fixup! Enable payment routing" # fix for that commit
$ grda                                          # autosquash — fixup is absorbed
```

Git's `--autosquash` flag automatically reorders and squashes `fixup!` and
`squash!` commits into their targets. These aliases make that one keystroke.

## Functions

| Function | Description |
|----------|-------------|
| [`grd`](grd.md) | Interactive rebase onto origin/develop |
| [`grda`](grda.md) | Autosquash rebase onto origin/develop (non-interactive) |
| [`grma`](grma.md) | Autosquash rebase onto origin/main |
| [`gria`](gria.md) | Generic autosquash rebase |
| [`gri`](gri.md) | Bare interactive rebase |
| [`gra` / `grc`](gra-grc.md) | Rebase abort & continue |
| [`grhu`](grhu.md) | Reset to upstream |
| [`gpf`](gpf.md) | Safe force push |

## Workflow: Clean Up Before Merge

```
$ gf                  # fetch latest
$ grda                # autosquash fixups onto develop
# resolve any conflicts...
$ grc                 # continue after resolving
$ gpf                 # force-push the clean history
```

---

[Back to course overview](../index.md)
