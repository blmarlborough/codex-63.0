#!/usr/bin/env bash
# Validate that pussy-footing edits were applied correctly

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../codex-rs/core" && pwd)"
PASS=0
FAIL=0

echo -e "${YELLOW}=== Codex Prompt Validation ===${NC}"
echo "Checking for pussy-footing patterns in system prompts..."
echo

# Check function: looks for anti-patterns
check_pattern() {
    local file=$1
    local pattern=$2
    local description=$3

    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${RED}✗${NC} $description"
        echo "  Found in: $file"
        echo "  Pattern: $pattern"
        ((FAIL++))
        return 1
    else
        echo -e "${GREEN}✓${NC} $description"
        ((PASS++))
        return 0
    fi
}

# Check for presence of desired patterns
check_positive() {
    local file=$1
    local pattern=$2
    local description=$3

    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASS++))
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        echo "  Missing in: $file"
        echo "  Expected: $pattern"
        ((FAIL++))
        return 1
    fi
}

echo -e "${YELLOW}Checking for removed pussy-footing patterns:${NC}"
echo

# Check 1: Friendly tone removed
check_pattern "$CORE_DIR/gpt_5_1_prompt.md" "friendly coding teammate" \
    "No 'friendly coding teammate' in gpt_5_1_prompt.md"

check_pattern "$CORE_DIR/gpt-5.1-codex-max_prompt.md" "friendly coding teammate" \
    "No 'friendly coding teammate' in gpt-5.1-codex-max_prompt.md"

check_pattern "$CORE_DIR/gpt_5_codex_prompt.md" "friendly coding teammate" \
    "No 'friendly coding teammate' in gpt_5_codex_prompt.md"

# Check 2: "Please" weakening removed
check_pattern "$CORE_DIR/prompt.md" "Please keep going" \
    "No 'Please keep going' weak imperative in prompt.md"

# Check 3: Approval weaseling removed
check_pattern "$CORE_DIR/gpt_5_1_prompt.md" "weigh alternative paths that do not require approval" \
    "No approval weaseling in gpt_5_1_prompt.md"

check_pattern "$CORE_DIR/gpt-5.1-codex-max_prompt.md" "weigh alternative paths that do not require approval" \
    "No approval weaseling in gpt-5.1-codex-max_prompt.md"

# Check 4: Testing timidity removed
check_pattern "$CORE_DIR/gpt_5_1_prompt.md" "hold off on running tests or lint commands" \
    "No testing timidity in gpt_5_1_prompt.md"

check_pattern "$CORE_DIR/prompt.md" "hold off on running tests or lint commands" \
    "No testing timidity in prompt.md"

echo
echo -e "${YELLOW}Checking for added decisive patterns:${NC}"
echo

# Check 5: Decisive personality added
check_positive "$CORE_DIR/gpt_5_1_prompt.md" "concise, direct, and decisive" \
    "Decisive personality in gpt_5_1_prompt.md"

check_positive "$CORE_DIR/gpt-5.1-codex-max_prompt.md" "concise, direct, and decisive" \
    "Decisive personality in gpt-5.1-codex-max_prompt.md"

check_positive "$CORE_DIR/gpt_5_codex_prompt.md" "concise, direct, and decisive" \
    "Decisive personality in gpt_5_codex_prompt.md"

check_positive "$CORE_DIR/prompt.md" "concise, direct, and decisive" \
    "Decisive personality in prompt.md"

# Check 6: Strengthened imperatives
check_positive "$CORE_DIR/prompt.md" "You MUST keep going" \
    "Strong imperative in prompt.md"

check_positive "$CORE_DIR/gpt_5_1_prompt.md" "COMPLETELY handled end-to-end" \
    "End-to-end completion emphasis in gpt_5_1_prompt.md"

# Check 7: Direct approval instructions
check_positive "$CORE_DIR/gpt_5_1_prompt.md" "Do NOT ask in natural language" \
    "Direct approval instructions in gpt_5_1_prompt.md"

# Check 8: Proactive testing
check_positive "$CORE_DIR/gpt_5_1_prompt.md" "run tests proactively" \
    "Proactive testing in gpt_5_1_prompt.md"

check_positive "$CORE_DIR/prompt.md" "Run validation commands proactively" \
    "Proactive validation in prompt.md"

# Check 9: Shop mode variant exists
if [ -f "$CORE_DIR/shop_mode_prompt.md" ]; then
    echo -e "${GREEN}✓${NC} Shop mode variant created"
    ((PASS++))

    if grep -q "SHOP MODE VARIANT" "$CORE_DIR/shop_mode_prompt.md"; then
        echo -e "${GREEN}✓${NC} Shop mode header present"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} Shop mode header missing"
        ((FAIL++))
    fi
else
    echo -e "${RED}✗${NC} Shop mode variant not found"
    ((FAIL++))
fi

# Summary
echo
echo -e "${YELLOW}=== Validation Summary ===${NC}"
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo "System prompts have been successfully edited to remove pussy-footing patterns."
    exit 0
else
    echo -e "${RED}✗ Some validations failed${NC}"
    echo "Review the failed checks above and ensure all edits were applied correctly."
    exit 1
fi
