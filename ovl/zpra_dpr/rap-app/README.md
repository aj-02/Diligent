# DPR RAP App — release-ported source

Release-adapted source for the ZPRA DPR Analytical RAP (ONGC DPR Excel replica:
tab-2 Actual-vs-BE-Target BOEPD graph, tab-3 Production Performance, summary
download). These files are the versions adapted to activate on the target
S/4HANA release (older) — they differ from the original design/repo, which does
not activate as-is.

## Build order (create/activate top-down)
1. Interface views: `ZPRA_I_DPR_DAILY`, `ZPRA_I_DPR_MONTHLY`, `ZPRA_I_DPR_TARGET`
2. Cube + base: `ZPRA_C_DPR_CUBE`, `ZPRA_P_DPR_DAY_BASE`, `ZPRA_C_DPR_BOEPD_DAY`, `ZPRA_P_DPR_TAR_GRP`
3. Queries (plain views): `ZPRA_Q_DPR_PROD_QUERY`, `ZPRA_Q_DPR_TARGET_QUERY`, `ZPRA_Q_DPR_DAILY_TREND`, `ZPRA_Q_DPR_BOEPD_TREND`, `ZPRA_P_DPR_PERF_AGG`, `ZPRA_Q_DPR_PROD_PERF`
4. Metadata extensions (`.ddlx.asddlx`): one per query (add `@Metadata.allowExtensions: true` on each base view first)
5. Download stack: abstract entities `ZPRA_A_DPR_*` -> root `ZPRA_I_DPR_EXCEL_DL` -> `ZCL_ZPRA_DPR_EXCEL` + `ZCL_ZPRA_DPR_PDF` -> behavior def `ZPRA_BP_DPR_EXCEL_DL` (unmanaged) -> impl `ZBP_ZPRA_DPR_EXCEL_DL` (global class + `locals_imp` handler)
6. Service: `ZPRA_SD_DPR_ANALYTICS` -> service binding `ZPRA_SB_DPR_ANALYTICS_O4` (OData V4 - UI, activate + publish)

## Notes / known gaps
- Excel download emits **CSV** (XCO XLSX not available on this release).
- `ZCL_ZPRA_DPR_PDF` is a **stub**; real PDF needs Adobe forms `ZPRA_FRM_DPR_PRODUCTION` / `ZPRA_FRM_DPR_TARGETS` (SFP) + ADS.
- Cubes not exposed in OData (analytical objects not supported by the OData V4 UI binding here); analytical queries were converted to plain views.
- **Data check:** uses `tar_qty` (design expected `tar_qty2`, which does not exist in `ZPRA_T_PRD_TAR`) — verify BE-target semantics.
- Fiscal year assumed April–March.
