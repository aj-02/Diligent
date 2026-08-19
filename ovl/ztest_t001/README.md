# ZTEST_T001 - abapGit round-trip test

Smallest possible abapGit repository: one executable report, no DDIC, no package
object, no dependencies. Purpose is to prove the offline (ZIP) or online (clone)
import path works on a system with no ADT connection.

## Contents

    /.abapgit.xml                    repo descriptor (required, must be at ZIP root)
    /src/ztest_t001.prog.abap        ABAP source
    /src/ztest_t001.prog.xml         TRDIR attributes + report title text

## Import - offline (no network on the SAP system)

1. Run ZABAPGIT_STANDALONE in SE38.
2. `+ New Online/Offline` -> **New Offline** repo.
3. Name: `ZTEST_T001`, Package: `$TMP` (or a Z package; abapGit offers to create it).
4. Repo menu -> **Import package** -> upload `ZTEST_T001.zip`.
5. **Pull** / Deserialize. Confirm the object list. If the package is transportable
   abapGit prompts for a transport request; `$TMP` does not.
6. SE38 -> `ZTEST_T001` -> Execute. Expect `Hello World`.

## Import - online

abapGit always reads `.abapgit.xml` from the **git repository root**, never from a
subfolder. Two ways to serve this over an online clone:

- Push `ztest_t001/` as its own standalone repository (recommended - this folder
  is already laid out as one), or
- Keep it inside an existing repository and place a `.abapgit.xml` at that
  repository's root with `<STARTING_FOLDER>/ztest_t001/src/</STARTING_FOLDER>`.

Then in abapGit: `+ New Online`, paste the clone URL, branch `main`, package as
above, PAT as password if the host needs auth.

## Verify the serialization is well formed

After the pull, use abapGit's diff/stage view: a freshly pulled object should show
zero local changes against the repo. Any diff means a field in the XML did not
round-trip.
