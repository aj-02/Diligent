# ZFORECAST Paints (CR-2C) — build contract

Binding for every object in `kpmg/zpp_forecast_paints/src/`. Nothing invents a name that
is not in this file. Where the FS is silent the code carries `" ASSUMPTION:` and the point
is listed in `docs/OPEN_QUESTIONS.md`.

## House rules (from CLAUDE.md — non-negotiable)

- Source lines **under 120 characters**. Everything ships by paste as a fallback and SE38
  wraps long lines on paste.
- **Strict Open SQL**: comma-separated field list; `@` on every host variable, host
  expression and inline declaration — `INTO @lt_tab`, `INTO TABLE @DATA(lt_x)`,
  `FOR ALL ENTRIES IN @lt_y`, `WHERE werks = @lv_werks`.
- Clause order: `INTO`/`APPENDING` **after** `ORDER BY`; `UP TO n ROWS` **after** `INTO`.
- `IS NOT INITIAL` guard before **every** `FOR ALL ENTRIES`.
- No `SELECT` inside a `LOOP` where `FOR ALL ENTRIES` or a join would do.
- `DELETE ADJACENT DUPLICATES` needs a matching `SORT` **outside** any loop, on exactly
  the fields the DELETE compares.
- No hardcoded clients, dates, company codes or sales organisations — VKORG and BWART come
  from `ZPPT_PNT_CFG`.
- Error paths give the user a message. No short dump, no silent skip.
- Selection texts and column headings are readable words, never technical names.
- **Screen-free.** No `CALL SCREEN`, no `MODULE`, no `SET PF-STATUS`, no
  `cl_gui_custom_container`. Everything displays through `CL_SALV_TABLE` full screen.
  This is what keeps the object abapGit-shippable — do not break it.
- New objects, so no BOC/EOC change markers. Object header block uses `DD.MM.YYYY`.
- One `#EC` pseudo-comment per line, only where genuinely needed.

## Object names

| Type | Name | Description |
|---|---|---|
| Package | `ZPP_PNT_FCST` | ZFORECAST Paints - forecasting |
| Message class | `ZPP_PFCST` | ZFORECAST Paints |
| Class | `ZCL_PP_PFCST_UTIL` | FY / quarter / period / conversion helpers |
| Class | `ZCL_PP_PFCST` | Calculation engine |
| Report | `ZPP_PAINT_FORECAST` | Generation, 3 radio modes — tcode `ZPFCST` |
| Report | `ZPP_PAINT_FCST_UPL` | All uploads — tcode `ZPFCST_UPL` |
| Report | `ZPP_PAINT_FCST_RPT` | Final ALV — tcode `ZPFCST_RPT` |
| Number range | `ZPPPFCST` | Forecast number, FY-wise (SNRO, manual) |
| Auth object | `ZPP_PFCST` | `WERKS` + `ACTVT` (SU21, manual) |

## Tables — exact field names

`ZPPT_PNT_PCAT`  MANDT WERKS MATNR (key) · PROD_CAT LOAD_FCT MTS_MTO · ERNAM ERDAT AENAM AEDAT
`ZPPT_PNT_MTRK`  MANDT WERKS NEW_MATNR (key) · OLD_MATNR1 OLD_MATNR2 · admin
`ZPPT_PNT_MEXC`  MANDT WERKS MATNR (key) · admin
`ZPPT_PNT_CFG`   MANDT WERKS (key) · VKORG BWART TVARV_LEGACY · admin
`ZPPT_PNT_SHIST` MANDT WERKS MATNR GJAHR (key) · MEINS M01..M12 · admin
`ZPPT_PNT_FYR`   MANDT WERKS MATNR FYEAR (key) · FCST_NO MAKTX MATKL GEWEI NTGEW BRGEW
                 MVGR1..MVGR5 MEINS M01..M12 LY_TOTAL PROD_CAT LOAD_FCT MTS_MTO
                 FCST_TOTAL M01_FCST..M12_FCST M01_TON..M12_TON · admin
`ZPPT_PNT_FQT`   MANDT WERKS MATNR GJAHR QUARTER (key) · FCST_NO MAKTX MATKL GEWEI NTGEW
                 BRGEW MVGR1..MVGR5 MEINS M4_LAST M5_LAST M6_LAST LY_QTR_TOT
                 M1_CURR M2_CURR M3_CURR L3M_TOT MAX_QTY PROD_CAT LOAD_FCT MTS_MTO
                 FCST_QTY BUS_FCST BUS_FCST_ADD FINAL_QTY M4_FCST M5_FCST M6_FCST
                 M4_TON M5_TON M6_TON REASON · admin
`ZPPT_PNT_FMN`   as FQT but key PERIOD (POPER) instead of QUARTER, `L3M_AVG` instead of
                 `L3M_TOT`, and only `M4_FCST` / `M4_TON`

Admin fields are always filled: ERNAM/ERDAT on insert, AENAM/AEDAT on update, from
`sy-uname` and `sy-datum`.

## Data elements

`ZDE_PNT_FCST_NO` `ZDE_PNT_PROD_CAT` `ZDE_PNT_LOAD_FCT` `ZDE_PNT_MTS_MTO` `ZDE_PNT_FYEAR`
`ZDE_PNT_QUARTER` `ZDE_PNT_FCST_QTY` `ZDE_PNT_VOL_KL` `ZDE_PNT_VAL_CR` `ZDE_PNT_PACK_SZ`
`ZDE_PNT_QTY_CTN` `ZDE_PNT_DPL` `ZDE_PNT_BRAND` `ZDE_PNT_REASON`

## Typing rule for standard fields

Where a standard data element name is not certain, type from the table field directly —
`TYPE t001w-name1`, `TYPE tvm1t-bezei`, `TYPE marm-umren`, `TYPE mvke-aumng`. Never guess
a data element name. `MATNR`, `WERKS_D`, `MAKTX`, `MATKL`, `MEINS`, `GEWEI`, `BRGEW`,
`NTGEW`, `MVGR1`..`MVGR5`, `GJAHR`, `POPER`, `VKORG`, `BWART`, `RVARI_VNAM`, `ERNAM`,
`ERDAT`, `AENAM`, `AEDAT` are confirmed and may be used directly.

## ZCL_PP_PFCST_UTIL — public static methods

All `CLASS-METHODS`, all in the public section, class is `PUBLIC FINAL CREATE PUBLIC`.

    TYPES: BEGIN OF ty_daterange,
             date_from TYPE dats,
             date_to   TYPE dats,
           END OF ty_daterange.

| Method | Importing | Returning | Behaviour |
|---|---|---|---|
| `is_fyear_valid` | `iv_fyear TYPE zde_pnt_fyear` | `rv_valid TYPE abap_bool` | pattern `YYYY-YYYY`, second year = first + 1 |
| `get_fyear_range` | `iv_fyear` | `rs_range TYPE ty_daterange` | 01.04.YYYY to 31.03.YYYY+1 |
| `get_fyear_from_date` | `iv_date TYPE dats` | `rv_fyear TYPE zde_pnt_fyear` | April-March |
| `get_quarter_range` | `iv_fyear`, `iv_quarter TYPE zde_pnt_quarter` | `rs_range` | Q1 Apr-Jun, Q2 Jul-Sep, Q3 Oct-Dec, Q4 Jan-Mar |
| `get_quarter_from_date` | `iv_date` | `rv_quarter TYPE zde_pnt_quarter` | fiscal quarter |
| `get_period_range` | `iv_fyear`, `iv_period TYPE poper` | `rs_range` | period 1 = April |
| `shift_range_years` | `is_range TYPE ty_daterange`, `iv_years TYPE i` | `rs_range` | move a range by n years |
| `get_month_slot` | `iv_date TYPE dats` | `rv_slot TYPE i` | 1..12 where 1 = April |
| `to_tonnage` | `iv_qty TYPE zde_pnt_fcst_qty`, `iv_brgew TYPE brgew` | `rv_ton TYPE zde_pnt_fcst_qty` | qty * brgew / 1000 |
| `to_volume_kl` | `iv_qty`, `iv_pack_sz TYPE zde_pnt_pack_sz` | `rv_kl TYPE zde_pnt_vol_kl` | qty * pack size / 1000 |
| `to_value_cr` | `iv_qty`, `iv_dpl TYPE zde_pnt_dpl` | `rv_cr TYPE zde_pnt_val_cr` | qty * dpl / 10000000 |
| `get_config` | `iv_werks TYPE werks_d` | `rs_cfg TYPE zppt_pnt_cfg` | read ZPPT_PNT_CFG; if no row, raise message 006 as E |
| `get_next_fcst_no` | `iv_fyear` | `rv_fcst_no TYPE zde_pnt_fcst_no` | `NUMBER_GET_NEXT` on object `ZPPPFCST`, range number from the FY (see below) |
| `check_plant_auth` | `iv_werks`, `iv_actvt TYPE activ_auth` | `rv_ok TYPE abap_bool` | `AUTHORITY-CHECK OBJECT 'ZPP_PFCST'` |

Divide-by-zero is never allowed: every division guards the denominator with
`IF <denominator> IS NOT INITIAL` and yields 0 otherwise.

`get_next_fcst_no` derives the number-range interval from the last two digits of the first
year in the financial year (`2026-2027` -> `26`). If `NUMBER_GET_NEXT` raises any exception
the method issues message 021 as E.

## ZCL_PP_PFCST — engine

`PUBLIC FINAL CREATE PUBLIC`. Public types, exact component names:

    TYPES: BEGIN OF ty_annual,
             werks, name1, brand, matnr, maktx, mts_mto,
             mvgr1, mvgr1_txt, mvgr3, mvgr3_txt, mvgr4, mvgr4_txt,
             matkl, pack_sz, dpl, qty_ctn,
             meins, gewei, brgew,
             m01..m12,                       " last year sales, April..March
             ly_total, prod_cat, load_fct, fcst_total,
             m01_fcst..m12_fcst,
             m01_ton..m12_ton,
             m01_kl..m12_kl,
             m01_cr..m12_cr,
             fcst_no,
           END OF ty_annual.
    TYPES tt_annual TYPE STANDARD TABLE OF ty_annual WITH EMPTY KEY.

    TYPES: BEGIN OF ty_quarter,
             werks, name1, brand, matnr, maktx, mts_mto,
             mvgr1, mvgr1_txt, mvgr2, mvgr2_txt, mvgr3, mvgr3_txt,
             mvgr4, mvgr4_txt, mvgr5, mvgr5_txt,
             matkl, pack_sz, dpl, qty_ctn, meins, gewei, brgew, ntgew,
             m4_last, m5_last, m6_last, ly_qtr_tot,
             m1_curr, m2_curr, m3_curr, l3m_tot, max_qty,
             prod_cat, load_fct, fcst_qty, bus_fcst, bus_fcst_add, final_qty,
             m4_fcst, m5_fcst, m6_fcst,
             m4_ton, m5_ton, m6_ton,
             m4_kl, m5_kl, m6_kl,
             m4_cr, m5_cr, m6_cr,
             gjahr, quarter, fcst_no, reason,
           END OF ty_quarter.
    TYPES tt_quarter TYPE STANDARD TABLE OF ty_quarter WITH EMPTY KEY.

    TYPES: BEGIN OF ty_month,
             ... identical to ty_quarter except: l3m_avg replaces l3m_tot,
             only m4_fcst / m4_ton / m4_kl / m4_cr, and period TYPE poper
             replaces quarter,
           END OF ty_month.
    TYPES tt_month TYPE STANDARD TABLE OF ty_month WITH EMPTY KEY.

Component types: `werks TYPE werks_d`, `name1 TYPE t001w-name1`, `brand TYPE zde_pnt_brand`,
`matnr TYPE matnr`, `maktx TYPE maktx`, `mts_mto TYPE zde_pnt_mts_mto`,
`mvgrN TYPE mvgrN`, `mvgrN_txt TYPE tvmNt-bezei` (N = 1..5; for N=4 use `tvm4t-bezei`),
`matkl TYPE matkl`, `pack_sz TYPE zde_pnt_pack_sz`, `dpl TYPE zde_pnt_dpl`,
`qty_ctn TYPE zde_pnt_qty_ctn`, `meins TYPE meins`, `gewei TYPE gewei`,
`brgew TYPE brgew`, `ntgew TYPE ntgew`, every quantity `TYPE zde_pnt_fcst_qty`,
every `_kl TYPE zde_pnt_vol_kl`, every `_cr TYPE zde_pnt_val_cr`,
`prod_cat TYPE zde_pnt_prod_cat`, `load_fct TYPE zde_pnt_load_fct`,
`gjahr TYPE gjahr`, `quarter TYPE zde_pnt_quarter`, `period TYPE poper`,
`fcst_no TYPE zde_pnt_fcst_no`, `reason TYPE zde_pnt_reason`.

### Public methods

| Method | Importing | Returning / Exporting |
|---|---|---|
| `generate_annual` | `it_werks TYPE ty_r_werks`, `it_matnr TYPE ty_r_matnr`, `iv_fyear TYPE zde_pnt_fyear`, `iv_legacy TYPE abap_bool`, `iv_tonnage TYPE abap_bool` | `rt_data TYPE tt_annual` |
| `generate_quarter` | `it_werks`, `it_matnr`, `iv_fyear`, `iv_quarter TYPE zde_pnt_quarter`, `iv_date_from TYPE dats`, `iv_date_to TYPE dats`, `iv_legacy`, `iv_tonnage` | `rt_data TYPE tt_quarter` |
| `generate_month` | `it_werks`, `it_matnr`, `iv_fyear`, `iv_period TYPE poper`, `iv_date_from`, `iv_date_to`, `iv_legacy`, `iv_tonnage` | `rt_data TYPE tt_month` |
| `save_annual` | `it_data TYPE tt_annual`, `iv_fyear` | `rv_fcst_no TYPE zde_pnt_fcst_no` |
| `save_quarter` | `it_data TYPE tt_quarter` | `rv_fcst_no` |
| `save_month` | `it_data TYPE tt_month` | `rv_fcst_no` |

Range table types, declared public on the engine:

    TYPES ty_r_werks TYPE RANGE OF werks_d.
    TYPES ty_r_matnr TYPE RANGE OF matnr.

### Selection of billing data — one SELECT, no loop

    SELECT k~vbeln, k~fkdat, p~werks, p~matnr, p~fkimg, p~meins
      FROM vbrk AS k INNER JOIN vbrp AS p ON p~vbeln = k~vbeln
     WHERE k~fkdat  IN @lt_date
       AND k~fksto  <> 'X'
       AND k~vbtyp  <> 'U'
       AND p~werks  IN @it_werks
       AND p~matnr  IN @it_matnr
       AND p~shkzg  = @space
      INTO TABLE @DATA(lt_bill).

`p~shkzg = @space` on **every** mode. The FS quarterly sheet says "is not equal to blank";
that is a typo — it would return only returns and credits. Mark the line
`" ASSUMPTION: FS quarterly sheet says SHKZG NE blank; annual sheet and Adhesive v2 both`
`" use SHKZG = blank, which is the correct reading. Confirmed in system 21.08.2026.`

VKORG for the MVKE reads comes from `ZPPT_PNT_CFG-VKORG`, never a literal. The FS annual
sheet says 4000 and the quarterly sheet says 1100 — config decides.

### Old-material rollup

For every plant/material in the result, read `ZPPT_PNT_MTRK` and add `MATDOC-MENGE` for
`OLD_MATNR1` / `OLD_MATNR2` over the same `BUDAT` window with `BWART` from config, using
`FOR ALL ENTRIES` (guarded) — never a SELECT in a loop.

### Legacy flag

When `iv_legacy` is set, read `ZPPT_PNT_SHIST` M01..M12 for the plant/material/year and add
into the same month slots. Authorisation for the legacy checkbox is via the TVARVC name in
`ZPPT_PNT_CFG-TVARV_LEGACY`; if the user is not listed, message 027 as E.

### Annual calculation

    ly_total   = sum( m01..m12 )
    fcst_total = ly_total * load_fct
    mNN_fcst   = ( mNN / ly_total ) * fcst_total      " each month uses ITS OWN month
    mNN_ton    = mNN_fcst * brgew / 1000
    mNN_kl     = mNN_fcst * pack_sz / 1000
    mNN_cr     = mNN_fcst * dpl / 10000000

The FS repeats "april 25" on all twelve rows. That is a copy-paste in the sheet: each month
divides by its own last-year month. Carry
`" ASSUMPTION: FS repeats April on all 12 rows; each month uses its own LY month.`

### Quarterly calculation

    ly_qtr_tot = m4_last + m5_last + m6_last          " same 3 months, last year
    l3m_tot    = m1_curr + m2_curr + m3_curr          " 3 months before the quarter, this year
    max_qty    = max( ly_qtr_tot, l3m_tot )
    fcst_qty   = max_qty * load_fct
    final_qty  = max( fcst_qty, bus_fcst + bus_fcst_add )
    m4_fcst    = ( m4_last / ly_qtr_tot ) * final_qty     " and m5, m6 likewise
    mN_ton     = mN_fcst * ntgew / 1000

`bus_fcst` / `bus_fcst_add` are read from the existing `ZPPT_PNT_FQT` row for the same
plant / material / year / quarter, uploaded beforehand by `ZPP_PAINT_FCST_UPL`.

Tonnage uses `NTGEW` in quarterly and monthly, `BRGEW` in annual — that is what the FS says.
Flag it: `" ASSUMPTION: FS uses gross weight annually and net weight quarterly.`

### Monthly calculation

Same as quarterly except `l3m_avg = ( m1_curr + m2_curr + m3_curr ) / 3` and only the one
requested period is produced.

### Save

Forecast number is reused, not regenerated: read the existing row for the key; if
`FCST_NO` is found, keep it and update (AENAM/AEDAT); if not, call
`get_next_fcst_no` and insert (ERNAM/ERDAT). Lock with `ENQUEUE_E_TABLE` on the table name
before the modify and dequeue after. Materials present in `ZPPT_PNT_MEXC` are dropped
before calculation, not at save time.

## Messages — message class ZPP_PFCST

    001 Enter a plant
    002 Financial year &1 is not in the format YYYY-YYYY
    003 Enter either a quarter or a date range, not both
    004 Enter a quarter or a date range
    005 Financial year is mandatory when a quarter is entered
    006 No configuration found for plant &1 in table ZPPT_PNT_CFG
    007 No billing data found for the selection
    008 No forecast data found for the selection
    009 Material &1 is not created in plant &2
    010 Forecast &1 saved for plant &2
    011 Select at least one row
    012 Product category is not maintained for material &1 plant &2
    013 File &1 could not be read
    014 The file contains no data rows
    015 Row &1: plant is missing
    016 Row &1: material is missing
    017 Row &1: &2 is not a valid number
    018 Row &1: quarter &2 must be between 1 and 4
    019 Row &1: financial year &2 is not valid
    020 &1 rows uploaded, &2 rows rejected
    021 Number range object ZPPPFCST is not maintained
    022 Material &1 is excluded from forecast in plant &2
    023 You are not authorised for plant &1
    024 Row &1: reason for change is mandatory
    025 Brand is not maintained for plant &1 material &2
    026 Quarter &1 does not match the entered date range
    027 You are not authorised to use legacy data
    028 Row &1: unit &2 does not match the base unit of material &3
    029 Save cancelled
    030 Forecast &1 updated for plant &2
    031 Row &1: period &2 must be between 1 and 12
    032 Enter a financial year

## Not sourced by the FS — code it, flag it, leave it empty

- **BRAND.** The FS reads `ZPP_BRAND-BRAND` by plant + material. That table is not defined
  anywhere in the document and may not exist. Do **not** SELECT from it — an unknown table
  fails activation. Leave `brand` initial, and put the intended SELECT in a commented block
  directly above with `" ASSUMPTION: ZPP_BRAND not confirmed to exist — enable once the`
  `" structure is supplied.`
- **DPL.** No source table or field is given anywhere in the FS, yet Value in Crores depends
  on it. Leave `dpl` initial, same commented-block treatment. `_cr` columns will therefore
  come out as zero until the source is supplied.

## abapGit XML shapes

Copy shapes from `kpmg/zpp_forecast_v2/src/` **except** for two corrections:

- `DD03P`: `REFTABLE` / `REFFIELD` go **after `ADMINFIELD`, before `NOTNULL`** — v2 puts
  them after `COMPTYPE`, which is out of component order.
- `PROGDIR`: element order is `NAME, VARCL, SUBC, FIXPT, UCCHECK` — v2 emits `SUBC` before
  `VARCL`, which is out of component order.
- `TPOOL` item order is `ID, KEY, ENTRY, LENGTH`. The `R` (title) item carries no `KEY`.
  `LENGTH` is the character length of `ENTRY`.
