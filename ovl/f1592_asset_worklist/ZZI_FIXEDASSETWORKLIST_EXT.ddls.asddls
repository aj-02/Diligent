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
* NOTE 1 - NO NEW VIEW NEEDED.
*   A CDS association may target a DDIC TABLE directly - it does not have to
*   target a CDS entity. So ANLU is associated straight from this extension
*   and no wrapper view is created. (An earlier draft of this fix created
*   ZZI_FIXEDASSET_USERFIELD for that job; it was unnecessary and has been
*   removed.) The delivery is now three objects, all of them extensions.
*
* NOTE 2 - WHY AN ASSOCIATION AT ALL, RATHER THAN JUST NAMING THE FIELD.
*   "extend view" appends to the SELECT list over the data sources the
*   extended view ALREADY has. It cannot add a join. ANLA is in scope in
*   I_FixedAssetWorklist; ANLU is not, because SAP has no reason to join a
*   customer-include table. The association is the only way to bring it into
*   scope without touching the standard view.
*
*   BEFORE PASTING: run a where-used on table ANLU (SE11 -> ANLU ->
*   Ctrl+Shift+F3). If some view already in this flow reads ANLU, or if
*   I_FixedAssetWorklist publishes an association to such a view, delete the
*   association below and select through the existing one instead - that is
*   strictly better than adding our own.
*
* NOTE 3 - [0..1], NOT [1..1].
*   An ANLU row exists only where user fields were actually maintained.
*   [0..1] makes the path expression generate a LEFT OUTER JOIN, so assets
*   with no custodian still appear in the worklist with a blank column.
*   [1..1] would inner-join and silently drop those rows from F1592 - a
*   data-loss bug that nobody notices until the list comes up short.
*
* NOTE 4 - NO CLIENT FIELD IN THE ON CONDITION.
*   ANLU is client-dependent (MANDT/BUKRS/ANLN1/ANLN2). CDS adds the client
*   condition implicitly; naming MANDT here is wrong and will not activate.
*
* NOTE 5 - NOT TIME-DEPENDENT, SO NOTHING TO DECIDE.
*   ANLU is one row per asset, same key as ANLA. Unlike ANLZ there is no
*   validity interval, so there is no key-date question for the functional
*   team and no risk of row multiplication.
*
* NOTE 6 - THE ON CONDITION USES TABLE FIELDS, NOT CDS ELEMENT NAMES.
*   The right-hand side references ANLA columns through the alias the
*   standard view gives its data source. Deliberate: the raw table field
*   names are certain, the standard view's CDS element names are not, and a
*   wrong element name costs an activation cycle. The
*   ANLA alias in this view is "an" (confirmed by Arnav, 01/09/26).
*
* NOTE 7 - DDL VIEW vs VIEW ENTITY.
*   Written for a classic DDL view. If ADT shows the standard source as
*   "define view entity I_FixedAssetWorklist", switch to
*   "extend view entity ... with ..." and DELETE the sqlViewAppendName
*   annotation - a view entity rejects it.
*
* NOTE 8 - IF ADT REJECTS THE ASSOCIATION ITSELF.
*   Declaring an association inside a view extension is release-dependent.
*   If activation fails on the association, stop and tell me - the fallback
*   is a different design, not a syntax tweak. See NOTES.md.
*****************************************************************************/

@EndUserText.label: 'Ext: Custodian of Assets - Interface'
@AbapCatalog.sqlViewAppendName: 'ZZIFAWLCUST'

extend view I_FixedAssetWorklist with ZZI_FixedAssetWorklist_Ext
  association [0..1] to anlu as _ZZAssetUserField
    on  _ZZAssetUserField.bukrs = an.bukrs
    and _ZZAssetUserField.anln1 = an.anln1
    and _ZZAssetUserField.anln2 = an.anln2
{
  " ANLU-ZZCUSTODIAN, a CI_ANLU customer-include field (confirmed 01/09/26).
  _ZZAssetUserField.zzcustodian as ZZCustodianOfAssets
}
