# Uploading the ATC corrections with abapGit standalone

51 corrected program includes, 14 packages. Everything here is **program / program
include (R3TR PROG)** — no function groups, classes or smart forms.

---

## The one rule that decides the whole process

**abapGit will not write an object from a bare `.abap` file.** Every object in a
repo needs its metadata companion `<name>.prog.xml` (PROGDIR: SUBC, APPL, FIXPT,
UCCHECK, …) plus the text pool. If the XML is missing, abapGit ignores the file;
if the XML is wrong, it can change the program's attributes.

I cannot write that XML by hand safely — and I don't need to, because **these
objects already exist in the target system**. So:

> **Export from the target first, drop our `.abap` files on top, import back.**

The exported ZIP already contains the correct XML for every object. We only ever
replace source, never metadata.

---

## Process, per package

Do this once per package (see the package list below).

### 1. Create the offline repo — target system

1. Run the abapGit standalone report (`ZABAPGIT_STANDALONE`, or whatever it was
   installed as).
2. `+ New` → **New Offline Repo**.
3. Package: e.g. `ZFI_OTH`. Name it anything, e.g. `ATC_ZFI_OTH`.
4. The repo opens and lists the objects in that package.

### 2. Export the current state

5. Repo menu → **Advanced → Export package to ZIP** (some builds: `Zip → Export`).
6. Save the ZIP to your PC. **Keep this file untouched — it is your rollback.**
7. Take a second copy and unzip it. You get a `src/` folder with, per object,
   `<name>.prog.abap` and `<name>.prog.xml`.

### 3. Overlay the corrections

8. From `by_package\<PACKAGE>\src\`, copy the `*.prog.abap` files over the ones in
   the unzipped `src\`. Filenames match exactly, so this is a plain overwrite.
9. **Do not touch any `.xml`.** Do not add files that were not in the export.
10. Re-zip so the archive has the same internal layout as the exported one
    (usually `src/...` at the root — match whatever you unzipped).

### 4. Import and pull

11. In the same repo → **Advanced → Import package from ZIP** (`Zip → Import`).
12. abapGit shows the diff. **Review it**: only the files you overwrote should
    appear, and the changes should be the `"#EC` pragmas, `SORT`/`ORDER BY`
    additions, commented-out old statements and their replacements.
13. **Pull**. abapGit asks for a transport request. Objects are written and
    activated.
14. Anything that fails activation stays inactive — fix, then mass-activate via
    SE80 → Utilities → Inactive Objects.

---

## Packages and file counts

| Package | Files | Parent objects |
|---|---:|---|
| ZFI_OTH | 20 | SAPMZFI_VPAN_MAINTAIN(_BAK), ZFI_BCM_REJREC, ZFI_CHNG_PYBLCK(D), ZFI_CP_MASS_VEN_PAY, ZFI_JV_TB, ZFI_REM_PYBLCK, ZFI_REP_BLOCK, ZFI_RFSEPA03, ZFI_TAX_* , ZFI_UPDATE_*, ZJVC_LOG_REPORT, ZR_JV_POST |
| ZMM_OTH | 8 | SAPMZMMCODREQ, SAPMZMMCODREQ_ERROR_RESET, SAPMZMMVENDOR, ZZRBUS2105 |
| ZFI_GL | 4 | ZFCLEAR, ZF_CHECK_OI_BALANCE_EXT, ZF_FILL_MISSING_AUGGJ_NGLM, ZF_RESET_CLR |
| ZJVA_OTH | 3 | SAPMZPSJVCCFCFORMS, ZJV_SAPF100 |
| ZCO_PCA | 3 | Z_CORR_PRCTR, Z_CORR_PRCTR2, Z_CORR_PRCTR_OVL |
| ZHR_DEV | 2 | SAPMZPZ9920_MED_INPATIENT |
| ZGEN_00 | 2 | ZF_CORR_PSWSL, ZF_EDIT_CLEARING |
| ZPM_WCM | 2 | ZRIWFWA01, ZRIWFWD01 |
| ZSD_BL | 2 | ZSD_CORRECT_RFBSK, ZSD_INVOICE_VAPEXP_DP |
| ZUFSO_TO_ICE | 1 | ZFI_VOUCHER_PRINT |
| ZCFM | 1 | ZF_RESET_CLEARING |
| ZEHS_OH | 1 | ZPME_SFORM_REPORT |
| ZPM_LDM | 1 | ZRCCWFL01 |
| ZFI_AR | 1 | Z_REVERSE_CLEARING |

**Three packages carry 32 of the 51 files** — do `ZFI_OTH`, `ZMM_OTH` and
`ZFI_GL` first and most of the work is done.

### Fewer repos, if the packages share a parent

If these 14 are subpackages of one parent (check SE21 / SE80 package hierarchy),
create **one** offline repo on the parent and set *Folder logic = PREFIX* (repo
settings). abapGit then covers the parent and its subpackages, and one
export/import round does everything. Worth 5 minutes checking before creating 14
repos.

---

## Before you pull — checks that matter

- **Our files are the full include source as downloaded on 08.08.2026.** If anyone
  changed those includes in the system since, pulling overwrites that work.
  The step-2 export is your safety net: diff the exported `.abap` against
  `by_package\...` before overwriting, and stop if you see changes you don't
  recognise.
- **Review the abapGit diff screen every time.** If an object appears that you did
  not overwrite, something is wrong — cancel.
- **Keep the untouched export ZIP.** Re-importing it is the rollback.
- **Transport**: non-`$TMP` packages will prompt for a TR. Use one TR for the whole
  exercise if you want it to move as a unit.

---

## Not included here

- **`MANUAL_REVIEW_LIST.xlsx`** (26 rows) — P1 field-length decisions, the XK01
  BDC, BSEG statements a CDS can't serve. Not code changes; nothing to upload.
- **Objects with no source** — 13 function groups, 3 classes, 6 smart forms were
  never exported, so none of their findings were worked.
- **Parked**: BP\* reads (20 findings) and all DML writes (24 findings).

---

## If you would rather use a GitHub repo than offline ZIP

The layout in `src/` is already abapGit-shaped, so this folder can be committed
as-is once the `.xml` files from the target export are added alongside. Online
repos need the SAP system to reach github.com over HTTPS with the certificate in
STRUST, which is usually the blocker — offline ZIP avoids it entirely.
