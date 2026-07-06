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
- Deferring known-wrong behavior in this task → KNOWN_GAPS.md entry in the same commit, not at session end

### 4. Knowledge
- [x] CLAUDE.md + LEARNINGS.md (always)
- [ ] Specific files: [list]

### 5. Success Criteria
- [ ] [Exact measurable check]
- [ ] Verification: `[command that returns 0 on success]`
- [ ] Evidence is PROVEN (command + output shown in-session), not a self-report; anything unprovable here is listed as NOT VERIFIED HERE
- [ ] Wiring: every behavior-affecting field this task adds is shown to change output, or explicitly marked DECORATIVE
- [ ] Vocabulary: external values the code matches against (enums, statuses, DB values) verified against the live source — note what was found and where
- [ ] Scope: `git diff --name-only` matches the files this task expected to touch — extras get a rationale added here, or are reverted into their own task

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
1. Discovery: confirm the current shape/state of everything this task changes (persistence format, existing consumers) BEFORE writing code
2. [Step]

## On Completion
- Commit: `[type]: [description]`
- Update: CLAUDE.md if new rule learned
