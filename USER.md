# AGENTS.md Files - Quick Reference

**📋 Documentation:**
- **QUICKSTART.md** - ⭐ Start here - what to read first
- **SUMMARY.md** - Complete overview of all findings
- **FILETREE.md** - Visual file tree + code flow
- **ARCHITECTURE.md** - Detailed code architecture & prompt flow
- **PROMPT-SURGERY.md** - Analysis of timid behavior patterns
- **EDITS.md** - Exact surgical edits to apply
- **TEMPLATES.md** - Ready-to-use AGENTS.md templates
- **TESTING.md** - Build & validation after changes
- **AUTOMATION-GUIDE.md** - ⭐ Strategies to enhance Codex autonomy

---

## Layer 2: System Prompts (Codex Harness)

Main prompts (codex-rs/core/) - pick one based on model:
- `gpt_5_1_prompt.md` - GPT-5.1 system prompt (369 lines)
- `gpt-5.1-codex-max_prompt.md` - GPT-5 Codex Max (118 lines)
- `gpt_5_codex_prompt.md` - GPT-5 Codex (106 lines)
- `prompt.md` - Generic fallback (311 lines)
- `review_prompt.md` - Code review guidelines (88 lines)

Templates (codex-rs/core/templates/) - injected at runtime:
- `parallel/instructions.md` - Parallel tool use rules
- `sandboxing/assessment_prompt.md` - Sandbox risk assessment
- `compact/prompt.md` - History compaction
- `compact/summary_prefix.md` - Summary prefix
- `review/history_message_interrupted.md`
- `review/history_message_completed.md`

Tool instructions:
- `codex-rs/apply-patch/apply_patch_tool_instructions.md` - Patch format
- `codex-rs/tui/prompt_for_init_command.md` - AGENTS.md generator

## Layer 3: User Instructions

### Existing
- `/home/user/codex-63.0/AGENTS.md` (Rust conventions)

### Potential Locations
Global:
- `~/.codex/AGENTS.md`
- `~/.codex/AGENTS.override.md`

Per-crate:
- `/home/user/codex-63.0/codex-rs/core/AGENTS.md`
- `/home/user/codex-63.0/codex-rs/tui/AGENTS.md`
- `/home/user/codex-63.0/codex-rs/cli/AGENTS.md`
- `/home/user/codex-63.0/codex-rs/exec/AGENTS.md`
- `/home/user/codex-63.0/codex-rs/mcp-server/AGENTS.md`
- `/home/user/codex-63.0/codex-rs/linux-sandbox/AGENTS.md`
- `/home/user/codex-63.0/codex-rs/windows-sandbox-rs/AGENTS.md`
- `/home/user/codex-63.0/docs/AGENTS.md`

## Mac/Windows Fluff

**AGENTS.md** (Layer 3):
- Lines 9-10: Seatbelt (`/usr/bin/sandbox-exec`) - macOS sandbox

**System prompts** (Layer 2):
- Lines referencing GUI apps: `open` (macOS), `xdg-open` (Linux), `osascript` (macOS)
  - gpt-5.1-codex-max_prompt.md:183
  - gpt_5_1_prompt.md:183
  - gpt_5_codex_prompt.md:49
  - prompt.md:174

**Config** (docs/example-config.md):
- Lines 154-155: `windows_wsl_setup_acknowledged`
- Line 221: `enable_experimental_windows_sandbox`

**Directories (moved to .cut/):**
- `.cut/codex-rs/WINDOWS.windows-sandbox-rs/` - Windows sandbox impl
- `.cut/codex-rs/core/src/MACOS.seatbelt*` - macOS Seatbelt files
- `.cut/DEPRECATED.codex-cli/` - Legacy TypeScript CLI
- `codex-rs/linux-sandbox/` - Linux sandbox impl (still in tree)
- `codex-rs/process-hardening/` - Platform-specific hardening

## Discovery
Priority: AGENTS.override.md → AGENTS.md → fallbacks (config: `project_doc_fallback_filenames`)
Max size: 32 KiB (config: `project_doc_max_bytes`)
Docs: `/home/user/codex-63.0/docs/agents_md.md`
