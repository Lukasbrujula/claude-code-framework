# Pipeline Boundaries

## Critical Paths Fail Loudly

A critical path (data write, payment, auth, pipeline stage, webhook handler) must never report success while swallowing a failure. At every boundary, a failure does one of exactly two things:

1. **Propagate** — rethrow or return an error so the caller sees a 500 / the pipeline halts, or
2. **Flag + alert** — return a result carrying an explicit error field AND emit an alerting event (error-level log to a monitored sink, metric, or alert). Both, not either.

Banned on critical paths, all stacks:
- Empty handlers: `catch {}`, `except: pass`, `.catch(() => {})`
- Log-and-proceed at info level, then returning a success shape
- Returning 200 / `{ success: true }` from a handler whose work partially failed
- Fallback values (empty array, null, defaults) that make an upstream failure look like "no data" with no error flag
- Silent early exits: a guard (`if (!record) return;`) that skips a critical write with no signal — the row never exists and nobody is told

"Log and continue" is only valid on a path explicitly designated non-critical, and the log level is error.

## Symmetric Coverage

When a flag or branch splits a critical path into parallel variants (with/without X, webhook vs. interactive), every branch gets the same failure behavior. The observed pattern: the primary path alerts on failure while the sibling path — added later, reviewed shallowly — console-logs and returns success. On any flag-gated path, audit both branches for identical propagate-or-flag+alert handling; asymmetry is accepted only when written down.

## Enforcement

- `scripts/verify-silent-failures.sh` greps for empty handlers — runs in `/verify` and CI.
- `eslint-rules/no-success-in-catch.js` blocks success shapes returned from catch blocks (JS/TS).
- Fallback-masking is not statically catchable — it is a named check in every code review of a critical path.
- Silent early exits and asymmetric branch coverage are also not statically catchable — `/audit-wiring` traces both (every early exit must emit a signal; every branch of a gated path must reach the alerting sink).
