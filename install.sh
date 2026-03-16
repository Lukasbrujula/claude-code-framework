#!/bin/bash

# Install Claude Code Framework
# Copies framework files to ~/.claude/ and ~/bin/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[install]${NC} $1"; }
success() { echo -e "${GREEN}[install]${NC} $1"; }
warn() { echo -e "${YELLOW}[install]${NC} $1"; }

# Create directories
mkdir -p ~/.claude
mkdir -p ~/bin

# Backup existing if present
if [ -d ~/.claude/rules ] || [ -d ~/.claude/agents ]; then
    warn "Existing ~/.claude/ content found"
    read -p "Overwrite? (yes/no): " response
    if [ "$response" != "yes" ] && [ "$response" != "y" ]; then
        echo "Aborted."
        exit 0
    fi
fi

log "Installing framework..."

# Copy .claude contents
cp -r "$SCRIPT_DIR/.claude/rules" ~/.claude/
cp -r "$SCRIPT_DIR/.claude/agents" ~/.claude/
cp -r "$SCRIPT_DIR/.claude/skills" ~/.claude/
cp -r "$SCRIPT_DIR/.claude/commands" ~/.claude/
cp -r "$SCRIPT_DIR/.claude/project-template" ~/.claude/

# Install hooks
mkdir -p ~/.claude/hooks
cp -r "$SCRIPT_DIR/.claude/hooks/"* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# Copy settings.json template if no existing settings
if [ ! -f ~/.claude/settings.json ]; then
    cp "$SCRIPT_DIR/.claude/settings.json.template" ~/.claude/settings.json
    success "Created ~/.claude/settings.json with hooks & permissions"
else
    warn "~/.claude/settings.json exists — review settings.json.template for hook examples"
fi

# Copy bin scripts
cp "$SCRIPT_DIR/bin/claude-init" ~/bin/
cp "$SCRIPT_DIR/bin/wiggum" ~/bin/
chmod +x ~/bin/claude-init ~/bin/wiggum

success "Framework installed!"
echo ""
echo "Installed to:"
echo "  ~/.claude/rules/        (2 files — auto-loaded every session)"
echo "  ~/.claude/hooks/        (SessionStart, PreToolUse, PostToolUse, Stop)"
echo "  ~/.claude/agents/       (on-demand when invoked)"
echo "  ~/.claude/skills/       (on-demand when needed)"
echo "  ~/.claude/commands/     (on-demand slash commands)"
echo "  ~/.claude/project-template/"
echo "  ~/.claude/settings.json (hooks & permissions)"
echo "  ~/bin/claude-init"
echo "  ~/bin/wiggum"
echo ""
echo "Make sure ~/bin is in your PATH:"
echo "  export PATH=\"\$HOME/bin:\$PATH\""
echo ""
echo -e "${BLUE}[optional]${NC} Install recommended plugins inside Claude Code:"
echo "  /plugin marketplace add mksglu/context-mode      # 70-90% context savings on CLI output"
echo "  /plugin install context-mode@context-mode"
echo ""
echo "  /plugin marketplace add thedotmack/claude-mem    # Persistent cross-session memory"
echo "  /plugin install claude-mem"
echo ""
echo "  npx -y @anthropic-ai/claude-code mcp add context7 -- npx -y @upstash/context7-mcp@latest  # Live docs"
echo ""
