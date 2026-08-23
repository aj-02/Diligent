@EndUserText.label: 'DPR Analytics - Service Definition'
define service ZPRA_SD_DPR_ANALYTICS
{
  /* Analytical queries (converted to plain views) */
  expose ZPRA_Q_DPR_PROD_QUERY   as DPRProductionQuery;
  expose ZPRA_Q_DPR_TARGET_QUERY as DPRTargetQuery;
  expose ZPRA_Q_DPR_DAILY_TREND  as DPRDailyTrend;
  expose ZPRA_Q_DPR_BOEPD_TREND  as DPRBoepdTrend;
  expose ZPRA_Q_DPR_PROD_PERF    as DPRProductionPerformance;

  /* Interface views (raw data) */
  expose ZPRA_I_DPR_DAILY        as DPRDailyProduction;
  expose ZPRA_I_DPR_MONTHLY      as DPRMonthlyProduction;
  expose ZPRA_I_DPR_TARGET       as DPRProductionTargets;

  /* Excel/PDF download action entity */
  expose ZPRA_I_DPR_EXCEL_DL     as DPRExcelDownload;
}
