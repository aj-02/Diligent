# ovl/atc — notes

## Rule auditor

`./scripts/abap-audit.py <folder|file> [--md report.md]` checks ABAP source against the
standing rules in CLAUDE.md — strict Open SQL, clause order, FOR ALL ENTRIES guards,
ORDER BY PRIMARY KEY, DELETE ADJACENT DUPLICATES, SELECT-in-loop, hardcoded values,
duplicate inline @DATA. It is statement-aware (joins continuation lines, respects string
literals), reads raw SE80 / ZR_PROG_DOWNLOAD listings directly (strips the banner and the
line-number prefix), skips Native SQL blocks, and audits each distinct content once so
duplicated copies of an object do not multiply the counts.

It reads source, it does not compile — findings are candidates for review. Blind spots are
listed at the end of `AUDIT-2026-08-23.md`.

## Handover

`ATC_HANDOVER.md` is the single-file handover for all ATC correction knowledge —
project identity and marker rules, the 31 correction/activation rules with the failures
behind them, finding routing, verified CDS / API / note mappings, the state of the 51-object
OVL batch, and the gated questions still waiting on Arnav. Read it before any ATC work; the
kb/ files and the atc-fix skill are the long-form sources it distils.
