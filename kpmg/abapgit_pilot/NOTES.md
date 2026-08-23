# ABAPGIT_PILOT — NOTES

## What it is

Not a deliverable — a **proof of concept**. Purpose: prove that domains, data elements and
tables can be created in the SAP system by importing an abapGit repository instead of being
built by hand in SE11. Deliberately small, but it exercises the full **DOMA → DTEL → TABL**
dependency chain, which is the only part genuinely in doubt: abapGit has to create and
activate them in the right order for the table to activate at all.

## Contents

`.abapgit.xml` + `src/` with `ZDO_BUDGET_AMT` (CURR 15,2), `ZDE_BUDGET`, `ZDE_ADD_BUDGET`,
`ZMM_PO_BUDGET` (**9 fields here**), package.devc — packaged as `ZMM_PO_BUDGET_pilot.zip`
(6 files). README carries the procedure and pass criteria. No message class.

## Gotchas

- **Use standalone / offline mode.** `ZABAPGIT_STANDALONE` is a single report with no package
  dependencies, and an offline repo takes a ZIP from the PC, so the server never needs to
  reach github.com — which matters because outbound internet from the app server is blocked
  here. Online repos and the abapGit ADT integration (`gitCreateRepo` / `gitPullRepo`) require
  direct GitHub access; starting there will fail for network reasons and tell you nothing
  about whether DDIC import works.
- If the table fails on the first pass, **pull a second time** — abapGit retries dependencies
  but a single pass can leave objects inactive.
- The package must exist or be creatable; create it in SE21 first if your user cannot.
  `$TMP` will not transport.
- Pass criteria: all four objects active in SE11; `ZMM_PO_BUDGET` activating with no "field
  does not exist" errors; `BUDGET` / `ADD_BUDGET` showing currency reference
  `ZMM_PO_BUDGET-WAERS`; objects on a transport.
- **Name collision.** This pilot uses the same names as the real `zmm_po_budget/` repo, with a
  different field count and no message class. Importing both into one system will collide —
  pick one. Never treat the pilot table as the same table.
- `abapgit_pilot/README.md` records the ADT host used elsewhere in this repo
  (192.168.11.21) as timing out; nothing here was verified against a live system from the
  repo alone.

## What the pilot does NOT cover — stays manual on every object regardless of the result

SE51 screens · SE41 GUI statuses · SE54 maintenance generation · SNRO number ranges ·
SU21 auth objects · SCDO change document objects.

## Shipping: abapGit ZIP

That is the entire point of the folder.
