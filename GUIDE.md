# How This Framework Works

A personal Claude Code productivity system built on principles from Boris Cherny (creator of Claude Code, Anthropic) and optimized through real-world project experience. This guide explains the architecture, the token compression strategy, and how to use the system to its full potential.

---

## The Core Idea

Claude Code reads a `CLAUDE.md` file at the start of every session. Most people pack it with generic coding knowledge Claude already has — React patterns, Tailwind breakpoints, SEO rules. This wastes tokens before you even ask a question.

This framework flips the approach: **only load what Claude can't infer, and make the file get smarter over time.**

---

## Architecture: Four Layers

### Layer 1 — Rules (Auto-Loaded, ~1,100 tokens)

Two files in `~/.claude/rules/` that load on every Claude Code session:

- **core.md** — Task execution protocol, failure handling, git conventions, code quality standards, agent usage patterns. These are behavioral rules that prevent mistakes.
- **hooks.md** — Documents the installed hooks and available plugins. Serves as a reference so Claude knows what automation is running.

**Why only 2 files?** Boris Cherny's CLAUDE.md for the Claude Code repo itself is ~2,500 tokens. Our per-session overhead is under that. Every token spent on rules is a token unavailable for your actual work. The old version had 13 rule files totaling ~9,300 tokens — a 94% reduction.

### Layer 2 — Hooks (Automatic, Zero Tokens)

Hooks run outside Claude's context window. They don't consume tokens — they enforce quality silently:

| Hook | When | What It Does |
|------|------|-------------|
| **SessionStart** | Session opens | `detect-project.sh` reads `package.json`, `pyproject.toml`, `go.mod`, etc. and tells Claude what stack you're using |
| **PreToolUse** | Before file edits | Blocks writes to `.env`, `package-lock.json`, `.git/` — prevents accidental damage |
| **PostToolUse** | After file edits | Auto-runs Prettier/formatter on every changed file — catches the last 10% of formatting issues |
| **Stop** | Session ends | Runs `tsc --noEmit` to surface type errors before you walk away |

Hooks are the highest-ROI investment because they prevent mistakes without costing context.

### Layer 3 — Skills and Agents (On-Demand)

39 skills and 16 agents live in `~/.claude/skills/` and `~/.claude/agents/`. Claude only loads them when relevant — they don't consume tokens just by existing.

**Skills** are domain knowledge bundles (Next.js best practices, PostgreSQL patterns, security review checklists, design system guidelines). When Claude detects you're working on a Next.js project, it can pull in the `next-best-practices` skill. When you ask for a security review, it loads `security-review`.

**Agents** are specialized personas with specific instructions (planner, code-reviewer, tdd-guide, architect, database-reviewer). You invoke them via slash commands (`/plan`, `/code-review`, `/tdd`) or Claude spawns them as sub-agents for parallel work.

The old framework had 5 of these skills auto-loading as rules on every session (design-system, web-performance, SEO, compliance, patterns — ~4,000 tokens). Now they're skills, loaded only when actually needed.

### Layer 4 — Plugins (External Tools)

Three optional plugins extend Claude Code's capabilities:

**Context Mode** (`mksglu/context-mode`) — The biggest context saver. When Claude runs bash commands, reads files, or greps through code, the raw output can be massive (a `git log` might be 12KB, a test suite output 50KB). Context Mode intercepts these outputs, stores them in a local SQLite database with full-text search, and feeds Claude only a compressed summary (~100-300 bytes). Claude can retrieve specific details from the database when needed.

**claude-mem** (`thedotmack/claude-mem`) — Persistent memory across sessions. When you end a Claude Code session, insights are automatically extracted and stored. Next session, Claude searches past learnings before starting work. This is the automated version of manually maintaining LEARNINGS.md.

**Context7** (`@upstash/context7-mcp`) — Real-time documentation. Instead of Claude guessing at API signatures from training data (which may be outdated), it fetches the current docs for whatever library version you're using.

---

## How Token Compression Works

Claude Code has a ~200K token context window, but you burn through it faster than you'd think. Here's where tokens go and how each layer reduces waste:

### The Problem

| Source | Typical Cost | Example |
|--------|-------------|---------|
| System prompt + rules | 5,000–15,000 tokens | 13 rule files with CSS examples and HTML tutorials |
| Tool outputs (bash, read, grep) | 10,000–50,000 per command | `git log` output, test results, file contents |
| Conversation history | Grows continuously | Every message back and forth |
| Skill/agent instructions | 2,000–5,000 per activation | Loading a full security review checklist |

When the context fills up, Claude Code runs a "compaction" — it summarizes the conversation so far and drops the raw history. Each compaction loses nuance. After 2-3 compactions, Claude starts forgetting what you were working on.

### How Each Layer Helps

**Rules optimization (Layer 1):** Reduced from ~9,300 to ~1,100 tokens. Saves ~8,200 tokens every session — that's roughly 40 more back-and-forth messages before compaction.

**Hooks (Layer 2):** Zero token cost. The SessionStart detection hook means Claude doesn't waste turns asking "what framework are you using?" The PostToolUse formatter means Claude doesn't spend tokens noticing and fixing formatting inconsistencies.

**On-demand skills (Layer 3):** A skill like `web-performance` (1,353 words) only loads when you're doing performance work. In the old setup, it loaded every session whether you needed it or not.

**Context Mode plugin (Layer 4):** This is the biggest single saver for heavy coding sessions. Real benchmarks from the project:

| Tool Output | Raw Size | Compressed | Savings |
|-------------|----------|------------|---------|
| Playwright snapshot | 56 KB | 299 bytes | 99.5% |
| `gh issue list` | 59 KB | 1.1 KB | 98.1% |
| `git log` | 11.6 KB | 107 bytes | 99.1% |
| Full session total | 315 KB | 5.4 KB | 98.3% |

**Important caveat:** Context Mode only compresses built-in tool outputs (Bash, Read, Grep, WebFetch). Third-party MCP server responses (GitHub MCP, database MCPs) flow into context uncompressed.

**Net effect:** Sessions that used to hit compaction after 30 minutes can run 2-3 hours. You maintain higher accuracy because Claude retains more of the conversation in its original form.

---

## The Learning Loop

This is the most important concept in the framework. Everything else is optimization — this is what makes the system compound over time.

```
You notice Claude made a mistake
          ↓
You correct it and say: "Update CLAUDE.md so you don't make that mistake again"
          ↓
Claude's meta-rules kick in:
  - Writes ONE concise line in the Mistakes section
  - Format: "Do X, not Y" — max 15 words
  - Checks for duplicates first
  - Only adds project-specific gotchas, not generic knowledge
          ↓
Next session reads CLAUDE.md → mistake doesn't repeat
          ↓
Over weeks, the Mistakes section becomes a project-specific brain
```

### CLAUDE.md vs LEARNINGS.md

**CLAUDE.md** is the rule book — concise one-liners that Claude reads every session. Keep it under 200 lines. Example entries in the Mistakes section:

```
- Use ON/OFF for HA toggles, not Y/N
- FE category is "Y" (GIWL), not "8" (No-Lapse UL)
- Telnyx uses POST not PATCH for assistant updates
- Always run tsc --noEmit after changes
```

**LEARNINGS.md** is the journal — full context about what went wrong and why. It feeds rules into CLAUDE.md but doesn't load every session. Example:

```
### 2026-03-12 — Compulife HA toggle format
**What happened:** Health Analyzer returned wrong results for diabetic clients
**Root cause:** API uses ON/OFF strings, not Y/N booleans
**Fix:** Changed all HA toggle values to ON/OFF
**Rule for CLAUDE.md:** "Use ON/OFF for HA toggles, not Y/N"
```

### Cross-Session Memory (claude-mem)

The plugin automates parts of this loop. When a session ends, it extracts key learnings and stores them in a local database. Next session, it searches past learnings for relevant context. Think of it as an automated LEARNINGS.md that persists even if you don't manually write entries.

---

## Workflow: How to Use This Day-to-Day

### Starting a New Project

```bash
mkdir my-project && cd my-project
claude-init                    # Creates CLAUDE.md, LEARNINGS.md, PROJECT_SCOPE.md, TASKS/
claude                         # Open Claude Code
/kickoff                       # Brain dump your idea
```

`/kickoff` asks clarifying questions, recommends a tech stack, assesses compliance requirements, creates atomic tasks in `TASKS/`, and populates CLAUDE.md and PROJECT_SCOPE.md.

### Working on Tasks

**Manual mode** (you drive):
```
/plan                          # Plan before implementing (shift+tab twice for plan mode)
# ... review and approve the plan ...
# ... Claude implements ...
/verify                        # Check build, types, lint, tests
/learn                         # Extract reusable patterns
```

**Autopilot mode** (Claude drives):
```bash
wiggum                         # Runs tasks sequentially with fresh context per task
```

Wiggum reads CLAUDE.md for context, finds the next pending task, checks dependencies, runs `/plan`, implements, verifies, and moves to the next task. Human checkpoints pause for approval on risky operations (migrations, deployments, first-time API integrations).

### The 9 Pillars Task Template

Every task file in `TASKS/` includes:

1. **Model** — haiku (simple), sonnet (default), opus (complex)
2. **Tools Required** — what Claude needs access to
3. **Guardrails** — what NOT to do (protected files, forbidden operations)
4. **Knowledge** — files to read before starting
5. **Success Criteria** — how to verify the task is done
6. **Dependencies** — what must be complete first
7. **Failure Handling** — max retries, rollback strategy, escalation path
8. **Learning** — what to log if something unexpected happens

This structure means each task is self-contained. Claude can pick up any task with fresh context and know exactly what to do, what not to do, and how to verify its work.

### Parallel Execution

Independent tasks can run in parallel across multiple Claude Code sessions:

```bash
# Terminal 1
claude
/plan TASKS/03-api-endpoints.md

# Terminal 2
claude
/plan TASKS/04-ui-components.md
```

Use `git worktree` to give each session its own working directory:
```bash
claude --worktree feature-api
claude --worktree feature-ui
```

### Key Slash Commands

| Command | When to Use |
|---------|------------|
| `/kickoff` | Start a new project from a brain dump |
| `/plan` | Before any non-trivial implementation |
| `/next` | Pick up the next pending task (wiggum mode) |
| `/verify` | Validate build, types, lint, tests before committing |
| `/learn` | Extract reusable patterns from the current session |
| `/checkpoint` | Save or verify progress state |
| `/code-review` | Review code quality after implementation |
| `/build-fix` | Fix build errors systematically |
| `/tdd` | Test-driven development workflow |

---

## Tips for Getting the Most Out of It

**Invest in the plan.** Boris Cherny says the quality of the plan determines whether Claude can one-shot the implementation. Spend time in plan mode (shift+tab twice) iterating until the plan is solid. One team member at Anthropic has a second Claude review the plan as a "staff engineer" before implementation begins.

**Feed the Mistakes section.** Every correction you make and capture is a correction you never make again. After a month, your CLAUDE.md becomes a project-specific expert. After three months, Claude rarely makes project-specific errors.

**Use Opus with thinking.** It's slower per-response but faster overall because you steer less and it handles complexity better. The correction tax on cheaper models exceeds the compute savings.

**Don't over-customize.** Boris's own setup is "surprisingly vanilla." Claude Code works well out of the box. The framework adds structure around it — it doesn't replace Claude Code's core behavior.

**Keep CLAUDE.md under 200 lines.** Beyond that, instructions start competing with each other and compliance drops. If you need more context, use the `@path/to/file` import syntax or put it in a skill.
