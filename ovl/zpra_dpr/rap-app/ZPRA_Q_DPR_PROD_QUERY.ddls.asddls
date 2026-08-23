@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Production Query - By Product & Asset'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@OData.entityType.name: 'DPRProductionQueryType'

/* Converted from an analytical query (@Analytics.query) to a plain keyed view:
   @Analytics.query is not exposable via an OData V4 - UI service binding on
   this release. */
define view entity ZPRA_Q_DPR_PROD_QUERY
  with parameters
    P_DateFrom : datum,
    P_DateTo   : datum

  as select from ZPRA_C_DPR_CUBE

{
  key ProductionDate,
  key CalendarYear,
  key CalendarMonth,
  key Product,
  key Asset,
  key Block,
  key VolumeType,

      ProductDescription,
      cast( AssetDescription as abap.char( 100 ) ) as AssetDescription,
      VolumeTypeDescription,

      ProdQty1,
      ProdUom1,
      ProdQty2,
      ProdUom2,
      OvlShareQty1,
      OvlShareQty2,
      ParticipatingInterest
}
where ProductionDate >= $parameters.P_DateFrom
  and ProductionDate <= $parameters.P_DateTo
