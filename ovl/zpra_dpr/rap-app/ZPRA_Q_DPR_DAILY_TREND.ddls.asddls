@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Daily Production Trend Query'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@OData.entityType.name: 'DPRDailyTrendQueryType'

define view entity ZPRA_Q_DPR_DAILY_TREND
  with parameters
    P_DateFrom : datum,
    P_DateTo   : datum,
    P_Asset    : oiu_dn_no

  as select from ZPRA_C_DPR_CUBE

{
  key ProductionDate,
  key CalendarYear,
  key CalendarMonth,
  key Product,
  key Asset,
  key Block,

      ProductDescription,
      cast( AssetDescription as abap.char( 100 ) ) as AssetDescription,

      ProdQty1,
      ProdUom1,
      OvlShareQty1,
      ProdQty2,
      ProdUom2,
      OvlShareQty2
}
where ProductionDate >= $parameters.P_DateFrom
  and ProductionDate <= $parameters.P_DateTo
  and ( $parameters.P_Asset = '' or Asset = $parameters.P_Asset )
