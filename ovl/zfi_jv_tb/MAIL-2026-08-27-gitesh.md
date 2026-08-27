Draft — not sent. Attach: template/ZJVTB_TEMPLATE_wide_2026-08-27.xlsx

---

**Subject:** ZJVTB — Q1 FY27 Excel output: missing venture VN2012 — cause and corrected layout file

Dear Gitesh,

We have traced the VN2012 issue. ZJVTB is fetching and displaying all 73 ventures
correctly, and the column is also present in a direct Excel download from the report.
It is lost only when the layout file is uploaded during export: in that workbook the
defined name "RawData" covers columns A to BV, i.e. 74 columns, whereas the report
needs 75 — G/L account, G/L description and 73 ventures. The 75th column falls outside
this range and is therefore never written.

Attached is the same workbook with the "RawData" and "Header" ranges widened up to
column CZ, to allow for ventures added in future. No other change has been made to the
file. Request you to run ZJVTB and export using this attached layout, and confirm
whether "Closing Bal VN2012" appears in the RAW DATA sheet.

Two points to note: the summary sheets refer to RAW DATA by column position, so their
formulas may need to be extended by one column once VN2012 appears there; and for the
immediate Q1 FY27 requirement, the direct download from the report already carries all
73 ventures and can be used in the meantime.

Thanks & Regards,
Arnav Johri | Associate Consultant | Diligent Global
