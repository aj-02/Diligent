/*****************************************************************************
* DDL Source     : ZZI_FIXEDASSET_USERFIELD
* SQL View       : ZZIFAUSERFIELD
* Type           : CDS interface view (new customer object)
* Data source    : ANLU - Asset Master Record User Fields
* Purpose        : Expose the customer include (CI_ANLU) custodian field so it
*                  can be associated into the standard Asset Master Worklist
*                  stack behind Fiori app F1592.
* Package        : <customer package, same TR as the extensions>
* Created by     : Arnav
* Created on     : 01.09.2026
*
* NOTE 1 - WHY THIS VIEW EXISTS.
*   ANLU is a customer-include table and is NOT joined by SAP's
*   I_FixedAssetWorklist. A CDS "extend view" can only append to the SELECT
*   list over the data sources the extended view ALREADY has - it cannot add
*   a join. So the field is wrapped here and pulled in via an association
*   declared in ZZI_FIXEDASSETWORKLIST_EXT.
*
* NOTE 2 - KEY AND CARDINALITY.
*   ANLU is keyed on MANDT / BUKRS / ANLN1 / ANLN2 - the same asset key as
*   ANLA, one row per asset, NOT time-dependent. That is why this is a plain
*   [0..1] association with no validity-interval handling: unlike ANLZ, there
*   is no risk of row multiplication and no key-date question for the
*   functional team to answer.
*
* NOTE 3 - [0..1], NOT [1..1].
*   An ANLU row exists only where user fields were actually maintained.
*   [0..1] makes the path expression generate a LEFT OUTER JOIN, so assets
*   with no custodian still appear in the worklist with a blank column.
*   [1..1] would silently drop those rows from F1592 - a data-loss bug that
*   would not show up until someone noticed the list was short.
*
* NOTE 4 - CLIENT FIELD.
*   MANDT is deliberately not selected. CDS handles client separation
*   implicitly; selecting it would break the association ON condition.
*
* NOTE 5 - AUTHORISATION.
*   #NOT_REQUIRED is correct here: this view is never consumed directly. The
*   authorisation check stays where SAP put it, on the worklist stack that
*   associates to this view.
*****************************************************************************/

@AbapCatalog.sqlViewName: 'ZZIFAUSERFIELD'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fixed Asset User Fields (ANLU)'

define view ZZI_FixedAsset_UserField
  as select from anlu
{
      @EndUserText.label: 'Company Code'
  key bukrs                            as CompanyCode,

      @EndUserText.label: 'Main Asset Number'
  key anln1                            as MasterFixedAsset,

      @EndUserText.label: 'Asset Subnumber'
  key anln2                            as FixedAsset,

      " ASSUMPTION: replace ZZ_REPLACE_WITH_CONFIRMED_FIELD with the ANLU
      " ASSUMPTION: field name from AS03 -> F1 -> Technical Information.
      " ASSUMPTION: It is a CI_ANLU customer-include field, so expect a name
      " ASSUMPTION: like ZZCUSTODIAN / ZZ_CUSTODIAN / YY1_CUSTODIAN.
      " ASSUMPTION: Nothing else in this view changes.
      @EndUserText.label: 'Custodian of Assets'
      ZZ_REPLACE_WITH_CONFIRMED_FIELD  as ZZCustodianOfAssets
}
