---
description: Ralph Wiggum mode - run tasks with fresh context per task. Token-efficient autopilot.
---

# Wiggum Command (Ralph Wiggum Mode)

Run project tasks with fresh context for each task. Maximum token efficiency and reliability.

## What Is Ralph Wiggum Mode?

Named after the "I'm in danger" meme - but inverted. Each task runs in isolation:
- Fresh context window (0 tokens carried over)
- Clean slate = no context pollution
- Failed task = clear rollback point
- Verified completion before proceeding

## How It Works

```
┌─────────────────────────────────────────┐
│ Terminal 1: Task 01                     │
│ /plan → execute → verify → commit       │
│ Mark complete → EXIT                    │
└─────────────────┬───────────────────────┘
                  ▼
┌─────────────────────────────────────────┐
│ Terminal 2: Task 02 (fresh context)     │
│ /next → /plan → execute → verify        │
│ Mark complete → EXIT                    │
└─────────────────┬───────────────────────┘
                  ▼
┌─────────────────────────────────────────┐
│ Terminal 3: Task 03 (fresh context)     │
│ /next → /plan → execute → verify        │
│ ... and so on                           │
└─────────────────────────────────────────┘
```

## Usage

### Manual Mode (Recommended for Learning)

```bash
# Terminal 1
cd my-project
claude
/next
# ... task runs, completes, you exit

# Terminal 2 (new window)
cd my-project
claude
/next
# ... picks up next task automatically
```

### Automated Mode (Shell Script)

```bash
# Run the wiggum automation script
~/bin/wiggum /path/to/project
```

The script loops:
1. Opens claude in project directory
2. Runs `/next`
3. Waits for completion
4. Checks if more tasks remain
5. If yes, opens new terminal and repeats
6. If human checkpoint needed, pauses for approval

## Why Fresh Context Per Task?

| Problem | Solution |
|---------|----------|
| Context window fills up | Reset to 0 each task |
| Old context pollutes decisions | Fresh read of CLAUDE.md |
| Hard to debug failures | Each task is isolated |
| Token costs accumulate | Pay only for current task |
| Hallucinations compound | Can't hallucinate what you don't remember |

## Task Completion Protocol

Before exiting each task:

1. **Verify** - Run success criteria check
2. **Commit** - `git add . && git commit -m "[type]: [task name]"`
3. **Update status** - Mark task as Complete in TASKS/
4. **Handoff notes** - Write minimal context for next task
5. **Exit** - Close terminal cleanly

## Human Checkpoints

When a task has `Human Checkpoint: REQUIRED`:

```
⏸️  HUMAN CHECKPOINT REQUIRED

Task: 02-database-schema.md
Type: Database migration

This task will:
- Create tables: appointments, patients, reminders
- Add indexes on patient_id, appointment_date
- Enable RLS policies

Proceed? (yes/no/review):
```

Options:
- `yes` - Continue with task
- `no` - Skip task, mark blocked
- `review` - Show full task details before deciding

## Recovery From Failure

If a task fails:

```bash
# Check what happened
git log --oneline -5
git diff

# Rollback if needed
git checkout HEAD~1

# Re-run the failed task
claude
/next  # Will pick up the failed task again
```

## State Files

All state persists in files (not memory):

```
TASKS/01-setup-project.md      # Status: Complete ✓
TASKS/02-database-schema.md    # Status: Complete ✓
TASKS/03-whatsapp-integration.md # Status: In Progress ← current
TASKS/04-booking-flow.md       # Status: Pending
```

## Related Commands

- `/kickoff` - Create project and tasks
- `/next` - Pick up next task
- `/plan` - Expand task into steps

## Shell Script Location

After setup: `~/bin/wiggum`

Run with: `wiggum /path/to/project`
