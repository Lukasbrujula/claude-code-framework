# Core Rules

## Task Execution

- Read LEARNINGS.md before starting any task. If a similar task failed before, apply the learned fix first.
- Every task needs: clear success criteria, verification method, and rollback plan.
- Work incrementally: 50 lines → test → continue. Never 500 lines then test.
- After ANY correction: update CLAUDE.md or LEARNINGS.md so the mistake doesn't repeat.
- If something goes sideways mid-implementation: STOP and re-plan immediately.

## Failure Protocol

| Type | Example | Action |
|------|---------|--------|
| Transient | Network timeout, rate limit | Retry 3x with backoff (1s, 2s, 5s) |
| Permanent | Wrong API key, missing permission | STOP, log to ERRORS/, alert human |
| Partial | 3 of 5 items processed | Save progress, decide: continue or rollback |

Max 3 attempts per task. After that: save to `ERRORS/[task-name].md` and STOP.

## Human Approval Required

ALWAYS pause for approval before: database migrations, production deployments, destructive operations, sending emails/messages, financial/billing changes, security/permission changes, first-time API integrations.

## Git

Format: `<type>: <description>` — types: feat, fix, refactor, docs, test, chore, perf, ci
One logical change per commit. Use `git diff main...HEAD` for PR summaries.

## Code Quality

- Immutable: new objects, never mutate existing ones.
- Validate all inputs (Zod or equivalent). No hardcoded secrets. No console.log in commits.
- Functions < 50 lines, files < 800 lines. Catch every error with context.

## Agents

Use parallel sub-agents for independent work. When given a bug: fix it, don't ask for hand-holding.

## Context

If approaching 70% context, compact. Write state to checkpoint file when handing off sessions.
