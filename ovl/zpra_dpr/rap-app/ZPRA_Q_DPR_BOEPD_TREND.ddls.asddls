@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR BOEPD Trend - Actual vs BE Target (Excel tab 2)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@OData.entityType.name: 'DPRBoepdTrendType'

define view entity ZPRA_Q_DPR_BOEPD_TREND
  with parameters
    P_DateFrom : datum,
    P_DateTo   : datum,
    P_Asset    : oiu_dn_no

  as select from ZPRA_C_DPR_BOEPD_DAY

{
  key ProductionDate,
  key Asset,
  key Block,
  key Product,

      ProductGroup,

      @EndUserText.label: 'Actual Production (BOEPD)'
      ActualBoepdOvl,

      @EndUserText.label: 'BE Target (BOEPD)'
      TargetBoepd,

      @EndUserText.label: 'Actual BOEPD (JV)'
      ActualBoepdJv,

      @EndUserText.label: 'Actual Qty OVL (BOPD/MMSCMD)'
      ActualQtyOvl
}
where ProductionDate >= $parameters.P_DateFrom
  and ProductionDate <= $parameters.P_DateTo
  and ( $parameters.P_Asset = '' or Asset = $parameters.P_Asset )
