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

"Log and continue" is only valid on a path explicitly designated non-critical, and the log level is error.

## Enforcement

- `scripts/verify-silent-failures.sh` greps for empty handlers — runs in `/verify` and CI.
- `eslint-rules/no-success-in-catch.js` blocks success shapes returned from catch blocks (JS/TS).
- Fallback-masking is not statically catchable — it is a named check in every code review of a critical path.
