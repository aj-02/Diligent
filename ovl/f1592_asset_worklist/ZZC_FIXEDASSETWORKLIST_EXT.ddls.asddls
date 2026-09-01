/*****************************************************************************
* DDL Source     : ZZC_FIXEDASSETWORKLIST_EXT
* Type           : CDS view extension (consumption layer)
* Extends        : C_FixedAssetWorklist  (SAP standard)
* Purpose        : Carry "Custodian of Assets" up to the entity the OData
*                  service exposes, AND annotate it for the UI, for Fiori
*                  app F1592 - Display Asset Master Worklist.
* Package        : <customer package, same TR as the I_ extension>
* Created by     : Arnav
* Created on     : 01.09.2026
* Changed on     : 01.09.2026 - UI annotations moved in from the metadata
*                  extension route (see NOTE 2).
*
* NOTE 1 - THIS LAYER IS NOT OPTIONAL.
*   Adding the element to I_FixedAssetWorklist alone leaves it invisible to
*   the app. The service exposes the C_ view, so the element must be
*   published here too. ZZI_FIXEDASSETWORKLIST_EXT was activated 01/09/26.
*
* NOTE 2 - WHY THE UI ANNOTATIONS ARE HERE AND NOT IN A DDLX.
*   The intended route was a metadata extension (ZZC_FIXEDASSETWL_MDE).
*   That failed on 01/09/26: C_FixedAssetWorklist does not carry
*   @Metadata.allowExtensions: true on this release, so it accepts no DDLX
*   at all. The annotations therefore live on the element itself, here.
*   The DDLX object was abandoned - do not create it.
*
*   Do NOT "fix" this by adding @Metadata.allowExtensions to the standard
*   view. That is a modification of an SAP object and is out of bounds.
*
*   Upgrade risk of this route is low: ZZCustodianOfAssets is a customer
*   element, so SAP's own DDLX will never annotate it and cannot collide.
*
* NOTE 3 - POSITIONS.
*   900/910 are deliberately high so the column lands at the end of the
*   table and cannot collide with SAP's existing lineItem positions after
*   an upgrade.
*
* NOTE 4 - THE COLUMN WILL NOT APPEAR BY ITSELF.
*   @UI.lineItem makes the column AVAILABLE. F1592 users still add it via
*   Settings (gear) -> Columns. Changing the default variant for everyone is
*   a key-user Adapt UI change and is not carried by this transport.
*
* NOTE 5 - DDL VIEW vs VIEW ENTITY: same caveat as the I_ extension.
*   If C_FixedAssetWorklist is a view entity, use "extend view entity" and
*   drop @AbapCatalog.sqlViewAppendName.
*****************************************************************************/

@EndUserText.label: 'Ext: Custodian of Assets - Consumption'
@AbapCatalog.sqlViewAppendName: 'ZZCFAWLCUST'

extend view C_FixedAssetWorklist with ZZC_FixedAssetWorklist_Ext
{
  " Element published by ZZI_FIXEDASSETWORKLIST_EXT on the interface view
  " (activated 01/09/26). Annotations here because the view rejects a DDLX.
  @UI.lineItem:       [ { position: 900, label: 'Custodian of Assets' } ]
  @UI.identification: [ { position: 900, label: 'Custodian of Assets' } ]
  @UI.selectionField: [ { position: 910 } ]
  ZZCustodianOfAssets
}
