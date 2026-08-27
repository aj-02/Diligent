# Draft mail to functional — 27/08/26

Not sent. Sending stays manual.

---

**Subject:** ZFIIMPR — impairment posting corrected for S/4

---

Hi <name>,

ZFIIMPR was failing in SM35. On S/4, ABAA and ABZU are no longer posting
transactions — they redirect via RADISPATCH_AB01, and batch input cannot follow
a redirect.

The posting has been moved to the standard FI-AA BAPIs:

- BAPI_ASSET_VALUE_ADJUST — impairment and unplanned depreciation, replacing ABAA
- BAPI_ASSET_WRITEUP — write-back, replacing ABZU

Accounting principle 0004 is passed on both, as advised.

The program is ready for your testing. Please note Asset Accounting fiscal year
2026 is closed for OVL, so nothing will post until the period is confirmed.

Thanks & Regards,
Arnav Johri | Associate Consultant | Diligent Global
