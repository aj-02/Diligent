# ovl/asset_fiori_fields — missing fields in Asset Accounting Fiori apps

**Status: open, in analysis. No object built yet.**

Not a Z object. This folder tracks a functional/extensibility thread on the OVL S/4
landscape: three observations raised by OVL Corporate Accounts against the standard SAP
Fiori Asset Accounting apps, routed to us via SAP (Gaurav Sharma).

## Apps in scope

| Fiori ID | Title | Type |
|---|---|---|
| F1592 | Display Asset Master Worklist | asset master worklist — items 2 and 3 |
| W0135 | Group Data Analysis | item 3 (JV reporting) |
| F1615 / F1617 | Asset History Sheet / Asset Balances | not raised by OVL; the scope of KBA 3049624 |

## What SAP supplied

`sap_notes/3049624.md` — full extracted text of the KBA (PDF in `original/`). The SAP
support portal is not reachable from this machine, so that markdown file is the local copy
of record.

**The KBA is scoped to F1615/F1617 only.** It does not mention F1592, nor
`C_FixedAssetWorklist` / `I_FixedAssetWorklist`. It is a *works as designed* article — no
correction to implement, everything falls to customer-side extensibility.

The one mechanism it names, verbatim: *"This CDS View `I_FixedAsset` have reference
extension view `E_FixedAsset`. Using this Extension View, you can add any field contained in
table ANLU."*

## Gotchas

- **Object names fork by release.** The KBA gives one set of query/cube names for
  1809 FPS03 / 1909 FPS01 and above, another for 1809 FPS02 and lower. OVL's exact
  release + FPS is not yet confirmed — do not name a CDS view until it is.
- **"Custodian of Assets" is not a standard SAP asset-master field.** It is either an
  evaluation group, a personnel number, or a customer field in ANLU. Which one decides
  whether this is config or development. Unconfirmed — must be read off AS03 via
  F1 -> Technical Information.
- The KBA proves an `E_FixedAsset` extension reaches `I_FixedAsset`. It does **not**
  establish that the field propagates onward into the F1592 worklist stack, nor that it
  appears in "Adapt Filters" without a separate metadata extension. Open question.
- **Item 1 (depreciation key not defaulting) is not a Fiori defect** and should not be
  handled in the same thread as items 2 and 3.

## Ships how

Nothing to ship yet. If it becomes a CDS extension it is abapGit/paste of a new Z object;
no standard object is to be modified.
