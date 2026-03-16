# Installation Guide

## Prerequisites

- [Claude Code](https://code.claude.com) installed (v2.1.59+)
- macOS, Linux, or Windows with WSL
- [Bun](https://bun.sh) or Node.js (for hooks)
- `~/bin` in your PATH: add `export PATH="$HOME/bin:$PATH"` to `~/.zshrc` or `~/.bashrc`

## Step 1: Clone and Install the Framework

```bash
git clone https://github.com/Lukasbrujula/claude-code-framework.git
cd claude-code-framework
chmod +x install.sh
./install.sh
```

This copies everything to `~/.claude/` where Claude Code reads it:

| Destination | Contents |
|-------------|----------|
| `~/.claude/rules/` | 2 rule files (auto-loaded every session, ~1,100 tokens) |
| `~/.claude/hooks/` | Shell scripts for lifecycle automation |
| `~/.claude/agents/` | 16 agents (loaded on-demand) |
| `~/.claude/skills/` | 39 skills (loaded on-demand) |
| `~/.claude/commands/` | 28 slash commands |
| `~/.claude/project-template/` | Templates for new projects |
| `~/bin/claude-init` | Project scaffolding script |
| `~/bin/wiggum` | Autopilot mode script |

## Step 2: Merge Settings

If you already have `~/.claude/settings.json`, the install won't overwrite it. You need to merge the hooks manually.

Check if you need to merge:

```bash
cat ~/.claude/settings.json
```

If it doesn't have a `"hooks"` section, run this to write a clean config (adjust the `enabledPlugins` and other fields to match your existing settings):

```bash
python3 -c "
import json, os
config = {
    'hooks': {
        'SessionStart': [{'matcher': '*', 'hooks': [{'type': 'command', 'command': 'bash ~/.claude/hooks/detect-project.sh 2>/dev/null || true'}]}],
        'PreToolUse': [{'matcher': 'Write|Edit|MultiEdit', 'hooks': [{'type': 'command', 'command': 'case \"\$TOOL_INPUT\" in *.env*|*package-lock.json*|*.git/*) echo BLOCKED >&2; exit 2;; esac'}]}],
        'PostToolUse': [{'matcher': 'Write|Edit|MultiEdit', 'hooks': [{'type': 'command', 'command': 'bun run format 2>/dev/null || npx prettier --write \"\$TOOL_INPUT\" 2>/dev/null || true'}]}],
        'Stop': [{'matcher': '*', 'hooks': [{'type': 'command', 'command': 'echo --- Session end check --- && (npx tsc --noEmit 2>&1 | tail -3 || true)'}]}]
    },
    'permissions': {
        'allow': ['bun run *', 'npm run *', 'npx tsc --noEmit', 'npx prettier *', 'git status', 'git diff *', 'git log *', 'git add *', 'git commit *', 'git push *', 'git stash *', 'git checkout *', 'git worktree *']
    }
}
path = os.path.expanduser('~/.claude/settings.json')
if os.path.exists(path):
    with open(path) as f:
        existing = json.load(f)
    existing.update(config)
    config = existing
with open(path, 'w') as f:
    json.dump(config, f, indent=2)
print('Settings written')
"
```

Verify:

```bash
python3 -c "import json; json.load(open('$HOME/.claude/settings.json')); print('Valid JSON')"
```

## Step 3: Install Plugins (Optional but Recommended)

Open Claude Code in any project (`claude` in terminal) and run:

```
# Context compression — saves 70-90% context on CLI output
/plugin marketplace add mksglu/context-mode
/plugin install context-mode@context-mode

# Persistent memory across sessions
/plugin marketplace add https://github.com/thedotmack/claude-mem.git
/plugin install claude-mem

# Reload to activate both
/reload-plugins
```

Then in a regular terminal (not Claude Code):

```bash
# Live documentation — stops hallucinated deprecated APIs
npx -y @anthropic-ai/claude-code mcp add context7 -- npx -y @upstash/context7-mcp@latest
```

## Step 4: Verify Installation

```bash
# Check rules are in place
ls ~/.claude/rules/
# Should show: core.md  hooks.md

# Check hooks are in place
ls ~/.claude/hooks/
# Should show: detect-project.sh

# Check agents
ls ~/.claude/agents/ | wc -l
# Should show: 16

# Check commands
ls ~/.claude/commands/ | wc -l
# Should show: 28

# Check settings are valid
python3 -c "import json; json.load(open('$HOME/.claude/settings.json')); print('Valid JSON')"
```

## Usage: Starting a New Project

```bash
mkdir my-project && cd my-project
claude-init          # Scaffolds CLAUDE.md, LEARNINGS.md, PROJECT_SCOPE.md, TASKS/
claude               # Open Claude Code
/kickoff             # Brain dump your idea — Claude structures it into tasks
```

## Usage: Running Autopilot

```bash
wiggum               # Runs all tasks sequentially with fresh context per task
```

## Usage: Manual Task Flow

```bash
claude               # Open Claude Code
/plan                # Plan before implementing
/verify              # Check build, types, lint, tests
/learn               # Extract reusable patterns from current session
/checkpoint          # Save progress state
```

## Updating

Pull the latest framework and re-run install:

```bash
cd claude-code-framework
git pull
./install.sh
```

Your `settings.json` won't be overwritten. Plugins persist independently.

## Uninstalling

```bash
rm -rf ~/.claude/rules ~/.claude/hooks ~/.claude/agents ~/.claude/skills ~/.claude/commands
rm -rf ~/.claude/project-template
rm ~/bin/claude-init ~/bin/wiggum
```

This doesn't touch your `settings.json`, plugins, or any project files.
