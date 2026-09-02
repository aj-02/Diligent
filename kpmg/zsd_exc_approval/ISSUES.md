# ISSUES — WRICEF 141 A/B Exceptional Approval

## 02/09/26 — FS review, questions raised before build

| # | Doc | Item | Problem | Needed from functional |
|---|-----|------|---------|------------------------|
| 1 | A+B | L4/L5/L6 Name | FS says "Submit program SAPLSLVC_FULLSCREEN, fetch L4 Name". That is the generic ALV full-screen function group — not a program, not SUBMIT-able, holds no data. | Real source: report name, or the table/field holding the sales hierarchy (KNVP partner functions? Z hierarchy table? HR org level?) |
| 2 | A | Exceptional Approval Type | Sample column shows "Not Feasible"; stated values are Credit Limit / Order / Both. No source field given in the output mapping. | Which BP3100 field carries it — INFOTYPE? |
| 3 | A | Commitment Date | Mapped to BP3100-TEXT, a free-text field. Unparseable in the general case. | Agreed entry format, and behaviour when a row does not parse |
| 4 | A | Actual OS as on Commitment Date | BSID holds open items *as of now*, not as of a past date — needs BSID + BSAD with AUGDT > commitment date. Also WRBTR is document currency vs credit limit in segment currency, and GJAHR is not on the selection screen. | Confirm as-on-date logic, currency, and where GJAHR comes from |
| 5 | B | Actual Collection date range | Mapping table says BUDAT from selection screen; Parth Shah's comment says "collection received during the approval date & commitment date" (per row). Contradiction. | Which one applies |
| 6 | B | Non-Fulfilment Amount | Stated formula = Collection Commitment − Actual Collection. Sample row (100,000 / 125,000 → 25,000) is Actual − Credit Limit, i.e. copied from the Adhesives doc. Sign is opposite. | Confirm formula and sign convention |
| 7 | A+B | Default % of Non-Fulfilment | Divides by Actual Credit Limit — undefined when limit is 0. For Paints, dividing a collection shortfall by the credit limit looks wrong. | Confirm denominator + zero-limit handling |
| 8 | B | Field names | Table declares ZEXC_AMOUNT and ZEX_AMNT (both "Exceptional ... Amount"); output maps ZEXC_AMNT, which matches neither. | Confirm final field names and whether both amount fields are really needed |
| 9 | B | Table definition gaps | No currency key field for the CURR amounts (cannot activate without one). "Month" given as length "MM-YYYY" — that is a format, not a length. SR. No. key has no stated number source (SNRO or manual). | Confirm CURKY field, month storage (recommend NUMC 6 YYYYMM, displayed MM-YYYY), and SR. No. numbering |
| 10 | B | Info Category / Info Type | Both are *required* selection fields, but ZSD_EXP_PAINTS has no info category / info type field to filter on. | Drop them from the Paints selection screen, or add the fields to the table |
| 11 | A+B | "Date" selection field | Listed as required Range with no table/field. | Which date — approval date, commitment date, or posting date |
| 12 | B | Status - 2 | Uses > and < only; equality (collection exactly equals commitment) is undefined. | Confirm — assumed >= is Fulfilled unless told otherwise |
| 13 | A+B | Sales-area duplication | KNVV is sales-area dependent; a customer in several sales areas will multiply rows. | Dedupe rule, or accept one row per sales area |
| 14 | A+B | Output layout | Format shown as three stacked tables. | Confirm single flat ALV, one row per exception record, key columns repeated |
| 15 | A+B | Authorisation | FS says "Authorization TBD". | Auth object / check to build in |
