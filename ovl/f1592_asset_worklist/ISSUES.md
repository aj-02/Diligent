# ISSUES — F1592 Display Asset Master Worklist

| Date | Issue | Cause | Fix | TR | Status |
|---|---|---|---|---|---|
| 01/09/26 | "Custodian of Assets" maintained in the asset master does not appear in Fiori app F1592 | Field is on ANLU (CI_ANLU customer include), which SAP does not join in `I_FixedAssetWorklist` → `C_FixedAssetWorklist` | `[0..1]` association direct to table ANLU declared in `ZZI_FIXEDASSETWORKLIST_EXT`, carried up by `ZZC_FIXEDASSETWORKLIST_EXT`, annotated inline on the element in `ZZC_FIXEDASSETWORKLIST_EXT` (DDLX route unavailable), then gateway/UI cache cleanup | — | **In progress — object 1 activated 01/09/26; DDLX route failed (no `@Metadata.allowExtensions` on `C_FixedAssetWorklist`), UI annotations moved into object 2, awaiting its reactivation + cache cleanup** |
