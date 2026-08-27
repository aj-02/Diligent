# ZFI_JV_TB — issue log

| # | Date | Issue | Cause | Fix | TR | Status |
|---|------|-------|-------|-----|----|--------|
| 1 | 26/08/26 | Q1 FY27 run: last venture **VN2012** not populated in the Excel output (`RawData` sheet). Reported by Gitesh S Lad, Corporate Accounts. | **Still open.** The Excel-template theory was wrong — see "Retraction" below. Current lead: the export is truncated at a fixed `BAL_CLO<k>`, consistent with a saved ALV layout hiding every venture field above the number the layout was saved with. | Not yet determined. | n/a | **RETRACTED 27/08/26 — see below. Reopened.** |

## How it was localised (26–27/08/26)

Ruled out in order, each with evidence:

1. **Export/template column limit?** Not a hard limit — `ZJVTB_24.07.2026_Final.xlsx` has 75 columns
   (A1:BW776) including `Closing Bal VN2012` with 109 non-zero rows, against
   `ZJVTB for Q1 FY27 … 04.08.2026.xlsx` with 74 (A1:BV779). Same 74 headers, same order.
2. **Venture list SELECT dropping VN2012?** No. Breakpoint on the `SELECT DISTINCT rjvnam`
   in `AT SELECTION-SCREEN`: `lt_alljv` contained VN2012, last of 27 in the test run.
3. **Field catalogue losing it?** No. `lt_fieldcat` had all 29 entries —
   `BAL_CLO27` / `Closing Bal VN2012` at `col_pos 29`, positions contiguous 1…29.
4. **Saved ALV layout hiding the new column?** No. The column is displayed in the grid, and
   the direct download from that same list carries it.
5. **Template export.** Only the "upload the Excel" path loses it. `RawData` defined name is
   74 columns wide. Root cause.

The 24.07.2026 file reconciles with this: its `RawData` name is still `$A$1:$BV$765` while its
content runs to BW776 — it was produced by the direct download and put into the workbook by
hand, not by a template export.

## Separate defects noted, not fixed

- Four `break abapuser02.` statements left in a productive report — source lines 550, 1047,
  1151, 1561 of the filed baseline.
- `disp_data`, single-currency fill loop: `READ TABLE lt_fieldcat … WITH KEY coltext` has no
  `sy-subrc` check. On a miss it reuses the previous `ls_fieldcat-col_pos` and writes the
  amount into the wrong venture's column.
- Field names are positional (`BAL_CLO<sy-tabix>`), so `BAL_CLO27` means a different venture
  depending on what the selection returned. Any saved ALV layout is therefore only valid for
  one particular venture set.
- Object name unresolved: the `REPORT` statement reads `zzjvtb_test` while the SE38 print
  header says `ZFI_JV_TB`. Arnav confirms this is what runs in the backend.

## Retraction, 27/08/26 — the template named range was NOT the cause

Test run `ZJVTB Mock 2 Testing 27.08.2026xlsx.xlsx`, exported against the widened
template (`RawData` = `$A$1:$CZ$5000`), came back **worse**: 18 columns, i.e. 2 + 16
ventures, against 27 ventures in `lt_alljv`.

Two findings kill the template theory:

1. The output's own `RawData` defined name reads `RawData!$A$1:$R$692` — exactly the 18
   columns written. **The export rewrites that name to match what it produced.** It is an
   output of the export, not a constraint on it. Widening it to CZ had no effect because
   nothing reads it.
2. The 16 ventures written are exactly the **first 16 of the 27** in `lt_alljv`, in order.
   Dropped: MM1702, MM2002, MM2012, MM2013, RU2002, SD1102, SD2002, SY2002, VN1101,
   VN1102, VN2012.

So this is not "the last column is missing" — it is a clean cut after `BAL_CLO16`. Q1 FY27
had the same shape, cut after `BAL_CLO72`, which left only VN2012 missing and made it look
like a last-column defect.

### Current lead

A cut at a fixed `BAL_CLO<k>` matches a **saved ALV layout**. Field names are positional
(`BAL_CLO<sy-tabix>`), so a layout saved when a run had k venture columns knows
`BAL_CLO1…BAL_CLO<k>`; anything above lands in the hidden column set, and hidden columns
are not exported. `REUSE_ALV_GRID_DISPLAY_LVC` is called with `i_save = 'A'` and
`i_default = 'X'`, so a default layout is applied automatically.

Awaiting from Arnav, on one run: grid column count, the Change Layout (Ctrl+F8) hidden
pane contents, and whether an ALV variant is involved at all or "upload a layout" only
ever meant the Excel file in the export dialog.

The widened template in `template/` is harmless but does nothing. Do not ship it.
The draft mail in `MAIL-2026-08-27-gitesh.md` must not be sent.
