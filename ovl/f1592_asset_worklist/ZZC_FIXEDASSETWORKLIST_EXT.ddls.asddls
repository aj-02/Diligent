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
*   published here too. Activate ZZI_FIXEDASSETWORKLIST_EXT first - this is
*   object 2 of 3.
*
* NOTE 2 - NO UI ANNOTATIONS HERE.
*   @UI.lineItem / @UI.selectionField belong in the metadata extension
*   ZZC_FIXEDASSETWL_MDE, not in this source. Putting them here works but
*   collides with SAP's own DDLX on the next upgrade.
*
* NOTE 3 - DDL VIEW vs VIEW ENTITY: same caveat as the I_ extension.
*   If C_FixedAssetWorklist is a view entity, use "extend view entity" and
*   drop @AbapCatalog.sqlViewAppendName.
*
* NOTE 4 - IF THE ELEMENT IS NOT FOUND, IT IS AN ALIAS PROBLEM.
*   Same trap as object 1, where the ANLA data source turned out to be
*   aliased "an". Here the element being added comes from the extended
*   view's own data source, so the reference must match how that data source
*   is aliased in C_FixedAssetWorklist's FROM clause. In ADT put the cursor
*   inside the braces, type the alias followed by "." and press Ctrl+Space
*   to see what is actually in scope. Do NOT rename the element itself -
*   ZZCustodianOfAssets is what the DDLX and the OData service expect.
*****************************************************************************/

@EndUserText.label: 'Ext: Custodian of Assets - Consumption'
@AbapCatalog.sqlViewAppendName: 'ZZCFAWLCUST'

extend view C_FixedAssetWorklist with ZZC_FixedAssetWorklist_Ext
{
  " Element published by ZZI_FIXEDASSETWORKLIST_EXT on the interface view
  " (activated 01/09/26).
  " ASSUMPTION: C_FixedAssetWorklist selects from I_FixedAssetWorklist without
  " ASSUMPTION: an alias. If ADT rejects this, see NOTE 4 - prefix with the
  " ASSUMPTION: alias, do not rename the element.
  ZZCustodianOfAssets
}
