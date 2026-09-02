# WRICEF 141.A — Exceptional Approval format, Adhesives (FS text extract)

Astral Limited · project UDAY · module SD · V.01 · 24.08.2026 · prepared by Sanjay Modhvadiya

## 1.1 Requirement
Adhesives: Need report for Exceptional approval based on customer master ->
Further Information -> Information category -> Additional information in credit management.

## 1.2 Out of scope
No mass upload will be provided to upload the exception amount and related data to the
business partner.

## 2. Developments
- Report for Adhesives

## Report format (as drawn in the FS — three stacked blocks)

Block 1: Cust. Code | Name | L4_Name | L5_Name | L6_Name
  1009024 | BABA TRADING CO-MNT | Keerti Oberoi | Bharat Kapoor | Shailendra Mohan Pandey
  1025584 | AGRAWAL INDUSTRIES-MNT | Keerti Oberoi | Bharat Kapoor | Shailendra Mohan Pandey

Block 2: Exceptional Approval Month | Exceptional unique number |
         Exceptional Approval Type (Credit Limit / Order / Both) |
         Exceptional Approval Date | Exceptional Amount
  Jul'26 | Sr No. | Not Feasible | 7/25/2026 | 50,000
  Jul'26 |        |              | 7/26/2026 | 25,000

Block 3: Commitment Date | Actual Credit limit | Actual OS as on Commitment Date |
         Non-Fulfilment Amount | Default % of Non-Fulfilment Amount | Status
  8/5/2026 | 100,000 | 125,000 | 25,000  | 25% | Not Fulfilled
  8/6/2026 | 100,000 |  98,000 | -2,000  | -2% | Fulfilled

## Input (selection screen)

| DESCRIPTION | USE   | TABLE | FIELD | Obligation |
|---|---|---|---|---|
| Customer No. | Range | KNVV | KUNNR | Not required |
| Info Category | F4 | UKM_INFOCAT | INFOCATEGORY | Required |
| Info Type | F4 | UKM_INFOTYP (pass INFOCATEGORY selected above) | INFOTYPE | Required |
| Date | Range | — | — | Required |
| Company code | F4 | KNB1 | BUKRS | Required |
| Sales Org. | F4 | KNVV | VKORG | Required |
| Cust GRP 1 | F4 | KNVV | KVGR1 | Not Required |
| Cust GRP 2 | F4 | KNVV | KVGR2 | Not Required |

## Output mapping

| Label | Table | Field | Instructions |
|---|---|---|---|
| Customer | BP3100 | PARTNER | Fetch |
| Name | KNA1 | NAME1 | Pass PARTNER IN KUNNR fetch NAME1 |
| L4_Name | SAPLSLVC_FULLSCREEN | L4 Name | Submit program SAPLSLVC_FULLSCREEN pass VKORG = 1000, 1100, 1200, 1300 fetch L4 Name |
| L5_Name | SAPLSLVC_FULLSCREEN | L5 Name | as above |
| L6_Name | SAPLSLVC_FULLSCREEN | L6 Name | as above |
| Exceptional Approval Month | BP3100 | DATEFR | Pick month and year with bifurcation "/" MM/YYYY |
| Exception No. | BP3100 | COUNTER | Fetch |
| Exceptional Approval Date From | BP3100 | DATEFR | Fetch |
| Exceptional Approval Date To | BP3100 | DATETO | Fetch "DD/MM/YYYY" |
| Exceptional Amount | BP3100 | AMNT | Fetch |
| Commitment Date | BP3100 | TEXT | Fetch |
| Actual Credit limit | UKMBP_CMS_SGM | CREDIT_LIMIT | Fetch |
| Actual OS as on Commitment Date | BSID | — | Step-1: pass KUNNR, BUKRS and GJAHR into BSID and fetch WRBTR (REBZG blank). Step-2: for partial payment, KUNNR, BUKRS and GJAHR into BSID with REBZG not blank, fetch WRBTR. Sum step-1 and step-2 using SHKZG "S" debit / "H" credit. |
| Non-Fulfilment Amount | — | — | Actual OS as on Commitment Date - Actual Credit limit |
| Default % of Non-Fulfilment Amount | — | — | Non-Fulfilment Amount * 100 / Actual Credit limit |
| Status | — | — | If Non-Fulfilment Amount is (+) status is Not fulfilled; if (-) status is Fulfilled |

## 2.4 Security and authorization
Authorization TBD.

## Reviewer comments embedded in the document
- Yogesh Vanani, 26/08/26: "Wrote suitable status"
- Yogesh Vanani, 26/08/26: "If it is selection screen then need to add, company code,
  sales Organisation, division, customer group 1 & 2"
- Yogesh Vanani, 26/08/26: "Month with year"
