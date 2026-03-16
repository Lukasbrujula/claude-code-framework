---
description: Transform a brain dump into a structured project. Recommends tech stack, populates CLAUDE.md, PROJECT_SCOPE.md, and creates atomic tasks with 9 pillars.
---

# Kickoff Command

Start a new project from an unstructured idea.

## What This Command Does

1. **Asks clarifying questions** about your idea
2. **Recommends tech stack** with reasoning (you don't need to know coding)
3. **Assesses compliance** requirements based on location/data
4. **Populates CLAUDE.md** with full project context
5. **Populates PROJECT_SCOPE.md** with phases and goals
6. **Creates atomic tasks** in TASKS/ with 9 pillars
7. **Flags tasks needing human approval** (migrations, deployments)

## Usage

```
/kickoff

I want to build a WhatsApp bot for dental clinics in Colombia.
Should handle appointment booking, send reminders, confirmations.
Patients should be able to reschedule. Need to track no-shows.
Not sure about tech stack - maybe Supabase? I've heard of n8n.
Timeline: want MVP in 2 weeks.
```

## What You'll Get

After answering a few questions, kickoff creates:

```
your-project/
├── CLAUDE.md           # Tech stack, structure, commands, compliance
├── PROJECT_SCOPE.md    # Vision, phases, risks, recommended agents
├── LEARNINGS.md        # Empty, ready for discoveries
└── TASKS/
    ├── 01-setup-project.md
    ├── 02-database-schema.md      # 🔒 Human checkpoint
    ├── 03-whatsapp-integration.md # 🔒 Human checkpoint (first API)
    ├── 04-booking-flow.md
    ├── 05-reminder-system.md
    ├── 06-testing.md
    └── 07-deployment.md           # 🔒 Human checkpoint
```

## After Kickoff

1. **Review** CLAUDE.md and PROJECT_SCOPE.md
2. **Adjust** if needed (tech stack, scope, etc.)
3. **Start first task**: `/plan` on Task 01
4. **Or go autopilot**: `/wiggum` to run all tasks with Ralph Wiggum mode

## Task Pillars

Every task includes:
1. Model (haiku/sonnet/opus)
2. Tools required
3. Guardrails (what NOT to do)
4. Knowledge (files to read)
5. Memory (instincts to load)
6. Success criteria (verification)
7. Dependencies (ordering)
8. Failure handling (retry/rollback/escalate)
9. Learning (what to log)

## Human Checkpoints

These task types automatically require approval:
- Database migrations
- Production deployments
- Destructive operations
- Security changes
- First-time API integrations
- Payment/billing changes

## Related Commands

- `/plan` - Expand a specific task into detailed steps
- `/next` - Pick up next pending task (for Ralph Wiggum mode)
- `/wiggum` - Run full autopilot with fresh context per task

## Invokes

This command uses the `kickoff` agent at `~/.claude/agents/kickoff.md`
