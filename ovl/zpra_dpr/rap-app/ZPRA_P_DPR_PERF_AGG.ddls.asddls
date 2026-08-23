@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Production Performance - aggregation layer'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZPRA_P_DPR_PERF_AGG
  with parameters
    P_DateFrom   : abap.dats,
    P_DateTo     : abap.dats,
    P_FiscalYear : gjahr

  as select from ZPRA_C_DPR_BOEPD_DAY

{
  key cast( 'YTD' as abap.char( 6 ) )                 as ScopeType,
  key ProductGroup                                    as ProductGroup,

      cast( sum( ActualQtyOvl )   as abap.dec( 23, 7 ) ) as SumActualQty,
      cast( sum( ActualBoepdOvl ) as abap.dec( 23, 3 ) ) as SumActualBoepd,
      cast( sum( TargetQty )      as abap.dec( 23, 7 ) ) as SumTargetQty,
      cast( sum( TargetBoepd )    as abap.dec( 23, 3 ) ) as SumTargetBoepd,

      cast( count( distinct ProductionDate ) as abap.dec( 10, 0 ) ) as Divisor
}
where ProductionDate >= $parameters.P_DateFrom
  and ProductionDate <= $parameters.P_DateTo
group by ProductGroup

union all

  select from ZPRA_P_DPR_TAR_GRP as Tar
{
  key cast( 'ANNUAL' as abap.char( 6 ) )              as ScopeType,
  key Tar.ProductGroup                                as ProductGroup,

      cast( 0 as abap.dec( 23, 7 ) )                  as SumActualQty,
      cast( 0 as abap.dec( 23, 3 ) )                  as SumActualBoepd,

      cast( sum( Tar.TarQty ) as abap.dec( 23, 7 ) )  as SumTargetQty,

      cast( sum( case Tar.ProductGroup
                   when 'GAS' then Tar.TarQty * cast( 6290 as abap.dec( 5, 0 ) )
                   else            Tar.TarQty
                 end ) as abap.dec( 23, 3 ) )         as SumTargetBoepd,

      cast( count( distinct Tar.Monat ) as abap.dec( 10, 0 ) ) as Divisor
}
where Tar.Gjahr        = $parameters.P_FiscalYear
  and Tar.TarCode      = 'TAR_BE'
  and Tar.ProdVlTypeCd = 'NET_PROD'
group by Tar.ProductGroup
