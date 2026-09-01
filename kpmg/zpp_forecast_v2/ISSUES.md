# Issues — ZPP_FORECAST_V2

Log format: date | issue | root cause | files changed | commit | TR


---

## 31/08/26 — user review round 1, seven points

Raised by Arnav from the functional/user review of the first cut. All seven are
in this one change set. Author tag `Arnav`, date `31/08/26`.

### 1. Legacy data not available → fall back to the standard tables

- **Issue:** with the Legacy Data checkbox ticked the run read `ZPPT_SLS_HIST`
  and nothing else. A plant/material/month the legacy file did not cover was
  reported as zero, and a material with no legacy row at all vanished from the
  list — the SAP history sitting in VBRK/VBRP or MATDOC was never looked at.
- **Cause:** `IF iv_legacy = abap_true. mt_hist = read_legacy( ). ELSE. …` — the
  two sources were exclusive.
- **Fix:** legacy is now the *preferred* source, not the only one. The standard
  source is always read (billing for annual/quarterly, MATDOC 601 for monthly),
  the superseded-material consolidation is applied to it, and new private method
  `MERGE_MISSING` inserts every plant/material/month bucket that legacy does not
  already carry. Legacy always wins where it has a figure. New message 023 says
  how many buckets were filled that way.
- **Cost:** in legacy mode the standard SELECT now always runs. That is the
  point of the fix, but it makes a legacy run as expensive as a normal one.
- **Files:** `src/zcl_pp_fcst.clas.abap` (all three GENERATE methods +
  `MERGE_MISSING`), `src/zpp_fcst.msag.xml` (023).

### 2. Quarter based planning showed M1/M2 instead of month names

- **Issue:** the quarterly and monthly lists headed their columns "LY Month 1",
  "Current Month 1", "Month 1". Only the annual list named its months.
- **Cause:** the quarterly/monthly headings were hardcoded neutral text, because
  the calendar month behind each column depends on the quarter chosen.
- **Fix:** new `FORM month_headings` draws the real month — `Jul-25`, `Aug-25`,
  `Sep-25` for the comparison quarter, `Apr-26`…`Jun-26` for the three months
  before the plan, and the planned months themselves. `LY_QTR_TOT` is headed
  "Total LY Q2 Sales Qty". The neutral texts are still written first and remain
  the fallback if the quarter cannot be resolved.
- **Also fixed on the way:** quarter based planning accepts a date range instead
  of a quarter, in which case `P_QUART` was blank and the class was asked to plan
  quarter `""`. New `FORM resolve_quarter` fills global `G_QUART` from the
  quarter, or from the first date of the range, and that is what is passed to
  `GENERATE_QUARTERLY` and used for the headings.
- **Files:** `src/zpp_forecast.prog.abap`.

### 3. Net weight from MARA-NTGEW

- Already sourced from `MARA-NTGEW` / `MARA-GEWEI` in `FILL_MASTER_DATA` and
  already the only figure `TO_TONNAGE` multiplies by — confirmed, commented in
  the code, and the column now carries the heading "Net Weight" (it previously
  fell back to the DDIC label). No calculation change.
- **Files:** `src/zcl_pp_fcst.clas.abap`, `src/zpp_forecast.prog.abap`.

### 4. MTS/MTO column on Annual forecasting

- `MTS_MTO` was drawn on the quarterly sheet only. It is now in the annual
  column list too, immediately after Product Cat. — it is maintained alongside
  the category on `ZPPT_PROD_CAT`, so no new source is needed. The
  `GC_SHOW_EXTRAS` block no longer re-appends it for annual, which would have
  listed the column twice.
- **Files:** `src/zpp_forecast.prog.abap`.

### 5. Price column on all three radio buttons — logic pending

- New `TY_ALV-PRICE`, drawn on all three modes with the heading "Price".
  **It is empty**: where the figure comes from is still open with the functional
  team, marked `" ASSUMPTION:` in the class.
- Typed as a plain `P LENGTH 13 DECIMALS 2` and deliberately **not** over a CURR
  data element — a CURR column with no currency reference makes SALV raise
  `CX_SALV_DATA_ERROR`. Display only, written to no table, so no DDIC object
  changes and the abapGit ZIP is unaffected.
- **Open with the functional team:** source of the price (MVKE/VBRP/KONV/other),
  whether it is per base UoM, which currency, and whether it must be stored.
- **Files:** `src/zcl_pp_fcst.clas.abap`, `src/zpp_forecast.prog.abap`.

### 6. System does not let the user save

- **Cause 1 — the Save button never existed.** `DISPLAY` called
  `set_screen_status( pfstatus = 'PF_STATUS' report = sy-repid )`, and this
  program has no GUI status and cannot have one: it is screen-free so that the
  object ships by abapGit, and SE41 statuses are not serialised. SALV therefore
  fell back to its own toolbar every time and `ZSAVE` was never raised.
  **Fix:** the list is closed first and `FORM save_prompt` then asks
  "Save n forecast row(s) for 2026-2027?" through `POPUP_TO_CONFIRM` — no GUI
  status needed. Skipped when the Save checkbox already saved, when there is
  nothing to save, or when the user has no `01` authority.
- **Cause 2 — the Save checkbox had no selection text.** `P_SAVE` was missing
  from the textpool, so it drew as a nameless checkbox. Added as
  "Save Forecast to Database".
- **Cause 3 — no number range.** `NUMBER_GET_NEXT` on `ZPPFCST` cleared the
  number when the SNRO object or interval was missing, every annual row was then
  refused with message 021, and quarterly/monthly cascaded into message 005.
  **Fix:** new `NUMBER_FROM_TABLE` derives the next number from `ZPPT_FCST_YR`
  when SNRO cannot serve it. **SNRO `ZPPFCST` must still be created** — the
  fallback has no concurrency protection; it is marked `" ASSUMPTION:`.
- **Cause 4 — misleading failure message.** A run where every row was refused
  reported 017 "Select at least one line". New message 022 says how many rows
  were refused and points at the reasons; 017 is now only for a genuinely empty
  selection.
- **Files:** `src/zpp_forecast.prog.abap`, `src/zpp_forecast.prog.xml`,
  `src/zcl_pp_fcst.clas.abap`, `src/zpp_fcst.msag.xml` (022).

### 7. Upload: take the Excel file itself, and a template per radio button

- **Issue A — the program could not read an Excel file.** `GUI_UPLOAD` was
  called with `FILETYPE 'ASC'` and `HAS_FIELD_SEPARATOR`, which reads *tab
  separated text*. Handed a real `.XLSX` it read the zip container as text, so
  every row came back as rubbish or as nothing.
  **Fix:** `.XLSX / .XLSM / .XLS` are read as binary and parsed with
  `CL_FDT_XL_SPREADSHEET` (first worksheet, columns taken **by position** — the
  class names components from the sheet's heading row, which users retype).
  `.CSV` is read comma separated with quoted values understood, anything else
  tab separated with comma as a fallback. A file that will not parse gives
  message 024 telling the user to save it as CSV, instead of an empty list.
- **Issue B — one template button for eight layouts.** The single application
  toolbar button served whichever radio button was selected. Every radio button
  now has its own "Download Template" pushbutton on its line; the toolbar button
  is kept and still serves the selected type. The eight radio button texts moved
  from the selection texts into `SELECTION-SCREEN COMMENT` fields, because a
  parameter inside `BEGIN OF LINE` does not draw its selection text.
- **Issue C — template format.** The template was written as `.txt`, which Excel
  opens through the import wizard; a user who clicked past it got every column
  in one cell. It is written as `.csv` now, which opens straight into columns,
  and the message says row 2 is an example to overwrite or delete.
- **Header row:** `CL_FDT_XL_SPREADSHEET` consumes the heading row itself, so
  deleting on the checkbox alone threw away the first real row. `FORM
  drop_header` matches row 1 against the template's first heading and deletes it
  either way; the checkbox is only used for a text file whose first row is
  something else.
- **Files:** `src/zpp_forecast_upload.prog.abap`,
  `src/zpp_forecast_upload.prog.xml`, `src/zpp_fcst.msag.xml` (024).

### Not touched, deliberately

- No forecast formula changed. The two prose-vs-example disagreements recorded in
  `docs/00_TECHNICAL_OBJECTS.md` §9 stand as they were.
- `ZPP_FORECAST_REPORT` (the Final ALV) is unchanged — the Price and MTS/MTO
  requests were against the three radio buttons of `ZPP_FORECAST`. Say if the
  Final ALV needs them too.
- No DDIC object changed, so the existing `src/` DDIC XMLs and the ZIP layout are
  untouched. Price is display only; if it has to be stored, `ZPPT_FCST_YR/QT/MN`
  each need a new field and that is a separate change.
- Still screen-free — no `CALL SCREEN`, no `cl_gui_custom_container`, no GUI
  status. The object remains abapGit-shippable.

### Still manual

SNRO `ZPPFCST` (see cause 3 above — the fallback is not a replacement),
SE93 tcodes, SU21, the four SM30 views.

---

## 31/08/26 — activation round 1, and the hardcoding Arnav called out

### Syntax check: 16 x "'PLANT' and the row type of CT_HEAD are incompatible"

- **Where:** `ZPP_FORECAST_UPLOAD`, lines 283/285/290/292/... — two per upload
  type, eight types, sixteen errors.
- **Cause:** the rows of a `VALUE` **table** constructor must be *compatible*
  with the row type on this release, not merely convertible.
  `ct_head = VALUE #( ( 'PLANT' ) ... )` puts C literals into a `STRING_TABLE`
  whose row type is `STRING`, and every row was refused. Nothing to do with the
  31/08 change set — the construct was in the first cut of the program; it had
  simply never been through a syntax check on the real system.
- **Fix:** no table is built from literals any more. `APPEND` converts and is
  used throughout — the same statement `ZPP_FORECAST` already builds its column
  list with a few lines further down.
- **Found by grep, not by the user:** `ZPP_FORECAST` carried the identical
  construct — `ct_show = VALUE tt_fname( ( 'WERKS' ) ... )` over `LVC_FNAME` —
  and would have thrown the same error on its own activation. Replaced with
  `APPEND` before it was hit.
- **Release note added to NOTES.md**, alongside the existing `LVC_T_FNAME` one.

### "Why are we hardcoding things?"

Fair. The upload templates were the one place in this object where real business
data was written into the program:

- plant `1001`, materials `FG00000000001` / `FG00000000002`, year `2026` / `2025`,
  category `A`, load factor `1.300`, UoM `EA` — a whole sample row per type;
- every column heading as a literal, which drifts from the field it loads the
  first time someone renames that field in SE11.

**Fixed.** `TEMPLATE_COLUMNS` now holds only the table and field each column
loads, in file order. The heading is the DDIC label of that field, read through
`DDIF_FIELDINFO_GET` (long text, then medium, then field text, then the field
name) by new `FORM field_label`. Rename a field's label in SE11 and the template
follows it. The twelve legacy-history columns are the exception — they are all
`ZDE_FCST_QTY`, so the dictionary label is the same twelve times; they are named
from the financial calendar by the existing `PERIOD_TEXT`, which is what labels
the result list, so template and log agree.

The sample row is gone with it. What a column means is the heading's job; what a
valid value is belongs to the validation messages, which already name every rule.
Say if an example row is wanted back and it can be generated from each field's
own DDIC type rather than from invented master data.

**Deliberately left as they are** — these are configuration with a documented
source, not stray literals: `GC_VKORG_DEFAULT` 1100 and `GC_BWART_DEFAULT` 601 in
`ZCL_PP_FCST` (the FS names both, and `ZPPT_FCST_CFG` overrides them per plant
with no code change); the 1900-2999 year sanity range; object names `ZPP_FCST`,
`ZPPFCST`; and the template *file* names, which are there so the user recognises
the download.

- **Files:** `src/zpp_forecast_upload.prog.abap` (1956 -> 2090),
  `src/zpp_forecast.prog.abap`.

---

## 31/08/26 — MTS/MTO and Price on the Final ALV

Follow-up to point 4 and point 5 of the review round: the same two columns are
wanted on `ZPP_FORECAST_REPORT`, not only on the three radio buttons of
`ZPP_FORECAST`.

- **MTS/MTO** — taken from `ZPPT_FCST_YR-MTS_MTO`, which the annual save already
  writes, so most rows cost nothing. A forecast saved before the category was
  maintained carries a blank; `ZPPT_PROD_CAT` fills it in, read **once** with
  `FOR ALL ENTRIES` alongside the two reads already there rather than a
  `SELECT SINGLE` per row. Drawn with the material attributes, after Material
  Group, which is where the annual sheet puts it.
- **Price** — drawn last and **empty**, exactly as on the three planning modes.
  Same `P LENGTH 13 DECIMALS 2` typing and the same `" ASSUMPTION:` note; a CURR
  column with no currency reference makes SALV raise `CX_SALV_DATA_ERROR`.
- No DDIC change: neither column is stored by this report, it only displays.
- **Files:** `src/zpp_forecast_report.prog.abap` (365 -> 413).
