# Claude Code Framework

Personal Claude Code template system with autopilot mode.
Optimized following Boris Cherny's principles: every token earns its place.

## Philosophy

- **Rules are lean.** Only 2 auto-loaded rule files (~800 words). Generic knowledge lives in on-demand skills.
- **CLAUDE.md compounds.** Meta-rules teach Claude how to write rules for itself. Every correction makes the project smarter.
- **Hooks automate quality.** Format on edit, protect sensitive files, detect project type on start, type-check on stop.
- **Memory persists.** Optional plugins for cross-session learning (claude-mem, Context Mode).
- **Tasks are atomic.** 9 Pillars template with failure handling, rollback, and learning loops.

## Structure

```
.claude/
├── rules/              ← 2 files (auto-loaded every session, ~800 words total)
│   ├── core.md         ← Task execution, git, code quality, failure protocol
│   └── hooks.md        ← Hook config, permissions, optional plugins
├── hooks/              ← Shell scripts for lifecycle hooks
│   └── detect-project.sh  ← SessionStart: auto-detect runtime/framework/db/ui
├── agents/             ← 16 agents (on-demand)
├── skills/             ← All skills including former rules (on-demand)
├── commands/           ← Slash commands (/kickoff, /next, /verify, /wiggum)
├── settings.json.template  ← Hooks, permissions, preferences
└── project-template/
    ├── CLAUDE.md       ← Lean: stack, rules, mistakes, meta-rules
    ├── LEARNINGS.md    ← Full context → feeds back to CLAUDE.md
    ├── PROJECT_SCOPE.md
    ├── ERRORS/
    └── TASKS/
        └── TASK_TEMPLATE.md  ← 9 Pillars (trimmed)

bin/
├── claude-init         ← Initialize new project from template
└── wiggum              ← Ralph Wiggum autopilot mode
```

## Installation

```bash
./install.sh
```

After install, open Claude Code and optionally add plugins:

```bash
# Context compression (70-90% savings on CLI output)
/plugin marketplace add mksglu/context-mode
/plugin install context-mode@context-mode

# Persistent cross-session memory
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem

# Live documentation (stops hallucinated APIs)
npx -y @anthropic-ai/claude-code mcp add context7 -- npx -y @upstash/context7-mcp@latest
```

## Workflow

```bash
# 1. Create new project
mkdir my-idea && cd my-idea
claude-init

# 2. Brain dump with kickoff
claude
/kickoff

# 3. Run autopilot (optional)
wiggum
```

## What's Included

### Auto-Loaded Every Session (~1,350 tokens)

| File | Purpose |
|------|---------|
| `rules/core.md` | Task execution, failure protocol, git, code quality, agent usage |
| `rules/hooks.md` | Hook descriptions, permissions, optional plugins |

### Hooks (in settings.json)

| Hook | Trigger | What It Does |
|------|---------|-------------|
| `detect-project.sh` | SessionStart | Detects runtime, framework, DB, UI → suggests skills |
| File guard | PreToolUse | Blocks edits to `.env*`, `package-lock.json`, `.git/` |
| Auto-format | PostToolUse | Runs formatter after every Write/Edit |
| Type-check | Stop | Runs `tsc --noEmit` before session ends |

### The Learning Loop

```
Claude makes mistake
        ↓
You correct it → "Update CLAUDE.md so you don't make that mistake again"
        ↓
Meta-rules kick in → Claude writes ONE concise line in Mistakes section
        ↓
Next session reads the rule → mistake doesn't repeat
        ↓
Compound over weeks → Claude gets project-specific smart
```

### Key Commands

| Command | When |
|---------|------|
| `/kickoff` | Start new project from brain dump |
| `/plan` | Before any non-trivial implementation |
| `/next` | Pick up next pending task (wiggum mode) |
| `/verify` | Check build, types, lint, tests |
| `/learn` | Extract reusable pattern from current session |
| `/checkpoint` | Save/verify progress state |

## Optional Plugins

| Plugin | What It Does | Install |
|--------|-------------|---------|
| **Context Mode** | Compresses Bash/Read/Grep output by ~98%. Extends sessions 3-6x. Only built-in tools, not third-party MCPs. | `/plugin marketplace add mksglu/context-mode` |
| **claude-mem** | Persistent memory across sessions. Auto-captures via hooks. Web viewer UI. | `/plugin marketplace add thedotmack/claude-mem` |
| **Context7** | Real-time version-specific docs. Stops hallucinated deprecated APIs. | `mcp add context7 -- npx -y @upstash/context7-mcp@latest` |
| **memory-mcp** | Simpler alternative to claude-mem. Two-tier briefing system. | `memory-mcp init ~/Projects/my-app` |

## Token Budget

| Component | Before | After |
|-----------|--------|-------|
| Auto-loaded rules | ~9,300 tokens | ~1,100 tokens |
| CLAUDE.md template | ~200 tokens | ~300 tokens |
| **Per-session overhead** | **~9,500 tokens** | **~1,400 tokens** |

Boris Cherny's CLAUDE.md: ~2,500 tokens. This framework's overhead is well under that.
