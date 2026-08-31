# Issues — ZPP_FORECAST_V2

Log format: date | issue | root cause | files changed | commit | TR


---

## 31/08/26 — ZPP_FORECAST_UPLOAD, review of the upload program

Found by review of the repo copy, not by a user report. No fresh SE80 download was
available, so the repo copy was the baseline. Nothing had been loaded through the
program yet, so no data needs correcting. `ZPP_FCST` had to change with it (two new
messages), so the message class goes in first.

| # | Issue | Root cause | Fix |
|---|---|---|---|
| 1 | "File Row" in the result list pointed at the wrong line | the heading and the blank rows were deleted out of `GT_RAW`, then `SY-TABIX` of the trimmed table was reported | rows are copied into `GT_ROW`, each keeping the line number it has in the file |
| 2 | A plant cell with a leading blank was rejected against a plant the user never typed | `cv_werks = pv_in` cut the 40 character cell to 4 characters BEFORE the `CONDENSE`, so " 1001" became "100" | condensed at full width first; a cell longer than a plant code is refused instead of being shortened |
| 3 | A business forecast that was not a number loaded as zero and was reported as created | `TO_DEC` cleared the field on `CX_SY_CONVERSION_NO_NUMBER` and told the caller nothing | `TO_DEC` / `TO_INT` return a validity flag; every caller acts on it. Empty and unreadable are separate messages |
| 4 | A monthly history figure that was not a number loaded as zero | same | the row is rejected and the column named |
| 5 | A product category longer than two characters loaded silently truncated | `ZDE_PROD_CAT` is CHAR 2 and the entry was assigned to it | longer entries refused |
| 6 | An invalid unit of measure was stored as typed and only failed later, in the tonnage conversion | no validation, and no conversion from the external form | new `TO_UOM`, `CONVERSION_EXIT_CUNIT_INPUT`; the column is now mandatory |
| 7 | A business forecast or a change could be loaded for an excluded material and then be ignored by the generation run | `ZPPT_MAT_EXCL` was never read | new `CHECK_EXCL` on upload types 5 to 8 |
| 8 | Nothing locked anything — two runs could read the same row and write it back over each other | no `ENQUEUE` | `ENQUEUE_E_TABLE` per plant (per plant and year for the forecast tables), taken once for the run, `DEQUEUE_ALL` after the `COMMIT` |
| 9 | One MARC read and one authorisation check per row | validation was written row by row | new `PREFETCH` — one `FOR ALL ENTRIES` on MARC and on the exclusion list, authorisation buffered per plant |
| 10 | "Upload file could not be read" was shown when no file was named, and again when a template DOWNLOAD failed | message 013 was reused for both | new messages 022 and 023 in `ZPP_FCST` |
| 11 | The example row in the downloaded template came back as a rejected row | it was written as data | it is written commented out, and any row whose first cell starts with `*` is ignored |
| 12 | A change standing against a period was overwritten without a word | `BUS_FCST_ADD` is replaced, not accumulated | kept as replace, marked `ASSUMPTION`, and the log now says what it replaced |

**Still open, not in this program.** `ZCL_PP_FCST` builds `CORRESPONDING zppt_fcst_qt( <ls> )`
on save. `TY_ALV-REASON` is declared but never read from the database, and `TY_ALV` has no
`ERNAM` / `ERDAT` at all, so the quarterly and monthly save writes blank `REASON`, `ERNAM`
and `ERDAT` over the rows this upload has just written. The annual branch already guards
`ERNAM` / `ERDAT`; the other two do not. A user loads a change with a reason, presses Save
in ZFCST, and the reason is gone. The class also has to take the same lock as `LOCK_ROW`
for the locking to cover upload against ZFCST.

TR: not yet transported.
