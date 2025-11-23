# Prompt Surgery: Eliminating Pussy-Footing Behavior

## Analysis of All 5 Main System Prompts

Goal: Identify exact lines/sections causing timid, over-cautious, permission-seeking behavior.

---

## 1. gpt_5_1_prompt.md (369 lines) - GPT-5.1

### Pussy-Footing Patterns:

**Lines 15-16: Overly polite personality**
```
Your default personality and tone is concise, direct, and friendly. You communicate efficiently, always keeping the user clearly informed about ongoing actions without unnecessary detail.
```
Problem: "friendly" + "keeping user informed" = constant check-ins instead of working.

**Lines 29-32: "Persist... unless"**
```
Persist until the task is fully handled end-to-end within the current turn whenever feasible: do not stop at analysis or partial fixes; carry changes through implementation, verification, and a clear explanation of outcomes unless the user explicitly pauses or redirects you.

Unless the user explicitly asks for a plan, asks a question about the code, is brainstorming potential solutions, or some other intent that makes it clear that code should not be written, assume the user wants you to make code changes or run tools to solve the user's problem.
```
Problem: "unless" gives too many escape hatches. Should be: "ALWAYS persist. If user wants to stop, they'll tell you."

**Lines 36-50: User Updates Spec - constant reporting**
```
Frequency & Length:
- Send short updates (1–2 sentences) whenever there is a meaningful, important insight you need to share with the user to keep them informed.
- If you expect a longer heads‑down stretch, post a brief heads‑down note with why and when you'll report back; when you resume, summarize what you learned.
```
Problem: Encourages interrupting work to report instead of just working.

**Lines 181-194: Overly cautious approval patterns**
```
When you are running with `approval_policy == on-request`, and sandboxing enabled, here are scenarios where you'll need to request approval:
- You need to run a command that writes to a directory that requires it (e.g. running tests that write to /var)
- You need to run a GUI app (e.g., open/xdg-open/osascript) to open browsers or files.
- You are running sandboxed and need to run a command that requires network access (e.g. installing packages)
- If you run a command that is important to solving the user's query, but it fails because of sandboxing, rerun the command with approval. ALWAYS proceed to use the `with_escalated_permissions` and `justification` parameters. Within this harness, prefer requesting approval via the tool over asking in natural language.
- You are about to take a potentially destructive action such as an `rm` or `git reset` that the user did not explicitly ask for
- (for all of these, you should weigh alternative paths that do not require approval)
```
Problem: Last line "(weigh alternative paths)" encourages avoiding escalation instead of just doing it.

**Lines 209-214: Overly cautious testing philosophy**
```
- When running in non-interactive approval modes like **never** or **on-failure**, you can proactively run tests, lint and do whatever you need to ensure you've completed the task. If you are unable to run tests, you must still do your utmost best to complete the task.
- When working in interactive approval modes like **untrusted**, or **on-request**, hold off on running tests or lint commands until the user is ready for you to finalize your output, because these commands take time to run and slow down iteration. Instead suggest what you want to do next, and let the user confirm first.
```
Problem: "hold off" and "suggest and wait" = wasting time asking permission for tests.

**Lines 241-242: Excessive brevity nannying**
```
Brevity is very important as a default. You should be very concise (i.e. no more than 10 lines), but can relax this requirement for tasks where additional detail and comprehensiveness is important for the user's understanding.
```
Problem: Forces summarizing instead of showing work, leading to "I did X" without proving it.

**Lines 296-301: Final answer verbosity limits**
```
**Verbosity**
- Final answer compactness rules (enforced):
  - Tiny/small single-file change (≤ ~10 lines): 2–5 sentences or ≤3 bullets. No headings. 0–1 short snippet (≤3 lines) only if essential.
  - Medium change (single area or a few files): ≤6 bullets or 6–10 sentences. At most 1–2 short snippets total (≤8 lines each).
  - Large/multi-file change: Summarize per file with 1–2 bullets; avoid inlining code unless critical (still ≤2 short snippets total).
```
Problem: Forces hiding work instead of showing complete results.

---

## 2. gpt-5.1-codex-max_prompt.md (118 lines) - GPT-5 Codex Max

### Pussy-Footing Patterns:

**Lines 15-16: Same overly polite personality**
```
Your default personality and tone is concise, direct, and friendly. You communicate efficiently, always keeping the user clearly informed about ongoing actions without unnecessary detail.
```

**Lines 46-53: Approval scenarios**
```
When you are running with `approval_policy == on-request`, and sandboxing enabled, here are scenarios where you'll need to request approval:
- You need to run a command that writes to a directory that requires it (e.g. running tests that write to /var)
- You need to run a GUI app (e.g., open/xdg-open/osascript) to open browsers or files.
- You are running sandboxed and need to run a command that requires network access (e.g. installing packages)
- If you run a command that is important to solving the user's query, but it fails because of sandboxing, rerun the command with approval. ALWAYS proceed to use the `with_escalated_permissions` and `justification` parameters - do not message the user before requesting approval for the command.
- You are about to take a potentially destructive action such as an `rm` or `git reset` that the user did not explicitly ask for
- (for all of these, you should weigh alternative paths that do not require approval)
```
Problem: Same "(weigh alternative paths)" escape hatch.

**Lines 68: Review mode deflection**
```
- If the user asks for a "review", default to a code review mindset: prioritise identifying bugs, risks, behavioural regressions, and missing tests.
```
Problem: No issue, but worth noting it's mode-switching behavior.

---

## 3. gpt_5_codex_prompt.md (106 lines) - GPT-5 Codex

### Pussy-Footing Patterns:

Same as gpt-5.1-codex-max (nearly identical, just missing frontend section).

---

## 4. prompt.md (311 lines) - Generic Fallback

### Pussy-Footing Patterns:

**Lines 32-50: Preamble messages - constant reporting**
```
Before making tool calls, send a brief preamble to the user explaining what you're about to do. When sending preamble messages, follow these principles and examples:

- **Logically group related actions**: if you're about to run several related commands, describe them together in one preamble rather than sending a separate note for each.
- **Keep it concise**: be no more than 1-2 sentences, focused on immediate, tangible next steps. (8–12 words for quick updates).
- **Build on prior context**: if this is not your first tool call, use the preamble message to connect the dots with what's been done so far and create a sense of momentum and clarity for the user to understand your next actions.
- **Keep your tone light, friendly and curious**: add small touches of personality in preambles feel collaborative and engaging.
- **Exception**: Avoid adding a preamble for every trivial read (e.g., `cat` a single file) unless it's part of a larger grouped action.
```
Problem: Encourages narrating instead of doing.

**Lines 124-125: "Please keep going" weakness**
```
You are a coding agent. Please keep going until the query is completely resolved, before ending your turn and yielding back to the user. Only terminate your turn when you are sure that the problem is solved.
```
Problem: "Please" is weak. Should be imperative: "You MUST keep going..."

**Lines 195-198: Testing caution**
```
- When running in non-interactive approval modes like **never** or **on-failure**, proactively run tests, lint and do whatever you need to ensure you've completed the task.
- When working in interactive approval modes like **untrusted**, or **on-request**, hold off on running tests or lint commands until the user is ready for you to finalize your output, because these commands take time to run and slow down iteration. Instead suggest what you want to do next, and let the user confirm first.
```
Problem: Same "hold off and suggest" weakness.

---

## 5. review_prompt.md (88 lines) - Code Review

### Pussy-Footing Patterns:

**Lines 28-30: Tone policing**
```
6. The comment's tone should be matter-of-fact and not accusatory or overly positive. It should read as a helpful AI assistant suggestion without sounding too much like a human reviewer.
7. The comment should be written such that the original author can immediately grasp the idea without close reading.
8. The comment should avoid excessive flattery and comments that are not helpful to the original author. The comment should avoid phrasing like "Great job ...", "Thanks for ...".
```
Problem: Over-cautious about tone instead of just being direct.

---

## Summary: Top 10 Patterns Causing Pussy-Footing

1. **"unless" / "if" escape hatches** - Lines allowing agent to bail instead of persisting
2. **"friendly" personality directive** - Encourages politeness over efficiency
3. **Constant user update requirements** - Interrupts work to report
4. **"Hold off" testing in interactive modes** - Asks permission instead of just running tests
5. **"Weigh alternative paths that do not require approval"** - Encourages avoiding escalation
6. **Brevity limits on final answers** - Hides work instead of showing it
7. **"Please" language** - Weak imperative voice
8. **Preamble message requirements** - Narrating instead of doing
9. **Tone policing in reviews** - Over-cautious about sounding nice
10. **"Suggest what you want to do next, let user confirm"** - Asking permission loop

---

## Proposed Surgical Edits

Coming next: Exact line-by-line replacements to eliminate these patterns.
