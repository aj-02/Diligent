// ---------------------------------------------------------------------
// Object   : ZI_CNSINTEGRPTDFINDATA_JV   (CDS view extension)
// Extends  : I_CnsldtnIntegRptdFinData   (GR Realtime Reported Data TAI)
// Purpose  : Pull ZZVNAME through the SAP-declared _Extension association
//            (to E_JournalEntryItem) so the element carries EXTENDNAME and
//            survives the filter in
//            CL_FINCS_DRT_MAPPING_CUST=>GET_ACDOCA_EXTENSION_FIELDS,
//            making it selectable as "Field in General Ledger" in the
//            Release Universal Journal mapping (view V_FINCS_DRT_TRAN).
// Author   : Arnav
// Created  : 02.09.2026
// Object 2 of 2 - requires ZE_JOURNALENTRYITEM_JV active first
// ---------------------------------------------------------------------
@AbapCatalog.sqlViewAppendName: 'ZIINTFINDATAJV'
@EndUserText.label: 'JV: Joint Venture in GR Reported Data'

extend view I_CnsldtnIntegRptdFinData with ZI_CNSINTEGRPTDFINDATA_JV
{
  _Extension.ZZVNAME as ZZVNAME
}
