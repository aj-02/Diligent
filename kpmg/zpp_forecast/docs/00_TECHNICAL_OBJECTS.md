# ZPP_FORECAST — Technical Object List & DDIC Definitions

Astral Limited / Project UDAY / Adhesive division / WRICEF **ID-2A** — `ZFORECAST`
Built to the assumption register `FSD/ZFORECAST_Adhesive_Assumptions_and_Queries.docx` (B01–B42).

> **Table naming (Q2 — blocking).** Every table name proposed in the BRD exceeds the SAP
> 16-character limit and cannot be created as written:
>
> | BRD name | Chars | Renamed |
> |---|:--:|---|
> | `ZPP_FORECAST_YEAR` | 17 | `ZPPT_FCST_YR` |
> | `ZPP_FORECAST_QUATER` | 19 | `ZPPT_FCST_QT` |
> | `ZPP_FORECAST_MONTH` | 18 | `ZPPT_FCST_MN` |
> | `ZPP_PRODUCT_CATEGORY` | 20 | `ZPPT_PROD_CAT` + `ZPPT_LOAD_FCT` |
> | `ZPP_FORECAST_EXCLUDE` / `ZPP_MATERIAL_SKIP` | 20 / 17 | `ZPPT_FCST_EXCL` |
> | `ZSD_FORECAST_PER` | 16 | `ZPPT_FCST_PER` (borderline, renamed for consistency) |
>
> Namespace assumed `Z*`, package `ZPP_FORECAST` (Q1 open).

---

## 1. Object inventory

| # | Type | Technical name | Description |
|---|---|---|---|
| 1 | Package | `ZPP_FORECAST` | Adhesive forecasting |
| 2 | Table | `ZPPT_FCST_YR` | Annual forecast |
| 3 | Table | `ZPPT_FCST_QT` | Quarterly forecast |
| 4 | Table | `ZPPT_FCST_MN` | Monthly forecast |
| 5 | Table | `ZPPT_FCST_ADJ` | Additions / subtractions (B25–B27) |
| 6 | Table | `ZPPT_FCST_BUS` | Business (sales) forecast upload |
| 7 | Table | `ZPPT_PROD_CAT` | Product category per plant / material |
| 8 | Table | `ZPPT_LOAD_FCT` | Load factor per plant / category / year / quarter |
| 9 | Table | `ZPPT_FCST_EXCL` | Materials excluded from forecast |
| 10 | Table | `ZPPT_SLS_HIST` | Uploaded 3-year sales history (B12) |
| 11 | Table | `ZPPT_MTS_MTO` | MTS / MTO indicator (B37) |
| 12 | Table | `ZPPT_FCST_CFG` | Billing types + go-live cut-off |
| 13 | Structure | `ZPPS_FCST_ALV` | ALV / working line — all three modes |
| 14 | Structure | `ZPPS_FCST_HIST` | Monthly sales history line |
| 15 | Table type | `ZPPTT_FCST_ALV` | `ZPPS_FCST_ALV` table type |
| 16 | Table type | `ZPPTT_FCST_HIST` | `ZPPS_FCST_HIST` table type |
| 17 | Number range | `ZPPFCST` | Forecast number (B31) |
| 18 | Message class | `ZPP_FORECAST` | Messages |
| 19 | Auth object | `ZPP_FCST` | `WERKS` + `ACTVT` (B41) |
| 20 | Lock object | `EZPPT_FCST_YR` | Lock on plant / material / year |
| 21 | Class | `ZCL_PP_FORECAST_UTIL` | FY, quarter, period and tonnage helpers |
| 22 | Class | `ZCL_PP_FORECAST` | Calculation engine — history, all three modes, save |
| 23 | Report | `ZPP_FORECAST` | Generation program, 3 modes |
| 24 | Report | `ZPP_FORECAST_REPORT` | Final forecast report |
| 25 | Report | `ZPP_FORECAST_UPLOAD` | All three uploads |
| 26 | Tcode | `ZFCST` | Forecast Generation |
| 27 | Tcode | `ZFCST_RPT` | Forecast Report |
| 28 | Tcode | `ZFCST_UPL` | Forecast Upload |
| 29 | Maint. views | `ZPPV_PROD_CAT` `ZPPV_LOAD_FCT` `ZPPV_FCST_EXCL` `ZPPV_MTS_MTO` `ZPPV_FCST_CFG` | SM30 |

---

## 2. Domains and data elements

| Domain | Type | Len | Fixed values |
|---|---|---|---|
| `ZDO_FCST_NO` | CHAR | 10 | — |
| `ZDO_FCST_TYPE` | CHAR | 1 | `A` Annual, `Q` Quarterly, `M` Monthly |
| `ZDO_PROD_CAT` | CHAR | 2 | `A` `B` `C` `D` `E` (extensible) |
| `ZDO_FYEAR` | CHAR | 9 | Pattern `2026-2027` |
| `ZDO_QUARTER` | NUMC | 1 | `1` Q1 Apr–Jun, `2` Q2 Jul–Sep, `3` Q3 Oct–Dec, `4` Q4 Jan–Mar |
| `ZDO_LOAD_FCT` | DEC | 5,3 | — |
| `ZDO_FCST_QTY` | QUAN | 15,3 | — |

Data elements `ZDE_FCST_NO`, `ZDE_FCST_TYPE`, `ZDE_PROD_CAT`, `ZDE_FYEAR`,
`ZDE_QUARTER`, `ZDE_LOAD_FCT`, `ZDE_FCST_QTY`, `ZDE_FCST_REASON` (CHAR 100).

---

## 3. Tables

### 3.1 `ZPPT_FCST_YR` — Annual Forecast (B13–B15)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` | `MANDT` | Client |
| ✔ | `WERKS` | `WERKS_D` | Plant |
| ✔ | `MATNR` | `MATNR` | Material |
| ✔ | `FYEAR` | `ZDE_FYEAR` | Financial year |
| | `FCST_NO` | `ZDE_FCST_NO` | Forecast number (B31) |
| | `PROD_CAT` | `ZDE_PROD_CAT` | Product category |
| | `LOAD_FCT` | `ZDE_LOAD_FCT` | Load factor applied |
| | `LY_TOTAL` | `ZDE_FCST_QTY` | Total last year sales quantity |
| | `FCST_TOTAL` | `ZDE_FCST_QTY` | Annual forecast quantity |
| | `M01` … `M12` | `ZDE_FCST_QTY` | Monthly split, M01 = April (B04) |
| | `MEINS` | `MEINS` | Base unit of measure |
| | `ERNAM` `ERDAT` `ERZET` | | Created by / on / at |

**The key is plant + material + financial year, not the forecast number.** This makes the
BRD rule "same material cannot be saved twice in a financial year" a property of the
data model rather than a coded check — a duplicate save is impossible by construction
(B32). `FCST_NO` carries a **non-unique** secondary index `Z01`, because one forecast
number is drawn per save run and stamped on every material in that run.

### 3.2 `ZPPT_FCST_QT` — Quarterly Forecast (B16–B21)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` / `WERKS` / `MATNR` / `FYEAR` / `QUARTER` | | Key |
| | `FCST_NO` | `ZDE_FCST_NO` | Forecast number |
| | `PROD_CAT` `LOAD_FCT` | | Category and factor |
| | `LY_QTR_QTY` | `ZDE_FCST_QTY` | Last year same quarter total |
| | `L3M_QTY` | `ZDE_FCST_QTY` | Current year last 3 months total |
| | `BASE_QTY` | `ZDE_FCST_QTY` | max of the two (B16) |
| | `FCST_QTY` | `ZDE_FCST_QTY` | Base x load factor (B17) |
| | `BUS_FCST` | `ZDE_FCST_QTY` | Business forecast from upload |
| | `FINAL_QTY` | `ZDE_FCST_QTY` | max(FCST_QTY, BUS_FCST) (B18) |
| | `MTH1` `MTH2` `MTH3` | `ZDE_FCST_QTY` | Month split within the quarter (B20) |
| | `MEINS` + audit fields | | |

### 3.3 `ZPPT_FCST_MN` — Monthly Forecast (B22–B24)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` / `WERKS` / `MATNR` / `FYEAR` / `PERIOD` | `PERIOD` NUMC 2 | Key, 01 = April |
| | `FCST_NO` `PROD_CAT` `LOAD_FCT` | | |
| | `LY_MTH_QTY` | `ZDE_FCST_QTY` | Last year same month |
| | `L3M_AVG` | `ZDE_FCST_QTY` | Last 3 month average (B22) |
| | `AVG_LOAD` | `ZDE_FCST_QTY` | Average x load factor |
| | `REQ_QTY` | `ZDE_FCST_QTY` | max(LY month, avg x load) (B23) |
| | `BUS_FCST` | `ZDE_FCST_QTY` | Business forecast |
| | `FINAL_QTY` | `ZDE_FCST_QTY` | max(REQ_QTY, BUS_FCST) (B24) |
| | `MEINS` + audit fields | | |

### 3.4 `ZPPT_FCST_ADJ` — Adjustments (B25–B27)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` / `WERKS` / `MATNR` / `FYEAR` / `FCST_TYPE` / `PERIOD` / `SEQNR` | | Key |
| | `ADJ_QTY` | `ZDE_FCST_QTY` | Signed — negative is a subtraction (B25) |
| | `REASON` | `ZDE_FCST_REASON` | Mandatory (B27) |
| | `ERNAM` `ERDAT` `ERZET` | | |

Adjustments never overwrite the calculated figure (B26).

### 3.5 `ZPPT_FCST_BUS` — Business / Sales Forecast Upload

Key `MANDT` / `WERKS` / `MATNR` / `FYEAR` / `FCST_TYPE` / `PERIOD`, plus `BUS_QTY`,
`FCST_NO`, audit fields. `PERIOD` holds the quarter for type `Q` and the period for type `M`.

### 3.6 `ZPPT_PROD_CAT` / `ZPPT_LOAD_FCT` (B28)

`ZPPT_PROD_CAT` — key `MANDT` / `WERKS` / `MATNR`, field `PROD_CAT`.
`ZPPT_LOAD_FCT` — key `MANDT` / `WERKS` / `PROD_CAT` / `FYEAR` / `QUARTER`, field `LOAD_FCT`.

`QUARTER = 0` is the annual / default factor. This reconciles the BRD's two conflicting
field lists and delivers "quarter wise load factor will be maintained" (Q3).

### 3.7 `ZPPT_FCST_EXCL` — Excluded Materials (B30)
Key `MANDT` / `WERKS` / `MATNR`. SM30 view `ZPPV_FCST_EXCL`.

### 3.8 `ZPPT_SLS_HIST` — Uploaded Sales History (B12)
Key `MANDT` / `WERKS` / `MATNR` / `GJAHR` / `PERIOD`, plus `SLS_QTY`, `MEINS`, audit fields.

### 3.9 `ZPPT_MTS_MTO` — MTS / MTO (B37)
Key `MANDT` / `WERKS` / `MATNR`, field `MTS_MTO` CHAR 3. Display only.

### 3.10 `ZPPT_FCST_CFG` — Configuration (B09, B12)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` / `WERKS` / `FKART` | | Billing types counting as normal sales (Q4) |
| | `GOLIVE_DT` | `DATS` | Read history table before this date, VBRK/VBRP after (Q5) |

---

### 3.11 `ZPPS_FCST_ALV` — ALV / working structure

One structure serves all three modes; the field catalogue switches columns by mode.
**The component names below are referenced by `ASSIGN COMPONENT` in the code and must
match exactly.**

| Group | Components |
|---|---|
| Selection | `MARK` CHAR1 · `LIGHT` CHAR1 · `STATUS` CHAR1 · `MESSAGE` CHAR100 |
| Key | `FCST_NO` · `WERKS` · `MATNR` · `FYEAR` · `FCST_TYPE` · `QUARTER` · `PERIOD` NUMC2 |
| Master data | `MAKTX` · `MATKL` · `MEINS` · `NTGEW` · `BRGEW` · `GEWEI` · `MVGR1`–`MVGR5` · `MTS_MTO` |
| Category | `PROD_CAT` · `LOAD_FCT` |
| Annual | `LY01`…`LY12` · `LY_TOTAL` · `FCST_TOTAL` · `M01`…`M12` |
| Quarterly | `LY_QTR_QTY` · `L3M_QTY` · `BASE_QTY` · `FCST_QTY` · `MTH1` `MTH2` `MTH3` |
| Monthly | `LY_MTH_QTY` · `L3M_AVG` · `AVG_LOAD` · `REQ_QTY` |
| Common | `BUS_FCST` · `FINAL_QTY` · `ADJ_QTY` · `TOTAL_QTY` |
| Tonnage | `TN01`…`TN12` · `TON_TOTAL` |

All quantity components are `ZDE_FCST_QTY` (QUAN 15,3) with reference field `MEINS`.
`LY01` and `M01` are **April**, in line with B04.

---

## 4. Number range `ZPPFCST`
Object `ZPPFCST`, length 10, interval `01` = `0000000001`–`0999999999`, internal, not buffered.

## 5. Authorisation object `ZPP_FCST`
Class `PP`. Fields `WERKS`, `ACTVT`. Activities `01` Generate/Save, `02` Change/Adjust,
`03` Display, `06` Delete.

## 6. Message class `ZPP_FORECAST`

| No | Type | Text |
|---|---|---|
| 001 | E | Enter a plant |
| 002 | E | Enter a financial year |
| 003 | E | Financial year &1 is not in the format YYYY-YYYY |
| 004 | E | Select only one tonnage option |
| 005 | E | Annual forecast does not exist for plant &1 material &2 year &3 |
| 006 | E | Forecast already exists for plant &1 material &2 year &3 |
| 007 | E | No load factor for plant &1 category &2 year &3 quarter &4, 1.000 used |
| 008 | E | No product category maintained for plant &1 material &2 |
| 009 | I | No data selected for the given criteria |
| 010 | S | Forecast number &1 saved for &2 material(s) |
| 011 | E | No authorisation for plant &1 activity &2 |
| 012 | E | Enter a quarter |
| 013 | E | Enter a month |
| 014 | E | Only a single quarter may be entered |
| 015 | E | Upload file could not be read: &1 |
| 016 | E | Row &1: &2 |
| 017 | S | &1 rows uploaded, &2 rows in error |
| 018 | E | Plant &1 material &2 does not exist |
| 019 | E | Reason is mandatory for an adjustment |
| 020 | E | Configuration missing for plant &1 |
| 021 | S | Forecast deleted for plant &1 material &2 year &3 |
| 022 | E | Select at least one line |
| 023 | W | Material &1 is excluded from forecasting |
| 024 | E | Quantity could not be converted to base unit for material &1 |

---

## 7. Selection screens

### 7.1 `ZPP_FORECAST` (tcode `ZFCST`)

| Block | Element | Type | Notes |
|---|---|---|---|
| Mode | `P_ANN` / `P_QTR` / `P_MTH` | Radio group `MOD` | Annual / Quarter based / Month based |
| Selection | `S_WERKS` | Select-option, obligatory | Plant |
| | `S_MATNR` | Select-option | Material |
| | `P_FYEAR` | Parameter, obligatory | Financial year `2026-2027` |
| | `P_QUART` | Parameter | Quarter — single entry only, obligatory for mode Q |
| | `P_PERIOD` | Parameter | Month — single entry only, obligatory for mode M |
| Options | `P_TONNET` | Checkbox | Tonnage — net weight |
| | `P_TONGRS` | Checkbox | Tonnage — gross weight |
| | `P_SHOWEX` | Checkbox | Also list excluded materials |

`AT SELECTION-SCREEN OUTPUT` greys `P_QUART` unless mode `Q`, and `P_PERIOD` unless mode `M`.

ALV: `CL_GUI_ALV_GRID` on screen `0100`, custom control **`CC_ALV`**, GUI status **`S0100`**
with `SAVE` `DELE` `BACK` `EXIT` `CANC`, title **`T0100`**.

### 7.2 `ZPP_FORECAST_REPORT` (tcode `ZFCST_RPT`)
`S_FCSTNO`, `S_WERKS` (obligatory), `S_MATNR`, `P_FYEAR`, `P_QUART`, `P_PERIOD`. `CL_SALV_TABLE`.

### 7.3 `ZPP_FORECAST_UPLOAD` (tcode `ZFCST_UPL`)
Radio group `TYP`: `P_HIST` sales history · `P_BUS` sales forecast · `P_ADJ` addition/subtraction.
`P_FILE` (F4 file dialog), `P_HEAD` header row, `P_TEST` test run.

---

## 8. Build sequence

1. Domains → data elements → tables → structures → table types
2. Number range, lock object, message class, authorisation object, SM30 views
3. `ZCL_PP_FORECAST_UTIL`
4. `ZCL_PP_FORECAST`
5. `ZPP_FORECAST_UPLOAD` (needed to load history before anything can be tested)
6. `ZPP_FORECAST`
7. `ZPP_FORECAST_REPORT`
8. Config entries in `ZPPT_FCST_CFG` (needs Q4, Q5)
