# ZFORECAST Paints (CR-2C) — Technical Objects

Astral / UDAY / Paints · built to `Forecast Template-Paints.xlsx`, mail of 31.08.2026.
Counterpart of `kpmg/zpp_forecast_v2/` (Adhesive), which kept Paints out of scope.
Separate object set — no Adhesive object is touched.

## Renaming — forced by SAP limits

| FS name | Chars | Renamed | Why |
|---|:--:|---|---|
| `ZPP_PROD_CATEGORY` | 17 | `ZPPT_PNT_PCAT` | table names cap at 16 |
| `ZPP_MATERIAL_TRACKING` | 21 | `ZPPT_PNT_MTRK` | |
| `ZPP_MATERIAL_EXCLUDE` | 20 | `ZPPT_PNT_MEXC` | |
| `ZPP_SALES_HISTORY` | 17 | `ZPPT_PNT_SHIST` | |
| `ZPP_PAINTS_YEAR` | 15 | `ZPPT_PNT_FYR` | kept in family with the other three |
| *(quarterly, unnamed in FS)* | — | `ZPPT_PNT_FQT` | |
| *(monthly, unnamed in FS)* | — | `ZPPT_PNT_FMN` | |
| *(config, not in FS)* | — | `ZPPT_PNT_CFG` | holds what the FS hardcodes |
| `ZPP_PAINTS_SNRO` | 15 (max **10**) | `ZPPPFCST` | number range objects cap at 10 |

## 1. Object inventory

| Type | Name | Description | Ships by |
|---|---|---|---|
| Package | `ZPP_PNT_FCST` | ZFORECAST Paints - forecasting | ZIP |
| Domain | `ZDO_PNT_FCST_NO` | CHAR 10 | ZIP |
| Domain | `ZDO_PNT_PROD_CAT` | CHAR 2 | ZIP |
| Domain | `ZDO_PNT_LOAD_FCT` | DEC 5,3 | ZIP |
| Domain | `ZDO_PNT_MTS_MTO` | CHAR 10, fixed MTS / MTO / DIS ART / TINTING | ZIP |
| Domain | `ZDO_PNT_FYEAR` | CHAR 9 (`2026-2027`) | ZIP |
| Domain | `ZDO_PNT_QUARTER` | NUMC 1 | ZIP |
| Domain | `ZDO_PNT_FCST_QTY` | QUAN 15,3 | ZIP |
| Domain | `ZDO_PNT_VOL_KL` | QUAN 15,3 | ZIP |
| Domain | `ZDO_PNT_VAL_CR` | DEC 15,3 | ZIP |
| Domain | `ZDO_PNT_PACK_SZ` | QUAN 13,3 | ZIP |
| Domain | `ZDO_PNT_QTY_CTN` | QUAN 13,3 | ZIP |
| Domain | `ZDO_PNT_DPL` | DEC 13,2 | ZIP |
| Domain | `ZDO_PNT_BRAND` | CHAR 40 | ZIP |
| Data elements | `ZDE_PNT_*` (14) | one per domain, plus `ZDE_PNT_REASON` on the **existing** `ZDO_REASON` | ZIP |
| Tables | `ZPPT_PNT_*` (8) | see §2 | ZIP |
| Message class | `ZPP_PFCST` | 35 messages | ZIP |
| Class | `ZCL_PP_PFCST_UTIL` | FY / quarter / period / conversions | ZIP |
| Class | `ZCL_PP_PFCST` | calculation engine | ZIP |
| Report | `ZPP_PAINT_FORECAST` | generation, 3 radio modes | ZIP |
| Report | `ZPP_PAINT_FCST_UPL` | six upload types | ZIP |
| Report | `ZPP_PAINT_FCST_RPT` | final ALV | ZIP |
| Number range | `ZPPPFCST` | FY-wise intervals | **SNRO, by hand** |
| Auth object | `ZPP_PFCST` | WERKS + ACTVT | **SU21, by hand** |
| TMG | `ZPPT_PNT_PCAT` `ZPPT_PNT_MTRK` `ZPPT_PNT_MEXC` `ZPPT_PNT_CFG` | SM30 maintenance | **SE54, by hand** |
| Tcodes | `ZPFCST` `ZPFCST_UPL` `ZPFCST_RPT` | | **SE93, by hand** |

## 2. Table field lists — for SE11 if the ZIP will not import

Every quantity field takes a reference: `ZDE_PNT_FCST_QTY` fields reference `MEINS` of the
same table, `*_TON` / `NTGEW` / `BRGEW` reference `GEWEI`. Delivery class A, table
maintenance allowed on the four config tables. Admin block on every table is
`ERNAM ERDAT AENAM AEDAT`.

**ZPPT_PNT_PCAT** — product category and growth factor
key `MANDT` `WERKS`(WERKS_D) `MATNR`(MATNR) · `PROD_CAT` `LOAD_FCT` `MTS_MTO` · admin

**ZPPT_PNT_MTRK** — new / old material tracking
key `MANDT` `WERKS` `NEW_MATNR`(MATNR) · `OLD_MATNR1` `OLD_MATNR2` (MATNR) · admin

**ZPPT_PNT_MEXC** — materials excluded
key `MANDT` `WERKS` `MATNR` · admin

**ZPPT_PNT_CFG** — configuration
key `MANDT` `WERKS` · `VKORG` `BWART` `TVARV_LEGACY`(RVARI_VNAM) · admin

**ZPPT_PNT_SHIST** — legacy sales history
key `MANDT` `WERKS` `MATNR` `GJAHR` · `MEINS` `M01`..`M12` · admin

**ZPPT_PNT_FYR** — annual forecast
key `MANDT` `WERKS` `MATNR` `FYEAR`(ZDE_PNT_FYEAR)
`FCST_NO` `MAKTX` `MATKL` `GEWEI` `NTGEW` `BRGEW` `MVGR1`..`MVGR5` `MEINS`
`M01`..`M12` `LY_TOTAL` `PROD_CAT` `LOAD_FCT` `MTS_MTO` `FCST_TOTAL`
`M01_FCST`..`M12_FCST` `M01_TON`..`M12_TON` · admin

**ZPPT_PNT_FQT** — quarterly forecast
key `MANDT` `WERKS` `MATNR` `GJAHR` `QUARTER`(ZDE_PNT_QUARTER)
`FCST_NO` `MAKTX` `MATKL` `GEWEI` `NTGEW` `BRGEW` `MVGR1`..`MVGR5` `MEINS`
`M4_LAST` `M5_LAST` `M6_LAST` `LY_QTR_TOT` `M1_CURR` `M2_CURR` `M3_CURR` `L3M_TOT`
`MAX_QTY` `PROD_CAT` `LOAD_FCT` `MTS_MTO` `FCST_QTY` `BUS_FCST` `BUS_FCST_ADD`
`FINAL_QTY` `M4_FCST` `M5_FCST` `M6_FCST` `M4_TON` `M5_TON` `M6_TON` `REASON` · admin

**ZPPT_PNT_FMN** — monthly forecast
as `ZPPT_PNT_FQT`, but key carries `PERIOD`(POPER) instead of `QUARTER`, `L3M_AVG`
replaces `L3M_TOT`, and only `M4_FCST` / `M4_TON` are present.

## 3. Where the FS is silent

See `docs/OPEN_QUESTIONS.md` — 22 points, of which BRAND and DPL leave a column empty
until answered. Everything else is coded to a stated reading and flagged in the source
as `" ASSUMPTION:`.

## 4. Shipping

`.abapgit.xml` at the folder root (`STARTING_FOLDER /src/`, `FOLDER_LOGIC PREFIX`);
`src/` holds the package, 13 domains, 14 data elements, 8 tables, the message class (35 messages),
2 classes and 3 reports. Import via `ZABAPGIT_STANDALONE` -> New Offline Repo ->
Import package from ZIP -> Pull.

**Two element-order corrections** were applied that `kpmg/zpp_forecast_v2/src/` does not
have, both of which are the known `CX_XSLT_FORMAT_ERROR` signature on this landscape:

- `DD03P`: `REFTABLE` / `REFFIELD` sit after `ADMINFIELD` and before `NOTNULL`.
  v2 emits them after `COMPTYPE`.
- `PROGDIR`: order is `NAME, VARCL, SUBC, FIXPT, UCCHECK`. v2 emits `SUBC` before `VARCL`.

If the import still dumps, §2 above is the SE11 fallback and the `.abap` files paste
directly into SE24 / SE38.
