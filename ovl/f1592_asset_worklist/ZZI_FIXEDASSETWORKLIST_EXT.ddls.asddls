/*****************************************************************************
* DDL Source     : ZZI_FIXEDASSETWORKLIST_EXT
* Type           : CDS view extension (interface layer)
* Extends        : I_FixedAssetWorklist  (SAP standard)
* Purpose        : Pull "Custodian of Assets" (ANLU / CI_ANLU) into the Asset
*                  Master Worklist stack behind Fiori app F1592.
* Package        : <customer package, same TR as the other objects>
* Created by     : Arnav
* Created on     : 01.09.2026
*
* NOTE 1 - EXTENSION, NOT MODIFICATION.
*   I_FixedAssetWorklist is a standard SAP object and is NOT touched. This is
*   the modification-free route and survives upgrade.
*
* NOTE 2 - ACTIVATION ORDER.
*   1) ZZI_FIXEDASSET_USERFIELD   2) this view
*   3) ZZC_FIXEDASSETWORKLIST_EXT 4) ZZC_FIXEDASSETWL_MDE
*   Out of order fails - each layer needs the one below it activated.
*
* NOTE 3 - WHY AN ASSOCIATION AND NOT A PLAIN FIELD.
*   ANLU is not in the FROM of I_FixedAssetWorklist, and an extend view
*   cannot add a join. The association below is declared IN the extension,
*   which is legal, and the path expression in the select list resolves to a
*   LEFT OUTER JOIN because the cardinality is [0..1].
*
*   Before pasting: open I_FixedAssetWorklist in ADT and search the source
*   for ANLU. If it is already a data source there, throw this association
*   away and just select <alias>.<field> directly - one line instead of six.
*
* NOTE 4 - THE ON CONDITION USES TABLE FIELDS, NOT CDS ELEMENT NAMES.
*   The right-hand side references ANLA columns (bukrs/anln1/anln2) through
*   the alias the standard view gives its data source. This is deliberate:
*   the raw table field names are certain, whereas the standard view's CDS
*   element names are not, and a wrong element name costs an activation
*   cycle. Replace <ANLA_ALIAS> with the alias from the standard view's
*   "from anla as ..." clause. If the view selects from an intermediate CDS
*   view rather than ANLA directly, send me its FROM clause and I will
*   rewrite this ON condition against that view's elements instead.
*
* NOTE 5 - DDL VIEW vs VIEW ENTITY.
*   Written for a classic DDL view. If ADT shows the standard source as
*   "define view entity I_FixedAssetWorklist", switch to
*   "extend view entity ... with ..." and DELETE the sqlViewAppendName
*   annotation - a view entity rejects it.
*
* NOTE 6 - IF ADT REJECTS THE ASSOCIATION.
*   Support for declaring associations inside a view extension is
*   release-dependent. If activation fails on the association itself, stop
*   and tell me - the fallback is a different design (custom worklist view),
*   not a syntax tweak.
*****************************************************************************/

@EndUserText.label: 'Ext: Custodian of Assets - Interface'
@AbapCatalog.sqlViewAppendName: 'ZZIFAWLCUST'

extend view I_FixedAssetWorklist with ZZI_FixedAssetWorklist_Ext
  association [0..1] to ZZI_FixedAsset_UserField as _ZZAssetUserField
    on  _ZZAssetUserField.CompanyCode      = <ANLA_ALIAS>.bukrs
    and _ZZAssetUserField.MasterFixedAsset = <ANLA_ALIAS>.anln1
    and _ZZAssetUserField.FixedAsset       = <ANLA_ALIAS>.anln2
{
  _ZZAssetUserField.ZZCustodianOfAssets as ZZCustodianOfAssets
}
