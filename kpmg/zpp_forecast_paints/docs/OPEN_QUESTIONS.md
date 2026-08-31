# ZFORECAST Paints (CR-2C) — questions for Bhavini / the functional team

Everything below is coded to the reading in the right-hand column, flagged in the source as
`" ASSUMPTION:` so it is greppable. Confirm or correct; only items 1 and 2 change output the
user can see as blank today.

## Blocking — the column comes out empty until answered

| # | Question | What the code does today |
|---|---|---|
| 1 | **BRAND.** The FS reads `ZPP_BRAND-BRAND` by plant + material. That table is not defined anywhere in the document. Does it exist in SE11, and with what field names? | The BRAND column is present but left empty. The intended SELECT sits commented out directly above, ready to enable. Selecting from a table that may not exist would fail activation. |
| 2 | **DPL.** No source table or field is given anywhere in the FS, yet "Value in Crores" = DPL x forecast qty / 1,00,00,000 depends on it. Which table and field — a condition record, `MVKE`, or a Z table? | DPL is left empty, so all "Value in Crores" columns come out as zero. Same commented-out treatment. |

## Contradictions in the template — coded to the reading shown

| # | Point | Reading used |
|---|---|---|
| 3 | **VKORG.** Annual logic says `VKORG=4000`, quarterly logic says `VKORG=1100`. | Neither is hardcoded. VKORG comes from `ZPPT_PNT_CFG` per plant, so a wrong value is a config change, not a code change. Which is correct for Paints? |
| 4 | **SHKZG.** Annual says `VBRP-SHKZG = blank`, quarterly says `NE blank`. | `= blank` everywhere. `NE blank` would return only returns and credit notes. Adhesive v2 uses blank, verified in the system 21.08.2026. |
| 5 | **Annual month split.** All twelve month columns read `(april 25 / Total LY Sales Qty) * forecast Qty`. | Each month divides by **its own** last-year month. As written every month would carry April's share. |
| 6 | **Volume in KL / Value in Crores** repeat "April 25" on all twelve rows the same way. | Same fix — each month uses its own forecast quantity. |
| 7 | **Tonnage basis.** Annual says gross weight (`MARA-BRGEW`), quarterly says net weight (`MARA-NTGEW`). | Coded exactly as written — gross annually, net quarterly. Confirm this is deliberate. |
| 8 | **"Total LY Quarter Sales Qty = sum of aug 2025 to sep 25"** names two months for a three-month quarter. | All three months of the quarter (Jul + Aug + Sep for Q2). |
| 9 | **Business forecast source.** The quarterly sheet reads `ZPP_ADH_FORE_QUATER` — the *Adhesive* quarterly table. | Reads the Paints table `ZPPT_PNT_FQT`. Paints reading Adhesive business forecast would be a cross-product-line dependency; assumed a copy-paste from the Adhesive FS. |
| 10 | **Material group labels.** The annual sheet labels MVGR1 / MVGR3 / MVGR4 as "Material Group 1 / 2 / 5"; the quarterly sheet lists MVGR1..MVGR5 properly. | The quarterly mapping is used — MVGR1..MVGR5 to their own text tables. The annual sheet's "2 -> MVGR3, 5 -> MVGR4" is treated as a typo. |
| 11 | **`TVM4T-MVG41`** in the FS is not a field of TVM4T. | Read as `TVM4T-MVGR4`. |
| 12 | **Monthly requirement qty** = `max(...) / 3 * category %`. Divide by three because a quarter's worth is being spread over one month? | Coded as written: the three-month average times the growth factor. |
| 13 | **Final report** marks Plant, Month **and** Quarter mandatory. A row can be annual-only. | Only Plant is mandatory; month and quarter are optional, otherwise annual-only rows are unreachable. |

## Things the FS does not mention that the object needs

| # | Item | Proposal |
|---|---|---|
| 14 | **Number range.** The FS names `ZPP_PAINTS_SNRO` — 17 characters, and SNRO objects are capped at 10. | Renamed `ZPPPFCST`, financial-year-wise intervals. Created in SNRO by hand. |
| 15 | **Table names.** Every table name in the FS exceeds the 16-character limit (`ZPP_PROD_CATEGORY` is 17, `ZPP_MATERIAL_TRACKING` 21, `ZPP_PAINTS_YEAR` is fine but inconsistent). | Renamed to the `ZPPT_PNT_*` set — full mapping in `docs/00_TECHNICAL_OBJECTS.md`. |
| 16 | **Authorisation object.** The FS mentions authorisation only for the legacy-data checkbox, via TVARVC. | Added `ZPP_PFCST` (WERKS + ACTVT) on all three reports, plus the TVARVC check for legacy. Confirm the plant-level check is wanted. |
| 17 | **MTS/MTO domain.** The FS column is "MTS / MTO / DIS ART / TINTING" — four values, not two. | Domain `ZDO_PNT_MTS_MTO`, CHAR 10, fixed values MTS / MTO / DIS ART / TINTING. Confirm the exact codes the business wants stored. |
| 18 | **Growth factor precision.** "Load Factor" / "Growth Based on Category" / "Product category %" appear to be one field. | One field, `LOAD_FCT`, DEC 5.3 — a multiplier such as 1.300, not a percentage. Confirm it is a multiplier and that 99.999 is a safe ceiling. |
| 19 | **Test run on uploads.** Not requested. | Added a "Test run" checkbox on the upload program — validates and shows the log without writing. Cheap, and it prevents a bad file half-loading. |
| 20 | **Update vs insert on re-run.** The FS says reuse the existing forecast number on a re-run. | The save reads the existing row, keeps its `FCST_NO`, and updates with AENAM/AEDAT; a new key inserts with ERNAM/ERDAT. Table is locked with `ENQUEUE_E_TABLE` around the write. |
| 21 | **Decimal commas in upload files.** Not mentioned. | Cells are cleaned before conversion, so "1,5" loads as 1.5. This exact bug was reported on the Adhesive upload. |
| 22 | **What happens to a material with no product category?** The FS gives no rule. | Message 012 names the material and plant; the row is reported, not silently dropped. Confirm the business would rather skip it. |

## Manual objects — abapGit cannot carry these

SNRO number range `ZPPPFCST`; SU21 auth object `ZPP_PFCST`; SE54 table maintenance for
`ZPPT_PNT_PCAT`, `ZPPT_PNT_MTRK`, `ZPPT_PNT_MEXC`, `ZPPT_PNT_CFG`; SE93 transaction codes
`ZPFCST`, `ZPFCST_UPL`, `ZPFCST_RPT`. These are created by hand after the import.
