# Quick Start - What to Read First

## If You Only Have 5 Minutes

1. **Read SUMMARY.md** - Complete overview of everything done
2. **Skim EDITS.md** - See the exact changes to make
3. **Apply 1 edit** - Pick the most annoying behavior, fix it in your target prompt file
4. **Rebuild & test** - `cd codex-rs && cargo build --release`

That's it. You'll immediately see more decisive, autonomous behavior.

---

## If You Have 15 Minutes

**Day 1: Quick Wins**

1. **Deploy global shop-floor culture:**
   ```bash
   mkdir -p ~/.codex
   # Copy Template 1 from TEMPLATES.md to ~/.codex/AGENTS.md
   ```
   This affects ALL future Codex sessions.

2. **Apply 2-3 key edits** to your main prompt:
   - Edit 1: Personality (kill "friendly")
   - Edit 2: Persistence (remove "unless" escapes)
   - Edit 4: Approval (kill "weigh alternatives")

3. **Rebuild:**
   ```bash
   cd /home/user/codex-63.0/codex-rs
   cargo build --release
   ```

4. **Test with known annoyance:**
   - Task that used to ask permission
   - Should now just do it

---

## If You Have 1 Hour

**Complete Setup:**

### Phase 1: File Organization (Done)
✅ Platform-specific files moved to `.cut/`
✅ Legacy TypeScript CLI archived
✅ Clean tree for better observability

### Phase 2: Apply System Prompt Edits (15 min)

1. **Backup originals:**
   ```bash
   cd /home/user/codex-63.0/codex-rs/core
   cp gpt-5.1-codex-max_prompt.md gpt-5.1-codex-max_prompt.md.orig
   ```

2. **Apply all 6 edits from EDITS.md** to your target prompt

3. **Rebuild:**
   ```bash
   cd ../.. && cd codex-rs
   cargo build --release
   ```

### Phase 3: Deploy AGENTS.md Templates (10 min)

4. **Global template:**
   ```bash
   mkdir -p ~/.codex
   # Copy Template 1 from TEMPLATES.md
   ```

5. **Per-crate templates (optional):**
   ```bash
   # Copy Template 2 to codex-rs/core/AGENTS.md
   # Copy Template 3 to codex-rs/tui/AGENTS.md
   # etc.
   ```

### Phase 4: Validation (20 min)

6. **Run test scenarios from TESTING.md:**
   - Nix hash update task (should auto-fix)
   - Test run task (should auto-run tests)
   - Approval-requiring task (should escalate immediately)

7. **Verify checklist from TESTING.md:**
   - No "friendly" language
   - No permission loops
   - Validation proof in final messages
   - Minimal update spam

### Phase 5: Document Your Findings (15 min)

8. **Track what worked:**
   - Before/after examples
   - Behavior improvements
   - Any remaining issues

9. **Adjust templates if needed**

---

## Reading Order by Goal

### Goal: "I want to understand what's wrong"
1. **PROMPT-SURGERY.md** - Problem analysis
2. **ARCHITECTURE.md** - How it all works

### Goal: "I want to fix it now"
1. **EDITS.md** - Exact changes to make
2. **TESTING.md** - How to validate

### Goal: "I want to customize for my workflow"
1. **TEMPLATES.md** - AGENTS.md examples
2. **ARCHITECTURE.md** - Code flow understanding

### Goal: "I want the complete picture"
1. **SUMMARY.md** - Start here
2. **FILETREE.md** - File locations
3. **ARCHITECTURE.md** - Code internals
4. **PROMPT-SURGERY.md** - Detailed analysis
5. **EDITS.md** - Surgical fixes
6. **TEMPLATES.md** - Deployment examples
7. **TESTING.md** - Validation process

---

## Most Important Files

### For You (Human):
- **SUMMARY.md** - Overview
- **EDITS.md** - What to change
- **TEMPLATES.md** - Ready-to-use configs

### For Codex (Agent):
- **gpt-5.1-codex-max_prompt.md** - Current model's system prompt (edit this)
- **~/.codex/AGENTS.md** - Global user instructions (create this)
- **codex-rs/*/AGENTS.md** - Per-crate instructions (optional)

### Reference:
- **ARCHITECTURE.md** - How it works
- **TESTING.md** - How to validate
- **FILETREE.md** - Where everything is

---

## Common Issues & Quick Fixes

### Issue: "Agent still asks permission for routine ops"

**Likely cause:** AGENTS.md not deployed or prompt not rebuilt after edits

**Fix:**
```bash
# 1. Verify global AGENTS.md exists
cat ~/.codex/AGENTS.md

# 2. Verify prompt edits applied
grep "You MUST keep going" /home/user/codex-63.0/codex-rs/core/gpt-5.1-codex-max_prompt.md

# 3. Verify rebuild happened
ls -lh /home/user/codex-63.0/codex-rs/target/release/codex
# Should show recent timestamp

# 4. Try task again
```

### Issue: "Agent still too verbose/friendly"

**Likely cause:** Edit 1 (Personality) not applied

**Fix:**
- Check line 15 of your prompt file
- Should say "concise, direct, and decisive" NOT "friendly"
- Rebuild if needed

### Issue: "Agent stops after describing plan"

**Likely cause:** Edit 2 (Persistence) not applied

**Fix:**
- Check persistence section of prompt
- Should say "You MUST keep going" NOT "Please keep going"
- Should NOT have "unless" escape hatches
- Rebuild

### Issue: "Tests not running automatically"

**Likely cause:** Edit 5 (Testing) not applied

**Fix:**
- Check testing section
- Should NOT say "hold off on running tests"
- Should say "run tests proactively"
- Rebuild

---

## Success Metrics

You'll know it's working when:
- ✅ Fewer messages during execution (no play-by-play narration)
- ✅ Tests run without asking
- ✅ Hashes update without asking
- ✅ Final messages include validation proof
- ✅ Escalation requests are immediate and direct
- ✅ No "I'll do X later" promises—either does X or explains why not

---

## Next Steps After Initial Setup

1. **Track improvements** - Document before/after behaviors
2. **Refine templates** - Adjust AGENTS.md based on experience
3. **Share learnings** - If changes work well, consider contributing back
4. **Iterate** - Codex behavior is highly tunable; keep experimenting

---

## Emergency Rollback

If something breaks:

```bash
cd /home/user/codex-63.0/codex-rs/core

# Restore original prompts
cp gpt-5.1-codex-max_prompt.md.orig gpt-5.1-codex-max_prompt.md

# Rebuild
cd ../.. && cd codex-rs
cargo build --release

# Remove global AGENTS.md if needed
rm ~/.codex/AGENTS.md
```

Everything is in git, so you can always `git checkout` specific files.

---

## Support & Resources

- **Git history:** `git log --oneline` to see all commits
- **Diffs:** `git show <commit>` to see what changed
- **Docs:** All `.md` files in repo root
- **Original Codex docs:** `docs/` directory

---

**Remember:** You're sandboxed, everything is git-tracked, zero risk. Experiment freely.
