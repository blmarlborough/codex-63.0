# Codex Layer 2 System Prompts - Filetree

```
codex-63.0/
├── AGENTS.md (Layer 3: User Rust conventions)
│
└── codex-rs/
    ├── core/
    │   ├── gpt_5_1_prompt.md          ← GPT-5.1 system prompt
    │   ├── gpt-5.1-codex-max_prompt.md ← GPT-5 Codex Max system prompt
    │   ├── gpt_5_codex_prompt.md      ← GPT-5 Codex system prompt
    │   ├── prompt.md                  ← Generic system prompt
    │   ├── review_prompt.md           ← Code review guidelines
    │   │
    │   └── templates/
    │       ├── parallel/
    │       │   └── instructions.md     ← Parallel tool use rules
    │       ├── sandboxing/
    │       │   └── assessment_prompt.md ← Sandbox risk assessment
    │       ├── compact/
    │       │   ├── prompt.md           ← History compaction prompt
    │       │   └── summary_prefix.md   ← Summary prefix template
    │       └── review/
    │           ├── history_message_interrupted.md
    │           └── history_message_completed.md
    │
    ├── apply-patch/
    │   └── apply_patch_tool_instructions.md ← Patch format spec
    │
    └── tui/
        └── prompt_for_init_command.md  ← AGENTS.md generation prompt
```

## What Each File Controls

**Main System Prompts** (pick one based on model):
- `gpt_5_1_prompt.md` - Full GPT-5.1 system prompt (369 lines)
  - Personality: concise, direct, friendly
  - Autonomy: persist until task complete
  - Planning: update_plan tool usage
  - Sandbox/approval behavior
  - File references, formatting, tool guidelines

- `gpt-5.1-codex-max_prompt.md` - GPT-5 Codex Max (118 lines)
  - Shorter, more aggressive
  - Editing constraints (dirty worktree, no amend)
  - Plan tool (skip for 25% easiest tasks)
  - Frontend tasks (no AI slop)
  - Special requests (review mindset)

- `gpt_5_codex_prompt.md` - GPT-5 Codex (106 lines)
  - Minimal version
  - Same structure as codex-max
  - No frontend section

- `prompt.md` - Generic fallback (311 lines)
  - Preamble message guidelines
  - Planning examples (high vs low quality)
  - Task execution rules
  - No autonomy/persistence section

**Review System**:
- `review_prompt.md` - Code review behavior (88 lines)
  - Bug flagging guidelines (8 rules)
  - Comment formatting rules
  - Priority levels (P0-P3)
  - JSON output schema

**Injected Templates** (added to conversation at specific points):
- `parallel/instructions.md` - Forces multi_tool_use.parallel for reads
- `sandboxing/assessment_prompt.md` - Risk assessment JSON output
- `compact/prompt.md` - Context checkpoint handoff format
- `compact/summary_prefix.md` - Summary template
- `review/history_message_*.md` - Review flow messages

**Tool Documentation**:
- `apply_patch_tool_instructions.md` - Patch format grammar
- `prompt_for_init_command.md` - AGENTS.md auto-generation prompt

## Platform-Specific References Found

**macOS-only**:
- `osascript` - AppleScript runner (Lines: gpt-5.1-codex-max:183, gpt_5_1:183, gpt_5_codex:49, prompt:174)
- `open` - macOS file opener (same lines)

**Linux**:
- `xdg-open` - Linux file opener (same lines)

**Cross-platform** (but mentions platform variants):
- GUI app approval mentions all three

**In repo structure**:
- `codex-rs/windows-sandbox-rs/` - Windows sandbox impl
- `codex-rs/linux-sandbox/` - Linux sandbox impl
- Seatbelt references in AGENTS.md (macOS sandbox)
