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
