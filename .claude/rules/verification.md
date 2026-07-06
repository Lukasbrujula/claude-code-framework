# Verification & Evidence

## PROVEN vs CLAIM

Every completion report and finding labels each statement as one of two kinds:

- **PROVEN** — a command ran in this session and its observable output is shown. Build exit code, test output, HTTP response, query result. Evidence = command + result, pasted.
- **CLAIM** — everything else: inference, memory, documentation, code that was written but never executed, "should work", and any agent's report of its own work.

Rules:
- "Done" requires PROVEN evidence for each success criterion. A CLAIM presented as done is a false report.
- A sub-agent's self-report is a CLAIM until the main lane re-runs the check or an independent reviewer confirms it against the artifact.
- Re-reading code you just wrote is inspection, not proof. Proof is execution.
- End every completion report with a `NOT VERIFIED HERE:` list (deploy behavior, external API contracts, cross-service effects). An empty list must be stated, not implied.

## Wiring-Completeness

Any field, flag, env var, config value, or parameter that is supposed to change behavior must be PROVEN to change output: toggle it, run, show the differing output. If that proof doesn't exist yet, mark the field **DECORATIVE (unwired)** in the task file and code review — never assume it is active. Applies especially to config objects passed to libraries, props threaded through layers, and feature flags.

When a change alters a data shape that has more than one consumer, the verification lists every consumer and proves semantic compatibility with each. Types passing is not compatibility: a casing or qualifier-format change breaks a string-matched consumer with no compile error — the task passes its own success criteria while silently breaking a consumer it never listed.

## External Vocabulary

Before writing code that string-matches or switches on values owned by an external system (DB column values, API enums, webhook event names, status strings):
1. Query the live source for the actual distinct values, or read the authoritative schema/docs for the exact version in use.
2. Record what was found and where — in the task file, and in a comment at the match site ("values verified against X, <date>").
3. Handle the unknown-value case explicitly; the vocabulary will grow.

Never match against a guessed value.

## Delegated Behavior

A comment asserting that an external system handles a responsibility ("the vendor filters by region", "the library dedupes") is a CLAIM, not a property of the code. It stands only with dated test evidence: a probe that fed the external system a case it should reject, plus the observed result, recorded at the comment site or in the task file. Without that, mark the site `UNVERIFIED ASSUMPTION` — `/audit-wiring` classifies these UNCLEAR, and each must be probed or logged to KNOWN_GAPS.md. This class of comment has shipped compliance-grade bugs: the assumed filtering did not exist anywhere.
