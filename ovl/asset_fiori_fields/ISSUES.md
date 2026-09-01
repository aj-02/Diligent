# ISSUES — Asset Accounting Fiori missing fields (OVL)

Source mail: Khyati Sharma (OVL Corporate Accounts) -> Gaurav Sharma / Tushar Anand (SAP),
01/09/26, "SAP FIORI Testing - Observations in Asset Master". Forwarded to Arnav 01/09/26
with SAP KBA 3049624 attached.

| # | Issue | App | Status | Cause | Fix | TR | Date |
|---|---|---|---|---|---|---|---|
| 1 | Depreciation Key not defaulted from asset class on asset creation | Create Asset (AS01) | open — analysis | not yet confirmed; suspected asset-class / dep-area config, not an app defect | — | — | 01/09/26 |
| 2 | "Custodian of Assets" field not available in Asset Master | F1592 | open — analysis | field absent from the app's CDS field set; underlying source field not yet identified | — | — | 01/09/26 |
| 3 | "Joint Venture" field not available in Asset Master / Group Data Analysis | F1592, W0135 | open — analysis | same class as #2 | — | — | 01/09/26 |

## Log

**01/09/26** — SAP replied to items 2/3 citing KBA 3049624. Note read and filed
(`sap_notes/3049624.md`). Finding: the KBA is scoped to F1615/F1617, not F1592, and is a
"works as designed" article — no correction exists. Sanctioned route is a customer field in
ANLU plus an extension of `E_FixedAsset`. Blocked pending three answers from OVL/SAP:
exact S/4 release + FPS, the technical name behind "Custodian of Assets", and note 3435255.
