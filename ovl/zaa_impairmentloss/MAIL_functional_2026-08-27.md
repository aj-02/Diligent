# Draft mail to functional — 27/08/26

Not sent. Sending stays manual.

---

**Subject:** ZFIIMPR — impairment posting corrected for S/4, three confirmations needed

---

Hi <name>,

ZFIIMPR was failing in SM35. On S/4, ABAA and ABZU are no longer posting
transactions — they redirect via RADISPATCH_AB01, and batch input cannot follow
a redirect. We have moved the posting to the standard FI-AA BAPIs:
BAPI_ASSET_VALUE_ADJUST for impairment and unplanned depreciation, and
BAPI_ASSET_WRITEUP for write-back. There is no longer an SM35 session — each
asset is validated before posting and the result is shown on screen.

Please confirm:

1. Which period the impairment should post to. Asset Accounting fiscal year
   2026 is closed for OVL, so nothing posts at present.
2. That impairment should post under accounting principle 0004 only. ECC had no
   accounting principle on this posting.
3. That transaction types X20 / X30, and X21 / X32 / X70 / X71 / 641 / 651,
   remain correct under new Asset Accounting.

Thanks & Regards,
Arnav Johri | Associate Consultant | Diligent Global
