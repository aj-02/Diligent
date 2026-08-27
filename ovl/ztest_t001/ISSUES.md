# Issues — ZTEST_T001

Log format: date | issue | root cause | files changed | commit | TR

| 27/08/26 | `ZTEST_T001.zip` import would short-dump `XML_FORMAT_ERROR` / `CX_XSLT_FORMAT_ERROR` in `FROM_XML` | `<VARCL>` out of sequence in `PROGDIR`. abapGit deserialises with `CALL TRANSFORMATION id`, which walks `zif_abapgit_sap_report=>ty_progdir` in component order and rejects out-of-order elements. Declared order is `name`(1), `varcl`(5), `subc`(11), `fixpt`(23), `uccheck`(30); the file had `NAME, SUBC, FIXPT, VARCL, UCCHECK`. Found while debugging the same dump on `kpmg/zfi_tds_cl34` | `src/ztest_t001.prog.xml` reordered to `NAME, VARCL, SUBC, FIXPT, UCCHECK`; `ZTEST_T001.zip` rebuilt | n/a |
