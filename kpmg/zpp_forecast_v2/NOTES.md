# ZPP_FORECAST_V2 — NOTES

## What it is

ZFORECAST (Adhesive), Astral / UDAY, built to `Forecast Template-Adhesive.xlsx` dated
20.08.2026. Paints (WRICEF ID-2B) out of scope. **Supersedes `zpp_forecast/` (v1).**

- `ZCL_PP_FCST` — calculation engine (global class).
- `ZCL_PP_FCST_UTIL` — FY / quarter / period / tonnage helpers (global class).
- `ZPP_FORECAST` (tcode ZFCST) — three radio modes.
- `ZPP_FORECAST_REPORT` (tcode ZFCST_RPT) — final ALV.
- `ZPP_FORECAST_UPLOAD` (tcode ZFCST_UPL) — eight upload types, each with its own
  Download Template button on the line of its radio button. Reads a real `.XLSX`
  (`CL_FDT_XL_SPREADSHEET`), a `.CSV`, or tab separated text; templates download as
  `.csv`.

## Gotchas

- **Screen-free by design, and that is load-bearing.** Everything displays through
  `CL_SALV_TABLE` full screen: there is no SE51 screen and no SE41 GUI status anywhere in the
  repo — rows are picked with the standard SALV selection column instead of a checkbox, and
  Save is added to the SALV toolbar. A grep for `CALL SCREEN` / `^MODULE ` / `SET PF-STATUS` /
  `cl_gui_custom_container` across `src/*.abap` returns nothing. This is precisely what makes
  the object abapGit-shippable and why v1 was rewritten. **Do not reintroduce `CALL SCREEN`
  or `cl_gui_custom_container` here** — doing so converts the whole repo back to paste-only.
- `LVC_T_FNAME` is not available in every release, so the column-name list is typed locally
  over `LVC_FNAME`.
- **Do not build an internal table with a `VALUE` constructor over literals here.** The
  rows of a `VALUE` table constructor must be *compatible* with the row type on this
  release, not merely convertible, so `VALUE #( ( 'PLANT' ) )` into a `STRING_TABLE`
  (row type `STRING`) and `VALUE tt_fname( ( 'WERKS' ) )` (row type `LVC_FNAME`) are both
  refused — "'PLANT' and the row type of CT_HEAD are incompatible", 16 of them in the
  upload program on 31/08/26. `APPEND` converts; use it. Structured rows with named
  components (`VALUE #( ( sign = 'I' ... ) )`) are fine and are used in `ZCL_PP_FCST`.
- **Upload template headings come from the DDIC, not from the program.** `TEMPLATE_COLUMNS`
  lists the table and field behind each column; `FIELD_LABEL` reads the label through
  `DDIF_FIELDINFO_GET`. There is no sample data row — see ISSUES.md 31/08/26.
- Every table name in the source document exceeds SAP's 16-character limit and had to be
  renamed (`ZPP_ADH_FORECAST_YEAR` → `ZPPT_FCST_YR`, etc.); `ZPP_ADHESIVE_SNRO` → `ZPPFCST`
  because number range objects are capped at 10. The rename table is in
  `00_TECHNICAL_OBJECTS.md`.
- `ZDO_REASON` (CHAR 40) already exists and is reused, not created.
- Sources are exactly as the document specifies: annual and quarterly from VBRK / VBRP
  summing `VBRP-FKIMG`; monthly from MATDOC `BWART 601` summing `MATDOC-MENGE`; old material
  codes from MATDOC; legacy flag from `ZPPT_SLS_HIST` M01–M12. `VBRP-SHKZG` was verified in
  the system on 21.08.2026 against the FS wording.
- Two places where the document's prose and its worked example disagree are documented in
  `00_TECHNICAL_OBJECTS.md` §9 — **read that before "fixing" a formula**.
- **Save has no button and cannot have one.** There is no GUI status and SE41
  statuses are not serialised by abapGit, so `set_screen_status` always failed and
  SALV fell back to its own toolbar. Saving is driven by the `P_SAVE` checkbox and,
  when that is not ticked, by a `POPUP_TO_CONFIRM` raised after the list is closed
  (`FORM save_prompt`). Do not "fix" this by adding a GUI status — that makes the
  whole object paste-only again.
- **The number range fallback is not a substitute for SNRO.** `NUMBER_FROM_TABLE`
  derives a forecast number from `ZPPT_FCST_YR` when `NUMBER_GET_NEXT` on `ZPPFCST`
  cannot serve one, so a system without the SNRO object can still save. It has no
  concurrency protection. `ZPPFCST` must still be created in SNRO.
- **Legacy data is preferred, not exclusive.** With the Legacy checkbox on, the
  standard source is still read and `MERGE_MISSING` fills every plant/material/month
  bucket `ZPPT_SLS_HIST` does not carry. Legacy wins where it has a figure. This
  makes a legacy run cost the same as a normal one.
- **`TY_ALV-PRICE` is empty by design.** The column is drawn on all three modes; the
  source and the calculation are still open with the functional team. It is typed
  `P LENGTH 13 DECIMALS 2` rather than over a CURR data element, because a CURR
  column with no currency reference makes SALV raise `CX_SALV_DATA_ERROR`, and it is
  written to no table — storing it would need a new field on all three forecast
  tables.
- `ZPPT_FCST_CFG` holds what the document hardcodes (VKORG default 1100, BWART default 601,
  legacy TVARVC name) so config changes need no code change. MTS/MTO lives on
  `ZPPT_PROD_CAT`, not in a table of its own.
- Do not mix DDIC or class names with v1 — the inventories genuinely differ (see
  `zpp_forecast/NOTES.md`).

## Dependencies

8 tables, 7 domains, 8 data elements, message class `ZPP_FCST`, number range `ZPPFCST`,
auth object `ZPP_FCST` (WERKS + ACTVT), SM30 views `ZPPV_PROD_CAT` / `ZPPV_MAT_TRACK` /
`ZPPV_MAT_EXCL` / `ZPPV_FCST_CFG`, tcodes ZFCST / ZFCST_RPT / ZFCST_UPL.

## Shipping: abapGit ZIP

The only object in this repository that ships this way cleanly. `.abapgit.xml`
(`STARTING_FOLDER /src/`, `FOLDER_LOGIC PREFIX`) is correctly at the ZIP root; `src/` holds
package.devc, the 2 classes, 3 reports, 7 domains, 8 data elements, 8 tables and msag
`zpp_fcst`. Built `ZPP_FORECAST.zip` = 36 files.

Import via `ZABAPGIT_STANDALONE` → New Offline Repo → Import package from ZIP → Pull.

**Re-zip from `src/` rather than trusting the existing archive** — `ZPP_FORECAST.zip` was
rebuilt 23.08 while several `src/` XMLs date from 20–21.08.

## Stays manual regardless

SE93 tcodes ZFCST / ZFCST_RPT / ZFCST_UPL · SNRO `ZPPFCST` · SU21 `ZPP_FCST` ·
SE54 for the four SM30 views.

## Duplicate copies — none authoritative except `src/`

`zpp_forecast_v2/zcl_pp_fcst_nocomments.abap` is a comment-stripped paste copy of the engine
for when SE24 paste is preferred over an import, and `zpp_forecast_v2_nocomments.abap` exists
at the repository root as well. Both drift silently from
`src/zcl_pp_fcst.clas.abap`, which is the source of truth — keep them in step or delete them.
