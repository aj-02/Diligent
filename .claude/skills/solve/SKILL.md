---
name: solve
description: End-to-end fix for a program Arnav has dropped in ~/Downloads — find the source by program name, diagnose the issue he describes, propose the corrected object, and on his approval draft the reply mail into his Outlook Drafts for him to send. Use when he names a program plus a symptom and the code is in Downloads rather than the repo. Triggers on "/solve", "solve ZXXX", "code is in downloads", "I pasted the program in downloads", "check <program> for <issue>", "fix <program>, download is in my downloads folder".
---

# Solve an issue from a Downloads drop

Arnav's loop: paste the SE80 source into `~/Downloads` named after the program, then
name the program and the symptom. This skill takes it from there to a mail sitting in
his Outlook Drafts.

Shared marker, correction, SQL and delivery rules live in `CLAUDE.md` at the repo root.
Read it. This skill does not repeat them — it adds the Downloads intake and the mail hand-off.

There are **two hard stops**: after the proposal (step 5) and before the draft (step 6).
Never run past either one.

## 1. Find the source

```bash
.claude/skills/solve/find-download.sh <PROGRAM_NAME>
```

- **One hit** — use it. Say which file and its timestamp.
- **Several hits** — show them with timestamps and ask which. Never assume the newest;
  `ZFI_BNK_APP.txt` and `ZFI_BNK_APP1.txt` are different programs, not versions.
- **Prefix-match only** (the script says so on stderr) — the download is misspelt, e.g.
  `ZAA_IMPARMENTLOSS.txt` for `ZAA_IMPAIRMENTLOSS`. Confirm with him before reading it.
- **No hit** — the script lists what is actually there. Show that and ask; do not guess.

These are SE80 listings: every line carries a line-number prefix, and the banner repeats
at each page break. `scripts/abap-audit.py` strips both (`unwrap_se80_listing`) — reuse that
logic rather than writing another parser. **Line numbers in the listing are snapshot-bound.
Locate by FORM / MODULE / METHOD name, never by line number.**

## 2. File it into the repo, and drift-check

Downloads is outside git, so nothing there survives the session. Move it in before working:

```bash
./scripts/save-original.sh <client>/<object> ~/Downloads/<FILE>
```

If `<client>/<object>/` does not exist yet, create it with `original/`, `ISSUES.md` and
`NOTES.md` per the repo layout, and say that this object is new to the repo.

`save-original.sh` keeps the first copy as the baseline and reports drift if a later
download differs. **Report what it says before writing any code.** Drift means someone
edited the object in SAP behind us — stop and ask whether to build on the new version.

## 3. Understand the issue

From what he typed, extract: symptom, trigger (tcode, selection values, date range,
company code), and what he expected instead. He sometimes drops the issue text as its own
file (`zfibrs_issue.txt`) — check Downloads for one and read it if present.

If there is no reproducible trigger, ask for one. A fix aimed at a guess is worse than no fix.

## 4. Diagnose, then correct

State the root cause in two or three sentences **before** editing. If you cannot name a
specific cause, say so and list what you would need to see — a dump, ST22 short text, the
selection values, table contents. Never dress a speculative fix as a diagnosis.

Then apply it per `CLAUDE.md`: comment out never delete, BOC/EOC with today's date in
DD/MM/YY, never double-wrap an existing marker, touch only what the issue requires.

Write the **complete** corrected object to `<client>/<object>/` — `src/` for abapGit
objects, a loose `.abap` at the folder root for paste-only ones. State the before/after
line count. Fragments are a failure.

Then check your own work before showing it:

```bash
python scripts/abap-audit.py <client>/<object>/<FILE>.abap
```

Fix what it reports, or say why a finding is a false positive. Do not present a fix that
still has open audit findings without saying so.

## 5. Propose — then STOP

Report in this shape:

**Root cause** — two or three sentences.
**Changed** — table: FORM/MODULE, what changed, why.
**File** — the repo path. Do not dump the program into chat.
**Paste map** — the blocks to paste, each with the anchor line above it.
**Not touched** — what you deliberately left alone, and why. Always include this.
**Risk** — other callers, performance, customising that may differ by client.

Then stop and ask whether the solution looks right. **No mail before he says yes.**
"Looks fine", "ok", "go ahead" is a yes. Silence is not.

## 6. On approval — draft the mail

Ask once who it goes to if he has not said. If he does not name anyone, create the draft
with no recipient and tell him to address it in Outlook.

Use `outlook_create_draft` with `bodyType: "html"`, each paragraph in `<p>...</p>`.
3–6 lines, professional, no flourish, per `CLAUDE.md`. Say what was wrong, what changed,
and what he needs from them (test in which client, on which data). Close exactly:

    Thanks & Regards,
    Arnav Johri | Associate Consultant | Diligent Global

Report the draft's `webLink` so he can open it.

**Create the draft. Never send it.** `outlook_send_draft` and `outlook_send_mail` are out
of scope for this skill regardless of how the approval was phrased — sending stays manual,
in Outlook, by him.

## 7. Record and push

Append the issue → cause → fix line to `<client>/<object>/ISSUES.md`, then:

```bash
./scripts/sync.sh "<client>/<object>: <what changed>"
```

Report the commit hash and the file path. This pushes the repo copy only — it is not
sign-off, and it does not touch SAP.

## Never

- Never write to SAP via the `abap-adt` MCP. It points at a different system.
- Never send the mail. Draft only.
- Never fabricate table, field or CDS element names. If a mapping is unconfirmed, say so.
- Never present an unverified fix as tested. You cannot run it.
