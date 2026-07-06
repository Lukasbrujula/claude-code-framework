#!/usr/bin/env bash
# verify-silent-failures — blocks empty error handlers on any stack.
# Enforces rules/pipeline-boundaries.md.
#
# Convention: every executable file matching scripts/verify-* is an invariant
# check. Exit 0 = pass, non-zero = fail. /verify and CI run all of them.
# When /retro graduates a recurring mistake, the check usually lands here.
#
# Known limits (documented, not hidden): catches single-line `except: pass`
# but not multi-line; catches empty catch blocks written on one line or with
# only whitespace; does NOT catch fallback values that mask failures — that
# stays a code-review check.

set -u

SRC_DIRS=${SRC_DIRS:-"."}
EXCLUDE_DIRS=(--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next)
fail=0

check() {
  local label="$1"; shift
  local hits
  hits=$("$@" 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "FAIL: $label"
    echo "$hits"
    echo ""
    fail=1
  fi
}

for dir in $SRC_DIRS; do
  [ -d "$dir" ] || continue

  # JS/TS: empty catch blocks — catch {} / catch (e) { }
  check "empty catch block in $dir/" \
    grep -rnE "${EXCLUDE_DIRS[@]}" 'catch[[:space:]]*(\([^)]*\))?[[:space:]]*\{[[:space:]]*\}' "$dir" \
      --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx'

  # JS/TS: swallowing promise rejections — .catch(() => {}) / .catch(function(){})
  check "empty .catch() handler in $dir/" \
    grep -rnE "${EXCLUDE_DIRS[@]}" '\.catch\([[:space:]]*(\([^)]*\)[[:space:]]*=>[[:space:]]*\{[[:space:]]*\}|function[[:space:]]*\([^)]*\)[[:space:]]*\{[[:space:]]*\})[[:space:]]*\)' "$dir" \
      --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx'

  # Python: single-line `except ...: pass`
  check "except-pass in $dir/" \
    grep -rnE "${EXCLUDE_DIRS[@]}" 'except[^:]*:[[:space:]]*pass[[:space:]]*(#.*)?$' "$dir" \
      --include='*.py'

  # Go: discarded errors — `_ = err` and `if err != nil { }` on one line
  check "discarded error in $dir/" \
    grep -rnE "${EXCLUDE_DIRS[@]}" '(^|[[:space:]])_[[:space:]]*=[[:space:]]*err\b|if err != nil \{[[:space:]]*\}' "$dir" \
      --include='*.go'
done

if [ "$fail" -eq 0 ]; then
  echo "OK: no silent failure handlers found"
fi
exit "$fail"
