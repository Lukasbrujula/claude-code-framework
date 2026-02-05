# Claude Code Framework

Personal Claude Code template system with autopilot mode.

## Structure

```
.claude/
├── rules/              ← Global rules (auto-loaded)
├── agents/             ← All agents including kickoff
├── skills/             ← All skills
├── commands/           ← Slash commands (/kickoff, /next, /wiggum)
└── project-template/   ← Template for new projects
    ├── CLAUDE.md
    ├── LEARNINGS.md
    ├── PROJECT_SCOPE.md
    ├── ERRORS/
    └── TASKS/
        └── TASK_TEMPLATE.md

bin/
├── claude-init         ← Initialize new project from template
└── wiggum              ← Ralph Wiggum autopilot mode
```

## Installation

```bash
./install.sh
```

Or manually:
```bash
cp -r .claude/* ~/.claude/
cp bin/* ~/bin/
chmod +x ~/bin/claude-init ~/bin/wiggum
```

## Workflow

```bash
# 1. Create new project
mkdir my-idea && cd my-idea
claude-init

# 2. Brain dump with kickoff
claude
/kickoff

# 3. Run autopilot (optional)
wiggum
```

## Features

- **9 Pillars Task Template**: Each task includes context, knowledge, memory, success criteria, dependencies, failure handling, and learning loops
- **Max 3 Retries**: Failed tasks saved to ERRORS/ after 3 attempts
- **Human Checkpoints**: Pause for approval on risky operations
- **Fresh Context**: Each task runs with clean context window
- **Skill Scanning**: /kickoff recommends best agents/skills for your project
