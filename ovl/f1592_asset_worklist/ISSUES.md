# ISSUES — F1592 Display Asset Master Worklist

| Date | Issue | Cause | Fix | TR | Status |
|---|---|---|---|---|---|
| 01/09/26 | "Custodian of Assets" maintained in the asset master does not appear in Fiori app F1592 | Field is not selected by the CDS stack `I_FixedAssetWorklist` → `C_FixedAssetWorklist` behind the app | Modification-free CDS extension: `ZZI_FIXEDASSETWORKLIST_EXT` + `ZZC_FIXEDASSETWORKLIST_EXT` + DDLX `ZZC_FIXEDASSETWL_MDE`, then gateway/UI cache cleanup | — | **Open — blocked on technical field name** (see NOTES.md, "Confirm before coding") |
