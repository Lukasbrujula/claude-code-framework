# Learnings

The single system of record for lessons in this project. CLAUDE.md's Mistakes section holds the distilled one-liners; this file holds full context. Auto-extracted stores (claude-mem, skills/learned/, instincts) are optional feeders — on any conflict, this file wins.

## Triggers — write the entry immediately, not at session end

1. The user corrects something you asserted or built.
2. A bug reaches runtime that a check could have caught.
3. An external system behaved differently than assumed (API, DB values, library, docs).
4. A "done" claim turned out to be false.

## Entry Format

```markdown
### [Date] — [Short title]  (seen: 1x)
**What happened:** One sentence.
**Root cause:** Why.
**Fix:** What solved it.
**Provenance:** How and when this was found + the source to read for full
context (ERRORS/ file, session, PR, log, file:line).
**Rule for CLAUDE.md:** "Do X, not Y" (copy this to the Mistakes section)
**Graduation:** none yet | proposed: [check] | GRADUATED → [path of check]
```

## Recurrence & Graduation

- On recurrence, increment `seen:` on the existing entry — never write a duplicate.
- At `seen: 2`, graduation is **mandatory**: the lesson becomes a deterministic check — an `eslint-rules/` rule, a `scripts/verify-*` script, a settings.json hook, or a CI gate — and the entry is marked `GRADUATED → <path>`. A lesson that recurs twice as prose is a failed lesson.
- If it genuinely cannot be machine-checked, record why in the entry. That is an explicit decision, not a default.
- Weekly: `/retro` reconciles this file against ERRORS/ and CLAUDE.md, detects recurrences, and forces pending graduations. A SessionStart hook nags when this file is 7+ days untouched.

---

<!-- Add learnings below -->
