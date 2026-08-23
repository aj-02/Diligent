@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Targets with Product Group (helper)'
@Metadata.ignorePropagatedAnnotations: true

/* Helper added for this release: CASE is not allowed in GROUP BY, so the
   oil/gas product-group classification is exposed here as a plain column
   that ZPRA_P_DPR_PERF_AGG can GROUP BY. */
define view entity ZPRA_P_DPR_TAR_GRP
  as select from zpra_t_prd_tar as Tar
{
  key Tar.gjahr                                       as Gjahr,
  key Tar.monat                                       as Monat,
  key Tar.asset                                       as Asset,
  key Tar.block                                       as Block,
  key Tar.product                                     as Product,
  key Tar.prod_vl_type_cd                             as ProdVlTypeCd,
  key Tar.tar_code                                    as TarCode,

      case Tar.product
        when '722000004' then 'GAS'
        else                  'OIL'
      end                                             as ProductGroup,

      cast( Tar.tar_qty as abap.dec( 23, 7 ) )        as TarQty
}
