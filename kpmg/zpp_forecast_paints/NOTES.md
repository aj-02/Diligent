# ZPP_FORECAST_PAINTS — NOTES

## What it is

ZFORECAST for **Paints** — CR-2C, mail "CR -2C Forecast paints" from Bhavini Jain,
31.08.2026, attachment `Forecast Template-Paints.xlsx`. This is the object that
`kpmg/zpp_forecast_v2/` (Adhesive) explicitly kept **out of scope**.

Source document as extracted: `docs/Forecast-Template-Paints.txt`.
The .xlsx binary is not in the repo — the mail connector returns extracted text only.

## Shape of the ask

Same three-mode shape as Adhesive: annual / quarterly / monthly generation, uploads,
final report. WRICEF identity in the sheet lists four items:

1. Yearly, monthly and quarterly data (the generation report)
2. Upload program for last year sales data
3. Upload program for sales forecast
4. Upload program for changes in final forecast qty

Plus the final ALV report with its own selection screen.

## What differs from Adhesive (v2) — do not assume the v2 objects fit

- **Extra ALV columns:** BRAND (from `ZPP_BRAND`), DPL, QTY / CARTON, PACK SIZE,
  Volume in KL, Value in Crores. Adhesive has none of these.
- **MTS/MTO domain is wider:** `MTS / MTO / DIS ART / TINTING` — v2's `ZDO_MTS_MTO`
  is CHAR 3 with values MTS/MTO only. Paints needs a wider domain.
- **Own number range and own tables:** the sheet names `ZPP_PAINTS_SNRO` and
  `ZPP_PAINTS_YEAR`, not the Adhesive ones.
- **Tonnage basis differs between sheets:** annual uses `MARA-BRGEW` (gross weight),
  quarterly uses `MARA-NTGEW` (net weight).
- **Material groups:** annual shows MVGR1 / MVGR3 / MVGR4 labelled "1 / 2 / 5";
  quarterly lists MVGR1..MVGR5 properly.

## Open points in the source document — resolve before coding the engine

1. **VKORG contradiction.** Annual logic says `VKORG=4000`, quarterly logic says
   `VKORG=1100`. Adhesive v2 uses 1100 (in `ZPPT_FCST_CFG`). One of the two is wrong.
2. **SHKZG contradiction.** Annual says `VBRP-SHKZG is equal to blank` (correct — that
   is what v2 does, and it was verified in the system on 21.08.2026). Quarterly says
   `is not equal to blank`, which would select only returns/credits. Reads as a typo.
3. **Monthly split formula is copy-pasted.** Every one of the 12 annual month columns
   reads `(april 25/Total LY Sales Qty) * forecast Qty`. Intent is clearly
   `(that month's LY sales / Total LY Sales Qty) * forecast Qty`. Same for the
   12 "Volume in KL" rows and the Value-in-Crores rows.
4. **`DPL` has no derivation** anywhere in the sheet, yet it drives Value in Crores.
   Source table/field needed.
5. **`ZPP_BRAND` is referenced but never defined** — does the table already exist
   in the system, and with which fields?
6. **Quarterly "Business Forecast" reads from `ZPP_ADH_FORE_QUATER`** — the *Adhesive*
   quarterly table. Either the sheet was copied from Adhesive and should say the Paints
   table, or Paints genuinely reads Adhesive business forecast (unlikely).
7. **"Total LY Quarter Sales Qty = sum of aug 2025 to sep 25"** — two months named for
   a three-month quarter. Means Jul+Aug+Sep for Q2.
8. **Growth factor vs Product category %.** The sheet uses "Load Factor",
   "Growth Based on Category" and "Product category %" for what looks like one field.
9. **Monthly mode wording** is the quarterly text with "month" substituted — the
   divide-by-3 in `Requirement Qty = max(...)/3 * category %` needs confirming.

## Object set

Separate from Adhesive — agreed 31/08/26. Package `ZPP_PNT_FCST`, everything prefixed
`ZPP_PNT_*` / `ZDO_PNT_*` / `ZDE_PNT_*` / `ZCL_PP_PFCST*`. No Adhesive object is touched.
Full inventory and the SE11 fallback field lists: `docs/00_TECHNICAL_OBJECTS.md`.
The contract every object was built against: `docs/00_CONTRACT.md`.

- `ZCL_PP_PFCST_UTIL` — FY / quarter / period / tonnage / KL / crore helpers.
- `ZCL_PP_PFCST` — calculation engine, three modes.
- `ZPP_PAINT_FORECAST` (tcode ZPFCST) — generation, three radio modes.
- `ZPP_PAINT_FCST_UPL` (tcode ZPFCST_UPL) — six upload types with template download.
- `ZPP_PAINT_FCST_RPT` (tcode ZPFCST_RPT) — final ALV.

## Gotchas

- **Screen-free by design, and load-bearing.** Same rule as Adhesive v2: everything
  displays through `CL_SALV_TABLE` full screen, rows are picked with the SALV selection
  column, Save is a SALV toolbar function. Adding `CALL SCREEN` or
  `cl_gui_custom_container` turns the whole folder back into a paste-only object.
- **VKORG and BWART are never hardcoded** — they come from `ZPPT_PNT_CFG` per plant,
  because the FS gives 4000 in one sheet and 1100 in another.
- **BRAND and DPL have no confirmed source.** Both columns are present but empty, with the
  intended SELECT commented out directly above. `ZPP_BRAND` is read by the FS but never
  defined; selecting from a table that may not exist would fail activation.
- **abapGit element order.** Two corrections were applied that v2 does not have — see
  `docs/00_TECHNICAL_OBJECTS.md` §4. If a TABL or PROG dumps on import, that is where to
  look first.
- Tonnage is gross weight annually and net weight quarterly, exactly as the FS says.

## Status

31/08/26 — full object set built to the FS, shipped as one ZIP for a single abapGit import.
Not yet activated on the system. 22 open points for the functional team in
`docs/OPEN_QUESTIONS.md`; of those only BRAND and DPL leave a visible column empty.
