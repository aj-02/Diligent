# Rectification analysis — Custodian of Assets / Joint Venture in Fiori Asset apps

Date: 01/09/26 · Source: SAP KBA 3049624 (`sap_notes/3049624.md`) + open-source research sweep.
**No system access.** Everything below is marked either CONFIRMED (corroborated by a source or by
this repo) or VERIFY (must be read off OVL's system before it goes into code or a client mail).
A wrong CDS/table/field name costs an activation cycle — nothing unverified goes into an object.

---

## 1. The two view names in SAP's reply are not SAP names

Gaurav's mail names `C_FixedAssetWorklist` and `I_FixedAssetWorklist`.

- **Neither could be found in any public SAP artefact.** (VERIFY, but searched hard.)
- `_FixedAssetWorklist` exists in real SAP CDS source only as an **association alias**, and it
  points at `I_FixedAsset` — seen in `I_PurgDocAccountAssignment` / `I_PurOrdAccountAssignment`
  (MM-PUR). That is the likely origin of the name: it reads like a view but is an alias. (CONFIRMED)
- `C_FixedAssetWorklistOvw` **does** exist — but it belongs to `FAA_ASSET_OVERVIEWPAGE_SRV`, i.e.
  the *Asset Master Worklist card on the Asset Accounting overview page*, not app F1592. (CONFIRMED)

**Do not create objects against, or raise an incident quoting, either name.** Read the real one
off the system (§6).

## 2. What KBA 3049624 does and does not cover

- Scoped to **F1615 / F1617** (analytical, cube+query). Says nothing about **F1592**. (CONFIRMED)
- "Works as designed" — there is **no correction to implement**. (CONFIRMED)
- Its route — custom field in **ANLU** → extension view **`E_FixedAsset`** → reachable from
  `I_FixedAsset` → consumed via the `_FixedAsset` association from the cube in a *custom analytical
  query* — is an **analytical** remedy. It does not transfer to F1592, which has no cube and no
  analytical query in its stack. (CONFIRMED)
- **Its release table is stale and self-contradicting.** The KBA prose says F1615 is based on
  `I_AssetHistorySheetCube`; its numbered list puts that view on the *older* releases. SAP's own
  S/4HANA 2020 material says the deprecation runs the **opposite** way to the KBA table:
  `I_FixedAssetValueCube` → successor `I_AssetBalanceCube`; `I_FixedAssetAHSValueCube` → successor
  `I_AssetHistorySheetCube`; `C_FixedAssetHistorySheet` → `C_AssetHistorySheet`;
  `C_FixedAssetBalance` → `C_AssetBalance`. (VERIFY in the View Browser — but do not build on the
  KBA's "FPS03 and above" column without checking, it is the more likely of the two to be wrong.)

## 3. What actually rectifies items 2 and 3 — key-user extensibility

**SAP documents the fixed asset master as key-user extensible via the "Custom Fields and Logic"
app, and documents Display Asset Master Worklist among the apps a field created against the
asset-master business context becomes available in.** (CONFIRMED) That is the single strongest
answer to OVL's observations 2 and 3, and it is configuration + publish, not development.

Route:

1. Custom Fields app → business context for the fixed asset master (pick it by its **label** in the
   dropdown; the technical name is only needed for SCFD_REGISTRY and BAdI filters — do **not** quote
   a technical name, none was corroborated).
2. Create the field (or promote an existing one — see the SCFD_EUI point below).
3. **"UIs and Reports" tab → Enable Usage, per target.** Nothing propagates automatically; each app,
   CDS view and OData service is enabled individually. (CONFIRMED — the earlier belief that key-user
   fields reach "the Fiori apps" automatically was REFUTED in verification.)
4. Publish. Then caches: `/IWBEP/CACHE_CLEANUP` → `/IWFND/CACHE_CLEANUP` →
   `/UI2/INVALIDATE_GLOBAL_CACHES` + `/UI2/INVALIDATE_CLIENT_CACHES` → hard browser refresh.
   Check `$metadata` in `/IWFND/GW_CLIENT` before reporting failure.

Three things that bite on this route:

- **If ECC-era `CI_ANLU` fields already exist** (very likely after a conversion), do **not** create a
  new custom field. Promote the existing one with transaction **`SCFD_EUI`** — it preserves the data,
  no migration. SCFD_EUI itself reports each field as enableable or as needing preparation; that
  report is the answer, not reasoning. (CONFIRMED)
- **On-premise these are transportable objects.** The field and every Enable Usage land in a
  transport and must be moved DEV→QA→PRD like any other change. This is not a runtime-only setting
  the way it is in Cloud. Put it in the estimate.
- **A key-user field will not appear in AS01/AS02/AS03** without separate screen-layout Customizing.
  Out of scope for what OVL raised (all three observations are Fiori), but raise it so nobody is
  surprised later.

## 4. The hard blocker to settle before any build

**The asset master can be key-user enhanced only with TIME-INDEPENDENT fields.** Time-dependent
asset data (ANLZ — cost centre, plant, location, room) is not key-user extensible. (CONFIRMED)

Custodians transfer. If OVL want "Custodian of Assets" to change over the asset's life and to be
reportable as of a date, the requirement is **inherently time-dependent** and this route cannot
deliver it — that becomes developer extensibility or a Z table plus CDS. **Establish the
time-dependency requirement with the functional consultant before anything is built.**

This is also why the KBA scopes its route to ANLU: ANLU is 1:1 with ANLA. You **cannot** pull a
field into an `EXTEND VIEW` through a `[0..*]` association — attempting it on ANLB via
`_FixedAssetDeprArea` fails with *"'To many' associations (cardinality [n..*]) are not allowed
here"*. The same restriction bars ANLZ fields. (CONFIRMED)

## 5. Three premises to test before treating either item as a build

| # | Question | Why it flips the answer |
|---|---|---|
| A | Does "Custodian of Assets" already exist? | Candidates: `ANLZ-PERNR` (personnel number, time-dependent tab — the strongest *standard* candidate); an evaluation group (`ANLA-ORD41..ORD44`, `ANLA-GDLGRP`); or an existing `CI_ANLU` field from ECC. If it exists, this is an **exposure** task, not an extensibility task. No standard SAP field labelled "Custodian" was found on ANLA. (`ANLA-XV0NM` is *not* it — it is "name of person who changed View0", an audit field. Ruled out despite the label.) |
| B | Does ANLA physically carry the JVA venture fields? | `VNAME` / `RECID` / `ETYPE` are confirmed on structure **ANLAV**; whether they sit on transparent **ANLA** is unsettled. ANLAV is built on ANLA, so the balance of probability runs *toward* ANLA holding them. **JVA is active at OVL** — this repo's `ZR_JV_POST` reads `JVSO1` and uses `jv_egroup`. So the "JVA not active, use a custom field" branch is wrong; the real question is whether the fields are exposed on the screen layout and whether they reach the app's CDS stack. |
| C | Did OVL mean W0135? | **W0135 "Group Data Analysis" is a Group Reporting / consolidation app, not Asset Accounting.** (CONFIRMED) Its extensibility path is entirely different — Group Reporting journal entry item / ACDOCU, not the asset CDS stack. Ask the functional consultant what they meant before answering it as an asset issue. |

## 6. In-system checks, in order (nothing here needs the SAP portal)

1. **F1592's real identity.** Open the app → user avatar → App Information / Technical Information.
   Gives the Fiori ID, UI5 component and the OData service actually called. Two minutes, and it
   settles §1.
2. `/IWFND/MAINT_SERVICE` → find that service → **Gateway Client → GET `$metadata`**. Every property
   with `sap:filterable="true"` is the Adapt Filters candidate list — that is literally what drives
   the dialog in OVL's screenshot. Look for existing `YY1_*` properties (key-user fields already
   published) and for the evaluation groups / `PERNR`.
3. `/IWFND/TRACES` → Payload Trace on your user → run F1592, apply a filter → read the request URI.
   Fastest empirical answer to "what drives Adapt Filters".
4. `SE11` → **ANLU** → Extras → Append structures, and the `CI_ANLU` include. Does Custodian already
   exist? Does Joint Venture? Note exact names and data elements.
5. `SE11` → **ANLA** → search the field list for `VNAME` / `RECID` / `ETYPE`. Settles premise B in
   thirty seconds.
6. `AS03` on a real asset → the field OVL call "Custodian" → **F1 → Technical Information**. Settles
   premise A definitively.
7. `SCFD_REGISTRY` → find the business context for the asset master → note its **exact** technical
   name and what is registered as extensible against it. If F1592's service/view is absent,
   key-user extensibility will not reach it and the remaining route is developer extensibility.
8. `SCFD_EUI` → does it list existing ANLU fields as enableable?
9. Sandbox test that settles everything empirically: create a throwaway custom field, open its
   **UIs and Reports** tab, screenshot which targets offer Enable Usage, publish, reopen F1592 →
   Adapt Filters. **That screenshot is the evidence for the reply to OVL.**
10. If it does come to developer extensibility: ADT → open `E_FixedAsset` and `I_FixedAsset` and
    record verbatim the `@AbapCatalog.extensibility{...}` block (elementSuffix, dataSources aliases,
    allowNewDatasources), `@AbapCatalog.viewEnhancementCategory` and whether
    `@Metadata.allowExtensions: true` is present. Everything about the syntax hangs on that block —
    see §7.

## 7. If it does come to developer extensibility (only after §6 says key-user cannot reach it)

- **Two extension objects, not one.** Extending `E_FixedAsset` alone does **not** put the field into
  `I_FixedAsset`. You extend `E_FixedAsset` to add the ANLU field, then extend `I_FixedAsset` to
  re-expose it through the association. The KBA sentence is shorthand for that. (CONFIRMED)
- **Nothing propagates up the stack.** Every consuming view that must show the field is its own
  extension object. (CONFIRMED — the most important single point in this thread.)
- `EXTEND VIEW` + mandatory `@AbapCatalog.sqlViewAppendName` (max 16 chars) for a DDIC-based view;
  `EXTEND VIEW ENTITY` with **no** sqlViewAppendName for a view entity. Getting this wrong is a
  guaranteed activation failure, and which one applies is unknown until §6.10.
- Element names carry the `ZZ` customer prefix **and**, if the view declares
  `@AbapCatalog.extensibility.elementSuffix`, must **end** with that exact 3-char suffix. Both rules
  apply together.
- Visibility is a **separate object**: a metadata extension (DDLX) on the consumption view,
  `@Metadata.layer: #CUSTOMER`, adding `@UI.selectionField` / `@UI.lineItem`. Only valid if the
  target carries `@Metadata.allowExtensions: true`.
- **DDLS extensions and DDLX have no SE80 editor — ADT/Eclipse is mandatory.** If the team is SE80-only
  this task cannot be done at all.
- **If F1592's service turns out to be a hand-built SEGW Gateway project**, CDS extension will not
  surface the field on its own — the model has to be regenerated there. Establish which it is
  (§6.1–6.2) *first*, not as an afterthought.
- Budget the activation: extending `I_FixedAsset` triggers mass activation of every dependent view.
  One field report puts it around two hours. Do it in DEV with the runtime measured.
- `E_FixedAsset`'s existence is asserted **only** by KBA 3049624 — no independent source. On an
  older S/4 release the E_* extension-include pattern may simply not be delivered. Confirm in ADT
  before promising this route at all.

## 8. Item 1 — depreciation key — is not a Fiori defect and not this thread

- **`0000` is not an empty field.** It is a real SAP depreciation key meaning *no depreciation and no
  interest*. The screenshot shows a key that defaulted — just the wrong one. (Reframes the whole
  question: it is not "defaulting is broken".)
- The default per asset class × chart × area is **`OAYZ`** ("Determine Depreciation Areas in the
  Asset Class", program `RAVCLUST`), table **`ANKB`**. (CONFIRMED)
- **`OAY2` is not it** — that is the low-value-asset check. **`AS08` is not it** — number ranges.
  Do not cite either to OVL. (CONFIRMED)
- Second, independent control: the **depreciation-area screen layout rule (`AO21`)**. A key that
  defaults correctly but sits in a suppressed field looks identical to "not defaulting". Both must
  be checked.
- **This repo already has what is needed to diagnose it without creating a test asset:**
  `ovl/zaa_impairmentloss/ISSUES.md` records chart of depreciation **ONGC** (confirmed 27/08/26 —
  there is no chart called "OVL"), and asset **106009197/0**, company code OVL, carrying ANLB areas
  01/15/20/30/31/40/60/90 — exactly the eight areas in the screenshot.

Order of work: (1) display the asset class's depreciation-area rows for chart ONGC and read the key
per area — this alone very likely closes it, and costs no test data; (2) read `ANLB-AFASL` on
106009197/0 for the historical default pattern; (3) only then the AS01 comparison.

**SAP answered items 2 and 3 and did not answer item 1 at all.** The reply must say so explicitly
and ask SAP to respond to the depreciation-key observation separately, or the thread gets closed by
a KBA that never addressed it.

## 9. Field-name traps recorded so they are not re-derived

- Config tables use **`AFABER`** (`T093-AFABER`); asset and value tables use **`AFABE`**
  (`ZAA_IMPARMENTLOSS` selects ANLC with `AFABE = '01'`). Both confirmed on this landscape. Read it
  in SE11 before writing either into a SELECT.
- `T8JV` — this repo contains both `VNAME` and `JVNAME` spellings for its key. Settle in SE11 before
  writing a SELECT. The key is company-code dependent (`BUKRS` + venture) in every case.
- `JV_NAME` and `JV_RECIND` are corroborated data elements. `JV_ETYPE` is **not** — and do not
  confuse it with `JV_EGROUP` (equity *group*), which is corroborated in `ZR_JV_POST`.
- `JV_OTYPE` / `JV_JIBCL` / `JV_JIBSA` are unconfirmed on any asset table. Do not use them.
  (And do not rule JIB/JIBE out on geography — OVL holds overseas JV interests.)
- The ledgers `4A` / `4C` in `COPILOT_CONTEXT_HANDOFF.md` §5.8 are **JVA** ledgers on `JVSO1`, not
  parallel accounting ledgers. They say nothing about depreciation-area count.
- OVL's own system supplies the DDIC names — `ovl/atc/object-list/Reports/Z_TEST_ACTT.txt` is typed
  against real tables on this landscape and confirms ANKA, ANKT, T090NA, T090NAT, T090NAZ, T093,
  T093T, T093C and the T082 family. No website needed.

## 10. Blocked on

1. OVL's exact S/4HANA release + FPS (System → Status; `CWBNTHEAD` in SE16 lists implemented notes).
   Every object name above is release-sensitive.
2. The technical name behind "Custodian of Assets" (§6.6).
3. Whether the custodian requirement is time-dependent (§4) — functional question, not technical.
4. KBA **3435255** "Customer fields (ANLU table) in Fiori Apps F1615, F1617" — the See Also of
   3049624 and almost certainly the actual step-by-step. Only its title is established; the body
   needs an S-user. Also worth pulling: **3517230** (WBS Element empty — the only KBA found that
   names F1592 explicitly), **3430780** (asset master custom field not available in Fiori app),
   **3366394** (custom field in Fiori but missing in SAP GUI), **2834107**.
