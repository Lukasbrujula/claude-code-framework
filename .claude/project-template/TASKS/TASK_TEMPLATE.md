# Task: [TASK_NAME]

**Status:** Pending | In Progress | Verified (criteria PROVEN in-session) | Complete
**Human Checkpoint:** None | Required (reason)
**Provenance:** [How/when this task originated + source to read for full context — retro, bug report, design doc, user request]

## Pillars

### 1. Model
<!-- haiku (simple) | sonnet (default) | opus (complex) -->
sonnet

### 2. Tools Required
- [ ] File ops (Read, Edit, Write)
- [ ] Bash: `[commands]`
- [ ] Search (Grep, Glob)
- [ ] Sub-agents (Task)

### 3. Guardrails
- Do NOT modify: [protected files]
- Do NOT skip: [tests, validation]

### 4. Knowledge
- [x] CLAUDE.md + LEARNINGS.md (always)
- [ ] Specific files: [list]

### 5. Success Criteria
- [ ] [Exact measurable check]
- [ ] Verification: `[command that returns 0 on success]`
- [ ] Evidence is PROVEN (command + output shown in-session), not a self-report; anything unprovable here is listed as NOT VERIFIED HERE
- [ ] Wiring: every behavior-affecting field this task adds is shown to change output, or explicitly marked DECORATIVE
- [ ] Vocabulary: external values the code matches against (enums, statuses, DB values) verified against the live source — note what was found and where

### 6. Dependencies
- [ ] Task [ID] must be complete
- [ ] None (can start immediately)

### 7. Failure Handling
Max attempts: 3
On failure: Save to `ERRORS/[task-name].md`, STOP.
Rollback: `git stash && git checkout HEAD~1`

### 8. Learning
Log to LEARNINGS.md if: unexpected error, workaround discovered, API behaved differently than documented.

---

## Description
<!-- One paragraph. Single outcome. -->

## Steps
1. [Step]
2. [Step]

## On Completion
- Commit: `[type]: [description]`
- Update: CLAUDE.md if new rule learned
