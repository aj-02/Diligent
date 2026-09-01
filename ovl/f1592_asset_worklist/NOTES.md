# F1592 — Display Asset Master Worklist: add "Custodian of Assets"

**Client:** OVL · **App:** F1592 (Display Asset Master Worklist) · **Started:** 01/09/26

## What this is

The Custodian of Assets field is maintained in the asset master but does not
appear in F1592, because the field is not selected by the CDS stack behind the
app. Fix is a modification-free CDS extension of the two standard views plus a
metadata extension for the UI annotation.

Stack (views confirmed by Arnav; source table confirmed as **ANLU**):

    ANLU  (asset master user fields, CI_ANLU customer include)   <-- custodian lives here
        ~ associated [0..1] directly from the extension, no wrapper view ~
    ANLA -> I_FixedAssetWorklist             (standard interface view)
             -> C_FixedAssetWorklist         (standard consumption view, exposed by the service)
                 -> OData service            -> F1592

## Confirm before coding — 3 checks, ~10 minutes

These decide whether the delivered sources activate as written. Do not skip 1.

**1. Technical name of the field.** AS03 → open any asset → click into the
Custodian of Assets field → **F1** → *Technical Information*. Note **Table** and
**Field name** exactly. Two very different outcomes:

  - Field is on **ANLA** (or any table already in the FROM of
    I_FixedAssetWorklist) → Variant A below. Straightforward.
  - Field is on **ANLZ** (time-dependent allocations) or another table not in
    the view → **Variant B**. An extend view cannot add a join, so this is a
    materially bigger change. Tell me which before I finalise.

  Note: if the Technical Information shows a `ZZ`/`YY1_` field, this is a
  customer field, not standard SAP — say so, because if it was created with the
  *Custom Fields and Logic* (CBEB) app the correct fix is to enable it for the
  relevant business context there, and no hand-written CDS is needed at all.

**2. Alias used in the standard view's FROM.** In ADT open
`I_FixedAssetWorklist` (Ctrl+Shift+A). Read the `from ... as <alias>` clause.
The extension must reference `<alias>.<field>`.

**3. DDL view or view entity.** Same source. First line reads either
`define view I_FixedAssetWorklist` (classic DDL view — sources as delivered are
correct) or `define view entity I_FixedAssetWorklist` (then switch both extend
views to `extend view entity` and delete `@AbapCatalog.sqlViewAppendName`).

Also worth 2 minutes before any of this: open F1592 and try **Settings (gear)
→ Columns**. If Custodian of Assets is already listed there, it is in the
service already and no development is needed.

## Objects

Activate strictly in this order. Same transport.

| # | Object | Type | File |
|---|--------|------|------|
| 1 | `ZZI_FIXEDASSETWORKLIST_EXT` | CDS extend view (interface) | `ZZI_FIXEDASSETWORKLIST_EXT.ddls.asddls` |
| 2 | `ZZC_FIXEDASSETWORKLIST_EXT` | CDS extend view (consumption) | `ZZC_FIXEDASSETWORKLIST_EXT.ddls.asddls` |
| 3 | `ZZC_FIXEDASSETWL_MDE` | CDS metadata extension (DDLX) | `ZZC_FIXEDASSETWL_MDE.ddlx.asddlx` |

**All three are extensions — no new view is created.** A CDS association can
target a DDIC table directly, so ANLU is reached from the extension itself. The
earlier `ZZI_FIXEDASSET_USERFIELD` wrapper view was unnecessary and has been
deleted.

Exposed element name is `ZZCustodianOfAssets` in all three. Ships by paste into
ADT (new DDL source / new metadata extension) — not by abapGit ZIP.

## The ANLU finding, and what it means

Confirmed: the custodian field is on **ANLU** — *Asset Master Record User Fields*,
the CI_ANLU customer-include table. Consequences, all of them good:

- **Not time-dependent.** ANLU is keyed MANDT/BUKRS/ANLN1/ANLN2, one row per
  asset — the same key as ANLA. None of the ANLZ validity-interval trouble
  applies: no key-date decision for the functional team, no row multiplication.
- **But ANLU is not in the standard view's FROM.** SAP does not join a
  customer-include table. An `extend view` appends to the SELECT list over the
  *existing* data sources; it cannot add a join. So the field cannot simply be
  named in the extension.
- **Route taken:** declare a `[0..1]` association **straight to the ANLU table**
  inside the `I_FixedAssetWorklist` extension and select through it. A CDS
  association may target a DDIC table, not just a CDS entity, so no wrapper
  view is needed. The path expression compiles to a LEFT OUTER JOIN.
- **`[0..1]`, not `[1..1]`.** ANLU rows exist only where user fields were
  maintained. `[1..1]` would inner-join and silently drop every asset with no
  custodian from the worklist — a data-loss bug nobody notices until the list
  is short.
- **Not a CBEB field.** CI_ANLU is the classic append route, so the *Custom
  Fields and Logic* app is not involved and cannot do this for us.

Both unknowns are now confirmed (Arnav, 01/09/26):

| | Value |
|---|---|
| ANLU field | `ZZCUSTODIAN` |
| ANLA alias in `I_FixedAssetWorklist` | `an` |

No placeholders remain in any of the three sources.

## Does anything in the flow already read ANLU?

Worth checking before pasting — if it does, the association goes away too and
this collapses to a one-line extension. Fastest route is a where-used on the
table, which answers it for the whole system in one screen:

**`/nSE11` → Database table `ANLU` → Display → Where-Used List
(Ctrl+Shift+F3) → tick *Views* and *CDS views* / *DDIC objects* → Enter.**

ADT equivalent: open ANLU, Ctrl+Shift+G (Get Where-Used).

Read the result three ways:

- **Nothing comes back** → expected. Keep the association as delivered.
- **A standard CDS view reads ANLU** → open `I_FixedAssetWorklist` and check
  its association list at the top for one pointing at that view. If there is
  one, use `_ThatAssoc.<field>` and delete our association. If there is not,
  ours still stands — a view existing elsewhere does not put it in scope here.
- **A Z view already reads ANLU** → someone has done this before. Send it to
  me before we add a second one.

## Fallback, if the association is rejected

Declaring an association inside a view extension is release-dependent. If ADT
rejects it, this is a design change, not a syntax fix. Options in order:

1. **Use an association the standard view already publishes** — if
   `I_FixedAssetWorklist` exposes `_FixedAsset` or similar to an ANLA-based
   view, extend *that* view instead and let the worklist inherit the element.
2. **Custom worklist view** — copy the C_ stack into Z, join ANLU there, point
   a custom tile at it. Loses SAP maintenance; last resort.

## After activation

The CDS work is about half the job. Metadata is cached in several places and
clearing one is not enough.

| Step | Where |
|---|---|
| 1 | `/IWBEP/CACHE_CLEANUP` — backend metadata cache |
| 2 | `/IWFND/CACHE_CLEANUP` — gateway metadata cache |
| 3 | `/IWFND/MAINT_SERVICE` — select the F1592 service → **Load Metadata** |
| 4 | `/UI2/INVALIDATE_CLIENT_CACHES` — UI5 client cache |
| 5 | Browser hard reload / clear site data |

**Verify backend before touching the UI.** Call the service `$metadata` in the
browser and search for `ZZCustodianOfAssets`. If it is absent, the problem is
backend and no amount of frontend work will help.

Then in F1592: **Settings (gear) → Columns → add Custodian of Assets**, and
Adapt Filters if the field should be filterable. To make it appear by default
for all users, a key user must save it into the default variant via
**Adapt UI / key-user adaptation** — activating the CDS does not change anyone's
saved variant.

## What is NOT needed here

- No RAP / behavior-definition work. F1592 is display-only, so there is no
  draft table, no `extend behavior definition`, no BDEF reactivation.
- No SEGW regeneration — the app is CDS-service based, so an extended entity
  flows through without redefining the DPC/MPC.
- No DCL change for the field itself. But if Variant B pulls the value from a
  second table, re-check that the existing authorisation concept still holds.
- No change to any standard SAP object.

## Manual / out of scope

Transport release, QA and production import, and the key-user default-variant
change all stay manual.

## Risks

- The custodian field may turn out to be a customer field created in CBEB, in
  which case this whole CDS route is the wrong tool — see check 1.
- Field label comes from the underlying data element. The `label:` in the DDLX
  overrides it for the column header; if the value help or filter label reads
  as a technical name, that needs `@EndUserText.label` on the extend view too.
- No `original/` folder here: these are new customer objects, not SE80
  downloads of existing ones.
