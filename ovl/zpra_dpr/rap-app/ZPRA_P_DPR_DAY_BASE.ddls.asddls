@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Day Base - unit-normalized daily production'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #L,
  dataClass:      #TRANSACTIONAL
}

define view entity ZPRA_P_DPR_DAY_BASE
  as select from zpra_t_dly_prd as D

  left outer join zpra_t_prd_pi as PI
    on  D.asset            = PI.asset
    and D.block            = PI.block
    and D.production_date >= PI.vld_frm
    and D.production_date <= PI.vld_to

{
  key D.production_date                               as ProductionDate,
  key D.asset                                         as Asset,
  key D.block                                         as Block,
  key D.product                                       as Product,

      /* Oil-family vs Gas */
      case D.product
        when '722000004' then 'GAS'
        else                  'OIL'
      end                                             as ProductGroup,

      /* Fiscal YEAR (NUMC4), FY = April..March. Year of the date shifted back
         3 months = fiscal year. NUMC to match gjahr in the target join;
         year()/month() and INT->NUMC casts are unavailable on this release. */
      cast( substring( dats_add_months( D.production_date, -3, 'INITIAL' ), 1, 4 )
            as abap.numc( 4 ) )                       as FiscalYear,

      /* Fiscal PERIOD (NUMC2): calendar month mapped to fiscal month (Apr=01..Mar=12). */
      cast(
        case substring( D.production_date, 5, 2 )
          when '04' then '01'
          when '05' then '02'
          when '06' then '03'
          when '07' then '04'
          when '08' then '05'
          when '09' then '06'
          when '10' then '07'
          when '11' then '08'
          when '12' then '09'
          when '01' then '10'
          when '02' then '11'
          when '03' then '12'
          else           '00'
        end as abap.numc( 2 ) )                       as FiscalPeriod,

      /* Native daily figure: BOPD (oil family) / MMSCMD (gas) */
      cast(
        case D.product
          when '722000004' then
            case D.prod_vl_uom1
              when 'MCF' then D.prod_vl_qty1 / cast( '35.3' as abap.dec( 4, 1 ) )
              when 'M3'  then D.prod_vl_qty1 / cast( 1000000 as abap.dec( 10, 0 ) )
              else            D.prod_vl_qty1
            end
          else D.prod_vl_qty1
        end as abap.dec( 23, 7 )
      )                                               as QtyNative,

      /* BOE factor: gas MMSCMD -> BOEPD */
      cast(
        case D.product
          when '722000004' then 6290
          else                  1
        end as abap.dec( 5, 0 )
      )                                               as BoeFactor,

      /* PI share % (0 when no PI row) */
      cast( coalesce( PI.pi, cast( 0 as abap.dec( 5, 2 ) ) )
            as abap.dec( 5, 2 ) )                     as PiPct
}
where D.prd_vl_type = 'NET_PROD'
