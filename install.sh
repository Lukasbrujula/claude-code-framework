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

# Copy bin scripts
cp "$SCRIPT_DIR/bin/claude-init" ~/bin/
cp "$SCRIPT_DIR/bin/wiggum" ~/bin/
chmod +x ~/bin/claude-init ~/bin/wiggum

success "Framework installed!"
echo ""
echo "Installed to:"
echo "  - ~/.claude/rules/"
echo "  - ~/.claude/agents/"
echo "  - ~/.claude/skills/"
echo "  - ~/.claude/commands/"
echo "  - ~/.claude/project-template/"
echo "  - ~/bin/claude-init"
echo "  - ~/bin/wiggum"
echo ""
echo "Make sure ~/bin is in your PATH:"
echo "  export PATH=\"\$HOME/bin:\$PATH\""
echo ""
