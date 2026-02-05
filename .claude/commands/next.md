---
description: Pick up the next pending task in Ralph Wiggum mode. Reads project state, finds next task, runs /plan on it.
---

# Next Command

Continue to the next task with fresh context (Ralph Wiggum mode).

## What This Command Does

1. **Reads CLAUDE.md** for project context
2. **Scans TASKS/** for next pending task (by number order)
3. **Checks dependencies** are satisfied
4. **Checks for human checkpoint** requirement
5. **Runs /plan** on the task if ready

## Usage

```bash
# In a fresh terminal
claude

# Then run:
/next
```

## How It Works

```
/next
  │
  ├─→ Read CLAUDE.md (project context)
  ├─→ Read PROJECT_SCOPE.md (current phase)
  ├─→ Scan TASKS/*.md
  │     └─→ Find first task with Status: Pending
  │     └─→ Verify dependencies are Complete
  │
  ├─→ If Human Checkpoint required:
  │     └─→ Display task summary
  │     └─→ Ask: "Proceed with [task name]? (yes/no)"
  │
  └─→ Run /plan on the task
```

## Task Status Flow

```
Pending → In Progress → Verified → Complete
                │
                └─→ Failed → (retry/rollback/escalate)
```

## Output

```
# Next Task: 04-booking-flow.md

## Summary
Implement appointment booking flow via WhatsApp

## Dependencies
✓ 01-setup-project.md (Complete)
✓ 02-database-schema.md (Complete)
✓ 03-whatsapp-integration.md (Complete)

## Human Checkpoint
None - proceeding automatically

## Running /plan...
[plan output follows]
```

## If No Tasks Available

```
# All Tasks Complete! 🎉

## Summary
- Total tasks: 7
- Completed: 7
- Human checkpoints passed: 3

## What's Next
- Review the full implementation
- Run final tests: `npm test`
- Consider deployment checklist

## Learnings Captured
See LEARNINGS.md for issues encountered during build.
```

## Related Commands

- `/kickoff` - Start a new project (creates tasks)
- `/plan` - Expand specific task into steps
- `/wiggum` - Full autopilot mode

## Notes

- This command is designed for **fresh context** (new terminal)
- It reads all state from files, not memory
- Perfect for token-efficient, reliable execution
