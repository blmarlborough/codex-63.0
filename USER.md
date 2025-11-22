# AGENTS.md Navigation & Repository Guide

## Existing AGENTS.md Files

### 1. **Root AGENTS.md**
**Path:** `/home/user/codex-63.0/AGENTS.md`
**Scope:** Rust/codex-rs development conventions
**Key Content:**
- Rust crate naming (`codex-` prefix)
- Formatting/linting workflow (`just fmt`, `just fix`)
- TUI styling conventions (ratatui)
- Test conventions (snapshot tests with `insta`)
- Integration test patterns

**Platform Fluff:**
- Lines 9-10: Seatbelt (`/usr/bin/sandbox-exec`) - **macOS only**
- Line 8: References to sandbox env vars (cross-platform but mentions Seatbelt)

---

## Potential AGENTS.md Locations (Not Yet Created)

Based on the Codex AGENTS.md discovery system, you can create AGENTS.md files in these strategic locations:

### Global
- `~/.codex/AGENTS.md` - Applies to ALL Codex sessions
- `~/.codex/AGENTS.override.md` - Overrides global AGENTS.md

### Repository Subdirectories
These directories could have their own AGENTS.md for scoped guidance:

**Rust Crates:**
- `/home/user/codex-63.0/codex-rs/core/AGENTS.md` - Core library conventions
- `/home/user/codex-63.0/codex-rs/tui/AGENTS.md` - TUI-specific patterns
- `/home/user/codex-63.0/codex-rs/cli/AGENTS.md` - CLI-specific rules
- `/home/user/codex-63.0/codex-rs/exec/AGENTS.md` - Exec/sandbox conventions
- `/home/user/codex-63.0/codex-rs/mcp-server/AGENTS.md` - MCP server patterns
- `/home/user/codex-63.0/codex-rs/linux-sandbox/AGENTS.md` - Linux sandbox specifics
- `/home/user/codex-63.0/codex-rs/windows-sandbox-rs/AGENTS.md` - Windows sandbox specifics

**Documentation:**
- `/home/user/codex-63.0/docs/AGENTS.md` - Documentation writing standards

**Tests:**
- `/home/user/codex-63.0/codex-rs/core/tests/AGENTS.md` - Test-specific guidance

### Discovery Rules
From `docs/agents_md.md`:
1. Codex searches from repo root → current directory
2. In each directory, checks in order:
   - `AGENTS.override.md` (highest priority)
   - `AGENTS.md`
   - Fallback filenames from config (`project_doc_fallback_filenames`)
3. Files are concatenated from root → leaf (deeper = higher precedence)
4. Max 32 KiB total (configurable via `project_doc_max_bytes`)

---

## Mac/Windows Specific Fluff (For Linux Users)

### In AGENTS.md
- **Line 9-10:** Seatbelt sandbox (`/usr/bin/sandbox-exec`) - macOS process sandboxing
  - `CODEX_SANDBOX=seatbelt` env var check
  - Used to early-exit tests that can't run under Seatbelt

### In Config/Docs
From `docs/example-config.md`:
- **Line 154-155:** `windows_wsl_setup_acknowledged` - Windows onboarding flag
- **Line 221:** `enable_experimental_windows_sandbox` - Windows restricted-token sandbox
- **Line 131:** `file_opener` defaults to `vscode` (cross-platform, but mentions `vscode-insiders`, `windsurf`, `cursor`)

### In Codebase Structure
- **Directory:** `/home/user/codex-63.0/codex-rs/windows-sandbox-rs/` - Entire Windows sandbox implementation
- **Directory:** `/home/user/codex-63.0/codex-rs/process-hardening/` - May contain platform-specific hardening

### Platform-Specific Sandbox Notes
- **Linux:** Uses `linux-sandbox` crate (namespace-based isolation)
- **macOS:** Uses Seatbelt (App Sandbox/TCC)
- **Windows:** Uses restricted tokens + experimental sandbox

---

## Key Config Files

- **User Config:** `~/.codex/config.toml` (none currently exists)
- **Example Config:** `/home/user/codex-63.0/docs/example-config.md`
- **Config Docs:** `/home/user/codex-63.0/docs/config.md`

### Relevant Config Options for AGENTS.md
```toml
# Max bytes from AGENTS.md files (default: 32768)
project_doc_max_bytes = 32768

# Fallback filenames when AGENTS.md is missing (default: [])
project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]
```

---

## Documentation References

- **AGENTS.md Discovery:** `/home/user/codex-63.0/docs/agents_md.md`
- **Getting Started:** `/home/user/codex-63.0/docs/getting-started.md`
- **Config Reference:** `/home/user/codex-63.0/docs/config.md`
- **Slash Commands:** `/home/user/codex-63.0/docs/slash_commands.md`
- **Sandbox & Approvals:** `/home/user/codex-63.0/docs/sandbox.md` (if exists)

---

## Quick Actions

### View Existing AGENTS.md
```bash
cat /home/user/codex-63.0/AGENTS.md
```

### Create Global AGENTS.md
```bash
mkdir -p ~/.codex
nano ~/.codex/AGENTS.md
```

### Create Scoped AGENTS.md (Example: TUI)
```bash
nano /home/user/codex-63.0/codex-rs/tui/AGENTS.md
```

### Search for Platform-Specific Code
```bash
# Find Seatbelt references
rg -i "seatbelt" /home/user/codex-63.0

# Find Windows-specific code
rg -i "windows" /home/user/codex-63.0/codex-rs --type rust

# Find Linux-specific code
rg -i "linux" /home/user/codex-63.0/codex-rs --type rust
```

---

## Summary

**Existing Modifiable AGENTS.md Files:** 1
- `/home/user/codex-63.0/AGENTS.md`

**Potential Strategic Locations:** ~15+ (listed above)

**Mac/Windows Fluff Identified:**
- Seatbelt (macOS sandbox) in root AGENTS.md
- Windows sandbox crate + config flags
- Platform-specific directories

**Next Steps:**
1. Review root AGENTS.md for Linux-specific tuning
2. Create scoped AGENTS.md files for major crates if needed
3. Set up `~/.codex/AGENTS.md` for global shop-floor culture rules
4. Use `project_doc_fallback_filenames` if you want custom filenames
