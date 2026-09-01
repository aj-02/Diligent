/*****************************************************************************
* DDL Source     : ZZC_FIXEDASSETWORKLIST_EXT
* Type           : CDS view extension (consumption layer)
* Extends        : C_FixedAssetWorklist  (SAP standard)
* Purpose        : Carry "Custodian of Assets" from the interface layer up to
*                  the entity the OData service exposes, for Fiori app
*                  F1592 - Display Asset Master Worklist.
* Package        : <customer package, same TR as the I_ extension>
* Created by     : Arnav
* Created on     : 01.09.2026
*
* NOTE 1 - THIS LAYER IS NOT OPTIONAL.
*   Adding the element to I_FixedAssetWorklist alone leaves it invisible to
*   the app. The service exposes the C_ view, so the element must be
*   published here too. Activate ZZI_FIXEDASSETWORKLIST_EXT first.
*
* NOTE 2 - NO UI ANNOTATIONS HERE.
*   @UI.lineItem / @UI.selectionField belong in the metadata extension
*   ZZC_FIXEDASSETWL_MDE, not in this source. Putting them here works but
*   collides with SAP's own DDLX on the next upgrade.
*
* NOTE 3 - DDL VIEW vs VIEW ENTITY: same caveat as the I_ extension.
*   If C_FixedAssetWorklist is a view entity, use "extend view entity" and
*   drop @AbapCatalog.sqlViewAppendName.
*****************************************************************************/

@EndUserText.label: 'Ext: Custodian of Assets - Consumption'
@AbapCatalog.sqlViewAppendName: 'ZZCFAWLCUST'

extend view C_FixedAssetWorklist with ZZC_FixedAssetWorklist_Ext
{
  " Element published by ZZI_FIXEDASSETWORKLIST_EXT on the interface view.
  " ASSUMPTION: C_FixedAssetWorklist selects from I_FixedAssetWorklist without
  " ASSUMPTION: an alias. If ADT reports "ZZCustodianOfAssets is not defined",
  " ASSUMPTION: prefix it with the alias used in the standard view's FROM
  " ASSUMPTION: clause, e.g. Worklist.ZZCustodianOfAssets.
  ZZCustodianOfAssets
}
