# Git Isolation

## One Canonical Checkout

Each project has exactly one canonical checkout where integration operations run: merge, push, release, migrations. Every other checkout — an IDE window, a second clone — is reference-only: read from it, never run state-changing git operations in it. If you're unsure which checkout is canonical, ask before pushing; don't guess.

## Worktree Per Lane

Every concurrent lane of work — a sub-agent that edits files, a parallel experiment, a second feature — gets its own worktree on its own branch:

```bash
git worktree add .worktrees/<lane> -b lane/<lane>
```

- Two lanes never share a working tree; shared uncommitted state is how lanes destroy each other's work.
- A lane commits to its own branch inside its worktree. Merging happens only in the canonical checkout.
- When a lane ends: merge or discard, then `git worktree remove .worktrees/<lane>`.
- Multi-agent dispatch: give every subagent explicit absolute paths to the intended checkout. A subagent relying on the working directory silently reads the wrong branch when worktrees are in play.

## Enforcement

A PreToolUse hook (settings.json) blocks `git merge` and `git push` to main/master from inside a linked worktree (detected via `.git` being a file). It cannot distinguish two full clones — designating the canonical checkout among clones is convention, so state which checkout you're in when reporting git operations.
