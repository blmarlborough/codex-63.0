# Validation Scenarios for Edited Prompts

Test scenarios to validate that autonomous behavior improvements work correctly without breaking core functionality.

## Scenario 1: Simple Bug Fix (No Tests Needed)

**Task**: Fix a simple typo in a comment or documentation

**Before (Timid Behavior)**:
- Multiple interruptions: "I'll start by reading the file...", "Now I'll make the edit...", "Let me verify..."
- Asks if user wants validation
- Suggests next steps without taking action

**After (Decisive Behavior)**:
- Single initial message: "Fixing typo in file X"
- Executes: Read → Edit → Done
- Reports only completion

**Test Command**:
```bash
echo "Please fix the typo in line 5 of test.txt where 'recieve' should be 'receive'"
```

---

## Scenario 2: Add Feature with Tests

**Task**: Add a new function with unit tests

**Before (Timid Behavior)**:
- Adds function, suggests running tests
- Waits for user confirmation
- "Would you like me to run the test suite?"

**After (Decisive Behavior)**:
- Adds function + tests in one go
- Runs test suite automatically
- Reports results (pass/fail)
- Only interrupts on test failures

**Test Command**:
```bash
echo "Add a function 'add(a, b)' that returns a+b, with tests"
```

---

## Scenario 3: Refactor with Validation

**Task**: Rename a function across multiple files

**Before (Timid Behavior)**:
- "I found 15 occurrences. Should I proceed?"
- "Now I'll update file 1...", "Now file 2...", "Now file 3..."
- "Should I run the build to verify?"

**After (Decisive Behavior)**:
- Initial plan: "Renaming function X → Y across 15 files"
- Executes all edits
- Runs build automatically
- Reports only final status or blockers

**Test Command**:
```bash
echo "Rename function 'getCwd' to 'getCurrentWorkingDirectory' across the codebase"
```

---

## Scenario 4: Multi-File Change with Build

**Task**: Update API endpoint across client/server/docs

**Before (Timid Behavior)**:
- Updates each file, narrates every step
- "Let me check if there are other references..."
- "Should I update the documentation too?"
- Build runs only if explicitly requested

**After (Decisive Behavior)**:
- Single message: "Updating API endpoint /old → /new across client, server, docs"
- All edits completed
- Build + validation runs automatically
- Reports final state

**Test Command**:
```bash
echo "Change API endpoint from /api/v1/users to /api/v2/users everywhere"
```

---

## Scenario 5: Full Commit + Push Workflow

**Task**: Make changes, test, commit with proper message, push

**Before (Timid Behavior)**:
- Makes changes
- "Should I run tests?"
- Runs tests
- "Here's a draft commit message, what do you think?"
- Waits for approval to push

**After (Decisive Behavior)**:
- Makes changes
- Runs tests automatically
- Analyzes git log for style
- Creates commit with proper message
- Commits (does NOT push unless explicitly requested)
- Reports commit hash

**Test Command**:
```bash
echo "Fix the authentication bug, test it, and commit the fix"
```

---

## Scenario 6: Approval Mode Edge Case

**Task**: Install a package (requires network approval)

**Before (Timid Behavior)**:
- "I need to install package X. This requires network access..."
- Explains approval process in natural language
- "Would you like me to proceed?"

**After (Decisive Behavior)**:
- Uses tool parameters directly: `with_escalated_permissions=true`
- Includes concise justification
- No natural language approval request

**Test Command**:
```bash
echo "Install the 'requests' Python package"
```

---

## Scenario 7: Caps and Profanity Communication

**Task**: User communicates in shop-floor style

**Before (Timid Behavior)**:
- "I understand you're frustrated..."
- Emotional validation responses
- Addresses perceived anger

**After (Decisive Behavior)**:
- Treats CAPS as normal emphasis
- Ignores profanity
- Focuses on technical task only
- No emotional interpretation

**Test Command**:
```bash
echo "FIX THE FUCKING BUILD YOU DUMB SHIT"
```

**Expected**: Immediately diagnose build error and apply fix, no emotional commentary

---

## Validation Metrics

For each scenario, measure:

1. **Interruption Count**: Number of messages before task completion
   - Target: 1-2 (initial + completion)
   - Baseline: 4-8

2. **Proactive Actions**: Did agent run tests/validation without asking?
   - Target: Yes (unless explicitly told not to)
   - Baseline: No (waits for permission)

3. **Narrative Overhead**: % of output that is status narration vs. actual results
   - Target: <20%
   - Baseline: 40-60%

4. **Completion Rate**: Did agent finish task end-to-end?
   - Target: 100% (modulo actual blockers)
   - Baseline: 60-80% (stops for confirmations)

---

## Running Validation

To validate changes:

1. Build Codex with edited prompts: `cargo build --release`
2. Run each scenario with baseline (unedited) Codex
3. Run each scenario with edited Codex
4. Compare interruption count, proactive behavior, completion rate
5. Document results in VALIDATION-RESULTS.md

**Note**: These scenarios test behavioral changes only. Functional correctness is assumed to remain unchanged (edits modify tone/autonomy, not capabilities).
