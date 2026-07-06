#!/usr/bin/env bash
# verify-temp-comments — TEMP/FIXME/HACK markers must reference a tracked item.
# Enforces rules/boundary-typing.md (translation-table fallbacks) and the
# deferred-gap rule (KNOWN_GAPS.md): a temporary workaround with no tracking
# reference is tech debt with no owner. "TEMP — remove after X verified"
# comments were observed to outlive their intent by months.
#
# Convention: every executable file matching scripts/verify-* is an invariant
# check. Exit 0 = pass, non-zero = fail. /verify and CI run all of them.
#
# A marker line passes if it also contains any of:
#   ABC-123 ticket id | #123 issue ref | TASKS/ path | KNOWN_GAPS
# Known limits (documented, not hidden): matches markers anywhere on a line,
# so an uppercase identifier containing a bare TEMP/HACK token false-positives
# (rare; rename it or add a reference); does not check whether the referenced
# ticket is still open.

set -u

SRC_DIRS=${SRC_DIRS:-"src app lib server api"}
MARKERS=${MARKERS:-"TEMP|FIXME|HACK"}   # set MARKERS="TEMP|FIXME|HACK|TODO" to require refs on TODOs too
REF_PATTERN='[A-Z][A-Z0-9]+-[0-9]+|#[0-9]+|TASKS/|KNOWN_GAPS'

fail=0
for dir in $SRC_DIRS; do
  [ -d "$dir" ] || continue
  hits=$(grep -rnIE "\b(${MARKERS})\b" "$dir" \
           --exclude-dir=node_modules --exclude-dir=vendor \
           --exclude-dir=dist --exclude-dir=build --exclude-dir=.next \
         | grep -vE "$REF_PATTERN")
  if [ -n "$hits" ]; then
    echo "FAIL: unreferenced marker(s) [${MARKERS}] in $dir/ — link a task, issue, or KNOWN_GAPS entry:"
    echo "$hits"
    echo ""
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "OK: every ${MARKERS} marker carries a tracking reference"
fi
exit "$fail"
