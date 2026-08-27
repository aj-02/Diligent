# Issues — ZFI_TDS_CL34

Running log: issue → cause → fix → TR → date. Newest last.

Object: `ZFI_TDS_CL34` (+ `_TOP` / `_SCR` / `_FORMS`) | KPMG — UDAY / Astral | FI
FS: Clause 34 TDS Report FS.xlsx v1, 21/08/2026 | Owners: Ankita Parikh (FI/TDS),
Bhavin Suthar (MM / account determination)

| Date | Issue | Cause | Fix | TR |
|---|---|---|---|---|
| 26/08/26 | New development from Clause 34 TDS Report FS.xlsx v1 | — | `ZFI_TDS_CL34` + `_TOP` / `_SCR` / `_FORMS` built; 25-column ALV, base tables per build decision D1 | `<TR>` |
| 27/08/26 | Round-1 hardening pass | Diagnostic counters lost on an empty result; "Fixed point arithmetic" not on the paste checklist; reversed/parked and fiscal-year-variant assumptions unmarked in the source; empty `CATCH` would draw an ATC P3; unreachable `p_gjahr IS INITIAL` check; TS / NOTES / ISSUES missing | Empty-result path now issues the diagnostic message instead of the generic one; manual-steps checklist (incl. **Fixed point arithmetic**) added to `_SCR`; two `" ASSUMPTION:` markers added; `##NO_HANDLER` on the `FORM txt` catch; dead `p_gjahr IS INITIAL` check removed; `docs/TS_ZFI_TDS_CL34.md`, `NOTES.md`, `ISSUES.md` written; QUERIES Q13–Q15 registered | `<TR>` |
| 27/08/26 | Review finding not applied as proposed | Review called the second `IF gt_dockey IS INITIAL` guard (before the BKPF `FOR ALL ENTRIES`) dead code and asked for its removal. It is unreachable, but removing it would have left the only unguarded `FOR ALL ENTRIES` in the program, against BUILD_BRIEF D6 / CLAUDE.md ("`IS NOT INITIAL` before EVERY `FOR ALL ENTRIES`") and an ATC check — and an empty driver reads all of BKPF | Guard **kept**; a comment now states it cannot fire, why it is kept anyway, and that the live guard is the one before the BSEG read | `<TR>` |
| 27/08/26 | No authorisation check anywhere in the program | Build decision D1 moved the read off `I_WithholdingTaxItem`, which is authorisation-filtered by its own DCLS, onto raw `WITH_ITEM` / `BKPF` / `BSEG`. A base-table `SELECT` performs no check of its own, so any user who could start the report saw TDS base amounts, tax amounts, vendor names and vendor PANs for every company code they typed | New `FORM check_authorisation`: `F_BKPF_BUK` (`BUKRS`, `ACTVT` = `03`) against every company code the selection resolves to. Called from `VALIDATE_SELECTION` (dialog, `TYPE 'E'`) **and** from `START-OF-SELECTION` — `AT SELECTION-SCREEN` does not run in a background job started from a variant, so a check placed only there would have left every scheduled run unprotected. Object name registered as QUERIES Q16 | `<TR>` |
| 27/08/26 | `GT_GLMSG-REASON` / `GT_GLAMB-REASON` collected on every failed document and never surfaced | `REPORT_GL_GAPS` emitted counts only, so a user told "GL could not be derived for 37 document(s)" could not tell a missing `GHKON` from a missing logistics invoice — and columns F/G are blank either way | Distinct reasons folded into the one surviving status message, capped at 170 characters with the overflow marked, since the status bar truncates without warning | `<TR>` |
| 27/08/26 | Review asked for the col X heading to be reverted to the FS spelling "Ceritificate" | Reviewer held it inconsistent with col W, which keeps the FS's own contradictory "(Y/N)" heading | **Not applied.** A misspelling has one defensible reading and correcting it changes nothing anyone has to decide; an unresolved question about what a column *contains* has to stay visible until the business answers it. The two FS defects are different in kind. Source comment now states the distinction; both stay logged as Q13 and Q4 | `<TR>` |
| 27/08/26 | Five FS instructions had been implemented differently from the FS | The departures rested on a DDIC read taken from the ADT development system at `192.168.11.21` clnt 200, which is **not** the Astral landscape. A field list from the wrong system is not evidence about this one, and the FS is the signed document | **Reverted to the FS as written**, all five: [B2] driver now reads `I_WithholdingTaxItem` ⋈ `I_JournalEntry`; [I2] col I from `T059Z-TXT40`; [K2]/[M2] cols K/M from `BSEG-H_BUDAT` / `H_BLDAT`; [G2] `KTOPL` hardcoded `'ASTL'` via `GC_KTOPL_GL`; [H27] `MBEW` keyed on `RSEG-WERKS`. Each carries the fallback in a source comment and a row in QUERIES (Q12, Q9, Q17, Q18, Q19). One departure kept — see next row | `<TR>` |
| 27/08/26 | GLCode tab "For records having AWKEY as RMRP" NOT implemented literally | The FS contradicts itself two rows later: "provide first 10 digits of AWKEY in BELNR of RSEG and Fiscal year in GJAHR". A field cannot both equal `RMRP` and hold a 10-digit invoice number plus a year. `RMRP` is `BKPF-AWTYP` | Tested on `AWTYP`. Unlike the five reverted above this one **fails silently** — `AWKEY = 'RMRP'` matches nothing, every PO invoice would drop to the direct-FI branch and col F would be wrong for most of the report with no error. Registered as Q14 for Bhavin | `<TR>` |
| 27/08/26 | Object had no abapGit packaging | Only loose sources existed; the manual-steps block assumed paste-only delivery | `.abapgit.xml`, `src/package.devc.xml` and a `.prog.xml` per program written. The main program's `TPOOL` carries the title, all five selection texts and text symbol `B01`, and its `PROGDIR` carries `FIXPT` / `UCCHECK` — so an import needs no manual text maintenance. `ZFI_TDS_CL34.zip` built from `src/`. The `_SCR` manual-steps block now distinguishes the ZIP path from the paste path | `<TR>` |

## Open, not yet defects

Tracked in `docs/QUERIES.md` (Q1–Q15). The ones that would change a number on the report:

- **Q1** column Y accumulation rule — `FIWTIN_ACC_EXEM` is keyed by `SECCO` (Ankita).
- **Q2** columns U–X certificate pick — `SECCODE` / `FIWTIN_TANEX_SUB` unrestricted (Ankita).
- **Q3** is a valuation grouping code active (OMWM)? `T001K-BWMOD` unverified (Bhavin).
- **Q11** is `BSEG-GHKON` populated on the `KTOSL='WIT'` line? Blank ⇒ F/G blank for every
  direct FI posting. Fallback order `GKONT` → `WITH_ITEM-HKONT_OPP`; one-field switch.
- **Q10** is `LFA1-J_1IPANNO` populated? Blank ⇒ E and U–Y blank together.
- **Q6** reversed / parked documents — reported today; needs a client decision.
- **Q12** *(highest)* do `I_WithholdingTaxItem` / `I_JournalEntry` exist with the FS's
  element names? If not the program will not activate. Try this first (Basis).
- **Q9** does `T059Z` carry `TXT40`? Also an activation-stopper if not.
- **Q17** is `BSEG-H_BUDAT` populated? Blank ⇒ K and U–Y blank together.
- **Q18** do both 1000 and 4000 run chart of accounts `ASTL`?
- **Q19** is valuation at plant level (`BWKEY` = `WERKS`)?
- **Q20** should customer withholding items be excluded (no `KOART` filter today)?
- **Q16** is `F_BKPF_BUK` the right authorisation object? If it is wrong the report refuses
  every company code and nobody can run it (Basis).

## Before the next change

Ask for a fresh SE38 download (`ZR_PROG_DOWNLOAD`, program + include tree) and diff it
against `src/` before editing. The repo copy is a snapshot, not necessarily the running
version. Locate by FORM name, never by line number.
