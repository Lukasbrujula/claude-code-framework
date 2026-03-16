---
name: task-decomposition
description: Methodology for breaking complex work into reliable, self-contained tasks with built-in quality assurance
version: 1.0.0
---

# Task Decomposition Methodology

A systematic approach to breaking down complex work into tasks that maximize success probability and enable reliable execution.

## Core Principles

### 1. Self-Contained Tasks
Each task should be completable without knowledge of other tasks. If a task requires understanding the full system to complete, it's too big.

### 2. Small Scope
**Target: 5-30 minutes per task.**
- If you think it'll take an hour, break it into 2-4 tasks
- If you can't estimate, you don't understand it well enough

### 3. Clear Boundaries
- Explicit inputs (what you need to start)
- Explicit outputs (what you produce)
- No hidden dependencies

### 4. Verifiable Completion
Every task needs a way to prove it's done. "It looks right" is not verification.

## Task Definition Schema

```yaml
task:
  # Identification
  id: "task-unique-id"           # kebab-case, descriptive
  name: "Human Readable Name"    # What someone sees in a list
  phase: "setup | core | integration | testing | deployment"
  
  # Description
  description: |
    What this task accomplishes and why it matters.
    Keep to 2-3 sentences.
  
  # Inputs - What you need to start
  inputs:
    - name: "config_file"
      type: "file"
      source: "user"              # user | previous_task | config | environment
      required: true
      description: "Configuration with API credentials"
    
    - name: "user_list"
      type: "array"
      source: "task-fetch-users"  # References another task's output
      required: true
  
  # Outputs - What you produce
  outputs:
    - name: "processed_data"
      type: "file"
      location: "/tmp/processed.json"
      description: "Cleaned and validated user data"
  
  # Success Criteria - How we know it's done
  success_criteria:
    - criterion: "File exists at output location"
      verification: "test -f /tmp/processed.json"
    
    - criterion: "All records have required fields"
      verification: "jq '.[] | select(.email == null)' /tmp/processed.json | wc -l  # Should be 0"
    
    - criterion: "No validation errors in log"
      verification: "grep -c 'VALIDATION_ERROR' /tmp/task.log  # Should be 0"
  
  # Dependencies - What must complete first
  dependencies:
    - task_id: "task-fetch-users"
      output_required: "user_list"
      type: "required"            # required | optional
    
    - task_id: "task-setup-database"
      type: "required"
  
  # Human Approval - Does someone need to sign off?
  requires_approval: false        # true for: sends, deletes, deploys, payments
  approval_reason: ""             # If true, explain why
  
  # Failure Handling
  failure_handling:
    retry_strategy: "exponential_backoff"  # none | immediate | exponential_backoff
    max_retries: 3
    retry_delays: [1000, 2000, 5000]        # milliseconds
    
    failure_categories:
      transient:                            # Retry these
        - "NETWORK_TIMEOUT"
        - "RATE_LIMITED"
        - "SERVICE_UNAVAILABLE"
      permanent:                            # Don't retry, escalate
        - "INVALID_CREDENTIALS"
        - "PERMISSION_DENIED"
        - "VALIDATION_FAILED"
    
    on_permanent_failure: "stop"            # stop | skip | rollback
    
    rollback_steps:
      - "Delete partial output file"
      - "Log failure with full context"
  
  # Metadata
  estimate: "15min"               # 5min | 15min | 30min
  risk: "low"                     # low | medium | high
  risk_notes: ""                  # If medium/high, explain
  
  # Learning
  check_learnings: true           # Should check LEARNINGS.md before starting
  relevant_learnings:             # Specific learnings to review
    - "api-rate-limits"
    - "data-validation-edge-cases"
```

## Task Breakdown Process

### Step 1: Start with the Goal
What does "done" look like? Write it down before anything else.

```markdown
Goal: User can upload a CSV and see it displayed in a table
Done when:
- Upload button visible on dashboard
- CSV files accepted (reject other types)
- Data displayed in sortable table
- Error shown if CSV is malformed
```

### Step 2: Identify Phases
Group work into logical phases that could be independently verified.

```markdown
Phases:
1. UI Setup (the upload button exists)
2. File Handling (CSV is received and parsed)
3. Data Display (table renders the data)
4. Error Handling (edge cases covered)
```

### Step 3: Break Each Phase into Tasks
Each task should be 5-30 minutes. If bigger, break it down.

```markdown
Phase 1: UI Setup
- Task 1.1: Create upload component (15min)
- Task 1.2: Add to dashboard layout (5min)
- Task 1.3: Style to match design system (10min)

Phase 2: File Handling
- Task 2.1: Add file input handler (10min)
- Task 2.2: Implement CSV parsing (20min)
- Task 2.3: Validate file type (10min)
- Task 2.4: Validate file size limit (5min)
...
```

### Step 4: Define Success Criteria for Each
How will you PROVE each task is done?

```markdown
Task 2.2: Implement CSV parsing
Success Criteria:
- Unit test passes with sample CSV
- Handles UTF-8 encoding
- Handles quoted fields with commas
- Returns structured array
Verification: npm test -- --grep "CSV parsing"
```

### Step 5: Map Dependencies
What must complete before each task can start?

```markdown
Task 2.2 depends on:
- Task 1.1 (upload component exists)
- No external dependencies

Task 3.1 depends on:
- Task 2.2 (parsed data available)
```

### Step 6: Identify Approval Gates
Which tasks have irreversible effects?

```markdown
Approval required:
- Task 5.3: Deploy to production
- Task 4.2: Send notification email
```

## Common Patterns

### Pattern: API Integration Task

```yaml
task:
  id: "integrate-payment-api"
  inputs:
    - name: "api_credentials"
      type: "object"
      source: "environment"
  outputs:
    - name: "payment_client"
      type: "module"
  success_criteria:
    - criterion: "Can create test charge"
      verification: "npm test -- --grep 'payment integration'"
    - criterion: "Handles API errors gracefully"
      verification: "npm test -- --grep 'payment error handling'"
  failure_handling:
    retry_strategy: "exponential_backoff"
    failure_categories:
      transient: ["RATE_LIMITED", "NETWORK_ERROR"]
      permanent: ["INVALID_KEY", "ACCOUNT_DISABLED"]
```

### Pattern: Database Migration Task

```yaml
task:
  id: "add-user-preferences-table"
  inputs:
    - name: "database_connection"
      source: "environment"
  outputs:
    - name: "migration_applied"
      type: "boolean"
  success_criteria:
    - criterion: "Table exists with correct schema"
      verification: "SELECT * FROM information_schema.tables WHERE table_name = 'user_preferences'"
    - criterion: "RLS policies active"
      verification: "SELECT * FROM pg_policies WHERE tablename = 'user_preferences'"
  failure_handling:
    on_permanent_failure: "rollback"
    rollback_steps:
      - "DROP TABLE IF EXISTS user_preferences"
      - "Revert migration file"
  requires_approval: true
  approval_reason: "Modifies production database schema"
```

### Pattern: UI Component Task

```yaml
task:
  id: "create-data-table-component"
  inputs:
    - name: "design_spec"
      source: "user"
    - name: "data_schema"
      source: "task-define-data-types"
  outputs:
    - name: "component_file"
      type: "file"
      location: "src/components/DataTable.tsx"
  success_criteria:
    - criterion: "Component renders without errors"
      verification: "npm test -- --grep 'DataTable renders'"
    - criterion: "Matches design spec"
      verification: "Manual visual inspection"
    - criterion: "Accessible (keyboard nav, screen reader)"
      verification: "npm run test:a11y -- DataTable"
```

## Anti-Patterns to Avoid

### ❌ Vague Success Criteria
```yaml
# BAD
success_criteria:
  - criterion: "Works correctly"
    verification: "Test it"

# GOOD
success_criteria:
  - criterion: "Returns 200 for valid input"
    verification: "curl -X POST /api/users -d '{...}' | jq '.status'"
  - criterion: "Returns 400 for invalid email"
    verification: "curl -X POST /api/users -d '{\"email\": \"invalid\"}' | jq '.status'"
```

### ❌ Hidden Dependencies
```yaml
# BAD - Assumes database is ready
task:
  id: "insert-test-data"
  dependencies: []  # Missing database setup!

# GOOD - Explicit dependency
task:
  id: "insert-test-data"
  dependencies:
    - task_id: "setup-test-database"
      type: "required"
```

### ❌ Oversized Tasks
```yaml
# BAD - Too big, too vague
task:
  id: "implement-user-authentication"
  estimate: "4 hours"

# GOOD - Broken down
tasks:
  - id: "auth-setup-provider"
    estimate: "20min"
  - id: "auth-create-login-page"
    estimate: "30min"
  - id: "auth-create-signup-page"
    estimate: "30min"
  - id: "auth-implement-session-handling"
    estimate: "25min"
  - id: "auth-add-protected-routes"
    estimate: "20min"
```

### ❌ Missing Failure Handling
```yaml
# BAD - What happens when it fails?
task:
  id: "call-external-api"
  # No failure handling!

# GOOD - Explicit failure handling
task:
  id: "call-external-api"
  failure_handling:
    retry_strategy: "exponential_backoff"
    max_retries: 3
    on_permanent_failure: "stop"
    rollback_steps:
      - "Log failure context"
      - "Alert monitoring"
```

## When to Use This Skill

Invoke this methodology when:
- Starting a new feature
- Refactoring existing code
- Planning a sprint
- Debugging task failures
- Onboarding someone to a project

**Remember**: Time spent on good task definition saves 3x time in execution. Ambiguity in the plan becomes bugs in the code.
