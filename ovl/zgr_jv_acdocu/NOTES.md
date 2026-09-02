# ovl/zgr_jv_acdocu — Joint Venture (ACDOCA-VNAME) into ACDOCU

## What this is

Two CDS view extensions that make standard `ACDOCA-VNAME` (Joint Venture, CHAR 6,
data element `JV_NAME`, check table `T8JV`) available as a **source field** in the
Group Reporting "Release Universal Journal" field mapping, so it can be released
into the ACDOCU key-user custom field `ZZ1_JV_NAME_CJE`.

## Why extensions are needed

The mapping config (view `V_FINCS_DRT_TRAN`, table `FINCS_DRT_TRANS`) builds its
source-field F4 at runtime in:

    CL_FINCS_RUJ_FACTORY=>GET_MAPPING_CUST( )->GET_AVAILABLE_ACDOCA_FIELDS( )
      -> CL_FINCS_DRT_MAPPING_CUST=>GET_ACDOCA_EXTENSION_FIELDS( )

That method reads the fields of CDS view `I_CnsldtnIntegRptdFinData` and then:

    delete ... where extendname is initial
                and not ( fieldname = 'ASSETCLASS' or 'GROUPMASTERFIXEDASSET' or
                          'ACCOUNTINGDOCUMENTTYPE' or 'BUSINESSTRANSACTIONTYPE' or
                          'FINANCIALCLOSINGSTEP' or 'SUBLEDGERACCTLINEITEMTYPE' or
                          'SOURCELEDGER' or 'COSTANALYSISRESOURCE' )
    delete ... where datatype = CURR/CUKY/QUAN/UNIT/DATS/TIMS/DEC

So a field is offered only if it is one of those 8 hardcoded standard fields, or
its `extendname` is filled — i.e. it was contributed by a view extension.
`VNAME` is neither, hence the two extensions. CHAR 6 passes the datatype filter.

## Objects

| # | Object | Extends | Adds |
|---|--------|---------|------|
| 1 | `ZE_JOURNALENTRYITEM_JV` | `E_JournalEntryItem` | `Persistence.vname as ZZVNAME` |
| 2 | `ZI_CNSINTEGRPTDFINDATA_JV` | `I_CnsldtnIntegRptdFinData` | `_Extension.ZZVNAME as ZZVNAME` |

`E_JournalEntryItem` is `@VDM.viewType: #EXTENSION` and selects directly
`from acdoca as Persistence`, so `vname` is reachable without adding a data source.
`I_CnsldtnIntegRptdFinData` already declares
`association [1..1] to E_JournalEntryItem as _Extension` (joined on the 5 ACDOCA
keys) but selects nothing from it — that association is the intended extension point.

## Config that follows activation

SM30 / IMG activity on view `V_FINCS_DRT_TRAN`
("DRT: Mapping for Jrnl Entry to Group Jrnl Entry Ext Fields"), one entry:

| Field in General Ledger | Extension Field in Group Journal Entries |
|---|---|
| `ZZVNAME` | `ZZ1_JV_NAME_CJE` |

`CLASSNAME` and `DBNAME` are not on the maintenance screen — the framework fills them.
Take a Customizing request on save; do **not** insert via SE16.

Then Data Monitor (CXCD) -> Release Universal Journal for the unit/period, and
verify in SE16N on `ACDOCU`.

## Gotchas

- `I_CnsldtnIntegRptdFinData` has **no** `@AbapCatalog.extensibility` block, only
  `@Metadata.allowExtensions: true` (annotations only). So the Custom Fields app can
  never add `VNAME` here — it must be a developer view extension.
- The `_Extension` association is a self-join of ACDOCA on the full key against an
  XXL view. Watch the release job runtime after activation.
- Already-released periods do not backfill. Reverse and re-release them.
- The business scenario "Accounting: Coding Block to Consolidation Journal Entry"
  must stay **disabled**. It carries `ACDOCA-ZZ1_JV_NAME` (empty) into
  `ACDOCU-ZZ1_JV_NAME_CJE` and would fight this mapping.
- A residual empty `ZZ1_JV_NAME` column remains in ACDOCA from when that scenario was
  briefly enabled. It is harmless; disabling does not drop the DDIC column.
- Two custom fields exist in ACDOCU: `ZZ1_JV_NAME_CJE` and `ZZ1_VNAME_CJE`.
  Only one is needed — delete the unused one.
- `elementSuffix`: neither view declares one, so `ZZVNAME` is used as-is. If
  activation complains about the element name, adopt the suffix the error names.
