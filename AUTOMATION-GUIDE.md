# Codex Automation Enhancement Guide

This document outlines strategies to enhance Codex's autonomous behavior and reduce manual intervention.

## Overview

The prompt modifications in this PR eliminate timid patterns, but there are additional automation opportunities at multiple levels:

### Layer 1: System Prompts (Already Addressed)
✅ Removed cautious language patterns
✅ Strengthened autonomous decision-making
✅ Eliminated approval escape hatches
✅ Reduced status update spam

### Layer 2: Runtime Configuration (Automation Opportunities)

#### A. Sandbox Policy Automation

**Current State:**
- Requires `approval_policy` configuration
- Manual approval for network access, destructive commands, etc.

**Automation Opportunities:**

1. **Trusted Action Patterns**
   - Create allowlists for common safe operations:
     ```toml
     # ~/.codex/config.toml
     [automation]
     auto_approve_patterns = [
       "npm install",
       "cargo build",
       "pytest",
       "npm test",
       "git status",
       "git diff"
     ]
     ```

2. **Context-Based Auto-Approval**
   - Auto-approve package installs in isolated dev containers
   - Auto-approve destructive actions when working in test branches
   - Auto-approve network access for package managers in known repos

**Implementation Location:**
- `codex-rs/core/src/sandbox/mod.rs` - Sandbox policy engine
- `codex-rs/core/src/config/mod.rs` - Config schema additions

#### B. Proactive Testing Configuration

**Current State:**
- Prompts suggest running tests but behavior varies
- No automatic test detection/execution policy

**Automation Opportunities:**

1. **Auto-Test Detection**
   ```rust
   // Pseudo-code for codex-rs/core/src/testing.rs
   fn detect_test_framework() -> Option<TestFramework> {
       if Path::new("package.json").exists() {
           return Some(TestFramework::Jest);
       }
       if Path::new("Cargo.toml").exists() {
           return Some(TestFramework::Cargo);
       }
       // ... more detection
   }
   
   fn should_auto_test(change: &FileChange) -> bool {
       // Run tests automatically for code changes
       // Skip for docs-only changes
       !change.files.iter().all(|f| f.ends_with(".md"))
   }
   ```

2. **Incremental Testing**
   - Track which files changed
   - Run only affected tests first
   - Full suite only if targeted tests fail

**Implementation Location:**
- New file: `codex-rs/core/src/testing.rs`
- Hook into: `codex-rs/core/src/codex.rs` after patch application

#### C. Commit Message Automation

**Current State:**
- Agent generates commit messages based on conventional commit patterns
- No systematic enforcement or learning from repo history

**Automation Opportunities:**

1. **Commit Style Learning**
   ```bash
   # Analyze last 50 commits to learn style
   git log --oneline -50 --format="%s"
   ```
   
2. **Auto-Commit After Validation**
   ```toml
   [automation]
   auto_commit = true  # Commit after tests pass
   auto_commit_require_tests = true  # Only if tests exist and pass
   ```

**Implementation Location:**
- `codex-rs/core/src/git.rs` - Git operations
- Add commit style analyzer

### Layer 3: Tool Function Enhancements

#### A. Batch Operations

**Current Limitation:**
- One shell command per tool call
- Sequential execution only

**Enhancement:**
```rust
// New tool function: batch_shell
{
  "name": "batch_shell",
  "description": "Execute multiple shell commands in parallel or sequence",
  "parameters": {
    "commands": [
      {"cmd": "npm install", "parallel": false},
      {"cmd": "npm run lint", "parallel": true},
      {"cmd": "npm test", "parallel": true}
    ]
  }
}
```

**Implementation Location:**
- `codex-rs/core/src/tools/shell.rs`

#### B. Smart Patch Application

**Current Limitation:**
- `apply_patch` tool applies one patch at a time
- No automatic conflict resolution

**Enhancement:**
```rust
// Enhanced apply_patch with auto-resolution
{
  "name": "apply_patch",
  "parameters": {
    "patches": [...],
    "conflict_resolution": "auto",  // auto, manual, abort
    "auto_strategies": ["prefer_incoming", "merge_hunks"]
  }
}
```

**Implementation Location:**
- `codex-rs/core/src/tools/patch.rs`

### Layer 4: Workflow Hooks

Create a hook system for automatic actions:

```toml
# ~/.codex/config.toml
[hooks]
# After any file change
post_change = ["just fmt", "cargo clippy --fix --allow-dirty"]

# After applying patches
post_patch = ["cargo test -p {affected_package}"]

# Before committing
pre_commit = ["cargo fmt --check", "cargo clippy"]

# After successful task completion
post_task = ["git add .", "git commit -m '{generated_message}'"]
```

**Implementation:**
```rust
// codex-rs/core/src/hooks.rs
pub struct HookManager {
    config: HookConfig,
}

impl HookManager {
    pub async fn run_hook(&self, event: HookEvent, context: &Context) {
        match event {
            HookEvent::PostChange => {
                for cmd in &self.config.post_change {
                    self.execute(cmd, context).await;
                }
            }
            // ...
        }
    }
}
```

### Layer 5: AGENTS.md Automation Directives

Extend AGENTS.md syntax to support automation rules:

```markdown
# AGENTS.md

## Automation Rules

```yaml
automation:
  # Always run tests after changes
  test_on_change: true
  
  # Auto-format on save
  format_on_change: true
  
  # Allowed to install packages without approval
  trusted_package_managers:
    - npm
    - cargo
    - pip
  
  # Auto-commit when tests pass
  auto_commit:
    enabled: true
    require_tests: true
    require_lint: true
  
  # Parallel operations allowed
  parallel_execution: true
```

**Implementation Location:**
- `codex-rs/core/src/project_doc.rs` - Parse automation section
- Apply during codex initialization

### Layer 6: Learning from User Patterns

**Concept:** Track user approval patterns to auto-approve similar actions

```rust
// codex-rs/core/src/learning.rs
pub struct ApprovalLearner {
    history: Vec<ApprovalDecision>,
}

impl ApprovalLearner {
    pub fn should_auto_approve(&self, action: &Action) -> bool {
        // If user approved this 3+ times, auto-approve
        self.history
            .iter()
            .filter(|d| d.action_similar(action))
            .filter(|d| d.approved)
            .count() >= 3
    }
}
```

Store in `~/.codex/approval_history.json`

## Implementation Priority

### Phase 1: Quick Wins (1-2 days)
1. ✅ Prompt modifications (done in this PR)
2. Add `auto_approve_patterns` config option
3. Add `auto_test` config option
4. Implement post-patch formatting hook

### Phase 2: Core Automation (1 week)
1. Implement hook system (post_change, post_patch, etc.)
2. Add batch_shell tool
3. Implement test framework detection
4. Add AGENTS.md automation section parsing

### Phase 3: Advanced Features (2-3 weeks)
1. Approval learning system
2. Smart conflict resolution in patches
3. Incremental testing based on file changes
4. Parallel operation execution

## Configuration Examples

### Minimal (Safe Defaults)
```toml
# ~/.codex/config.toml
[automation]
auto_test = true  # Run tests after code changes
auto_format = true  # Format after changes
```

### Aggressive (Maximum Autonomy)
```toml
[automation]
auto_test = true
auto_format = true
auto_commit = true
auto_commit_require_tests = true

auto_approve_patterns = [
  "npm install *",
  "pip install *",
  "cargo build",
  "cargo test",
  "npm test",
  "pytest",
  "git status",
  "git diff"
]

[hooks]
post_change = ["just fmt"]
post_patch = ["cargo test -p {package}"]
pre_commit = ["cargo clippy --fix --allow-dirty"]
```

### Shop Mode (Direct, Minimal Interruption)
```toml
[automation]
# Use shop_mode_prompt.md (set in model config)
auto_test = true
auto_format = true
auto_commit = true
auto_approve_patterns = ["*"]  # Trust everything in dev container

[hooks]
post_change = ["just fmt"]
post_patch = ["just fix -p {package}"]
```

## Testing Automation Changes

After implementing automation features:

1. **Unit Tests**
   ```bash
   cargo test -p codex-core automation
   ```

2. **Integration Tests**
   ```bash
   # Test auto-approval
   codex --config test/configs/auto-approve.toml "install pytest"
   # Should not prompt
   
   # Test hooks
   codex --config test/configs/hooks.toml "fix typo in readme"
   # Should auto-format
   ```

3. **Validation Scenarios**
   - Use scenarios from `VALIDATION-SCENARIOS.md`
   - Measure interruption count (target: <2 per task)
   - Measure completion rate (target: >95%)

## Security Considerations

1. **Approval Patterns**: Never auto-approve `rm -rf` or system-level destructive commands
2. **Network Access**: Limit auto-approval to known package managers
3. **Hooks**: Validate hook commands from AGENTS.md (no shell injection)
4. **Learning**: Store approval history per-project, not globally
5. **Escape Hatch**: Always allow `--no-automation` flag to disable

## Related Files

- System prompts: `codex-rs/core/*.md`
- Config: `codex-rs/core/src/config/mod.rs`
- Sandbox: `codex-rs/core/src/sandbox/mod.rs`
- Tools: `codex-rs/core/src/tools/*.rs`
- Project docs: `codex-rs/core/src/project_doc.rs`

## Next Steps

1. Review this guide with the team
2. Prioritize which automation features to implement first
3. Create GitHub issues for each automation enhancement
4. Start with Phase 1 quick wins
5. Iterate based on user feedback

## Metrics to Track

After implementing automation:

- **Interruption Rate**: Messages per task (target: <2)
- **Completion Rate**: % of tasks finished without manual intervention (target: >95%)
- **User Satisfaction**: Surveys on autonomy level
- **Safety**: Count of unintended destructive actions (target: 0)
