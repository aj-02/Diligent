# Issues — ZPP_FORECAST_V2

Log format: date | issue | root cause | files changed | commit | TR


## 02/09/26 — ZPP_FORECAST, four refinements from Arnav (points 2, 3, 4)

| # | Point | Cause / change | Where |
|---|-------|----------------|-------|
| 2 | Quarterly sheet must show `BUS_FCST_ADD` before the max-of-two field | `FINAL_QTY` is `nmax( FCST_QTY, BUS_FCST )` (`ZCL_PP_FCST` line ~520). `BUS_FCST_ADD` was only appended in the `gc_show_extras` block, i.e. never on the live sheet | `FORM visible_columns`, quarterly branch — `BUS_FCST_ADD` inserted between `BUS_FCST` and `FINAL_QTY`; the duplicate append in the extras block removed |
| 3 | No popup on save; drop the Save checkbox | `MESSAGES_SHOW` popup ran after every save; `p_save` also saved the whole run before the list was drawn | `p_save` withdrawn, `PERFORM save_all` and `FORM save_all` commented out, `show_log( )` replaced by `result_message( )` — one status line. `show_result( )` un-hides `FCST_NO` / `MESSAGE` after the Save button runs, which is what `p_save` used to do up front |
| 4 | Hide the Legacy checkbox when the switch is blank | New `g_legc_on`, read once in `INITIALIZATION` by `FORM legacy_switch`; `p_legc` carries `MODIF ID LGC` and is suppressed in `AT SELECTION-SCREEN OUTPUT` | ASSUMPTION: switch is TVARVC parameter `ZPP_FCST_LEGACY` ('X' / blank). Single reader, so the source swaps in one place |

TR: not yet · Files: `kpmg/zpp_forecast_v2/src/zpp_forecast.prog.abap`

## 02/09/26 — ZPP_FORECAST_UPLOAD, general result message (point 1)

Detail column repeated the uploaded values back at the user one row at a time
("History of X Y will now be reported under Z", "Business forecast 100, final
quantity now 250"). Replaced with a flat statement of what was uploaded; the
Result column (Created / Changed / Would create / Would change / Rejected) and
the closing "Upload finished: n created, n changed, n rejected" already carry
the outcome.

| FORM | Was | Now |
|------|-----|-----|
| `do_category` | `Category C, load factor 1.05, MTS` | `Product category uploaded` |
| `do_tracking` | `History of M1 M2 will now be reported under M3` | `Material mapping uploaded` |
| `do_exclusion` | `Already excluded, entry refreshed` / `Excluded from forecasting` | `Exclusion uploaded` |
| `do_history` | `Twelve months loaded, year total 1200 KG` | `Sales history uploaded` |
| `do_business` | `Business forecast 100, final quantity now 250` | `Business forecast uploaded` |
| `do_change` | `Change 50, final quantity now 300, reason RSN` | `Forecast change uploaded` |

Rejected rows keep their full reason — without it the user cannot correct the
file. `lv_total` in `do_business` was only computed for the removed text, so its
declaration and both assignments are commented out; the `lv_total` in `do_change`
stays, it guards the negative-quantity check.

TR: not yet · Files: `kpmg/zpp_forecast_v2/src/zpp_forecast_upload.prog.abap`

## 02/09/26 — ZPP_FORECAST_UPLOAD, 16 activation errors (pre-existing)

`"'PLANT' and the row type of 'CT_HEAD' are incompatible"` × 16, all in
`FORM template_columns`. Not caused by the point-1 change — the lines are
original code that had not been activated on this release before.

Root cause: a text literal `'PLANT'` is type `C`. On this release the row of a
`VALUE #( ( ... ) )` short form must be **compatible** with the row type, and
`C` is not compatible with `STRING`, which is the row type of `STRING_TABLE`.
All 16 `ct_head` / `ct_demo` assignments hit it; the `cv_name = '...'` lines did
not, because a plain MOVE into a `STRING` variable is a conversion and allowed.

Attempt 1 — string templates, `( |PLANT| )`: **rejected the same way.** So the
problem is not C-vs-STRING; this release will not take a constructor expression
with a literal row over an elementary line type at all, whatever the literal's
type.

Attempt 2 — plain `APPEND 'PLANT' TO ct_head.`: **this is the fix.** APPEND
assigns by conversion rather than by compatibility. All 16 assignments rewritten
as APPEND blocks; the one blank example cell appends a cleared `lv_blank TYPE
string` so no literal is involved there either.

Same shape corrected pre-emptively in `ZPP_FORECAST`, which had not been pasted
yet: the leading `ct_show = VALUE tt_fname( ( 'WERKS' ) ... )` block in
`FORM visible_columns` (pre-existing) and `lt_res` in `LCL_HANDLER=>SHOW_RESULT`
(added 02/09/26) are both APPEND now.

**Rule for this landscape: do not use `VALUE` with literal rows over an
elementary line type. Use APPEND.** Structured-row `VALUE #( ( sign = 'I' ... ) )`
in `ZCL_PP_FCST` is a different shape and is not affected.

TR: not yet · Files: `kpmg/zpp_forecast_v2/src/zpp_forecast_upload.prog.abap`,
`kpmg/zpp_forecast_v2/src/zpp_forecast.prog.abap`

## 02/09/26 — ZPP_FORECAST, two defects found on pre-paste read

Found by reading the file before it went to SE38, not by an activation error.

1. `LCL_HANDLER=>SHOW_RESULT` — on a **second** press of Save, neither `FCST_NO` nor
   `MESSAGE` is appended to `GT_SHOW` again, so `lines( gt_show )` returned the same
   number for both and `set_column_position` handed the two columns the same slot,
   shuffling the column order. Position now taken from `sy-tabix` when the column is
   already in the list. Cosmetic, no dump.
2. `p_legc` could still be forced on when the legacy switch is blank. `INITIALIZATION`
   runs **before** a selection-screen variant is transferred, so `CLEAR p_legc` there
   loses to a variant with the box ticked, and to `SUBMIT ... WITH p_legc = 'X'`. Hiding
   the checkbox only stops a user typing it. The switch is now re-asserted at
   `START-OF-SELECTION`, which runs last and runs in background and under SUBMIT too.

Unverifiable from the code, flagged rather than changed: `set_technical( abap_false )` +
`refresh( )` after `display( )` has run — the reveal-on-save mechanism. If the two columns
do not appear on screen after Save, the fallback is to list them from the start.

TR: not yet · Files: `kpmg/zpp_forecast_v2/src/zpp_forecast.prog.abap`

## 03/09/26 — CR of 02/09/26 built: month split, price columns, 5-material tracking

Everything in the CR except the price *logic*, which is still pending. `PRICE` is stored
and read but never derived, so it is 0 and both value columns compute to 0. When the
source is known, populate `PRICE` and `WAERS` — nothing else has to change.

**DDIC**

| Object | Change |
|---|---|
| `ZDO_FCST_VAL` | new domain, CURR 15,2 |
| `ZDE_FCST_PRICE` `ZDE_FCST_VAL` | new data elements over it |
| `ZPPT_FCST_QT` | `BUS_FCST_ADD` and `REASON` **removed**; added `BUS_FCST_ADD1/2/3`, `M4/M5/M6_FCST_FINAL`, `REASON1/2/3`, `WAERS`, `PRICE`, `M4/M5/M6_VAL`, `M4/M5/M6_TON_VAL` |
| `ZPPT_MAT_TRACK` | added `OLD_MATNR3/4/5` |

`ZPPT_FCST_MN` is untouched — the monthly table is already one row per month, so its
`BUS_FCST_ADD` and `REASON` stay.

**Code**

| Object | Change |
|---|---|
| `ZCL_PP_FCST` | `ty_alv` carries the new fields; quarterly reads the three additionals, the three reasons, `WAERS` and `PRICE` back (SAVE writes with CORRESPONDING, so anything not read would be blanked); per-month final and value computed in the split loop; material tracking walks 5 old codes in three places |
| `ZPP_FORECAST_UPLOAD` | quarterly change template gains `MONTH` at column 4, everything after shifts right; `do_change` resolves column offsets by mode; the change lands on `BUS_FCST_ADDn` / `REASONn` for the month it names; negative guard is now per month, not per quarter; tracking template gains 3 columns; `check_chain` and the duplicate checks walk 5 codes; new `FORM qt_finals`; `final_qty` lost its never-read `CV_ADD` parameter |
| `ZPP_FORECAST` | quarterly sheet shows `BUS_FCST_ADD1/2/3`, the three finals, `PRICE`, the six value columns and `WAERS`. Annual sheet carries no price |
| `ZPP_FORECAST_REPORT` | `QTR_ADD` is now `ADD1+ADD2+ADD3` — the report shows the quarter on one line |

Assumptions, all stated to Arnav and unchallenged: `month` is 1/2/3 **within the quarter**;
the CR's lines 12–13 naming `BUS_FCST_ADD1` for months 2 and 3 were a copy-paste slip;
the monthly change upload is untouched.

`M4_TON`/`M5_TON`/`M6_TON` still hold the tonnage of the forecast, not of the final. The
tonnage *value* columns use the final's tonnage. Flag if that should be consistent.

TR: not yet · ZIP rebuilt from `src/`, 39 files

## 03/09/26 — quarterly change upload: MONTH is the fiscal period, not a slot

Arnav confirmed "quarter 2 i.e. month 4 5 6". The first build read MONTH as 1/2/3 within
the quarter, which matched the CR's example row (Quarter 2, month 1) but not his intent.

MONTH is now the **fiscal period 1-12**, 1 = April, 12 = March — the same numbering the
monthly uploads already use. It must fall inside the quarter on the same row
(`period_to_quarter( month ) = quarter`), so Q1 takes 1-3, Q2 takes 4-6, Q3 takes 7-9,
Q4 takes 10-12. A mismatch is rejected with "Month 7 is not in quarter 2".

The column the value lands in is `month - ( quarter - 1 ) * 3` → 1, 2 or 3, which picks
`BUS_FCST_ADD1/2/3` and `REASON1/2/3`. Template demo row changed from month 1 to month 4.

Note for the TS: `M4_FCST` / `M5_FCST` / `M6_FCST` are named after Q2 but always hold the
first, second and third month of whichever quarter is run — Q4 fills them with Jan, Feb,
Mar. Pre-existing, not introduced here.

TR: not yet · Files: `kpmg/zpp_forecast_v2/src/zpp_forecast_upload.prog.abap`
