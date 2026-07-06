# Boundary Typing

Several production bugs, one root: logic operating on flattened string representations where it needed structured data. A matching engine exact-matching display names that a new formatter changed; an expansion function injecting worst-case synonyms because its `string[]` signature couldn't carry the context that should have constrained them; a filtering feature blocked because the column it needed was free-form prose. The fix is structural, not vigilance.

## IDs for Logic, Strings for Display

- Any function that matches, branches, filters, or scores accepts **stable IDs** (or typed objects carrying them) — never display strings. Display strings are for rendering; they change format (casing, qualifiers, parentheticals) without warning, and each change silently breaks exact-matching downstream as a false negative.
- Enforce it in the signature where the stack allows: the parameter type is `EntityId[]`, not `string[]`. A convention is a hope; a signature is a wall.

## Flatten for Display ≠ Flatten for Logic

- A utility that collapses structured objects to a display string must never feed logic. Keep two functions with two return types: `...ForDisplay(): string` and `...ForLogic(): TypedInput` (IDs and context preserved). One flatten utility consumed by both rendering and logic is a defect, not a convenience.
- Expansion/synonym/normalization functions take context objects, not bare strings. A bare-string signature cannot filter by context it never receives — it will inject every variant unconditionally, including the ones the context should exclude.

## Structured at Rest

- If application logic will query, filter, parse, or match on a stored field, the storage type must enforce the shape: array, enum, join table, or schema-validated JSON — not free text. The schema-review question for every new column: "will code ever branch on this?" If yes, the type must make garbage unrepresentable.
- Scraped or LLM-produced data passes a validating normalization step before insert. Sentinel prose (`"NOT_FOUND"`) in a logic-bearing column is a schema bug, and it blocks the feature that needs the column long after the ingestion session is forgotten.

## Translation Tables Ship Complete or Gated

- A lookup table mapping external identifiers to internal ones is complete before the dependent feature ships, or the feature is gated OFF until it is.
- An unmapped value arriving at a live table is an error signal (rules/pipeline-boundaries.md) — never warn-and-drop. The dropped entry is invisible exactly when the external side grows.
- When the external key is ambiguous (two internal records share one external ID), use a compound key. A 1:1 map silently orphans the second mapping and no error ever fires.
- Write the completeness test: iterate the real external population, assert every entry maps. It fails on the day the external side adds a value, which is the day you want to know.

## Enforcement

Signature-level typing is the primary enforcement — the compiler rejects `string[]` where `EntityId[]` is expected. What types cannot catch: `/audit-wiring` traces flatten boundaries and table gaps; `scripts/verify-temp-comments.sh` catches the "TEMP mapping fallback" that outlives its intent; the rest is a named check in every code review of matching logic.
