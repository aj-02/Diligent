# ZFI_JV_TB — issue log

| # | Date | Issue | Cause | Fix | TR | Status |
|---|------|-------|-------|-----|----|--------|
| 1 | 26/08/26 | Q1 FY27 run: last venture **VN2012** not populated in the Excel output (`RawData` sheet). Reported by Gitesh S Lad, Corporate Accounts. | **Excel template, not ABAP.** The template-based spreadsheet export writes the list into the workbook's `RawData` defined name, which is `RawData!$A$1:$BV$778` — 74 columns. The report needs 75 (G/L account + description + 73 ventures), so the 75th column falls outside the range and is never written. Always hits the alphabetically last venture. | Widen the defined names in the template: `RawData` → `=RawData!$A$1:$CZ$5000`, `Header` → `=Header!$A$11:$CZ$5000`. Headroom to CZ so the next new venture does not repeat it. Summary sheets that map RawData by position (`USD_PL_Sub_Heads2` ends at BV, `USD_BS_Sub_Head2` at BW) need their formulas extended one column right. | n/a — no code change | Fix handed over 27/08/26, awaiting user confirmation |

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
