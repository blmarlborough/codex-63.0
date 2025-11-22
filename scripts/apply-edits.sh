#!/usr/bin/env bash
# Apply pussy-footing edits to Codex system prompts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../codex-rs/core" && pwd)"
TIMESTAMP=$(TZ=America/New_York date +'[ %j // %Y ] /// [ %H:%M ] EST')

echo -e "${YELLOW}=== Codex Prompt Edit Script ===${NC}"
echo "Target directory: $CORE_DIR"
echo "Timestamp: $TIMESTAMP"
echo

# Backup function
backup_file() {
    local file=$1
    if [ -f "$file" ] && [ ! -f "$file.orig" ]; then
        echo -e "${GREEN}Backing up${NC} $file → ${file}.orig"
        cp "$file" "$file.orig"
    fi
}

# Apply edits to gpt_5_1_prompt.md
apply_gpt_5_1_edits() {
    local file="$CORE_DIR/gpt_5_1_prompt.md"
    echo -e "${YELLOW}Applying edits to gpt_5_1_prompt.md...${NC}"

    backup_file "$file"

    # Edit 1: Personality
    sed -i 's/Your default personality and tone is concise, direct, and friendly.*/Your default personality is concise, direct, and decisive. Execute tasks efficiently. Report only critical blockers or completed milestones—do not narrate ongoing work./' "$file"

    # Edit 2: Autonomy
    sed -i 's/Persist until the task is fully handled end-to-end.*/Persist until the task is COMPLETELY handled end-to-end within the current turn. Do not stop at analysis or partial fixes—finish the job. The user will explicitly tell you if they want you to stop./' "$file"

    # Edit 3: Update spam (multi-line replacement requires more complex sed/awk)
    # This script assumes edits were already applied manually or via another tool

    echo -e "${GREEN}✓${NC} gpt_5_1_prompt.md edited"
}

# Apply edits to gpt-5.1-codex-max_prompt.md
apply_max_edits() {
    local file="$CORE_DIR/gpt-5.1-codex-max_prompt.md"
    echo -e "${YELLOW}Applying edits to gpt-5.1-codex-max_prompt.md...${NC}"

    backup_file "$file"

    # Edit 1: Personality
    sed -i 's/- Default: be very concise; friendly coding teammate tone./- Default: be concise, direct, and decisive./' "$file"

    echo -e "${GREEN}✓${NC} gpt-5.1-codex-max_prompt.md edited"
}

# Apply edits to prompt.md
apply_prompt_edits() {
    local file="$CORE_DIR/prompt.md"
    echo -e "${YELLOW}Applying edits to prompt.md...${NC}"

    backup_file "$file"

    # Edit 1: Personality
    sed -i 's/Your default personality and tone is concise, direct, and friendly.*/Your default personality is concise, direct, and decisive. Execute tasks efficiently. Report only critical blockers or completed milestones—do not narrate ongoing work./' "$file"

    # Edit 2: Imperative
    sed -i 's/Please keep going until the query is completely resolved/You MUST keep going until the query is completely resolved. Do not yield to the user until the problem is solved and validated. Persist through failures and blockers autonomously./' "$file"

    echo -e "${GREEN}✓${NC} prompt.md edited"
}

# Apply edits to gpt_5_codex_prompt.md
apply_gpt_5_codex_edits() {
    local file="$CORE_DIR/gpt_5_codex_prompt.md"
    echo -e "${YELLOW}Applying edits to gpt_5_codex_prompt.md...${NC}"

    backup_file "$file"

    # Edit 1: Personality
    sed -i 's/- Default: be very concise; friendly coding teammate tone./- Default: be concise, direct, and decisive./' "$file"

    echo -e "${GREEN}✓${NC} gpt_5_codex_prompt.md edited"
}

# Restore originals
restore_originals() {
    echo -e "${YELLOW}Restoring original prompts...${NC}"

    for file in "$CORE_DIR"/*.md.orig; do
        if [ -f "$file" ]; then
            target="${file%.orig}"
            echo -e "${GREEN}Restoring${NC} $target"
            cp "$file" "$target"
        fi
    done

    echo -e "${GREEN}✓${NC} All prompts restored to originals"
}

# Main script logic
case "${1:-apply}" in
    apply)
        echo "Applying all edits..."
        apply_gpt_5_1_edits
        apply_max_edits
        apply_prompt_edits
        apply_gpt_5_codex_edits
        echo
        echo -e "${GREEN}✓ All edits applied successfully${NC}"
        echo "Run 'cargo build --release' to rebuild Codex with edited prompts"
        ;;
    restore)
        restore_originals
        ;;
    *)
        echo "Usage: $0 {apply|restore}"
        echo "  apply   - Apply pussy-footing edits to system prompts"
        echo "  restore - Restore original prompts from .orig backups"
        exit 1
        ;;
esac
