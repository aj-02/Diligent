---
name: fix-issue
description: Correct an ABAP object for a reported issue. Use when Arnav reports a bug, error, dump, or change request against a Z object and wants the corrected code back for review. Handles the SE80-download workflow — drift check, targeted fix with BOC/EOC markers, paste map. Triggers on "issue in", "error in", "dump in", "fix ZXXX", "user says", or a pasted issue mail.
---

# Fix an ABAP issue

Follow these steps in order. Do not skip step 2 — it is the step that prevents
silently reverting someone else's change.

## 1. Establish what you are fixing

Extract from the issue text: object name, symptom, who reported it, and the exact
trigger (transaction, selection values, movement type, date range). If the symptom
has no reproducible trigger, ask for one before writing code — a fix aimed at a
guess is worse than no fix.

Locate the object: `<name>/src/` in this repo, or a file in `incoming/`.

## 2. Drift check — mandatory

Ask: "Is this a fresh SE80 download, or the repo copy?"

If fresh, diff it against `<object>/src/`:

```bash
diff -u <object>/src/<file>.abap incoming/<file>.abap
```

Report the result before doing anything else:

- **No drift** — say so in one line, continue.
- **Drift found** — stop and show it. Someone changed the object outside this repo.
  Ask whether to build on the new version or investigate the difference first.

If Arnav supplies only the repo copy, say plainly that you are working from a copy of
unknown age and that a fresh download is safer.

## 3. Diagnose before editing

State the root cause in two or three sentences before touching a line. If you cannot
name a specific cause, say that, and list what you would need to see (a dump, ST22
short text, the selection screen values, table contents). Do not write a speculative
fix and present it as a diagnosis.

## 4. Apply the fix

Read `CLAUDE.md` and follow its marker and correction rules exactly:
comment out, never delete; DD/MM/YY dates; never double-wrap markers; touch only what
the issue requires.

## 5. Report back in this shape

**Root cause** — two or three sentences.

**Changed** — a table: file, line range, what changed and why.

**Full corrected source** — write the complete file to `<object>/src/`, and tell Arnav
the path. Do not dump a whole 2000-line program into chat.

**Paste map** — for the copy-paste path, the exact blocks to paste, each with the
anchor line above it so he can find the spot in SE80. This is what he needs when
abapGit is not available.

**Not touched** — what you deliberately left alone, and why. Always include this.

**Risk** — anything that could break elsewhere: other callers of a changed method,
performance on large selections, dependence on customising that may differ by client.

## 6. Stop

Do not commit, do not build a ZIP, do not touch git. Wait for Arnav to verify.
When he approves, `/ship-fix` takes over.

## Never

- Never write to SAP via the `abap-adt` MCP. It points at a different system.
- Never fabricate table or field names. If you need to confirm one exists, ask.
- Never present an unverified fix as tested. You cannot run it.
