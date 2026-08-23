@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Production - Analytical Cube'
@Metadata.ignorePropagatedAnnotations: true

@Analytics.dataCategory: #CUBE
@Analytics.internalName: #LOCAL

@OData.entityType.name: 'DPRProductionCubeType'

define view entity ZPRA_C_DPR_CUBE
  as select from ZPRA_I_DPR_DAILY as Daily

  left outer join zoiu_pr_dn as AssetTxt
    on Daily.Asset = AssetTxt.dn_no

  left outer join zpra_t_prd_pi as PI
    on  Daily.Asset           = PI.asset
    and Daily.Block           = PI.block
    and Daily.ProductionDate >= PI.vld_frm
    and Daily.ProductionDate <= PI.vld_to

{
  /* Keys first, contiguous */
  @AnalyticsDetails.query.axis: #FREE
  @EndUserText.label: 'Production Date'
  key Daily.ProductionDate                        as ProductionDate,

  @AnalyticsDetails.query.axis: #FREE
  @EndUserText.label: 'Calendar Year'
  key Daily.CalendarYear                          as CalendarYear,

  @AnalyticsDetails.query.axis: #FREE
  @EndUserText.label: 'Calendar Month'
  key Daily.CalendarMonth                         as CalendarMonth,

  @AnalyticsDetails.query.axis: #ROWS
  @EndUserText.label: 'Product Code'
  @ObjectModel.text.element: ['ProductDescription']
  key Daily.Product                               as Product,

  @AnalyticsDetails.query.axis: #ROWS
  @EndUserText.label: 'Asset'
  @ObjectModel.text.element: ['AssetDescription']
  key Daily.Asset                                 as Asset,

  @AnalyticsDetails.query.axis: #FREE
  @EndUserText.label: 'Block'
  key Daily.Block                                 as Block,

  @AnalyticsDetails.query.axis: #FREE
  @EndUserText.label: 'Volume Type'
  @ObjectModel.text.element: ['VolumeTypeDescription']
  key Daily.VolumeType                            as VolumeType,

  /* Non-key: texts */
  @EndUserText.label: 'Product'
  Daily.ProductDescription                        as ProductDescription,

  @EndUserText.label: 'Asset Description'
  AssetTxt.dn_de                                  as AssetDescription,

  @EndUserText.label: 'Volume Type Description'
  Daily.VolumeTypeDescription                     as VolumeTypeDescription,

  /* Measures */
  @EndUserText.label: 'Production Qty (Primary UoM)'
  @Aggregation.default: #SUM
  Daily.ProdQty1                                  as ProdQty1,

  @EndUserText.label: 'Primary UoM'
  Daily.ProdUom1                                  as ProdUom1,

  @EndUserText.label: 'Production Qty (Secondary UoM)'
  @Aggregation.default: #SUM
  Daily.ProdQty2                                  as ProdQty2,

  @EndUserText.label: 'Secondary UoM'
  Daily.ProdUom2                                  as ProdUom2,

  @EndUserText.label: 'Participating Interest %'
  @Aggregation.default: #NOP
  PI.pi                                           as ParticipatingInterest,

  @EndUserText.label: 'OVL Share Qty (Primary UoM)'
  @Aggregation.default: #SUM
  cast( Daily.ProdQty1 * PI.pi / cast( 100 as abap.dec( 5, 2 ) )
        as abap.dec( 23, 3 ) )                    as OvlShareQty1,

  @EndUserText.label: 'OVL Share Qty (Secondary UoM)'
  @Aggregation.default: #SUM
  cast( Daily.ProdQty2 * PI.pi / cast( 100 as abap.dec( 5, 2 ) )
        as abap.dec( 23, 3 ) )                    as OvlShareQty2,

  @EndUserText.label: 'Gas (MMSCMD)'
  @Aggregation.default: #SUM
  cast(
    case Daily.Product
      when '722000004' then
        case Daily.ProdUom1
          when 'MCF' then Daily.ProdQty1 / cast( '35.3' as abap.dec( 4, 1 ) )
          when 'M3'  then Daily.ProdQty1 / cast( 1000000 as abap.dec( 10, 0 ) )
          else            Daily.ProdQty1
        end
      else cast( 0 as abap.dec( 23, 7 ) )
    end as abap.dec( 23, 7 )
  )                                               as GasMmscmd,

  @EndUserText.label: 'Total O+OEG (BOEPD)'
  @Aggregation.default: #SUM
  cast(
    case Daily.Product
      when '722000004' then
        ( case Daily.ProdUom1
            when 'MCF' then Daily.ProdQty1 / cast( '35.3' as abap.dec( 4, 1 ) )
            when 'M3'  then Daily.ProdQty1 / cast( 1000000 as abap.dec( 10, 0 ) )
            else            Daily.ProdQty1
          end ) * cast( 6290 as abap.dec( 5, 0 ) )
      else Daily.ProdQty1
    end as abap.dec( 23, 3 )
  )                                               as BoepdQty
}
where Daily.VolumeType = 'NET_PROD'
