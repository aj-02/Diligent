# incoming/ — drop folder for fresh SE80 downloads

Put a freshly downloaded source file here before asking for a fix. The `/fix-issue`
skill diffs whatever lands here against the repo copy in `<object>/src/` and reports
drift before changing anything.

Naming: keep the abapGit convention so the diff pairs up automatically —
`zmb5b.prog.abap`, `zcl_pp_fcst.clas.abap`.

Once a fix ships, the corrected file replaces the copy in `<object>/src/` and the
file here can be deleted.
