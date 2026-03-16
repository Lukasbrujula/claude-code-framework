# Hooks & Permissions

## Installed Hooks (configured in settings.json)

### SessionStart
- **Project detection**: Runs `detect-project.sh` — auto-identifies runtime, framework, database, UI library, and suggests relevant skills.

### PreToolUse
- **File protection**: Blocks edits to `.env*`, `package-lock.json`, `.git/`. Exit code 2 = hard block.

### PostToolUse
- **Auto-format**: Runs formatter after every Write/Edit/MultiEdit.

### Stop
- **Type-check**: Runs `tsc --noEmit` at session end to catch errors before you leave.

## Pre-Allowed Commands

Set via `/permissions` to avoid unnecessary prompts:
- Build/dev/test: `bun run *`, `npm run *`
- Git: `git status`, `git diff`, `git log`, `git add`, `git commit`, `git push`, `git stash`, `git worktree`
- Type-check: `tsc --noEmit`, `prettier`

Never use `--dangerously-skip-permissions` outside sandboxed environments.

## Optional Plugins

- **Context Mode**: `/plugin marketplace add mksglu/context-mode` — compresses Bash/Read/Grep output by ~98%. Only works for built-in tools, not third-party MCPs.
- **claude-mem**: `/plugin marketplace add thedotmack/claude-mem` — persistent memory across sessions with auto-capture via hooks.
- **Context7**: `npx -y @anthropic-ai/claude-code mcp add context7 -- npx -y @upstash/context7-mcp@latest` — fetches real-time, version-specific docs instead of hallucinating deprecated APIs.
