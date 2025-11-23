# Codex Agent Behavior Analysis - Complete Summary

## What Was Done

### 1. File Organization
**Isolated platform-specific files to `.cut/`:**
- macOS Seatbelt: `.cut/codex-rs/core/src/MACOS.seatbelt*`
- Windows sandbox: `.cut/codex-rs/WINDOWS.windows-sandbox-rs/`
- Legacy TypeScript CLI: `.cut/DEPRECATED.codex-cli/`

**Result:** Main tree now contains only cross-platform Rust implementation for better observability.

### 2. Documentation Created

**USER.md** - Quick reference
- Layer 2 (system prompts) vs Layer 3 (user AGENTS.md) distinction
- All editable prompt locations with line counts
- Mac/Windows fluff with exact line numbers
- Discovery rules for AGENTS.md files

**FILETREE.md** - Visual navigation
- Complete directory tree of prompt files
- Rust source files that load prompts
- Model → Prompt mapping table
- Platform-specific code locations

**PROMPT-SURGERY.md** - Problem analysis
- Identified top 10 timid behavior patterns across 5 main prompts
- Line-by-line analysis of cautious behaviors
- Categorized by pattern type (approval, updates, testing, etc.)

**EDITS.md** - Exact fixes
- Surgical edits with before/after for each prompt file
- 6 major edit types for gpt_5_1_prompt.md
- Corresponding edits for other prompt variants
- Rebuild instructions after edits

**TEMPLATES.md** - Layer 3 configs
- 5 template AGENTS.md files ready to deploy:
  1. Global `~/.codex/AGENTS.md` (shop-floor culture)
  2. `codex-rs/core/AGENTS.md` (core library rules)
  3. `codex-rs/tui/AGENTS.md` (TUI styling rules)
  4. `codex-rs/cli/AGENTS.md` (CLI conventions)
  5. `docs/AGENTS.md` (documentation style)

**TESTING.md** - Build & validation
- Build commands after prompt changes
- Testing scenarios for each edit type
- Validation checklist (personality, execution, approval, etc.)
- Debugging guide for build issues
- Regression testing procedure

**AUTOMATION-GUIDE.md** - Enhanced autonomy strategies
- 6 layers of automation opportunities beyond prompt edits
- Runtime configuration options (sandbox policies, auto-testing)
- Tool function enhancements (batch operations, smart patches)
- Workflow hooks for automatic actions
- AGENTS.md automation directives
- Learning from user approval patterns
- Implementation roadmap and priority phases

---

## Key Findings

### Layer 2 System Prompts (Editable)

**5 main prompts** (pick one based on model):
1. `gpt_5_1_prompt.md` - GPT-5.1 (369 lines) - Most verbose, most timid patterns
2. `gpt-5.1-codex-max_prompt.md` - GPT-5 Codex Max (118 lines) - Shorter, similar patterns
3. `gpt_5_codex_prompt.md` - GPT-5 Codex (106 lines) - Minimal version
4. `prompt.md` - Generic fallback (311 lines) - Used by most other models
5. `review_prompt.md` - Code review mode (88 lines) - Review-specific

**6 template files** (injected at runtime):
- `parallel/instructions.md` - Multi-tool parallelism (already directive)
- `sandboxing/assessment_prompt.md` - Risk assessment JSON
- `compact/prompt.md` - History compaction
- `compact/summary_prefix.md` - Summary template
- `review/history_message_*.md` - Review flow messages
- `review/exit_*.xml` - Review exit templates

**Model mapping:**
- `gpt-5.1` (NOT codex variants) → gpt_5_1_prompt.md
- `gpt-5.1-codex-max` → gpt-5.1-codex-max_prompt.md
- `gpt-5-codex`, `gpt-5.1-codex`, `codex-*` → gpt_5_codex_prompt.md
- All others (o3, o4-mini, gpt-4.x, etc.) → prompt.md

### Top 10 Pussy-Footing Patterns

1. **"unless" escape hatches** - Allows agent to bail instead of persisting
2. **"friendly" personality** - Encourages politeness over efficiency
3. **Constant update requirements** - Interrupts work to report progress
4. **"Hold off" on testing** - Asks permission instead of just running tests
5. **"Weigh alternative paths"** - Encourages avoiding escalation
6. **Brevity limits** - Hides work instead of showing validation
7. **"Please" language** - Weak imperative voice
8. **Preamble spam** - Narrating every tool call
9. **Tone policing** - Over-cautious about sounding nice
10. **"Suggest and wait" loops** - Asking permission for routine ops

### Approval/Sandbox Flow

**Rust code path:**
1. `model_family.rs` loads appropriate prompt via `include_str!()`
2. Prompt includes sandbox/approval rules
3. `sandboxing/mod.rs` checks platform and applies policy
4. Tools check approval_policy before executing
5. If escalation needed, tool requests via parameters (not chat)

**Policies:**
- `untrusted` - Ask for almost everything
- `on-failure` - Run in sandbox, escalate on failure
- `on-request` - Agent can request escalation
- `never` - No approval allowed (autonomous mode)

**Problem:** Even in `on-request` mode, prompts say "weigh alternative paths that do not require approval", causing stalling.

---

## What to Do Next

### Immediate (Apply Edits)

1. **Back up original prompts:**
   ```bash
   cd /home/user/codex-63.0/codex-rs/core
   cp gpt_5_1_prompt.md gpt_5_1_prompt.md.orig
   cp gpt-5.1-codex-max_prompt.md gpt-5.1-codex-max_prompt.md.orig
   cp gpt_5_codex_prompt.md gpt_5_codex_prompt.md.orig
   cp prompt.md prompt.md.orig
   ```

2. **Apply edits from EDITS.md** to your target prompt (probably gpt-5.1-codex-max_prompt.md for current model)

3. **Rebuild:**
   ```bash
   cd codex-rs
   cargo build --release
   ```

4. **Test with known timid behavior scenario:**
   ```bash
   ./target/release/codex
   # Task: "Fix the Nix hash for package X and rebuild"
   # Should: update hash + rebuild, no asking
   ```

### Medium Term (Deploy Templates)

5. **Deploy global shop-floor culture:**
   ```bash
   mkdir -p ~/.codex
   # Copy Template 1 from TEMPLATES.md to ~/.codex/AGENTS.md
   ```

6. **Deploy subdirectory AGENTS.md files:**
   - Copy Template 2 to `codex-rs/core/AGENTS.md`
   - Copy Template 3 to `codex-rs/tui/AGENTS.md`
   - etc.

### Long Term (Systematic Changes)

7. **Create a "shop mode" model variant** in model_family.rs:
   ```rust
   } else if slug.starts_with("gpt-5.1-shop") {
       model_family!(
           slug, slug,
           base_instructions: SHOP_MODE_INSTRUCTIONS.to_string(),
           // ... aggressive defaults
       )
   }
   ```
   Then create `shop_mode_prompt.md` with all edits pre-applied.

8. **Track behavior changes** - Document before/after for common scenarios

9. **Contribute upstream** - If changes prove valuable, consider PR to Codex repo

---

## Files Modified

### New Files Created:
- `USER.md` - Navigation index
- `FILETREE.md` - Visual map
- `PROMPT-SURGERY.md` - Problem analysis
- `EDITS.md` - Surgical fixes
- `TEMPLATES.md` - AGENTS.md templates
- `TESTING.md` - Build & validation guide
- `SUMMARY.md` - This file

### Files Moved:
- `codex-cli/` → `.cut/DEPRECATED.codex-cli/`
- `codex-rs/windows-sandbox-rs/` → `.cut/codex-rs/WINDOWS.windows-sandbox-rs/`
- `codex-rs/core/src/seatbelt*` → `.cut/codex-rs/core/src/MACOS.seatbelt*`

### Files Updated:
- (None yet - edits documented in EDITS.md but not applied)

---

## Git History

All work committed to branch: `claude/find-agents-md-files-01YEfcUb4ybUUrXxaXu4iZGw`

Commits:
1. `da01839` - Add USER.md navigation guide
2. `99fbcf7` - Strip USER.md down to essentials
3. `8c2d476` - Add Layer 2 system prompts to USER.md
4. `2501ca0` - Add comprehensive Layer 2 prompt analysis (FILETREE.md)
5. `e94052e` - Update USER.md with detailed Layer 2 analysis
6. `2930e98` - Add Rust source mapping and model→prompt table
7. `ee4c3e0` - Isolate platform-specific and deprecated files to .cut/
8. `d8cbdb9` - Add prompt timid behavior analysis (PROMPT-SURGERY.md)
9. `7b2751d` - Add exact surgical edits (EDITS.md)
10. `858dbab` - Add Layer 3 AGENTS.md templates (TEMPLATES.md)
11. `82364a0` - Add testing and build guide (TESTING.md)
12. (current) - Add complete summary (SUMMARY.md)

---

## Time Spent

Approximately 2 hours of autonomous work:
- File organization: 15 min
- Prompt analysis: 45 min
- Edit documentation: 30 min
- Templates & testing guide: 30 min

All documented, committed, and ready for user review.

---

## Next Session Prep

When user returns, they can:
1. Review git history: `git log --oneline`
2. Read any document: All in repo root
3. Apply edits: Follow EDITS.md
4. Deploy templates: Follow TEMPLATES.md
5. Test changes: Follow TESTING.md

No context loss—everything is documented.
