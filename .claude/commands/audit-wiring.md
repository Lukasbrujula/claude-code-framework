---
description: Parallel read-only wiring audit — trace every field, flag, and state to its downstream consumer and classify it WIRED / PARTIAL / DECORATIVE / UNCLEAR. No code is written during the audit.
---

# Audit Wiring

A read-only, parallel audit of the product's surfaces, built around one question asked at every point:

> **Does changing this value produce a different observable outcome downstream?**

Not "does this code look correct" — that is code review, and code review misses this class of bug. A field can be typed, validated, and forwarded through five layers while nothing ever branches on it. The type checker verifies the wire, not whether anything is listening. Origin: a single overnight audit of exactly this shape surfaced 8 launch-blocking bugs that months of incremental development, passing type checks, and per-task success criteria never showed.

## When to Run

- **Mandatory before any first-customer, first-demo, or launch milestone.**
- After a multi-task arc merges — new data shapes have new consumers.
- Monthly pulse: `/audit-wiring pulse` — one agent, one surface, ~30 minutes total. The DECORATIVE count per pulse is the drift metric: trending to zero means the codebase is tightening; a spike after a release names the feature that introduced wiring gaps.

## Arguments

- (none) — full audit, all surfaces
- `pulse` — single surface with the most behavioral change since the last audit (state which and why)
- `<surface>` — audit one named surface

## Classifications

| Verdict | Meaning |
|---|---|
| **WIRED** | Changing the value provably changes output. Cite the branch point (file:line). |
| **PARTIAL** | Wired on some paths, dead on others (structured path reads it, boolean path drops it). Name both paths. |
| **DECORATIVE** | Collected, validated, forwarded — and nothing branches on it. On a behavior-critical path this is a launch blocker, not a cleanup item. |
| **UNCLEAR** | Consumption could not be established read-only (external system, dynamic dispatch). Never survives to the report as a hedge — see Phase 4. |

## Protocol

### Phase 0 — Anchor
1. Resolve which checkout and branch is being audited. Put the **absolute path** in every subagent prompt; never let a subagent rely on the working directory — with worktrees in play, CWD silently reads the wrong branch (rules/git-isolation.md).
2. Read `KNOWN_GAPS.md`. Known deferred gaps are **re-verified, not re-discovered**: confirm whether each is still open; do not count them as new findings.

### Phase 1 — Surface Inventory
Enumerate the product's surfaces: input forms/schemas, decision·matching·scoring engines, each API route, each async pipeline (save flows, webhook handlers, background jobs), and the UI consumers of response flags. List them in the report — an unlisted surface is an unaudited surface, silently.

### Phase 2 — Parallel Dispatch: One Read-Only Subagent Per Surface
Dispatch all surface agents concurrently, each restricted to read-only tools (Read/Grep/Glob — an agent type that cannot edit). Each agent:

- Traces every field, flag, and state on its surface end to end: where it enters, every transformation, and where it is consumed — or where consumption stops.
- Asks only the one question. No code-quality commentary, no refactoring notes, no fixes. **No code is written during the audit, by anyone.**
- Classifies every item, citing file:line for both the last point the value is carried and the point where it is (or is not) read.
- Checks the known kill zones explicitly:
  - **Error/failure flags in responses** (`*Failed`, `*Error`, status fields): who reads them? A flag the backend sets and no consumer surfaces is DECORATIVE — the failure it reports is invisible.
  - **Early-exit guards in persistence/pipeline code** (`if (!x) return;`): does the exit emit any signal, or does the record silently never exist? (rules/pipeline-boundaries.md)
  - **Flatten/serialize boundaries**: does a structured value collapse to a display string before the logic that needs the structure? (rules/boundary-typing.md)
  - **Comments delegating behavior to an external system** ("X handles the filtering"): UNCLEAR by definition unless dated test evidence exists (rules/verification.md, Delegated Behavior).
  - **Translation/lookup tables**: count entries against the expected external population; every gap and every ambiguous 1:1 key is a finding.

### Phase 3 — Cross-Cutting Synthesis
With all reports in, look across them for the same defect visible from multiple surfaces — a field DECORATIVE at intake *and* unread in the engine is one bug, double-confirmed, and the highest-confidence finding class. Group findings by shared root cause, not by surface.

### Phase 4 — Follow-Up Dispatch
Every UNCLEAR gets an immediate in-session probe where possible: live query, test request, log check. What cannot be resolved in-session is written up with the exact test that would resolve it and logged to `KNOWN_GAPS.md` or the task tracker. An UNCLEAR without a named resolution path is a failed audit item, not a hedge — synthesis on speculation produces "might be a problem" findings nobody triages.

### Phase 5 — Report and Feed the Loop
Write `.claude/AUDIT_WIRING_<date>.md`:

```
AUDIT WIRING <date>   (mode: full|pulse|<surface>, checkout: <abs-path> @ <branch>)
Surfaces audited:  n (list)
Items traced:      n
WIRED: n   PARTIAL: n   DECORATIVE: n   UNCLEAR resolved: n   UNCLEAR open: n
Known gaps re-verified: n still open / n resolved

FINDINGS (severity-ordered)
F-1 [DECORATIVE|PARTIAL|UNCLEAR] <item> — <surface>
    Evidence:   <file:line where carried> / <file:line where consumption stops>
    Impact:     <what is silently wrong for whom>
    Provenance: this audit, phase N, agent <surface>
```

Then close the loop:
- Every DECORATIVE/PARTIAL finding on a critical path becomes a task or `KNOWN_GAPS.md` entry **now**, at severity — not "noted".
- A finding whose *class* has appeared before: increment the LEARNINGS.md entry's `seen:` count. Graduation at `seen: 2` applies; the graduated check for a wiring bug is usually a parameterized test asserting that different values of the field produce different outputs.
- Subagent reports are CLAIMs (rules/verification.md). Before a launch-blocking finding enters the report, spot-check it against the cited file:line in the main lane.

## What This Command Is Not

Not a code review (`/code-review`), not a build/test gate (`/verify`), not a fix session. It answers exactly one question, in parallel, without touching code. Mixing in fixes or quality notes destroys the comparability of reports across surfaces — which is what makes Phase 3 work.
