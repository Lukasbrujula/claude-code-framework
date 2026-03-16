#!/bin/bash
# SessionStart hook: detect project type and inject context
# Place in ~/.claude/hooks/detect-project.sh
# Referenced by settings.json SessionStart hook

PROJECT_DIR="${PWD}"

detect_runtime() {
  if [ -f "$PROJECT_DIR/bun.lockb" ] || [ -f "$PROJECT_DIR/bunfig.toml" ]; then
    echo "bun"
  elif [ -f "$PROJECT_DIR/pnpm-lock.yaml" ]; then
    echo "pnpm"
  elif [ -f "$PROJECT_DIR/yarn.lock" ]; then
    echo "yarn"
  elif [ -f "$PROJECT_DIR/package-lock.json" ]; then
    echo "npm"
  elif [ -f "$PROJECT_DIR/Pipfile" ] || [ -f "$PROJECT_DIR/pyproject.toml" ]; then
    echo "python"
  elif [ -f "$PROJECT_DIR/go.mod" ]; then
    echo "go"
  elif [ -f "$PROJECT_DIR/Cargo.toml" ]; then
    echo "rust"
  else
    echo "unknown"
  fi
}

detect_framework() {
  if [ -f "$PROJECT_DIR/next.config.ts" ] || [ -f "$PROJECT_DIR/next.config.js" ] || [ -f "$PROJECT_DIR/next.config.mjs" ]; then
    echo "nextjs"
  elif [ -f "$PROJECT_DIR/nuxt.config.ts" ] || [ -f "$PROJECT_DIR/nuxt.config.js" ]; then
    echo "nuxt"
  elif [ -f "$PROJECT_DIR/svelte.config.js" ]; then
    echo "sveltekit"
  elif [ -f "$PROJECT_DIR/manage.py" ]; then
    echo "django"
  elif [ -f "$PROJECT_DIR/app.py" ] || [ -f "$PROJECT_DIR/main.py" ]; then
    echo "python-app"
  elif grep -q '"express"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "express"
  else
    echo "unknown"
  fi
}

detect_database() {
  if grep -rq "supabase" "$PROJECT_DIR/package.json" 2>/dev/null || [ -f "$PROJECT_DIR/supabase/config.toml" ]; then
    echo "supabase"
  elif grep -rq "prisma" "$PROJECT_DIR/package.json" 2>/dev/null || [ -d "$PROJECT_DIR/prisma" ]; then
    echo "prisma"
  elif grep -rq "drizzle" "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "drizzle"
  else
    echo "none-detected"
  fi
}

detect_ui() {
  if grep -rq "shadcn" "$PROJECT_DIR/package.json" 2>/dev/null || [ -f "$PROJECT_DIR/components.json" ]; then
    echo "shadcn"
  elif grep -rq "chakra" "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "chakra"
  elif grep -rq "mui" "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "mui"
  else
    echo "none-detected"
  fi
}

# Only run detection if package.json or equivalent exists
if [ -f "$PROJECT_DIR/package.json" ] || [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/go.mod" ] || [ -f "$PROJECT_DIR/Cargo.toml" ]; then
  RUNTIME=$(detect_runtime)
  FRAMEWORK=$(detect_framework)
  DATABASE=$(detect_database)
  UI=$(detect_ui)

  # Output summary for Claude's context (keep under 100 words)
  echo "Project detected: runtime=$RUNTIME framework=$FRAMEWORK database=$DATABASE ui=$UI"

  # Suggest relevant skills based on detection
  SKILLS=""
  case "$FRAMEWORK" in
    nextjs)  SKILLS="next-best-practices, frontend-patterns, shadcn-ui" ;;
    django)  SKILLS="django-patterns, django-tdd, django-security" ;;
    *)       SKILLS="" ;;
  esac

  case "$RUNTIME" in
    python)  SKILLS="$SKILLS python-patterns, python-testing" ;;
    go)      SKILLS="$SKILLS golang-patterns, golang-testing" ;;
  esac

  if [ -n "$SKILLS" ]; then
    echo "Suggested skills: $SKILLS"
  fi
fi
