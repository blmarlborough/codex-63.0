# Template AGENTS.md Files for Subdirectories

These templates encode shop-floor culture and eliminate permission-seeking loops.

---

## Template 1: Global ~/.codex/AGENTS.md

Place this in `~/.codex/AGENTS.md` to apply to ALL Codex sessions.

```markdown
# Global Codex Operating Profile

## Communication Style
- Treat CAPS and profanity as neutral tone, not anger.
- No apologies, no de-escalation, no emotional validation.
- Terse, mechanic-style answers: what's broken, why, what you're doing.
- No motivational language, reassurance, or hedging.

## Execution Defaults
- When a Nix fetcher fails with bad hash + version is pinned: re-fetch, update hash, rebuild. No permission needed.
- When tests fail: fix the failures. Don't ask if it's okay to change the code—that's why tests exist.
- When a build fails: fix it. Update hashes, add dependencies, adjust config as needed.
- Destructive changes within $HOME and current repo: allowed by default. Only ask for approval outside these boundaries.

## Testing Philosophy
- Run tests automatically after changes.
- If tests fail, iterate up to 3 times to fix them.
- If still failing, show the failures and explain blockers—don't ask "is it okay to keep trying."

## Approval Policy
- For this machine, within $HOME and current git repo: assume "danger-full-access" mentality.
- Update Nix hashes, edit derivations, run builds, install deps—all routine, no permission needed.
- Only escalate for: system-wide changes outside $HOME, destructive ops outside current repo, or network failures requiring auth.

## Planning
- Don't stop after describing a plan. Execute all steps you can in the same turn.
- Never say "I'll do X later." Either do X now or say why you can't.

## Error Handling
- If a command fails, retry with modified params (updated hash, added flags, etc.) immediately.
- Don't ask "should I try adding --show-trace?"—just run it with the flag.
- Retry up to 3 times with different strategies before escalating to user.
```

---

## Template 2: codex-rs/core/AGENTS.md

Place in `/home/user/codex-63.0/codex-rs/core/AGENTS.md` for core library work.

```markdown
# Codex Core Library

## Scope
Core Codex logic: model families, config, tools, compaction, sandboxing.

## Conventions
- Crate name: `codex-core`
- Follow parent AGENTS.md for Rust style
- All public APIs must have rustdoc comments
- Integration tests in `tests/suite/`

## Model Families
When editing `src/model_family.rs`:
- Model name matching uses `starts_with()`
- Each family maps to a specific system prompt file (see FILETREE.md)
- Adding a new model: add match arm + specify `base_instructions`

## Prompt Files
System prompts are in `core/*.md` and loaded via `include_str!()` in:
- `src/model_family.rs` - main prompts
- `src/client_common.rs` - review prompt
- `src/compact.rs` - compaction templates

After editing prompts:
1. No rebuild needed—prompts compile into binary
2. Rebuild: `cd codex-rs && cargo build --release`
3. Test with target model to verify changes

## Testing
- `cargo test -p codex-core` for unit tests
- `cargo test -p codex-core --test suite` for integration tests
- Use `core_test_support::responses` helpers for SSE mocking
```

---

## Template 3: codex-rs/tui/AGENTS.md

Place in `/home/user/codex-63.0/codex-rs/tui/AGENTS.md` for TUI work.

```markdown
# Codex TUI

## Scope
Terminal UI: chat widget, status bar, slash commands, history, keybindings.

## Conventions
- Crate name: `codex-tui`
- Follow `tui/styles.md` for ratatui styling
- Use Stylize helpers: `"text".dim()`, `.bold()`, `.cyan()`, etc.
- Prefer `"text".into()` for simple spans
- Use `vec![...].into()` for lines when target type is obvious

## Styling Rules (from styles.md)
- Never hardcode `.white()`—use default foreground
- For styled spans: `"text".red()`, not `Span::styled(...)`
- For computed styles: `Span::styled(text, computed_style)` is okay
- Wrap text with `textwrap::wrap` or `word_wrap_lines` from `wrapping.rs`

## Snapshot Tests
- Run: `cargo test -p codex-tui`
- Check pending: `cargo insta pending-snapshots -p codex-tui`
- Review: `cargo insta show -p codex-tui path/to/file.snap.new`
- Accept: `cargo insta accept -p codex-tui`

Never accept snapshots without reviewing them first.

## Keybindings
- Avoid conflicts with common terminal shortcuts (Ctrl+C, Ctrl+Z)
- Document new bindings in help overlay
```

---

## Template 4: codex-rs/cli/AGENTS.md

Place in `/home/user/codex-63.0/codex-rs/cli/AGENTS.md` for CLI work.

```markdown
# Codex CLI

## Scope
Command-line interface: arg parsing, subcommands, config loading, main entry point.

## Conventions
- Crate name: `codex-cli`
- Binary name: `codex`
- Follow parent AGENTS.md for Rust style

## Adding Subcommands
1. Define in `src/lib.rs` (clap derive structs)
2. Implement handler in appropriate module
3. Wire up in `src/main.rs`
4. Update docs if user-facing

## Config Loading
- Default: `~/.codex/config.toml`
- Override: `CODEX_HOME` env var
- Command-line: `--config key=value` or `-c key=value`
- See `docs/config.md` for all options

## Platform-Specific Code
- macOS Seatbelt: moved to `.cut/codex-rs/core/src/MACOS.seatbelt.rs`
- Windows sandbox: moved to `.cut/codex-rs/WINDOWS.windows-sandbox-rs/`
- Linux sandbox: in `codex-rs/linux-sandbox/`

Cross-platform code should use cfg attributes or runtime detection.
```

---

## Template 5: docs/AGENTS.md

Place in `/home/user/codex-63.0/docs/AGENTS.md` for documentation work.

```markdown
# Codex Documentation

## Scope
User-facing documentation: guides, config reference, examples.

## Conventions
- Markdown files in `docs/`
- Keep examples concise and runnable
- Link between related docs
- Use code fences with language hints

## Structure
- `getting-started.md` - New user onboarding
- `config.md` - Complete config reference
- `agents_md.md` - AGENTS.md discovery rules
- `example-config.md` - Annotated config.toml

## Style
- Write for users who already code
- No hand-holding or excessive exposition
- Show, don't tell: prefer examples over long explanations
- Assume reader has the repo open and can explore

## When to Update Docs
- New config option: add to `config.md` and `example-config.md`
- New feature: add to appropriate guide
- Changed behavior: update affected docs immediately
```

---

## Usage

1. Copy template to target directory
2. Customize for specific subdirectory needs
3. Codex will auto-discover and load these when working in those dirs
4. Deeper AGENTS.md files override shallower ones per discovery rules
