@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Target vs Actual Query'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@OData.entityType.name: 'DPRTargetQueryType'

define view entity ZPRA_Q_DPR_TARGET_QUERY
  with parameters
    P_FiscalYear : gjahr,
    P_TargetCode : ztar_code

  as select from ZPRA_I_DPR_MONTHLY as Actual

  left outer join ZPRA_I_DPR_TARGET as Target
    on  Actual.FiscalYear   = Target.FiscalYear
    and Actual.FiscalPeriod = Target.FiscalPeriod
    and Actual.Asset        = Target.Asset
    and Actual.Block        = Target.Block
    and Actual.Product      = Target.Product
    and Actual.VolumeType   = Target.VolumeType
    and Target.TargetCode   = $parameters.P_TargetCode

{
  key Actual.FiscalYear                           as FiscalYear,
  key Actual.FiscalPeriod                         as FiscalPeriod,

  @ObjectModel.text.element: ['ProductDescription']
  key Actual.Product                              as Product,

  @ObjectModel.text.element: ['AssetDescription']
  key Actual.Asset                                as Asset,

  key Actual.Block                                as Block,
  key Actual.VolumeType                           as VolumeType,

      Actual.ProductDescription                   as ProductDescription,
      cast( Actual._AssetText.dn_de as abap.char( 100 ) ) as AssetDescription,
      Actual.VolumeTypeDescription                as VolumeTypeDescription,

      Target.TargetCode                           as TargetCode,
      Target.TargetTypeDescription                as TargetTypeDescription,

      Actual.ProdQty1                             as ActualQty,
      Actual.ProdUom1                             as ActualUom,

      Target.TargetQty                            as TargetQty,
      Target.TargetUom                            as TargetUom,

      cast( Actual.ProdQty1 - Target.TargetQty
            as abap.dec( 23, 3 ) )                as VarianceQty,

      cast(
        case
          when Target.TargetQty <> 0
          then Actual.ProdQty1 * cast( 100 as abap.dec( 5, 2 ) ) / Target.TargetQty
          else cast( 0 as abap.dec( 5, 2 ) )
        end as abap.dec( 7, 2 )
      )                                           as AchievementPct
}
where Actual.FiscalYear = $parameters.P_FiscalYear
