# ZMM_PO_BUDGET_DEFERRED — NOTES

## What it is

`ZCL_MM_PO_BUDGET_CHECK` — the PO budget check as a standalone **global class** (224 lines),
plus its abapGit `.clas.xml`. Written with **no dependency on the BAdI interface** so the same
logic could serve the ME21N / ME22N implementation and, later, the ME31L / ME32L scheduling
agreement enhancement.

`check_document( )` takes ebeln / ekgrp / bedat / waers / items and returns `bapiret2_t`;
an empty table means the document may be saved. One check is performed **per plant**, because
plant is an item field while purchasing group is a header field — one document can consume
several budgets at once.

## Why it is "deferred"

The delivered path went **inline** into the existing `ME_PROCESS_PO_CUST` implementation
instead (see `zmm_po_budget/ZME_PROCESS_PO_CUST_CHECK_full.abap`). This class is the
alternative design, kept because it is the right shape if scheduling agreements ever come
into scope. It is currently wired to nothing.

## Gotchas

- The folder is **not a valid abapGit repo**: the two files sit at folder root, not under
  `src/`, and there is no `.abapgit.xml`. As it stands it **cannot be imported** — it must
  either move into `zmm_po_budget/src/` (and into that ZIP) or get its own `src/` +
  `.abapgit.xml`.
- `MANUAL_STEPS.md` in `zmm_po_budget/` describes a design where the BAdI `CHECK` method
  calls this class. That contradicts the inline snippet actually delivered there.
  **Decide which design is live before touching either — do not activate both.**
- The three `OPEN POINT` markers live in this class: no budget row → block or allow;
  calendar vs fiscal year; currency handling.

## Shipping: abapGit-able in principle, not importable today

Fix the folder layout first (`src/` + `.abapgit.xml`, or fold into `zmm_po_budget/src/`),
or paste into SE24.
