# ZFI_TDS_CL34 — NOTES

## What it is

`ZFI_TDS_CL34` — TDS Report, Clause 34 compliance. New development for KPMG / UDAY —
Astral, module FI, from `Clause 34 TDS Report FS.xlsx` v1 (21/08/2026).

Read-only ALV list of every FI document in which withholding tax was deducted from a
vendor: one row per withholding-tax item, 25 columns, GL wise and document number wise.
Nothing is posted, changed or written.

Four files, all under `src/`:

| File | Lines | What |
|---|---|---|
| `zfi_tds_cl34.prog.abap` | ~94 | Main program — includes and the four event blocks. No logic. |
| `zfi_tds_cl34_top.prog.abap` | ~511 | `TABLES`, `TYPES`, `CONSTANTS`, global `DATA`. No executable statement. |
| `zfi_tds_cl34_scr.prog.abap` | ~101 | The five selection fields, plus the manual-steps checklist as a trailer comment. |
| `zfi_tds_cl34_forms.prog.abap` | ~1938 | Every form routine. |

Companion docs: `docs/TS_ZFI_TDS_CL34.md` (the TS), `docs/DDIC_FACTS.md` (the verified
field list — it overrides both the FS and BUILD_BRIEF §D4), `docs/QUERIES.md` (Q1–Q15,
open points for Ankita Parikh and Bhavin Suthar), `BUILD_BRIEF.md` (the pinned build
contract).

## Shipping: abapGit ZIP, with paste as the fallback

The object is **screen-free by design** — `CL_SALV_TABLE`, no `CALL SCREEN`, no
`cl_gui_custom_container` — which is what makes it ZIP-shippable. Adding any of those
reverts it to paste-only.

**`ZFI_TDS_CL34.zip`** (object folder root) is a full abapGit offline serialisation:

```
.abapgit.xml
src/zfi_tds_cl34.prog.abap        + .prog.xml   SUBC 1, FIXPT, VARCL, UCCHECK, TPOOL (title only)
src/zfi_tds_cl34_top.prog.abap    + .prog.xml   SUBC I
src/zfi_tds_cl34_scr.prog.abap    + .prog.xml   SUBC I
src/zfi_tds_cl34_forms.prog.abap  + .prog.xml   SUBC I
```

The layout deliberately mirrors `ovl/ztest_t001/ZTEST_T001.zip`, the only ZIP in this repo
known to import cleanly here. Two things were stripped after an abapGit *"xml incorrect"*
error on the first attempt, both of them deviations from that reference:

- **`package.devc.xml`** — the reference has none, and it is only needed if abapGit is
  meant to create the package rather than import into an existing one.
- **`TPOOL` entries carrying a `KEY`** — the five selection texts and text symbol `B01`.
  The reference pool holds a title and nothing else, so that is all this one holds.

Consequence: **the ZIP carries the title and the program attributes, not the selection
texts.** Steps 3 and 4 below are manual on both paths. Arnav's decision, 27/08/26.

Re-zip from `src/` rather than reusing the archive if the sources change, and check the
four object names are free in the target before importing.

The steps below apply **when pasting**. Nothing travels with a paste. The same list is the
trailer comment of `ZFI_TDS_CL34_SCR`, so it is in front of whoever pastes the object:

1. Create the three includes as type **INCLUDE (I)**, not as executable programs.
   `ZFI_TDS_CL34_TOP` must **not** carry a `REPORT` / `PROGRAM` statement of its own.
2. `Goto → Attributes`:
   - Title `TDS Report - Clause 34 compliance`
   - **Fixed point arithmetic — tick it.** Every `SELECT` here is strict ABAP SQL
     (comma-separated field lists, `@`-escaped host variables) and will not compile
     without it. The failure text points at the SQL, not at the attribute: *"This ABAP
     SQL statement uses additions that can only be used when the fixed point arithmetic
     flag is activated"*, followed by `Field "LT_CC" is unknown` because the
     inline-declared target was never created. SE38 ticks it for a new program; a
     program created by copy or by a wizard can arrive with it off.
3. `Goto → Text elements → Selection texts` — `S_BUKRS` Company Code, `S_SECCO` Section
   Code, `S_LIFNR` Vendor Code, `P_GJAHR` Fiscal Year, `S_BUDAT` Posting Date. Do **not**
   tick "Dictionary reference": the DDIC labels for `WT_ACCO` and `SECCO` are not the
   words the FS asks for.
4. `Goto → Text elements → Text symbols` — `b01` = `Selection`.

Until 3 and 4 exist the block frame is blank and the fields show their technical names.

## Gotchas

- **The DDIC fact sheet wins.** `docs/DDIC_FACTS.md` was read off a live ADT rig and
  overrides `BUILD_BRIEF.md` §D4 and every field name in `FS_EXTRACT.md`. Three names the
  FS or the brief got wrong and that cost an activation cycle if re-introduced:
  `T059Z-TXT40` does not exist (T059Z has **no** text field — column I is
  `T059OT-TEXT40`, key field `WT_QSCOD`); `SKA1` has no text field either (column G is
  `SKAT-TXT50`); `RSEG` **does** carry `BUKRS`, so there is no RBKP detour.
- **Field-name traps inside the two FIWTIN tables.** The section code is `SECCODE` on
  `FIWTIN_TAN_EXEM` and `SECCO` on `FIWTIN_ACC_EXEM`. Not interchangeable.
- **`BSEG-GHKON` (position 364) is not `BSEG-GKONT` (position 362).** GHKON is the one the
  GL derivation uses. Substituting GKONT silently changes column F.
- **Amount suffixes.** `WT_QSSHH` / `WT_QBSHH` are company-code currency (what the FS
  wants); `WT_QSSHB` / `WT_QBSHB` are transaction currency. Easy to swap by eye.
- **`LFA1-J_1IPANNO` is CHAR 40**, never CHAR 10. And a blank PAN blanks column E *and*
  columns U–Y together — column-wide blanks are a defect to investigate, scattered blanks
  are normal.
- **`RSEG-BUZEI` is NUMC 6 (data element `RBLGP`)**, not the NUMC 3 `BUZEI` of BSEG. The
  two must not be moved into one another.
- **`WITH_ITEM` has six key fields, and `WT_WITHCD` is not one of them.** Any
  `DELETE ADJACENT DUPLICATES` on the driver buffer compares BUKRS/BELNR/GJAHR/BUZEI/WITHT
  and nothing else. (`BUILD_OUTPUT` *sorts* on those five plus `WT_WITHCD` for a
  deterministic display order — that is a sort, not a de-duplication.)
- **D1 — the report reads base tables, not the CDS views the FS names.** `WITH_ITEM` /
  `BKPF` / `BSEG` instead of `I_WITHHOLDINGTAXITEM` / `I_JOURNALENTRY`, because the CDS
  element names cannot be verified on this landscape. `AND w~wt_withcd <> @space` is in
  the driver `WHERE` so both paths return the same rows. The whole withholding read is
  isolated in **`FETCH_WT_ITEMS`** — swapping to CDS later is a one-form change.
- **D5 — five FS ambiguities are implemented as a default and flagged**, not stalled on:
  column J is `SGTXT` of the vendor line; column W is the threshold *amount* under the
  FS's own "(Y/N)" heading; U–X pick the certificate valid on the posting date, latest
  valid-from wins; the input Section Code filters `BSEG-SECCO` while column H displays
  `T059Z-QSCOD`; rows with neither a base nor a tax amount are dropped.
- **Fiscal-year variant is assumed April–March (V3).** `INIT_DEFAULTS` proposes a period
  on that basis. Under a calendar-year variant the proposed `P_GJAHR` and the proposed
  posting-date range contradict each other. Proposal only — both fields are guarded by
  `IS INITIAL`, so a variant or `SUBMIT ... WITH` wins. QUERIES Q15.
- **Reversed (`BKPF-STBLG`) and parked (`BKPF-BSTAT`) documents are reported, not
  excluded.** The FS is silent. QUERIES Q6 — a client decision. Acting on the answer means
  adding both fields to `TY_BKPF`, to the SELECT list and to the WHERE clause.
- **Amount columns carry no ALV currency reference.**
  `CL_SALV_COLUMN_LIST=>SET_CURRENCY_COLUMN` is UNVERIFIED on this release, so nothing
  claims to wire it up. `WAERS` (`T001-WAERS`) is carried in the row and set technical.
  QUERIES Q8 — confirm the method in SE24 before adding it.
- **No heuristic GL guess, anywhere.** A document whose GL cannot be derived keeps its row
  with F and G blank and is counted in one aggregated status message after the list is
  built. Only ONE status message survives on a list screen, which is why `REPORT_GL_GAPS`
  *replaces* the "no documents found" message on an empty run rather than joining it.

## Dependencies

Standard tables read: `WITH_ITEM`, `BKPF`, `BSEG`, `LFA1`, `T001`, `SKAT`, `T059Z`,
`T059OT`, `FIWTIN_TAN_EXEM`, `FIWTIN_ACC_EXEM`, `RSEG`, `EKKN`, `MBEW`, `T030`.
Class `CL_SALV_TABLE`. No Z DDIC object, no message class, no function module.

## Stays manual

Program and include creation in SE38, the "Fixed point arithmetic" attribute, the program
title, selection texts and text symbols, transport release, and anything touching QA or
production. No transaction code is part of this build — the FS did not ask for one.
