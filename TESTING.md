# Testing & Building Codex After Prompt Changes

## Quick Reference

```bash
# Build Codex after editing prompts
cd /home/user/codex-63.0/codex-rs
cargo build --release

# Binary location after build
./target/release/codex

# Run specific tests
cargo test -p codex-core
cargo test -p codex-tui
cargo test -p codex-cli

# Run all tests
cargo test --all-features

# Format code
just fmt

# Fix linter issues
just fix -p codex-core  # Specific crate
just fix                 # All crates (slow)
```

---

## Understanding Prompt Compilation

System prompts (`.md` files in `codex-rs/core/`) are compiled into the binary via `include_str!()` macros in Rust source.

**This means:**
- Editing a prompt `.md` file requires rebuilding Codex to see changes
- Prompts are embedded at compile time, not read at runtime
- No performance overhead from loading prompts

**Files that load prompts:**
- `codex-rs/core/src/model_family.rs` - Main prompts (gpt_5_1_prompt.md, etc.)
- `codex-rs/core/src/client_common.rs` - Review prompt
- `codex-rs/core/src/codex.rs` - Parallel instructions
- `codex-rs/core/src/compact.rs` - Compaction templates

---

## Build Process

### 1. After Editing Prompts

```bash
cd /home/user/codex-63.0/codex-rs

# Clean build (recommended after prompt changes)
cargo clean
cargo build --release

# Time: ~2-5 minutes depending on machine
```

### 2. Quick Rebuild (if only prompts changed)

```bash
# Faster incremental build
cargo build --release

# Time: ~30 seconds - 2 minutes
```

### 3. Debug Build (faster compile, slower runtime)

```bash
# Use for testing prompt changes
cargo build

# Binary: ./target/debug/codex
```

---

## Testing Prompt Changes

### Scenario 1: Test Specific Model Prompt

Edit: `codex-rs/core/gpt_5_1_prompt.md`

```bash
# 1. Rebuild
cd codex-rs && cargo build --release

# 2. Run Codex with GPT-5.1 model
cd ..
./codex-rs/target/release/codex --model gpt-5.1

# 3. Test with a task that previously pussy-footed
# Example: "Fix the Nix hash for package X and rebuild"
#
# Expected behavior after edits:
# - No "is it okay to update the hash?" message
# - Direct execution: fetches → updates hash → rebuilds
# - Minimal progress updates
# - Final message shows validation proof
```

### Scenario 2: Test Approval Behavior

```bash
# Run with on-request approval policy
./codex-rs/target/release/codex --approval on-request

# Test task requiring escalation (e.g., network fetch)
#
# Expected behavior after edits:
# - Immediately requests escalation with clear justification
# - No "let me try a workaround first" stalling
# - Uses tool parameters, not chat messages
```

### Scenario 3: Test Testing Behavior

```bash
# Run a code change task
./codex-rs/target/release/codex

# Give task: "Add function X to file Y"
#
# Expected behavior after edits:
# - Makes change
# - Runs tests automatically (no "should I run tests?")
# - Shows test output in final message
# - Iterates if tests fail, no permission needed
```

---

## Validation Checklist

After applying edits from EDITS.md, verify:

### ✓ Personality Changes
- [ ] No "friendly" language in responses
- [ ] No "I understand you're frustrated" de-escalation
- [ ] Terse, mechanic-style final messages

### ✓ Execution Changes
- [ ] No "I'll do X later" promises—either does X or explains blocker
- [ ] Doesn't ask "should I run tests?"—just runs them
- [ ] Doesn't ask "is it okay to update the hash?"—just does it

### ✓ Approval Changes
- [ ] Uses tool parameters for escalation, not chat messages
- [ ] Requests approval immediately when needed, no workaround stalling
- [ ] Clear 1-sentence justification in escalation requests

### ✓ Update Spam Eliminated
- [ ] Initial message states approach
- [ ] Silence during execution (no "Now I'll check X" spam)
- [ ] Final message with results + validation

### ✓ Verbosity Fixed
- [ ] Final answers include validation proof (test output, build logs)
- [ ] No artificial brevity limits hiding work
- [ ] Code snippets shown when they clarify changes

---

## Debugging Build Issues

### Issue: Prompt syntax error breaks build

```
error: expected string literal
  --> codex-rs/core/src/model_family.rs:11:38
   |
11 | const BASE_INSTRUCTIONS: &str = include_str!("../prompt.md");
   |                                              ^^^^^^^^^^^^^^^^
```

**Cause:** Malformed Markdown in prompt file (unclosed code fence, etc.)

**Fix:**
1. Check the prompt file for syntax errors
2. Ensure all code fences are closed: ` ``` `
3. Rebuild

### Issue: Binary doesn't use new prompts

**Cause:** Old binary still in use, or forgot to rebuild

**Fix:**
```bash
# Clean and rebuild
cd codex-rs
cargo clean
cargo build --release

# Verify binary timestamp
ls -lh target/release/codex

# Should show recent build time
```

### Issue: Tests fail after prompt changes

**Cause:** Tests may check exact prompt output or behavior

**Fix:**
```bash
# Identify failing test
cargo test --all-features 2>&1 | grep FAILED

# Read test to understand what it expects
# Update test if prompt change is intentional

# Example: Snapshot test
cargo insta review -p codex-tui
```

---

## Regression Testing

Before committing prompt changes:

```bash
# 1. Build
cd codex-rs && cargo build --release

# 2. Run core tests
cargo test -p codex-core

# 3. Run TUI tests (includes snapshot tests)
cargo test -p codex-tui

# 4. Run CLI tests
cargo test -p codex-cli

# 5. Manual smoke test
cd ..
./codex-rs/target/release/codex --help

# Should show help without errors
```

---

## Performance Notes

- **Prompt size impact:** Minimal. Prompts are small (369 lines max = ~15KB)
- **Build time:** Incremental builds are fast (~30s-2min)
- **Runtime impact:** Zero—prompts compiled into binary

---

## CI/CD Considerations

If setting up automated testing:

```bash
# Full CI test suite
cd codex-rs
cargo fmt --check        # Formatting
just fix                 # Linters (Clippy)
cargo test --all-features # All tests

# Build release binary
cargo build --release
```

Expected CI time: 5-10 minutes for full suite.
