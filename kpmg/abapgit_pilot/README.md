# abapGit DDIC import — pilot test

Purpose: prove that domains, data elements and tables can be created in the SAP
system by importing an abapGit repository, instead of building them by hand in SE11.

If this works, the DDIC effort on every object (currently costed at ~2.5 days for the
Pipes scheme and similar for the forecast object) collapses to writing XML.

## What is in the pilot

Deliberately small, but it exercises the full dependency chain DOMA -> DTEL -> TABL,
which is the only part that is genuinely in doubt. abapGit has to create and activate
them in the right order for the table to activate at all.

| File | Object | Type |
|---|---|---|
| `src/zdo_budget_amt.doma.xml` | `ZDO_BUDGET_AMT` | Domain, CURR 15,2 |
| `src/zde_budget.dtel.xml` | `ZDE_BUDGET` | Data element on that domain |
| `src/zde_add_budget.dtel.xml` | `ZDE_ADD_BUDGET` | Data element on that domain |
| `src/zmm_po_budget.tabl.xml` | `ZMM_PO_BUDGET` | Transparent table, 9 fields |
| `src/package.devc.xml` | package | Package description |

`ZMM_PO_BUDGET` is the budget table from WRICEF `050_BRD_FS`, with two fields the FS
omits — `WAERS` (the FS has an amount with no currency) and `AENAM` alongside the
change date.

## Which abapGit to use

**Use standalone / offline mode.** `ZABAPGIT_STANDALONE` is a single report with no
package dependencies, and an offline repository takes a ZIP uploaded from your PC.
The SAP server never needs to reach github.com — which matters, because outbound
internet from an application server is normally blocked at a client like this.

Online repositories (and the abapGit ADT integration that the MCP `gitCreateRepo` /
`gitPullRepo` calls use) require the server to reach GitHub directly. Do not start
there; it will most likely fail for network reasons and tell you nothing about
whether DDIC import works.

## Test procedure

1. Connect the VPN. The dev system is `192.168.11.21:8020` and is currently timing out.
2. Confirm abapGit is installed — `SE38` -> `ZABAPGIT_STANDALONE`. If it is not there,
   install it: download `zabapgit_standalone.prog.abap` from the abapGit releases page,
   create report `ZABAPGIT_STANDALONE` in `SE38`, paste, activate.
3. Run `ZABAPGIT_STANDALONE`.
4. `New Offline Repo`. Package `ZMM_PO_BUDGET` (or your approved package — see Q1 on
   namespace), name anything.
5. `Import package from ZIP` and choose `ZMM_PO_BUDGET_pilot.zip`.
6. `Pull` / `Import`. Assign a transport when prompted.
7. Check the result.

## What counts as a pass

- All four DDIC objects exist and are **active** (`SE11`)
- `ZMM_PO_BUDGET` activates with no "field ... does not exist" errors, proving abapGit
  resolved the DOMA -> DTEL -> TABL order itself
- `BUDGET` and `ADD_BUDGET` show currency reference `ZMM_PO_BUDGET-WAERS`
- The objects are on a transport

## Known things to watch

- **Activation order.** If the table fails first pass, pull a second time. abapGit
  retries dependencies, but a single pass can leave objects inactive.
- **Package must exist or be creatable.** If your user cannot create packages, create
  the package in `SE21` first and import into it.
- **`$TMP` will not transport.** Use a real package if you want the objects moved on.
- **Table maintenance generation (`SE54`) is not included** — abapGit does not
  serialise the generated maintenance dialog. That stays manual.

## If it passes

Everything else follows the same pattern. Next steps would be to serialise the full
DDIC set for `ZSD_SCHEME` (7 tables, 8 domains, 10 data elements) and `ZPP_FORECAST`
(11 tables), plus the classes and programs, which abapGit handles as plain `.abap`
files and is the easy part.

The realistic saving is on DDIC and source creation only. Screen painter (`SE51`),
GUI status (`SE41`), SM30 view generation (`SE54`), number ranges (`SNRO`),
authorisation objects (`SU21`) and change document objects (`SCDO`) are not
serialisable and stay manual.
