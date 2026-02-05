# Task Execution Protocol

## Before Starting ANY Task

### 1. Check Learnings First
```
Read LEARNINGS.md for relevant past issues before executing.
```

If similar task failed before, apply the learned fix BEFORE attempting.

### 2. Verify Task Definition

Every task MUST have:
- [ ] Clear success criteria (what does "done" look like?)
- [ ] Input requirements (what do I need to start?)
- [ ] Output specification (what do I produce?)
- [ ] Verification method (how do I check it worked?)

If any are missing, ASK before proceeding.

### 3. Check Dependencies

- Does this task depend on another task's output?
- Is that dependency complete and verified?
- If not, complete dependency first OR flag blocker.

## During Execution

### Work Incrementally

1. Complete smallest verifiable unit
2. Test/verify that unit works
3. Save checkpoint if significant progress
4. Move to next unit
5. Repeat

**Never** do 500 lines of changes then test. Do 50 lines, test, continue.

### When Errors Occur

**Step 1: Categorize the failure**

| Type | Example | Action |
|------|---------|--------|
| Transient | Network timeout, rate limit | Retry with backoff (1s, 2s, 5s) |
| Permanent | Wrong API key, missing permission | STOP, alert human |
| Partial | 3 of 5 items processed | Save progress, decide: continue or rollback |

**Step 2: For transient failures**
```
Retry up to 3 times with exponential backoff.
If still failing after 3 attempts, escalate to permanent.
```

**Step 3: For permanent failures**
```
1. STOP execution
2. Document exact error in response
3. Suggest fix or ask for human input
4. Do NOT keep retrying the same thing
```

**Step 4: Log the learning**
```
After fixing ANY error, add to LEARNINGS.md:
- What failed
- Why it failed  
- How it was fixed
- How to prevent next time
```

### Checkpoints

Save state after completing:
- Each phase of a multi-phase task
- Any operation that took >2 minutes
- Before any destructive operation
- Before any external API call that can't be retried

**Checkpoint format:**
```markdown
## Checkpoint: [Task Name] - [Phase]
**Timestamp:** [ISO timestamp]
**Completed:**
- Step 1: [description] ✓
- Step 2: [description] ✓
**Next:** Step 3
**State:** [any important variables/data]
```

## Human Approval Gates

### ALWAYS require human approval for:
- Sending emails/messages
- Publishing content
- Deleting data
- Financial transactions
- Modifying permissions/access
- Deploying to production
- Any action marked "irreversible"

### How to request approval:
```
🛑 APPROVAL REQUIRED

Action: [what you want to do]
Reason: [why this needs to happen]
Risk: [what could go wrong]
Reversible: [yes/no]

Approve? [yes/no]
```

Wait for explicit "yes" before proceeding.

## After Task Completion

### 1. Verify Success Criteria
Run the verification method defined in the task.
Don't mark complete until verification passes.

### 2. Update Learnings
If anything unexpected happened, document it:
```markdown
## [Date] - [Task Name]
**Issue:** [what happened]
**Root cause:** [why]
**Fix:** [what solved it]
**Prevention:** [how to avoid next time]
```

### 3. Clean Up
- Remove temporary files
- Close connections
- Clear sensitive data from memory

## Parallel Execution Rules

When multiple tasks can run in parallel:
1. Verify they have NO shared dependencies
2. Each task gets isolated context
3. Merge results only after ALL complete
4. If one fails, decide: wait for others or abort all

## Context Management

### Watch context usage
- If approaching 70% context, consider compacting
- Summarize completed work before continuing
- Keep active context focused on current task

### Handoff between sessions
If task spans multiple sessions:
1. Write detailed state to checkpoint file
2. List exact next steps
3. Note any pending decisions
4. New session reads checkpoint first
