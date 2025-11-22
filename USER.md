# AGENTS.md Files

## Existing
- `/home/user/codex-63.0/AGENTS.md` (Rust conventions)

## Potential Locations
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
AGENTS.md:
- Lines 9-10: Seatbelt (`/usr/bin/sandbox-exec`) - macOS only

Config (docs/example-config.md):
- Line 154-155: `windows_wsl_setup_acknowledged`
- Line 221: `enable_experimental_windows_sandbox`

Directories:
- `/home/user/codex-63.0/codex-rs/windows-sandbox-rs/`
- `/home/user/codex-63.0/codex-rs/process-hardening/`

## Discovery
Priority: AGENTS.override.md → AGENTS.md → fallbacks (config: `project_doc_fallback_filenames`)
Max size: 32 KiB (config: `project_doc_max_bytes`)
Docs: `/home/user/codex-63.0/docs/agents_md.md`
