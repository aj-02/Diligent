# ZFI_TDS_CL34 - build contract (pinned decisions)

Every agent on this build works to THIS file. Do not renegotiate these decisions.
Source of truth for requirements: `kpmg/zfi_tds_cl34/docs/FS_EXTRACT.md` (verbatim FS).
Repo rules: `CLAUDE.md` (root) - strict Open SQL, no fragments, etc.
Skeleton + header block: `COPILOT_CONTEXT_HANDOFF.md` sections 8.2 and 8.3.

## Identity

| Item | Value |
|---|---|
| Client / project | KPMG - UDAY / Astral |
| Module | FI |
| Program | `ZFI_TDS_CL34` |
| Includes | `ZFI_TDS_CL34_TOP`, `ZFI_TDS_CL34_SCR`, `ZFI_TDS_CL34_FORMS` |
| Repo folder | `kpmg/zfi_tds_cl34/` |
| Source files | `kpmg/zfi_tds_cl34/src/<lowercase name>.prog.abap` |
| Author (header block) | Arnav Johri, Date 26.08.2026 |
| Title | TDS Report - Clause 34 compliance |
| Related FS | Clause 34 TDS Report FS.xlsx, v1, 21/08/2026 |
| Transport | `<TR>` placeholder - Arnav fills it |
| ALV | `CL_SALV_TABLE` (no editable cells, no grid events needed) |

This is NEW development, not a correction. Therefore **no BOC/EOC change markers**
anywhere in the source - those are for edits to existing objects only. The header
block (section 8.2 format, dots `DD.MM.YYYY`) is the only provenance needed.

## Pinned technical decisions

### D1 - Data source: base tables, not the two CDS views
FS names `I_WITHHOLDINGTAXITEM` and `I_JOURNALENTRY`. We build on `WITH_ITEM` and
`BKPF` instead. Reason: `I_WITHHOLDINGTAXITEM` is a projection over `WITH_ITEM`;
its element names cannot be verified on this landscape (older S/4 release, no ADT
to the real system), and a wrong CDS element name costs an activation cycle.
`WITH_ITEM` / `BKPF` field names are stable across every release. Output is
identical. This must be stated in the TS and in the query sheet.
The whole read is isolated in ONE form (`fetch_wt_items`) so swapping to the CDS
views later is a one-form change.

### D2 - Row granularity
One output row per withholding-tax item = one row per (BUKRS, BELNR, GJAHR, BUZEI,
WITHT, WT_WITHCD) of `WITH_ITEM`. FS objective says "GL wise and document number
wise". Mark as ASSUMPTION in code.

### D3 - Selection screen (FS "Input Screen" tab)
Company Code, Section Code, Vendor Code, Fiscal Year, Posting Date From/To.
Company code, fiscal year and posting date are the FS's "mandatory filter" -> OBLIGATORY.
Never hardcode 1000/4000; FS states them as applicability, not as a filter.
Selection texts are human-readable words.

### D4 - Unverifiable names -> must be resolved by the DDIC recon agents
- `BSEG-GHKON` (FS cols F/G and GLCode tab). Verify against real DDIC.
- `FIWTIN_TAN_EXEM` and `FIWTIN_ACC_EXEM` - real field lists and full key.
- `FIWTIN_EXEM_THR` - is it a field of FIWTIN_TAN_EXEM or a data element?
- `RSEG` has no `BUKRS`; company code lives on `RBKP`.
Anything that cannot be verified gets a `" ASSUMPTION:` comment on the line AND a
row in `docs/QUERIES.md`.

### D5 - Open functional points -> implement a default, flag it, do not stall
- Col J "Nature of Payment": header says header text, logic says `BSEG-SGTXT`.
  Implement SGTXT of the vendor line (LIFNR <> blank). Flag.
- Col W "Threshold Applicability (Y/N)": header says Y/N, description says show the
  amount. Implement: show the amount; blank amount = no threshold maintained. Flag.
- Cols U/V/W/X: `FIWTIN_TAN_EXEM` read by PAN alone can return several rows.
  Implement: the row valid on the document posting date and matching the document's
  withholding tax code/type; if still several, the latest valid-from. Flag.
- Input "Section Code": `BSEG-SECCO` vs `T059Z-QSCOD`. Implement SECCO for the
  selection field (it is an input filter on the document) and QSCOD for output col H
  (FS states QSCOD explicitly there). Flag.
- Rows with zero tax: include a row only where a tax amount or a base amount exists.
  Flag.

### D6 - Non-negotiable code rules (from CLAUDE.md, restated)
- Strict Open SQL everywhere: comma-separated field lists; `@` on EVERY host
  variable, host expression and inline declaration, including `INTO @lt_tab`,
  `INTO TABLE @lt_tab`, `INTO @DATA(ls)`, `FOR ALL ENTRIES IN @lt_tab`.
- Clause order: `INTO`/`APPENDING` after `ORDER BY`; `UP TO n ROWS` / `OFFSET`
  after `INTO`.
- `IS NOT INITIAL` check before EVERY `FOR ALL ENTRIES`.
- No `SELECT` inside a `LOOP` where FOR ALL ENTRIES or a join does the job.
- `SORT` outside the loop, on exactly the fields `DELETE ADJACENT DUPLICATES`
  compares.
- Every error path gives the user a message. No short dump, no silent skip.
- One `#EC` pseudo-comment per line, `"` prefixed, never doubled.
- No hardcoded client, date or company code.
- Complete objects only. Never `" ... rest unchanged ..."`.

## Output columns (FS "Output Screen" tab, cols B..Y = 24 columns + Sr)

Sr | Document number | Vendor Code | Vendor Name | Vendor PAN | GL Code | GL Name |
Section | Section Code Description | Nature of Payment | Document Date (SAP) |
Invoice No. | Invoice Date | Payment Doc No. | Payment Date | Base Amount |
Tax Code | TDS Rate as per section | TDS Rate deducted | TDS Amount | Valid From |
Valid To | Threshold Applicability (Y/N) | Certificate Number |
Cumulative Amount as of now for FY

Column-by-column derivation is in FS_EXTRACT.md sheet "Output Screen" rows 2 and 6.
GL derivation decision tree is in FS_EXTRACT.md sheet "GLCode Logic".

## Deliverables

1. `src/zfi_tds_cl34.prog.abap` - main program
2. `src/zfi_tds_cl34_top.prog.abap` - declarations
3. `src/zfi_tds_cl34_scr.prog.abap` - selection screen
4. `src/zfi_tds_cl34_forms.prog.abap` - all logic
5. `docs/TS_ZFI_TDS_CL34.md` - TS document (template: handoff section 8.7)
6. `docs/QUERIES.md` - open points for Ankita Parikh / Bhavin Suthar
7. `NOTES.md`, `ISSUES.md` - repo convention
