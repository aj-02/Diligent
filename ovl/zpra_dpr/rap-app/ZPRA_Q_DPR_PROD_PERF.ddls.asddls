@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Production Performance (Excel tab 3)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@OData.entityType.name: 'DPRProdPerfQueryType'

define view entity ZPRA_Q_DPR_PROD_PERF
  with parameters
    P_DateFrom   : datum,
    P_DateTo     : datum,
    P_FiscalYear : gjahr

  as select from ZPRA_P_DPR_PERF_AGG(
                   P_DateFrom   : $parameters.P_DateFrom,
                   P_DateTo     : $parameters.P_DateTo,
                   P_FiscalYear : $parameters.P_FiscalYear )

{
  key ScopeType,
  key ProductGroup,

      @EndUserText.label: 'Scope'
      case ScopeType
        when 'YTD'    then 'YTD'
        when 'ANNUAL' then 'Annual'
        else               ScopeType
      end                                             as ScopeText,

      @EndUserText.label: 'Product Group'
      case ProductGroup
        when 'GAS' then 'Gas ( MMSCMD )'
        else            'Oil, LNG & Condensate ( BOPD )'
      end                                             as ProductGroupText,

      @EndUserText.label: 'Actual (BOPD / MMSCMD)'
      cast( case when Divisor > 0
                 then SumActualQty / Divisor
                 else cast( 0 as abap.dec( 23, 7 ) )
            end as abap.dec( 23, 7 ) )                as ActualPerDay,

      @EndUserText.label: 'Actual Total (BOEPD)'
      cast( case when Divisor > 0
                 then SumActualBoepd / Divisor
                 else cast( 0 as abap.dec( 23, 3 ) )
            end as abap.dec( 23, 3 ) )                as ActualBoepdPerDay,

      @EndUserText.label: 'BE Target (BOPD / MMSCMD)'
      cast( case when Divisor > 0
                 then SumTargetQty / Divisor
                 else cast( 0 as abap.dec( 23, 7 ) )
            end as abap.dec( 23, 7 ) )                as TargetPerDay,

      @EndUserText.label: 'BE Target Total (BOEPD)'
      cast( case when Divisor > 0
                 then SumTargetBoepd / Divisor
                 else cast( 0 as abap.dec( 23, 3 ) )
            end as abap.dec( 23, 3 ) )                as TargetBoepdPerDay,

      @EndUserText.label: '% Achv w.r.t. BE Target'
      cast( case when ScopeType = 'YTD' and SumTargetBoepd > 0
                 then SumActualBoepd * cast( 100 as abap.dec( 4, 0 ) )
                      / SumTargetBoepd
                 else cast( 0 as abap.dec( 10, 2 ) )
            end as abap.dec( 10, 2 ) )                as AchievementPct,

      @EndUserText.label: 'Achievement Criticality'
      cast( case
              when ScopeType <> 'YTD' or SumTargetBoepd <= 0        then 0
              when SumActualBoepd >= SumTargetBoepd                 then 3
              when SumActualBoepd * cast( 100 as abap.dec( 4, 0 ) )
                   >= SumTargetBoepd * cast( 90 as abap.dec( 4, 0 ) ) then 2
              else 1
            end as abap.int1 )                        as AchievementCriticality
}
