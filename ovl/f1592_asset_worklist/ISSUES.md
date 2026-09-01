# ISSUES — F1592 Display Asset Master Worklist

| Date | Issue | Cause | Fix | TR | Status |
|---|---|---|---|---|---|
| 01/09/26 | "Custodian of Assets" maintained in the asset master does not appear in Fiori app F1592 | Field is on ANLU (CI_ANLU customer include), which SAP does not join in `I_FixedAssetWorklist` → `C_FixedAssetWorklist` | `[0..1]` association direct to table ANLU declared in `ZZI_FIXEDASSETWORKLIST_EXT`, carried up by `ZZC_FIXEDASSETWORKLIST_EXT`, annotated by DDLX `ZZC_FIXEDASSETWL_MDE`, then gateway/UI cache cleanup | — | **Open — sources complete (ANLU-ZZCUSTODIAN, alias `an`), awaiting activation in ADT** |
