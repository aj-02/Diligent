// ---------------------------------------------------------------------
// Object   : ZE_JOURNALENTRYITEM_JV   (CDS view extension)
// Extends  : E_JournalEntryItem       (SAP extension include view, #EXTENSION)
// Purpose  : Surface standard ACDOCA-VNAME (Joint Venture) so it can be
//            pulled into I_CnsldtnIntegRptdFinData and become selectable
//            as a source field in the Release Universal Journal field
//            mapping (maintenance view V_FINCS_DRT_TRAN).
// Author   : Arnav
// Created  : 02.09.2026
// Object 1 of 2 - companion extension is ZI_CNSINTEGRPTDFINDATA_JV
// ---------------------------------------------------------------------
@AbapCatalog.sqlViewAppendName: 'ZEFIJRNENTITJV'
@EndUserText.label: 'JV: Joint Venture in Journal Entry Item'

extend view E_JournalEntryItem with ZE_JOURNALENTRYITEM_JV
{
  Persistence.vname as ZZVNAME
}
