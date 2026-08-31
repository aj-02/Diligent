# ZPP_FORECAST_PAINTS — ISSUES

| # | Date | Issue | Cause | Fix | TR |
|---|------|-------|-------|-----|----|
| — | 31/08/26 | CR-2C received (mail from Bhavini Jain, `Forecast Template-Paints.xlsx`). Template filed under `docs/`. Open points listed in `NOTES.md`. | — | — | — |
| — | 31/08/26 | CR-2C built end to end: DDIC, message class, 2 classes, 3 reports. Packaged as `ZPP_PAINT_FORECAST.zip` (47 objects) for a single abapGit import. | — | Built to the FS with 22 open points recorded in `docs/OPEN_QUESTIONS.md`. | — |
| — | 31/08/26 | Generation report called the engine statically while the engine declares instance methods with instance state. | Contract did not pin the engine to `CLASS-METHODS`; the parallel report agent assumed `=>`. | Report now does `CREATE OBJECT go_fcst` and calls `go_fcst->`, matching the Adhesive pattern. | — |
| — | 31/08/26 | Engine derived PACK SIZE from `MARA-VOLUM` and QTY/CARTON from `MARM-UMREZ / UMREN`. | Agent read the FS as silent on both; the FS does specify them. | PACK SIZE is `MARM-UMREN` of the first alternative unit, divided by 1000 when the unit is ML or GM; QTY/CARTON is `MVKE-AUMNG` where MVGR1 is not blank. | — |
| — | 31/08/26 | Plant declared `OBLIGATORY` on the generation report. | Mandatory fields are checked on every PAI, so an empty plant blocks the mode radio button — the trap the Adhesive report documents. | `OBLIGATORY` dropped; message 001 checks it on Execute and covers background runs. | — |
| — | 31/08/26 | Upload rejections for over-length values and for lock / write failure were free text, with no message number. | Message class stopped at 032. | Added 033, 034, 035 and wired them up. | — |
