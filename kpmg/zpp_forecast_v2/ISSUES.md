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
