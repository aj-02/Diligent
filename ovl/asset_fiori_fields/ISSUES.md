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

**01/09/26 (later)** — Research sweep completed; findings written to `ANALYSIS.md`.
Headline: the two CDS view names SAP quoted (`C_FixedAssetWorklist`, `I_FixedAssetWorklist`)
could not be corroborated as SAP objects and must not be built against. Recommended route for
items 2/3 is key-user extensibility (Custom Fields → business context for the asset master →
UIs and Reports → Enable Usage), with `SCFD_EUI` to promote any existing ECC-era `CI_ANLU`
fields rather than creating new ones. Hard constraint found: asset-master key-user extensibility
is time-independent only — if custodian must be time-dependent the route does not apply.
Item 1 reframed: `0000` is a real depreciation key ("no depreciation and no interest"), so the
key defaulted and is wrong, rather than failing to default; `OAYZ`/`ANKB` plus the `AO21`
depreciation-area screen layout rule are the two controls. Chart of depreciation is ONGC and
asset 106009197/0 already carries the same eight areas — no test asset needs creating.
