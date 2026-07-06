# Known Gaps

The register of deliberate debt: behavior known to be wrong, missing, or unverified that is being shipped anyway. LEARNINGS.md holds closed loops (lessons); this file holds open ones.

## The Rule

The entry is written **at the moment of deferral, in the same commit** that ships or preserves the gap. "I am deliberately leaving X broken" recorded now costs one paragraph; the same gap re-discovered by a later audit costs a full investigation and arrives with no context — the audit cannot tell a known architectural decision from an accidental omission. A deferral that exists only in the author's head is not a deferral; it is a silent gap.

The commit message references the entry title.

## Entry Format

```markdown
### [Date] — [Short title]   (severity: launch-blocker | fix-before-milestone | accepted)
**What is wrong:** The behavior as it actually is. One sentence.
**Why deferred:** The scope decision. One sentence.
**Resolution condition:** What must happen, and before which milestone or date.
**Provenance:** Commit / task / PR that created or preserved the gap.
```

## How This File Is Consumed

- **/audit-wiring** reads it in Phase 0: known gaps are re-verified (still open?) and excluded from new-finding counts.
- **/retro** escalates every entry past its resolution condition: fix now, renegotiate the condition explicitly with the user, or graduate to a blocking check. Overdue gaps do not silently age.
- A `launch-blocker` entry still open at its milestone requires explicit user sign-off to proceed — it never lapses by default.
- `scripts/verify-temp-comments.sh` accepts `KNOWN_GAPS` as a valid tracking reference in TEMP/FIXME/HACK comments, so code-side markers can point here.

---

<!-- Add gaps below -->
