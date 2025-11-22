# Codex Prompt Architecture & Code Flow

## High-Level Overview

```
User Request
    ↓
CLI Entry (codex-rs/cli/src/main.rs)
    ↓
Core Codex Logic (codex-rs/core/src/codex.rs)
    ↓
Model Family Selection (codex-rs/core/src/model_family.rs)
    ↓
Load System Prompt (include_str!() → one of 5 main prompts)
    ↓
Inject AGENTS.md (codex-rs/core/src/project_doc.rs)
    ↓
Add Runtime Templates (parallel, sandboxing, compact)
    ↓
Construct API Payload (codex-rs/core/src/client_common.rs)
    ↓
Send to Model API (OpenAI / other provider)
    ↓
Receive Response
    ↓
Execute Tools (shell, apply_patch, etc.)
    ↓
Loop until task complete
```

---

## Detailed Code Flow

### 1. Startup & Config Loading

**File:** `codex-rs/cli/src/main.rs`

```rust
fn main() {
    // 1. Parse CLI args (clap)
    let args = Args::parse();

    // 2. Load config from ~/.codex/config.toml
    let config = load_config()?;

    // 3. Determine model from CLI or config
    let model = args.model.unwrap_or(config.model);

    // 4. Start TUI or exec mode
    match args.command {
        Some(Command::Exec { ... }) => exec_mode(),
        None => tui_mode(),
    }
}
```

**Key Files:**
- `codex-rs/cli/src/main.rs` - Entry point
- `codex-rs/core/src/config/mod.rs` - Config parsing
- `codex-rs/core/src/config_loader/*.rs` - Platform-specific config

---

### 2. Model Family & Prompt Selection

**File:** `codex-rs/core/src/model_family.rs`

```rust
const BASE_INSTRUCTIONS: &str = include_str!("../prompt.md");
const GPT_5_CODEX_INSTRUCTIONS: &str = include_str!("../gpt_5_codex_prompt.md");
const GPT_5_1_INSTRUCTIONS: &str = include_str!("../gpt_5_1_prompt.md");
const GPT_5_1_CODEX_MAX_INSTRUCTIONS: &str = include_str!("../gpt-5.1-codex-max_prompt.md");

pub fn find_family_for_model(slug: &str) -> Option<ModelFamily> {
    if slug.starts_with("gpt-5.1-codex-max") {
        model_family!(
            slug, slug,
            base_instructions: GPT_5_1_CODEX_MAX_INSTRUCTIONS.to_string(),
            // ... other config
        )
    } else if slug.starts_with("gpt-5.1") {
        model_family!(
            slug, "gpt-5.1",
            base_instructions: GPT_5_1_INSTRUCTIONS.to_string(),
            // ...
        )
    } else if slug.starts_with("gpt-5-codex") || slug.starts_with("codex-") {
        model_family!(
            slug, slug,
            base_instructions: GPT_5_CODEX_INSTRUCTIONS.to_string(),
            // ...
        )
    } else {
        model_family!(
            slug, slug,
            base_instructions: BASE_INSTRUCTIONS.to_string(),
            // ...
        )
    }
}
```

**Result:** Model name determines which prompt file gets loaded at compile time.

---

### 3. AGENTS.md Discovery & Loading

**File:** `codex-rs/core/src/project_doc.rs`

```rust
pub async fn load_project_docs(...) -> Result<String> {
    // 1. Find git root
    let repo_root = find_git_root(cwd)?;

    // 2. Walk from repo_root to cwd
    let mut docs = Vec::new();
    for dir in walk_dirs(repo_root, cwd) {
        // 3. Check for AGENTS.override.md first
        if let Some(content) = read_if_exists(dir.join("AGENTS.override.md")) {
            docs.push(content);
            continue;
        }

        // 4. Then AGENTS.md
        if let Some(content) = read_if_exists(dir.join("AGENTS.md")) {
            docs.push(content);
            continue;
        }

        // 5. Then fallback filenames from config
        for fallback in config.project_doc_fallback_filenames {
            if let Some(content) = read_if_exists(dir.join(fallback)) {
                docs.push(content);
                break;
            }
        }
    }

    // 6. Concatenate with blank lines
    // 7. Truncate to project_doc_max_bytes (default 32KiB)
    Ok(docs.join("\n\n"))
}
```

**Priority Order:**
1. `AGENTS.override.md` (highest)
2. `AGENTS.md`
3. Configured fallback filenames
4. Deeper directories override shallower ones

---

### 4. Runtime Template Injection

**File:** `codex-rs/core/src/codex.rs`

```rust
// Parallel tool use instructions
if parallel_tool_calls {
    static INSTRUCTIONS: &str = include_str!("../templates/parallel/instructions.md");
    base_instructions.push_str("\n\n");
    base_instructions.push_str(INSTRUCTIONS);
}

// Sandbox assessment (if experimental feature enabled)
if config.experimental_sandbox_command_assessment {
    static ASSESSMENT: &str = include_str!("../templates/sandboxing/assessment_prompt.md");
    // Inject assessment prompt
}
```

**File:** `codex-rs/core/src/compact.rs`

```rust
pub const SUMMARIZATION_PROMPT: &str = include_str!("../templates/compact/prompt.md");
pub const SUMMARY_PREFIX: &str = include_str!("../templates/compact/summary_prefix.md");

// Used when context window is full, to compress history
```

**File:** `codex-rs/core/src/client_common.rs`

```rust
pub const REVIEW_PROMPT: &str = include_str!("../review_prompt.md");

// Used when in review mode
```

**Result:** Additional instructions injected based on:
- Features enabled (parallel, sandboxing)
- Mode (review vs normal)
- Context state (compaction needed)

---

### 5. API Payload Construction

**File:** `codex-rs/core/src/client_common.rs`

```rust
pub struct PayloadRequest {
    pub instructions: String,  // = base_prompt + AGENTS.md + templates
    pub messages: Vec<Message>,
    pub tools: Vec<Tool>,
    pub model: String,
    // ... other fields
}
```

**Payload Structure:**
1. **instructions** field:
   - System prompt (from model_family.rs)
   - AGENTS.md content (from project_doc.rs)
   - Runtime templates (parallel, etc.)
2. **messages** field:
   - User request
   - Previous conversation history
   - Tool results
3. **tools** field:
   - shell, apply_patch, update_plan, etc.

---

### 6. Tool Execution & Sandbox

**File:** `codex-rs/core/src/sandboxing/mod.rs`

```rust
pub enum SandboxMode {
    ReadOnly,
    WorkspaceWrite,
    DangerFullAccess,
}

pub enum ApprovalPolicy {
    Untrusted,
    OnFailure,
    OnRequest,
    Never,
}
```

**Platform Selection:**

```rust
#[cfg(target_os = "macos")]
use crate::seatbelt::SeatbeltSandbox;

#[cfg(target_os = "linux")]
use codex_linux_sandbox::LinuxSandbox;

#[cfg(target_os = "windows")]
use codex_windows_sandbox_rs::WindowsSandbox;
```

**File:** `codex-rs/core/src/tools/handlers/*.rs`

Each tool (shell, apply_patch, etc.) checks:
1. Sandbox mode
2. Approval policy
3. User-requested escalation
4. Executes or requests approval

---

### 7. Response Processing

**File:** `codex-rs/core/src/codex.rs`

```rust
loop {
    // 1. Send payload to model
    let response = client.send(payload).await?;

    // 2. Stream back thinking + text
    stream_to_tui(response.thinking);
    stream_to_tui(response.text);

    // 3. Execute tool calls
    for tool_call in response.tool_calls {
        let result = execute_tool(tool_call, sandbox, approval).await?;
        payload.messages.push(result);
    }

    // 4. If model says "done", break
    if response.finish_reason == "stop" {
        break;
    }

    // 5. Loop back (send tool results as next turn)
}
```

---

## Key Modification Points

### To Change Agent Behavior:

**1. Edit System Prompts (Layer 2)**
- Files: `codex-rs/core/*.md`
- Rebuild required: `cargo build --release`
- Affects: All users of that model

**2. Add AGENTS.md (Layer 3)**
- Files: Per-directory AGENTS.md
- No rebuild needed
- Affects: Only that directory subtree

**3. Modify Rust Code**
- Files: `codex-rs/core/src/*.rs`
- Rebuild required
- Can change: Tool behavior, sandbox rules, approval logic

**4. Config Changes**
- File: `~/.codex/config.toml`
- No rebuild needed
- Can change: Model, sandbox mode, approval policy, etc.

---

## Compilation & Embedding

### How Prompts Get Into Binary:

```rust
// At compile time
const PROMPT: &str = include_str!("../prompt.md");
// ↓
// Rust compiler reads prompt.md and embeds it as a string literal
// ↓
// Binary contains full prompt text
```

**Implications:**
- ✅ Zero runtime overhead (no file I/O)
- ✅ Prompts can't be modified post-build
- ❌ Must rebuild after prompt changes
- ✅ Binary is self-contained

### Build Process:

```bash
# 1. Cargo reads Cargo.toml
# 2. Compiles codex-rs/core/src/model_family.rs
# 3. include_str!() macros execute at compile time
# 4. Prompt files embedded as string literals
# 5. Final binary: codex-rs/target/release/codex
```

**Size Impact:**
- All 5 prompts + templates ≈ 1500 lines ≈ 60KB
- Negligible compared to typical binary size (10-50 MB)

---

## Platform-Specific Flow

### macOS (Seatbelt):

```
User runs command
    ↓
Codex checks sandbox_mode
    ↓
If sandboxed: spawn via /usr/bin/sandbox-exec
    ↓
Load .sbpl policy (base + network if allowed)
    ↓
Execute in sandbox
```

**Files:** `.cut/codex-rs/core/src/MACOS.seatbelt*`

### Linux (namespaces):

```
User runs command
    ↓
Codex checks sandbox_mode
    ↓
If sandboxed: use Linux sandbox crate
    ↓
Create namespace (mount, network, PID, etc.)
    ↓
Execute in namespace
```

**Files:** `codex-rs/linux-sandbox/`

### Windows (restricted tokens):

```
User runs command
    ↓
Codex checks sandbox_mode
    ↓
If sandboxed: use Windows sandbox crate
    ↓
Create restricted token
    ↓
Execute with token
```

**Files:** `.cut/codex-rs/WINDOWS.windows-sandbox-rs/`

---

## Debugging Flow

### Enable Verbose Logging:

```bash
# Set env var
export RUST_LOG=codex=debug

# Run
./codex-rs/target/release/codex
```

**What you'll see:**
- Config loading
- Model family selection
- AGENTS.md discovery
- Prompt assembly
- Tool execution
- Sandbox decisions

### Tracing Tool Calls:

```bash
# Look for tool execution in logs
RUST_LOG=codex::tools=trace ./codex-rs/target/release/codex
```

---

## Performance Characteristics

**Prompt Loading:** O(1) - embedded at compile time
**AGENTS.md Discovery:** O(n) where n = directory depth
**Model API Call:** O(network latency) ~1-3 seconds
**Tool Execution:** O(command execution time)
**Context Window:** Limited by model (GPT-5.1: 128K tokens)
**Compaction Frequency:** When context > ~80% of limit

---

## Summary

**Prompt flow:**
1. Model name → prompt file (compile-time)
2. AGENTS.md discovery (runtime, cached per session)
3. Template injection (conditional, runtime)
4. Concatenate all → API payload
5. Model processes → tool calls
6. Tools execute (sandbox checked) → results
7. Loop until done

**Key insight:** Most behavior is set at compile-time (system prompts), but can be overridden at runtime (AGENTS.md, config).
