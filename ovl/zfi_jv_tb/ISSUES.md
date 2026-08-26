# ZFI_JV_TB — issue log

| # | Date | Issue | Cause | Fix | TR | Status |
|---|------|-------|-------|-----|----|--------|
| 1 | 26/08/26 | Q1 FY27 run: last venture **VN2012** not populated in the Excel output (`RawData` sheet). Reported by Gitesh S Lad, Corporate Accounts. | Venture columns come 1:1 from `lt_alljv`, a `SELECT DISTINCT rjvnam` on `jv_jvto1_acdoca_4a_4c_switch` filtered by `ryear/rbukrs/rjvnam/rldnr='4A'/rrcty='0'/rrecin`. A venture with no matching **totals** row for that year/company code/recovery indicator gets no field-catalogue entry, so no column on screen and none in Excel. Not an export or template limit — the 24.07.2026 run exported all 73 columns from the same template. | Proposed: build the venture list from the JV master `T8JVT` (BUKRS = p_bukrs, VNAME IN p_jvnam) instead of from posted totals, so every master venture gets a column (zero-filled where there is no data). Pending confirmation of the selection values used on the 04.08.2026 run. | — | Open — awaiting clean source download + confirmation |

## Evidence (26/08/26)

Compared the two output workbooks in `~/Downloads`:

- `ZJVTB_24.07.2026_Final.xlsx` → `RawData` = **75 columns** (A1:BW776), last header
  `Closing Bal VN2012`, 109 non-zero rows in that column.
- `ZJVTB for Q1 FY27_SAP PR run date 04.08.2026.xlsx` → `RawData` = **74 columns**
  (A1:BV779), last header `Closing Bal VN2002`. `Closing Bal VN2012` absent entirely —
  header and data.
- The other 74 headers are identical and in the same order in both files.
- Both sheets carry SAP's `bestFit` column widths, so both are genuine SAP exports —
  the July file was not hand-patched.
- The workbook's `VN2012` sheet (a separate single-venture run) shows 75 GLs with debit
  and 77 with credit movement, so VN2012 *does* have Q1 FY27 activity.
- Conclusion: on the 04.08.2026 run the field catalogue itself had 72 ventures. The
  spreadsheet export did not drop a column.
