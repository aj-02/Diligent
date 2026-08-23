@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Daily Production - Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #L,
  dataClass:      #TRANSACTIONAL
}

define view entity ZPRA_I_DPR_DAILY
  as select from zpra_t_dly_prd as DlyPrd

  association [0..1] to zoiu_pr_dn as _AssetText
    on $projection.Asset = _AssetText.dn_no

  association [0..*] to zpra_t_prd_pi as _PrdPI
    on  $projection.Asset >= _PrdPI.asset
    and $projection.Block >= _PrdPI.block

{
  key DlyPrd.production_date              as ProductionDate,
  key DlyPrd.product                      as Product,
  key DlyPrd.asset                        as Asset,
  key DlyPrd.block                        as Block,
  key DlyPrd.prd_vl_type                  as VolumeType,

      cast( DlyPrd.prod_vl_qty1 as abap.dec( 23, 3 ) ) as ProdQty1,
      DlyPrd.prod_vl_uom1                 as ProdUom1,

      cast( DlyPrd.prod_vl_qty2 as abap.dec( 23, 3 ) ) as ProdQty2,
      DlyPrd.prod_vl_uom2                 as ProdUom2,

      /* year()/month() unavailable on this release -> derive from YYYYMMDD text */
      cast( substring( DlyPrd.production_date, 1, 4 ) as abap.numc( 4 ) ) as CalendarYear,
      cast( substring( DlyPrd.production_date, 5, 2 ) as abap.numc( 2 ) ) as CalendarMonth,

      case DlyPrd.product
        when '722000001' then 'Oil'
        when '722000003' then 'Condensate'
        when '722000004' then 'Gas'
        when '722000005' then 'LNG'
        else                  'Other'
      end                                 as ProductDescription,

      case DlyPrd.prd_vl_type
        when 'NET_PROD'   then 'Net Production'
        when 'GROSS_PROD' then 'Gross Production'
        when 'GAS_INJ'    then 'Gas Injection'
        else DlyPrd.prd_vl_type
      end                                 as VolumeTypeDescription,

      _AssetText,
      _PrdPI
}
