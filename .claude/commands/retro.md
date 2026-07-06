# Retro Command

Weekly learning-loop checkpoint. Closes the loop: LEARNINGS.md → CLAUDE.md rule → machine-enforced check. Run weekly (a SessionStart hook reminds you when LEARNINGS.md has been untouched for 7+ days), or after any incident.

## Process

1. **Read the stores**: `LEARNINGS.md`, `ERRORS/`, and the Mistakes section of `CLAUDE.md`.

2. **Reconcile**: every LEARNINGS entry should have its one-liner in CLAUDE.md Mistakes; every ERRORS/ file from the past week should have a LEARNINGS entry. Create what's missing (with provenance). Then check `KNOWN_GAPS.md`: every entry past its resolution condition is escalated — fix now, renegotiate the condition explicitly with the user, or graduate to a blocking check. Overdue gaps never age silently.

3. **Detect recurrence**: for each entry, check whether the same mistake happened again this week (ERRORS/, git history, session memory). If so, increment its `seen:` count — do not write a duplicate entry.

4. **Graduate** — the step that makes this loop real:
   - Any entry at `seen: 2+` MUST become a deterministic check. A note that failed to prevent a second occurrence is not a mitigation.
   - Pick the cheapest layer that fully catches it:
     | Layer | Use when |
     |---|---|
     | `eslint-rules/` (or stack linter) | statically detectable code pattern |
     | `scripts/verify-*` | greppable/runnable invariant, any stack |
     | hook (settings.json) | must block a tool call at the moment it happens |
     | CI workflow | must block a merge |
   - Draft the check now, in this session. Mark the entry `GRADUATED → <path of check>`.
   - If it genuinely cannot be machine-checked, write why in the entry — that's an explicit decision, not a default.

5. **Prune**: consolidate near-duplicate entries; delete entries whose graduated check has been green for 30+ days AND whose one-liner adds nothing (the check now owns the lesson).

## Output

```
RETRO <date>
New entries reconciled: n
Recurrences found:      n
Graduated:              n  (list: entry → check path)
Cannot machine-check:   n  (list, with reason)
Gaps overdue:           n  (KNOWN_GAPS.md entries past their resolution condition)
Pruned:                 n
```

Each graduation is a file created in this session — link it. If nothing graduated and nothing recurred, say so in one line; don't manufacture work.
