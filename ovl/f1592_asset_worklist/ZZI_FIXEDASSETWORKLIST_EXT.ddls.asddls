/*****************************************************************************
* DDL Source     : ZZI_FIXEDASSETWORKLIST_EXT
* Type           : CDS view extension (interface layer)
* Extends        : I_FixedAssetWorklist  (SAP standard)
* Purpose        : Expose "Custodian of Assets" in the Asset Master Worklist
*                  backend stack, for Fiori app F1592 - Display Asset Master
*                  Worklist.
* Package        : <customer package, same TR as the C_ extension>
* Created by     : Arnav
* Created on     : 01.09.2026
*
* NOTE 1 - EXTENSION, NOT MODIFICATION.
*   I_FixedAssetWorklist is a standard SAP object and is NOT touched. This
*   append-style extension is the modification-free route and survives upgrade.
*
* NOTE 2 - ACTIVATION ORDER.
*   1) this view   2) ZZC_FIXEDASSETWORKLIST_EXT   3) ZZC_FIXEDASSETWL_MDE
*   Activating out of order fails: the C_ layer cannot see an element the
*   I_ layer has not yet published.
*
* NOTE 3 - DDL VIEW vs VIEW ENTITY.
*   Written for a classic DDL view, which is what this release ships for the
*   FI-AA worklist stack: hence "extend view" plus a mandatory
*   @AbapCatalog.sqlViewAppendName. If ADT shows the standard source as
*   "define view entity I_FixedAssetWorklist" (no sqlViewName), then switch
*   this source to "extend view entity I_FixedAssetWorklist with ..." and
*   DELETE the sqlViewAppendName annotation - a view entity rejects it.
*****************************************************************************/

@EndUserText.label: 'Ext: Custodian of Assets - Interface'
@AbapCatalog.sqlViewAppendName: 'ZZIFAWLCUST'

extend view I_FixedAssetWorklist with ZZI_FixedAssetWorklist_Ext
{
  " ASSUMPTION: the custodian field sits on a data source that is ALREADY in
  " ASSUMPTION: the FROM of I_FixedAssetWorklist (expected: ANLA, the asset
  " ASSUMPTION: master segment). An extend view can only reach data sources
  " ASSUMPTION: the extended view already joins - it cannot add a join.
  " ASSUMPTION: Replace the token below with <source alias>.<field>, e.g.
  " ASSUMPTION:   Asset.ZZCUSTODIAN   or   ANLA.ORD41
  " ASSUMPTION: Confirm BOTH the alias and the field name before activating -
  " ASSUMPTION: see ovl/f1592_asset_worklist/NOTES.md, "Confirm before coding".
  ZZ_REPLACE_WITH_CONFIRMED_FIELD as ZZCustodianOfAssets
}
