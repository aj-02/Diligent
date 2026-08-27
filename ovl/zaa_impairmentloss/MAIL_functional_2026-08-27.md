# Draft mail to functional — 27/08/26

Not sent. Sending stays manual.

---

**Subject:** ZFIIMPR — impairment posting corrected for S/4, three confirmations needed

---

Hi <name>,

The impairment posting run (ZFIIMPR / ZAAIMP) was failing in SM35 with
"LEAVE TO TRANSACTION is not allowed in batch input". Cause: on S/4, ABAA and
ABZU are no longer posting transactions — both redirect through dispatcher
program RADISPATCH_AB01, and batch input cannot follow a redirect. The program
has worked this way since 2005 and was broken by the S/4 conversion, not by any
recent change.

We have replaced the batch input with the standard FI-AA posting BAPIs —
BAPI_ASSET_VALUE_ADJUST for impairment and unplanned depreciation (was ABAA)
and BAPI_ASSET_WRITEUP for write-back (was ABZU). Each asset is now validated
before it posts, and the result is shown on screen per asset. Note this means
there is no longer an SM35 session to review before processing.

Tested on OCQ today: no session is created and every asset reaches business
validation correctly.

Three points need your confirmation before this can go further:

1. Asset Accounting fiscal year 2026 is closed for company code OVL, so the run
   currently posts nothing (message AA 370 on all 117 assets). Please confirm
   which period the impairment should post to.

2. We are passing accounting principle 0004, as advised. ECC had no accounting
   principle on this posting, so this is a change in behaviour — please confirm
   in writing that impairment should post under 0004 only.

3. Please confirm transaction types X20 / X30 for impairment, and X21 / X32 /
   X70 / X71 / 641 / 651 for the write-back and unplanned depreciation options,
   remain correct under new Asset Accounting.

Thanks & Regards,
Arnav Johri | Associate Consultant | Diligent Global
