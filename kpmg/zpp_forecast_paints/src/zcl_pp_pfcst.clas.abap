CLASS zcl_pp_pfcst DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

*&---------------------------------------------------------------------*
*& Class       : ZCL_PP_PFCST
*& Title       : ZFORECAST Paints - forecast calculation engine
*& Package     : ZPP_PNT_FCST
*& Author      : Arnav
*& Date        : 31.08.2026
*& Reference   : CR-2C, Forecast Template-Paints.xlsx
*&---------------------------------------------------------------------*
*& Purpose
*&   Single calculation engine for ZFORECAST Paints. Shared by
*&   ZPP_PAINT_FORECAST, ZPP_PAINT_FCST_UPL and ZPP_PAINT_FCST_RPT so
*&   the three programs cannot drift apart.
*&
*& Sources
*&   Sales history   VBRK / VBRP        sum VBRP-FKIMG
*&   Old codes       MATDOC             sum MATDOC-MENGE, BWART from config
*&   Legacy flag     ZPPT_PNT_SHIST     M01 to M12
*&   Category        ZPPT_PNT_PCAT      product category and load factor
*&   Exclusions      ZPPT_PNT_MEXC      dropped before calculation
*&   Configuration   ZPPT_PNT_CFG       VKORG, BWART, legacy TVARVC name
*&
*& All fiscal year, quarter, period, tonnage, volume and value
*& arithmetic lives in ZCL_PP_PFCST_UTIL and is never repeated here.
*& Screen free by design - everything is displayed by the calling
*& report through CL_SALV_TABLE.
*&---------------------------------------------------------------------*

  PUBLIC SECTION.

    TYPES ty_r_werks TYPE RANGE OF werks_d.
    TYPES ty_r_matnr TYPE RANGE OF matnr.

    TYPES: BEGIN OF ty_annual,
             werks      TYPE werks_d,
             name1      TYPE t001w-name1,
             brand      TYPE zde_pnt_brand,
             matnr      TYPE matnr,
             maktx      TYPE maktx,
             mts_mto    TYPE zde_pnt_mts_mto,
             mvgr1      TYPE mvgr1,
             mvgr1_txt  TYPE tvm1t-bezei,
             mvgr3      TYPE mvgr3,
             mvgr3_txt  TYPE tvm3t-bezei,
             mvgr4      TYPE mvgr4,
             mvgr4_txt  TYPE tvm4t-bezei,
             matkl      TYPE matkl,
             pack_sz    TYPE zde_pnt_pack_sz,
             dpl        TYPE zde_pnt_dpl,
             qty_ctn    TYPE zde_pnt_qty_ctn,
             meins      TYPE meins,
             gewei      TYPE gewei,
             brgew      TYPE brgew,
             m01        TYPE zde_pnt_fcst_qty,
             m02        TYPE zde_pnt_fcst_qty,
             m03        TYPE zde_pnt_fcst_qty,
             m04        TYPE zde_pnt_fcst_qty,
             m05        TYPE zde_pnt_fcst_qty,
             m06        TYPE zde_pnt_fcst_qty,
             m07        TYPE zde_pnt_fcst_qty,
             m08        TYPE zde_pnt_fcst_qty,
             m09        TYPE zde_pnt_fcst_qty,
             m10        TYPE zde_pnt_fcst_qty,
             m11        TYPE zde_pnt_fcst_qty,
             m12        TYPE zde_pnt_fcst_qty,
             ly_total   TYPE zde_pnt_fcst_qty,
             prod_cat   TYPE zde_pnt_prod_cat,
             load_fct   TYPE zde_pnt_load_fct,
             fcst_total TYPE zde_pnt_fcst_qty,
             m01_fcst   TYPE zde_pnt_fcst_qty,
             m02_fcst   TYPE zde_pnt_fcst_qty,
             m03_fcst   TYPE zde_pnt_fcst_qty,
             m04_fcst   TYPE zde_pnt_fcst_qty,
             m05_fcst   TYPE zde_pnt_fcst_qty,
             m06_fcst   TYPE zde_pnt_fcst_qty,
             m07_fcst   TYPE zde_pnt_fcst_qty,
             m08_fcst   TYPE zde_pnt_fcst_qty,
             m09_fcst   TYPE zde_pnt_fcst_qty,
             m10_fcst   TYPE zde_pnt_fcst_qty,
             m11_fcst   TYPE zde_pnt_fcst_qty,
             m12_fcst   TYPE zde_pnt_fcst_qty,
             m01_ton    TYPE zde_pnt_fcst_qty,
             m02_ton    TYPE zde_pnt_fcst_qty,
             m03_ton    TYPE zde_pnt_fcst_qty,
             m04_ton    TYPE zde_pnt_fcst_qty,
             m05_ton    TYPE zde_pnt_fcst_qty,
             m06_ton    TYPE zde_pnt_fcst_qty,
             m07_ton    TYPE zde_pnt_fcst_qty,
             m08_ton    TYPE zde_pnt_fcst_qty,
             m09_ton    TYPE zde_pnt_fcst_qty,
             m10_ton    TYPE zde_pnt_fcst_qty,
             m11_ton    TYPE zde_pnt_fcst_qty,
             m12_ton    TYPE zde_pnt_fcst_qty,
             m01_kl     TYPE zde_pnt_vol_kl,
             m02_kl     TYPE zde_pnt_vol_kl,
             m03_kl     TYPE zde_pnt_vol_kl,
             m04_kl     TYPE zde_pnt_vol_kl,
             m05_kl     TYPE zde_pnt_vol_kl,
             m06_kl     TYPE zde_pnt_vol_kl,
             m07_kl     TYPE zde_pnt_vol_kl,
             m08_kl     TYPE zde_pnt_vol_kl,
             m09_kl     TYPE zde_pnt_vol_kl,
             m10_kl     TYPE zde_pnt_vol_kl,
             m11_kl     TYPE zde_pnt_vol_kl,
             m12_kl     TYPE zde_pnt_vol_kl,
             m01_cr     TYPE zde_pnt_val_cr,
             m02_cr     TYPE zde_pnt_val_cr,
             m03_cr     TYPE zde_pnt_val_cr,
             m04_cr     TYPE zde_pnt_val_cr,
             m05_cr     TYPE zde_pnt_val_cr,
             m06_cr     TYPE zde_pnt_val_cr,
             m07_cr     TYPE zde_pnt_val_cr,
             m08_cr     TYPE zde_pnt_val_cr,
             m09_cr     TYPE zde_pnt_val_cr,
             m10_cr     TYPE zde_pnt_val_cr,
             m11_cr     TYPE zde_pnt_val_cr,
             m12_cr     TYPE zde_pnt_val_cr,
             fcst_no    TYPE zde_pnt_fcst_no,
           END OF ty_annual.

    TYPES tt_annual TYPE STANDARD TABLE OF ty_annual WITH EMPTY KEY.

    TYPES: BEGIN OF ty_quarter,
             werks        TYPE werks_d,
             name1        TYPE t001w-name1,
             brand        TYPE zde_pnt_brand,
             matnr        TYPE matnr,
             maktx        TYPE maktx,
             mts_mto      TYPE zde_pnt_mts_mto,
             mvgr1        TYPE mvgr1,
             mvgr1_txt    TYPE tvm1t-bezei,
             mvgr2        TYPE mvgr2,
             mvgr2_txt    TYPE tvm2t-bezei,
             mvgr3        TYPE mvgr3,
             mvgr3_txt    TYPE tvm3t-bezei,
             mvgr4        TYPE mvgr4,
             mvgr4_txt    TYPE tvm4t-bezei,
             mvgr5        TYPE mvgr5,
             mvgr5_txt    TYPE tvm5t-bezei,
             matkl        TYPE matkl,
             pack_sz      TYPE zde_pnt_pack_sz,
             dpl          TYPE zde_pnt_dpl,
             qty_ctn      TYPE zde_pnt_qty_ctn,
             meins        TYPE meins,
             gewei        TYPE gewei,
             brgew        TYPE brgew,
             ntgew        TYPE ntgew,
             m4_last      TYPE zde_pnt_fcst_qty,
             m5_last      TYPE zde_pnt_fcst_qty,
             m6_last      TYPE zde_pnt_fcst_qty,
             ly_qtr_tot   TYPE zde_pnt_fcst_qty,
             m1_curr      TYPE zde_pnt_fcst_qty,
             m2_curr      TYPE zde_pnt_fcst_qty,
             m3_curr      TYPE zde_pnt_fcst_qty,
             l3m_tot      TYPE zde_pnt_fcst_qty,
             max_qty      TYPE zde_pnt_fcst_qty,
             prod_cat     TYPE zde_pnt_prod_cat,
             load_fct     TYPE zde_pnt_load_fct,
             fcst_qty     TYPE zde_pnt_fcst_qty,
             bus_fcst     TYPE zde_pnt_fcst_qty,
             bus_fcst_add TYPE zde_pnt_fcst_qty,
             final_qty    TYPE zde_pnt_fcst_qty,
             m4_fcst      TYPE zde_pnt_fcst_qty,
             m5_fcst      TYPE zde_pnt_fcst_qty,
             m6_fcst      TYPE zde_pnt_fcst_qty,
             m4_ton       TYPE zde_pnt_fcst_qty,
             m5_ton       TYPE zde_pnt_fcst_qty,
             m6_ton       TYPE zde_pnt_fcst_qty,
             m4_kl        TYPE zde_pnt_vol_kl,
             m5_kl        TYPE zde_pnt_vol_kl,
             m6_kl        TYPE zde_pnt_vol_kl,
             m4_cr        TYPE zde_pnt_val_cr,
             m5_cr        TYPE zde_pnt_val_cr,
             m6_cr        TYPE zde_pnt_val_cr,
             gjahr        TYPE gjahr,
             quarter      TYPE zde_pnt_quarter,
             fcst_no      TYPE zde_pnt_fcst_no,
             reason       TYPE zde_pnt_reason,
           END OF ty_quarter.

    TYPES tt_quarter TYPE STANDARD TABLE OF ty_quarter WITH EMPTY KEY.

    TYPES: BEGIN OF ty_month,
             werks        TYPE werks_d,
             name1        TYPE t001w-name1,
             brand        TYPE zde_pnt_brand,
             matnr        TYPE matnr,
             maktx        TYPE maktx,
             mts_mto      TYPE zde_pnt_mts_mto,
             mvgr1        TYPE mvgr1,
             mvgr1_txt    TYPE tvm1t-bezei,
             mvgr2        TYPE mvgr2,
             mvgr2_txt    TYPE tvm2t-bezei,
             mvgr3        TYPE mvgr3,
             mvgr3_txt    TYPE tvm3t-bezei,
             mvgr4        TYPE mvgr4,
             mvgr4_txt    TYPE tvm4t-bezei,
             mvgr5        TYPE mvgr5,
             mvgr5_txt    TYPE tvm5t-bezei,
             matkl        TYPE matkl,
             pack_sz      TYPE zde_pnt_pack_sz,
             dpl          TYPE zde_pnt_dpl,
             qty_ctn      TYPE zde_pnt_qty_ctn,
             meins        TYPE meins,
             gewei        TYPE gewei,
             brgew        TYPE brgew,
             ntgew        TYPE ntgew,
             m4_last      TYPE zde_pnt_fcst_qty,
             m5_last      TYPE zde_pnt_fcst_qty,
             m6_last      TYPE zde_pnt_fcst_qty,
             ly_qtr_tot   TYPE zde_pnt_fcst_qty,
             m1_curr      TYPE zde_pnt_fcst_qty,
             m2_curr      TYPE zde_pnt_fcst_qty,
             m3_curr      TYPE zde_pnt_fcst_qty,
             l3m_avg      TYPE zde_pnt_fcst_qty,
             max_qty      TYPE zde_pnt_fcst_qty,
             prod_cat     TYPE zde_pnt_prod_cat,
             load_fct     TYPE zde_pnt_load_fct,
             fcst_qty     TYPE zde_pnt_fcst_qty,
             bus_fcst     TYPE zde_pnt_fcst_qty,
             bus_fcst_add TYPE zde_pnt_fcst_qty,
             final_qty    TYPE zde_pnt_fcst_qty,
             m4_fcst      TYPE zde_pnt_fcst_qty,
             m4_ton       TYPE zde_pnt_fcst_qty,
             m4_kl        TYPE zde_pnt_vol_kl,
             m4_cr        TYPE zde_pnt_val_cr,
             gjahr        TYPE gjahr,
             period       TYPE poper,
             fcst_no      TYPE zde_pnt_fcst_no,
             reason       TYPE zde_pnt_reason,
           END OF ty_month.

    TYPES tt_month TYPE STANDARD TABLE OF ty_month WITH EMPTY KEY.

    "! Annual forecast - twelve months of last year, split forward.
    METHODS generate_annual
      IMPORTING it_werks         TYPE ty_r_werks
                it_matnr         TYPE ty_r_matnr
                iv_fyear         TYPE zde_pnt_fyear
                iv_legacy        TYPE abap_bool DEFAULT abap_false
                iv_tonnage       TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_data)   TYPE tt_annual.

    "! Quarterly forecast - last year quarter against the last three months.
    METHODS generate_quarter
      IMPORTING it_werks         TYPE ty_r_werks
                it_matnr         TYPE ty_r_matnr
                iv_fyear         TYPE zde_pnt_fyear
                iv_quarter       TYPE zde_pnt_quarter OPTIONAL
                iv_date_from     TYPE dats OPTIONAL
                iv_date_to       TYPE dats OPTIONAL
                iv_legacy        TYPE abap_bool DEFAULT abap_false
                iv_tonnage       TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_data)   TYPE tt_quarter.

    "! Monthly forecast - one period only.
    METHODS generate_month
      IMPORTING it_werks         TYPE ty_r_werks
                it_matnr         TYPE ty_r_matnr
                iv_fyear         TYPE zde_pnt_fyear
                iv_period        TYPE poper OPTIONAL
                iv_date_from     TYPE dats OPTIONAL
                iv_date_to       TYPE dats OPTIONAL
                iv_legacy        TYPE abap_bool DEFAULT abap_false
                iv_tonnage       TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_data)   TYPE tt_month.

    "! Writes ZPPT_PNT_FYR. The forecast number is reused where one exists.
    METHODS save_annual
      IMPORTING it_data           TYPE tt_annual
                iv_fyear          TYPE zde_pnt_fyear
      RETURNING VALUE(rv_fcst_no) TYPE zde_pnt_fcst_no.

    "! Writes ZPPT_PNT_FQT. The forecast number is reused where one exists.
    METHODS save_quarter
      IMPORTING it_data           TYPE tt_quarter
      RETURNING VALUE(rv_fcst_no) TYPE zde_pnt_fcst_no.

    "! Writes ZPPT_PNT_FMN. The forecast number is reused where one exists.
    METHODS save_month
      IMPORTING it_data           TYPE tt_month
      RETURNING VALUE(rv_fcst_no) TYPE zde_pnt_fcst_no.

  PRIVATE SECTION.

    CONSTANTS: gc_actvt_disp TYPE activ_auth VALUE '03',
               gc_actvt_save TYPE activ_auth VALUE '01'.

*   Own numeric helper types, so that the class does not depend on a
*   standard NUMC data element of a given length existing.
    TYPES ty_yrmon TYPE n LENGTH 6.
    TYPES ty_mm    TYPE n LENGTH 2.

    TYPES: BEGIN OF ty_hist,
             werks TYPE werks_d,
             matnr TYPE matnr,
             yrmon TYPE ty_yrmon,
             qty   TYPE zde_pnt_fcst_qty,
           END OF ty_hist,
           tt_hist TYPE SORTED TABLE OF ty_hist
                     WITH UNIQUE KEY werks matnr yrmon.

    TYPES: BEGIN OF ty_scope,
             werks TYPE werks_d,
             matnr TYPE matnr,
           END OF ty_scope,
           tt_scope TYPE STANDARD TABLE OF ty_scope WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_plant,
             werks TYPE werks_d,
             name1 TYPE t001w-name1,
             vkorg TYPE vkorg,
             bwart TYPE bwart,
             tvarv TYPE rvari_vnam,
           END OF ty_plant,
           tt_plant TYPE SORTED TABLE OF ty_plant WITH UNIQUE KEY werks.

    TYPES: BEGIN OF ty_mat,
             matnr   TYPE matnr,
             maktx   TYPE maktx,
             matkl   TYPE matkl,
             meins   TYPE meins,
             gewei   TYPE gewei,
             brgew   TYPE brgew,
             ntgew   TYPE ntgew,
             pack_sz TYPE zde_pnt_pack_sz,
             qty_ctn TYPE zde_pnt_qty_ctn,
           END OF ty_mat,
           tt_mat TYPE SORTED TABLE OF ty_mat WITH UNIQUE KEY matnr.

    TYPES: BEGIN OF ty_mvgr,
             vkorg     TYPE vkorg,
             matnr     TYPE matnr,
             mvgr1     TYPE mvgr1,
             mvgr2     TYPE mvgr2,
             mvgr3     TYPE mvgr3,
             mvgr4     TYPE mvgr4,
             mvgr5     TYPE mvgr5,
             mvgr1_txt TYPE tvm1t-bezei,
             mvgr2_txt TYPE tvm2t-bezei,
             mvgr3_txt TYPE tvm3t-bezei,
             mvgr4_txt TYPE tvm4t-bezei,
             mvgr5_txt TYPE tvm5t-bezei,
             qty_ctn   TYPE zde_pnt_qty_ctn,
           END OF ty_mvgr,
           tt_mvgr TYPE SORTED TABLE OF ty_mvgr WITH UNIQUE KEY vkorg matnr.

    TYPES: BEGIN OF ty_cat,
             werks    TYPE werks_d,
             matnr    TYPE matnr,
             prod_cat TYPE zde_pnt_prod_cat,
             load_fct TYPE zde_pnt_load_fct,
             mts_mto  TYPE zde_pnt_mts_mto,
           END OF ty_cat,
           tt_cat TYPE SORTED TABLE OF ty_cat
                    WITH NON-UNIQUE KEY werks matnr.

    TYPES: BEGIN OF ty_old,
             werks     TYPE werks_d,
             matnr     TYPE matnr,
             new_matnr TYPE matnr,
             bwart     TYPE bwart,
           END OF ty_old,
           tt_old TYPE SORTED TABLE OF ty_old
                    WITH NON-UNIQUE KEY werks matnr.

    TYPES: BEGIN OF ty_bus,
             werks        TYPE werks_d,
             matnr        TYPE matnr,
             fcst_no      TYPE zde_pnt_fcst_no,
             bus_fcst     TYPE zde_pnt_fcst_qty,
             bus_fcst_add TYPE zde_pnt_fcst_qty,
             reason       TYPE zde_pnt_reason,
           END OF ty_bus,
           tt_bus TYPE SORTED TABLE OF ty_bus
                    WITH NON-UNIQUE KEY werks matnr.

    TYPES: BEGIN OF ty_common,
             werks     TYPE werks_d,
             name1     TYPE t001w-name1,
             brand     TYPE zde_pnt_brand,
             matnr     TYPE matnr,
             maktx     TYPE maktx,
             mts_mto   TYPE zde_pnt_mts_mto,
             mvgr1     TYPE mvgr1,
             mvgr1_txt TYPE tvm1t-bezei,
             mvgr2     TYPE mvgr2,
             mvgr2_txt TYPE tvm2t-bezei,
             mvgr3     TYPE mvgr3,
             mvgr3_txt TYPE tvm3t-bezei,
             mvgr4     TYPE mvgr4,
             mvgr4_txt TYPE tvm4t-bezei,
             mvgr5     TYPE mvgr5,
             mvgr5_txt TYPE tvm5t-bezei,
             matkl     TYPE matkl,
             pack_sz   TYPE zde_pnt_pack_sz,
             dpl       TYPE zde_pnt_dpl,
             qty_ctn   TYPE zde_pnt_qty_ctn,
             meins     TYPE meins,
             gewei     TYPE gewei,
             brgew     TYPE brgew,
             ntgew     TYPE ntgew,
             prod_cat  TYPE zde_pnt_prod_cat,
             load_fct  TYPE zde_pnt_load_fct,
           END OF ty_common.

    DATA: mt_plant TYPE tt_plant,
          mt_hist  TYPE tt_hist,
          mt_mat   TYPE tt_mat,
          mt_mvgr  TYPE tt_mvgr,
          mt_cat   TYPE tt_cat,
          mt_scope TYPE tt_scope,
          mv_nocat TYPE i,
          ms_nocat TYPE ty_scope.

    "! Plant name, configuration and display authorisation, once per run.
    METHODS load_plants
      IMPORTING it_werks TYPE ty_r_werks.

    "! Billing history, old material rollup and legacy history into MT_HIST.
    METHODS load_history
      IMPORTING it_werks  TYPE ty_r_werks
                it_matnr  TYPE ty_r_matnr
                iv_from   TYPE dats
                iv_to     TYPE dats
                iv_legacy TYPE abap_bool.

    METHODS read_billing
      IMPORTING it_werks       TYPE ty_r_werks
                it_matnr       TYPE ty_r_matnr
                iv_from        TYPE dats
                iv_to          TYPE dats
      RETURNING VALUE(rt_hist) TYPE tt_hist.

    METHODS add_old_material
      IMPORTING it_werks TYPE ty_r_werks
                it_matnr TYPE ty_r_matnr
                iv_from  TYPE dats
                iv_to    TYPE dats
      CHANGING  ct_hist  TYPE tt_hist.

    METHODS add_legacy
      IMPORTING it_werks TYPE ty_r_werks
                it_matnr TYPE ty_r_matnr
                iv_from  TYPE dats
                iv_to    TYPE dats
      CHANGING  ct_hist  TYPE tt_hist.

    METHODS check_legacy_auth.

    METHODS build_scope
      IMPORTING it_werks        TYPE ty_r_werks
                it_matnr        TYPE ty_r_matnr
      RETURNING VALUE(rt_scope) TYPE tt_scope.

    "! One prefetch of every master data table the three modes share.
    METHODS load_master.

    METHODS build_common
      IMPORTING iv_werks         TYPE werks_d
                iv_matnr         TYPE matnr
      RETURNING VALUE(rs_common) TYPE ty_common.

    METHODS hist_qty
      IMPORTING iv_werks      TYPE werks_d
                iv_matnr      TYPE matnr
                iv_yrmon      TYPE ty_yrmon
      RETURNING VALUE(rv_qty) TYPE zde_pnt_fcst_qty.

    "! Year and month of a period offset that may fall outside IV_FYEAR.
    METHODS period_yrmon
      IMPORTING iv_fyear        TYPE zde_pnt_fyear
                iv_offset       TYPE i
      RETURNING VALUE(rv_yrmon) TYPE ty_yrmon.

    METHODS fyear_of_gjahr
      IMPORTING iv_gjahr        TYPE gjahr
      RETURNING VALUE(rv_fyear) TYPE zde_pnt_fyear.

    METHODS check_save_auth
      IMPORTING it_data TYPE tt_scope.

    METHODS lock_table
      IMPORTING iv_tabname   TYPE tabname
      RETURNING VALUE(rv_ok) TYPE abap_bool.

    METHODS unlock_table
      IMPORTING iv_tabname TYPE tabname.

ENDCLASS.



CLASS zcl_pp_pfcst IMPLEMENTATION.


*&---------------------------------------------------------------------*
*& Annual - twelve months of the previous financial year, split forward
*&---------------------------------------------------------------------*
  METHOD generate_annual.

    CLEAR: rt_data, mv_nocat, ms_nocat.

    IF it_werks IS INITIAL.
      MESSAGE e001(zpp_pfcst).
    ENDIF.
    IF iv_fyear IS INITIAL.
      MESSAGE e032(zpp_pfcst).
    ENDIF.
    IF zcl_pp_pfcst_util=>is_fyear_valid( iv_fyear ) = abap_false.
      MESSAGE e002(zpp_pfcst) WITH iv_fyear.
    ENDIF.

    load_plants( it_werks ).

*   The twelve sales columns are last year, so the history window is the
*   financial year before the one being forecast.
    DATA(ls_fy)  = zcl_pp_pfcst_util=>get_fyear_range( iv_fyear ).
    DATA(ls_ly)  = zcl_pp_pfcst_util=>shift_range_years( is_range = ls_fy
                                                         iv_years = -1 ).
    DATA(lv_lfy) = zcl_pp_pfcst_util=>get_fyear_from_date( ls_ly-date_from ).

    load_history( it_werks  = it_werks
                  it_matnr  = it_matnr
                  iv_from   = ls_ly-date_from
                  iv_to     = ls_ly-date_to
                  iv_legacy = iv_legacy ).

    mt_scope = build_scope( it_werks = it_werks it_matnr = it_matnr ).
    load_master( ).

*   Year and month of each of the twelve slots, resolved once
    DATA lt_slot TYPE STANDARD TABLE OF ty_yrmon WITH EMPTY KEY.
    DO 12 TIMES.
      APPEND period_yrmon( iv_fyear  = lv_lfy
                           iv_offset = sy-index ) TO lt_slot.
    ENDDO.

*   Forecast numbers already drawn for this year, so the report can show
*   which rows are an overwrite
    IF mt_scope IS NOT INITIAL.
      SELECT werks, matnr, fcst_no
        FROM zppt_pnt_fyr
        FOR ALL ENTRIES IN @mt_scope
        WHERE werks = @mt_scope-werks
          AND matnr = @mt_scope-matnr
          AND fyear = @iv_fyear
        INTO TABLE @DATA(lt_no).
    ENDIF.

    SORT lt_no BY werks matnr.

    LOOP AT mt_scope INTO DATA(ls_scope).

      DATA ls_row TYPE ty_annual.
      CLEAR ls_row.

      DATA(ls_com) = build_common( iv_werks = ls_scope-werks
                                   iv_matnr = ls_scope-matnr ).
      MOVE-CORRESPONDING ls_com TO ls_row.

      READ TABLE lt_no INTO DATA(ls_no)
        WITH KEY werks = ls_scope-werks
                 matnr = ls_scope-matnr BINARY SEARCH.
      IF sy-subrc = 0.
        ls_row-fcst_no = ls_no-fcst_no.
      ENDIF.

      DO 12 TIMES.

        DATA(lv_i)  = CONV ty_mm( sy-index ).
        DATA(lv_ym) = VALUE ty_yrmon( lt_slot[ sy-index ] OPTIONAL ).
        DATA(lv_q)  = hist_qty( iv_werks = ls_scope-werks
                                iv_matnr = ls_scope-matnr
                                iv_yrmon = lv_ym ).

        ASSIGN COMPONENT |M{ lv_i }| OF STRUCTURE ls_row
          TO FIELD-SYMBOL(<lv_m>).
        IF sy-subrc = 0.
          <lv_m> = lv_q.
        ENDIF.

        ls_row-ly_total = ls_row-ly_total + lv_q.

      ENDDO.

      ls_row-fcst_total = ls_row-ly_total * ls_row-load_fct.

      DO 12 TIMES.

        lv_i = sy-index.

        ASSIGN COMPONENT |M{ lv_i }| OF STRUCTURE ls_row TO <lv_m>.
        CHECK sy-subrc = 0.
        ASSIGN COMPONENT |M{ lv_i }_FCST| OF STRUCTURE ls_row
          TO FIELD-SYMBOL(<lv_f>).
        CHECK sy-subrc = 0.

        " ASSUMPTION: FS repeats April on all 12 rows; each month uses its own LY month.
        IF ls_row-ly_total IS NOT INITIAL.
          <lv_f> = <lv_m> / ls_row-ly_total * ls_row-fcst_total.
        ELSE.
*         Nothing sold last year leaves nothing to distribute. The month
*         stays at zero rather than dividing by zero.
          CLEAR <lv_f>.
        ENDIF.

*       ASSUMPTION: FS uses gross weight annually and net weight quarterly.
        ASSIGN COMPONENT |M{ lv_i }_TON| OF STRUCTURE ls_row
          TO FIELD-SYMBOL(<lv_t>).
        IF sy-subrc = 0 AND iv_tonnage = abap_true.
          <lv_t> = zcl_pp_pfcst_util=>to_tonnage( iv_qty   = <lv_f>
                                                  iv_brgew = ls_row-brgew ).
        ENDIF.

        ASSIGN COMPONENT |M{ lv_i }_KL| OF STRUCTURE ls_row
          TO FIELD-SYMBOL(<lv_k>).
        IF sy-subrc = 0.
          <lv_k> = zcl_pp_pfcst_util=>to_volume_kl( iv_qty     = <lv_f>
                                                    iv_pack_sz = ls_row-pack_sz ).
        ENDIF.

        ASSIGN COMPONENT |M{ lv_i }_CR| OF STRUCTURE ls_row
          TO FIELD-SYMBOL(<lv_c>).
        IF sy-subrc = 0.
          <lv_c> = zcl_pp_pfcst_util=>to_value_cr( iv_qty = <lv_f>
                                                   iv_dpl = ls_row-dpl ).
        ENDIF.

      ENDDO.

      APPEND ls_row TO rt_data.

    ENDLOOP.

    IF mv_nocat > 0.
      MESSAGE i012(zpp_pfcst) WITH ms_nocat-matnr ms_nocat-werks.
    ENDIF.
    IF rt_data IS INITIAL.
      MESSAGE i008(zpp_pfcst).
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Quarterly - last year quarter against the last three months
*&---------------------------------------------------------------------*
  METHOD generate_quarter.

    CLEAR: rt_data, mv_nocat, ms_nocat.

    IF it_werks IS INITIAL.
      MESSAGE e001(zpp_pfcst).
    ENDIF.
    IF iv_quarter IS NOT INITIAL AND iv_fyear IS INITIAL.
      MESSAGE e005(zpp_pfcst).
    ENDIF.
    IF iv_fyear IS INITIAL.
      MESSAGE e032(zpp_pfcst).
    ENDIF.
    IF zcl_pp_pfcst_util=>is_fyear_valid( iv_fyear ) = abap_false.
      MESSAGE e002(zpp_pfcst) WITH iv_fyear.
    ENDIF.
    IF iv_quarter IS INITIAL AND iv_date_from IS INITIAL.
      MESSAGE e004(zpp_pfcst).
    ENDIF.

*   The date range only names the quarter. The quarter itself always
*   spans the three full months the fiscal calendar gives it.
    DATA(lv_quarter) = iv_quarter.
    IF lv_quarter IS INITIAL.
      lv_quarter = zcl_pp_pfcst_util=>get_quarter_from_date( iv_date_from ).
    ENDIF.

    DATA(ls_qr) = zcl_pp_pfcst_util=>get_quarter_range( iv_fyear   = iv_fyear
                                                        iv_quarter = lv_quarter ).
    IF ls_qr-date_from IS INITIAL.
      MESSAGE e004(zpp_pfcst).
    ENDIF.

    IF iv_date_from IS NOT INITIAL
      AND ( iv_date_from < ls_qr-date_from OR iv_date_from > ls_qr-date_to ).
      MESSAGE e026(zpp_pfcst) WITH lv_quarter.
    ENDIF.
    IF iv_date_to IS NOT INITIAL
      AND ( iv_date_to < ls_qr-date_from OR iv_date_to > ls_qr-date_to ).
      MESSAGE e026(zpp_pfcst) WITH lv_quarter.
    ENDIF.

    load_plants( it_werks ).

    DATA(ls_lqr) = zcl_pp_pfcst_util=>shift_range_years( is_range = ls_qr
                                                         iv_years = -1 ).
    DATA(lv_lfy) = zcl_pp_pfcst_util=>get_fyear_from_date( ls_lqr-date_from ).
    DATA(ls_fyr) = zcl_pp_pfcst_util=>get_fyear_range( iv_fyear ).
    DATA(lv_gjahr) = CONV gjahr( ls_fyr-date_from(4) ).

*   One history window covering last year's quarter and the three
*   months that run up to this quarter
    DATA(lv_from) = ls_lqr-date_from.
    DATA(lv_to)   = CONV dats( ls_qr-date_from - 1 ).

    load_history( it_werks  = it_werks
                  it_matnr  = it_matnr
                  iv_from   = lv_from
                  iv_to     = lv_to
                  iv_legacy = iv_legacy ).

    mt_scope = build_scope( it_werks = it_werks it_matnr = it_matnr ).
    load_master( ).

    DATA(lv_p)   = ( lv_quarter - 1 ) * 3 + 1.
    DATA(lv_ly1) = period_yrmon( iv_fyear = lv_lfy iv_offset = lv_p ).
    DATA(lv_ly2) = period_yrmon( iv_fyear = lv_lfy iv_offset = lv_p + 1 ).
    DATA(lv_ly3) = period_yrmon( iv_fyear = lv_lfy iv_offset = lv_p + 2 ).
    DATA(lv_cu1) = period_yrmon( iv_fyear = iv_fyear iv_offset = lv_p - 3 ).
    DATA(lv_cu2) = period_yrmon( iv_fyear = iv_fyear iv_offset = lv_p - 2 ).
    DATA(lv_cu3) = period_yrmon( iv_fyear = iv_fyear iv_offset = lv_p - 1 ).

*   Business forecast and reason, uploaded beforehand by ZPP_PAINT_FCST_UPL
    DATA lt_bus TYPE tt_bus.
    IF mt_scope IS NOT INITIAL.
      SELECT werks, matnr, fcst_no, bus_fcst, bus_fcst_add, reason
        FROM zppt_pnt_fqt
        FOR ALL ENTRIES IN @mt_scope
        WHERE werks   = @mt_scope-werks
          AND matnr   = @mt_scope-matnr
          AND gjahr   = @lv_gjahr
          AND quarter = @lv_quarter
        INTO TABLE @DATA(lt_bus_db).
    ENDIF.

    LOOP AT lt_bus_db INTO DATA(ls_bus_db).
      INSERT CORRESPONDING ty_bus( ls_bus_db ) INTO TABLE lt_bus.
    ENDLOOP.

    LOOP AT mt_scope INTO DATA(ls_scope).

      DATA ls_row TYPE ty_quarter.
      CLEAR ls_row.

      DATA(ls_com) = build_common( iv_werks = ls_scope-werks
                                   iv_matnr = ls_scope-matnr ).
      MOVE-CORRESPONDING ls_com TO ls_row.

      ls_row-gjahr   = lv_gjahr.
      ls_row-quarter = lv_quarter.

      READ TABLE lt_bus INTO DATA(ls_bus)
        WITH KEY werks = ls_scope-werks matnr = ls_scope-matnr.
      IF sy-subrc = 0.
        ls_row-fcst_no      = ls_bus-fcst_no.
        ls_row-bus_fcst     = ls_bus-bus_fcst.
        ls_row-bus_fcst_add = ls_bus-bus_fcst_add.
        ls_row-reason       = ls_bus-reason.
      ENDIF.

      ls_row-m4_last = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_ly1 ).
      ls_row-m5_last = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_ly2 ).
      ls_row-m6_last = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_ly3 ).
      ls_row-ly_qtr_tot = ls_row-m4_last + ls_row-m5_last + ls_row-m6_last.

      ls_row-m1_curr = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_cu1 ).
      ls_row-m2_curr = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_cu2 ).
      ls_row-m3_curr = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_cu3 ).
      ls_row-l3m_tot = ls_row-m1_curr + ls_row-m2_curr + ls_row-m3_curr.

      ls_row-max_qty   = nmax( val1 = ls_row-ly_qtr_tot
                               val2 = ls_row-l3m_tot ).
      ls_row-fcst_qty  = ls_row-max_qty * ls_row-load_fct.
      ls_row-final_qty = nmax( val1 = ls_row-fcst_qty
                               val2 = ls_row-bus_fcst + ls_row-bus_fcst_add ).

*     Each month takes the share it held last year. A quarter with no
*     sales last year has no share to apply, so the months stay at zero.
      IF ls_row-ly_qtr_tot IS NOT INITIAL.
        ls_row-m4_fcst = ls_row-m4_last / ls_row-ly_qtr_tot * ls_row-final_qty.
        ls_row-m5_fcst = ls_row-m5_last / ls_row-ly_qtr_tot * ls_row-final_qty.
        ls_row-m6_fcst = ls_row-m6_last / ls_row-ly_qtr_tot * ls_row-final_qty.
      ENDIF.

*     ASSUMPTION: FS uses gross weight annually and net weight quarterly.
      IF iv_tonnage = abap_true.
        ls_row-m4_ton = zcl_pp_pfcst_util=>to_tonnage(
                          iv_qty = ls_row-m4_fcst iv_brgew = ls_row-ntgew ).
        ls_row-m5_ton = zcl_pp_pfcst_util=>to_tonnage(
                          iv_qty = ls_row-m5_fcst iv_brgew = ls_row-ntgew ).
        ls_row-m6_ton = zcl_pp_pfcst_util=>to_tonnage(
                          iv_qty = ls_row-m6_fcst iv_brgew = ls_row-ntgew ).
      ENDIF.

      ls_row-m4_kl = zcl_pp_pfcst_util=>to_volume_kl(
                       iv_qty = ls_row-m4_fcst iv_pack_sz = ls_row-pack_sz ).
      ls_row-m5_kl = zcl_pp_pfcst_util=>to_volume_kl(
                       iv_qty = ls_row-m5_fcst iv_pack_sz = ls_row-pack_sz ).
      ls_row-m6_kl = zcl_pp_pfcst_util=>to_volume_kl(
                       iv_qty = ls_row-m6_fcst iv_pack_sz = ls_row-pack_sz ).

      ls_row-m4_cr = zcl_pp_pfcst_util=>to_value_cr(
                       iv_qty = ls_row-m4_fcst iv_dpl = ls_row-dpl ).
      ls_row-m5_cr = zcl_pp_pfcst_util=>to_value_cr(
                       iv_qty = ls_row-m5_fcst iv_dpl = ls_row-dpl ).
      ls_row-m6_cr = zcl_pp_pfcst_util=>to_value_cr(
                       iv_qty = ls_row-m6_fcst iv_dpl = ls_row-dpl ).

      APPEND ls_row TO rt_data.

    ENDLOOP.

    IF mv_nocat > 0.
      MESSAGE i012(zpp_pfcst) WITH ms_nocat-matnr ms_nocat-werks.
    ENDIF.
    IF rt_data IS INITIAL.
      MESSAGE i008(zpp_pfcst).
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Monthly - the quarterly rules over a single period
*&---------------------------------------------------------------------*
  METHOD generate_month.

    CLEAR: rt_data, mv_nocat, ms_nocat.

    IF it_werks IS INITIAL.
      MESSAGE e001(zpp_pfcst).
    ENDIF.
    IF iv_fyear IS INITIAL.
      MESSAGE e032(zpp_pfcst).
    ENDIF.
    IF zcl_pp_pfcst_util=>is_fyear_valid( iv_fyear ) = abap_false.
      MESSAGE e002(zpp_pfcst) WITH iv_fyear.
    ENDIF.
    IF iv_period IS INITIAL AND iv_date_from IS INITIAL.
      MESSAGE e004(zpp_pfcst).
    ENDIF.

    DATA(lv_period) = iv_period.
    IF lv_period IS INITIAL.
      lv_period = zcl_pp_pfcst_util=>get_month_slot( iv_date_from ).
    ENDIF.

    DATA(ls_pr) = zcl_pp_pfcst_util=>get_period_range( iv_fyear  = iv_fyear
                                                       iv_period = lv_period ).
    IF ls_pr-date_from IS INITIAL.
      MESSAGE e004(zpp_pfcst).
    ENDIF.

    IF iv_date_from IS NOT INITIAL
      AND ( iv_date_from < ls_pr-date_from OR iv_date_from > ls_pr-date_to ).
      MESSAGE e026(zpp_pfcst) WITH lv_period.
    ENDIF.
    IF iv_date_to IS NOT INITIAL
      AND ( iv_date_to < ls_pr-date_from OR iv_date_to > ls_pr-date_to ).
      MESSAGE e026(zpp_pfcst) WITH lv_period.
    ENDIF.

    load_plants( it_werks ).

    DATA(ls_lpr) = zcl_pp_pfcst_util=>shift_range_years( is_range = ls_pr
                                                         iv_years = -1 ).
    DATA(lv_lfy) = zcl_pp_pfcst_util=>get_fyear_from_date( ls_lpr-date_from ).
    DATA(ls_fyr) = zcl_pp_pfcst_util=>get_fyear_range( iv_fyear ).
    DATA(lv_gjahr) = CONV gjahr( ls_fyr-date_from(4) ).

    DATA(lv_from) = ls_lpr-date_from.
    DATA(lv_to)   = CONV dats( ls_pr-date_from - 1 ).

    load_history( it_werks  = it_werks
                  it_matnr  = it_matnr
                  iv_from   = lv_from
                  iv_to     = lv_to
                  iv_legacy = iv_legacy ).

    mt_scope = build_scope( it_werks = it_werks it_matnr = it_matnr ).
    load_master( ).

    DATA(lv_p)   = CONV i( lv_period ).
    DATA(lv_ly1) = period_yrmon( iv_fyear = lv_lfy iv_offset = lv_p ).
    DATA(lv_cu1) = period_yrmon( iv_fyear = iv_fyear iv_offset = lv_p - 3 ).
    DATA(lv_cu2) = period_yrmon( iv_fyear = iv_fyear iv_offset = lv_p - 2 ).
    DATA(lv_cu3) = period_yrmon( iv_fyear = iv_fyear iv_offset = lv_p - 1 ).

    DATA lt_bus TYPE tt_bus.
    IF mt_scope IS NOT INITIAL.
      SELECT werks, matnr, fcst_no, bus_fcst, bus_fcst_add, reason
        FROM zppt_pnt_fmn
        FOR ALL ENTRIES IN @mt_scope
        WHERE werks  = @mt_scope-werks
          AND matnr  = @mt_scope-matnr
          AND gjahr  = @lv_gjahr
          AND period = @lv_period
        INTO TABLE @DATA(lt_bus_db).
    ENDIF.

    LOOP AT lt_bus_db INTO DATA(ls_bus_db).
      INSERT CORRESPONDING ty_bus( ls_bus_db ) INTO TABLE lt_bus.
    ENDLOOP.

    LOOP AT mt_scope INTO DATA(ls_scope).

      DATA ls_row TYPE ty_month.
      CLEAR ls_row.

      DATA(ls_com) = build_common( iv_werks = ls_scope-werks
                                   iv_matnr = ls_scope-matnr ).
      MOVE-CORRESPONDING ls_com TO ls_row.

      ls_row-gjahr  = lv_gjahr.
      ls_row-period = lv_period.

      READ TABLE lt_bus INTO DATA(ls_bus)
        WITH KEY werks = ls_scope-werks matnr = ls_scope-matnr.
      IF sy-subrc = 0.
        ls_row-fcst_no      = ls_bus-fcst_no.
        ls_row-bus_fcst     = ls_bus-bus_fcst.
        ls_row-bus_fcst_add = ls_bus-bus_fcst_add.
        ls_row-reason       = ls_bus-reason.
      ENDIF.

*     Only one month is produced, so M5_LAST and M6_LAST stay empty and
*     the last year total is that single month.
      ls_row-m4_last    = hist_qty( iv_werks = ls_scope-werks
                                    iv_matnr = ls_scope-matnr
                                    iv_yrmon = lv_ly1 ).
      ls_row-ly_qtr_tot = ls_row-m4_last.

      ls_row-m1_curr = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_cu1 ).
      ls_row-m2_curr = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_cu2 ).
      ls_row-m3_curr = hist_qty( iv_werks = ls_scope-werks
                                 iv_matnr = ls_scope-matnr
                                 iv_yrmon = lv_cu3 ).
      ls_row-l3m_avg = ( ls_row-m1_curr + ls_row-m2_curr
                         + ls_row-m3_curr ) / 3.

      ls_row-max_qty   = nmax( val1 = ls_row-ly_qtr_tot
                               val2 = ls_row-l3m_avg ).
      ls_row-fcst_qty  = ls_row-max_qty * ls_row-load_fct.
      ls_row-final_qty = nmax( val1 = ls_row-fcst_qty
                               val2 = ls_row-bus_fcst + ls_row-bus_fcst_add ).

      IF ls_row-ly_qtr_tot IS NOT INITIAL.
        ls_row-m4_fcst = ls_row-m4_last / ls_row-ly_qtr_tot * ls_row-final_qty.
      ELSE.
*       A single month has nothing to share with, so the whole final
*       quantity belongs to it. No division is performed.
        ls_row-m4_fcst = ls_row-final_qty.
      ENDIF.

*     ASSUMPTION: FS uses gross weight annually and net weight quarterly.
      IF iv_tonnage = abap_true.
        ls_row-m4_ton = zcl_pp_pfcst_util=>to_tonnage(
                          iv_qty = ls_row-m4_fcst iv_brgew = ls_row-ntgew ).
      ENDIF.

      ls_row-m4_kl = zcl_pp_pfcst_util=>to_volume_kl(
                       iv_qty = ls_row-m4_fcst iv_pack_sz = ls_row-pack_sz ).
      ls_row-m4_cr = zcl_pp_pfcst_util=>to_value_cr(
                       iv_qty = ls_row-m4_fcst iv_dpl = ls_row-dpl ).

      APPEND ls_row TO rt_data.

    ENDLOOP.

    IF mv_nocat > 0.
      MESSAGE i012(zpp_pfcst) WITH ms_nocat-matnr ms_nocat-werks.
    ENDIF.
    IF rt_data IS INITIAL.
      MESSAGE i008(zpp_pfcst).
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Plant name, configuration and display authorisation
*&---------------------------------------------------------------------*
  METHOD load_plants.

    CLEAR mt_plant.

    SELECT werks, name1
      FROM t001w
      WHERE werks IN @it_werks
      ORDER BY werks
      INTO TABLE @DATA(lt_plant).

    IF lt_plant IS INITIAL.
      MESSAGE e001(zpp_pfcst).
    ENDIF.

    LOOP AT lt_plant INTO DATA(ls_plant).

      IF zcl_pp_pfcst_util=>check_plant_auth( iv_werks = ls_plant-werks
                                              iv_actvt = gc_actvt_disp )
         = abap_false.
        MESSAGE e023(zpp_pfcst) WITH ls_plant-werks.
      ENDIF.

*     VKORG and BWART are never literals here - the util raises message
*     006 itself when the plant has no configuration row.
      DATA(ls_cfg) = zcl_pp_pfcst_util=>get_config( ls_plant-werks ).

      INSERT VALUE #( werks = ls_plant-werks
                      name1 = ls_plant-name1
                      vkorg = ls_cfg-vkorg
                      bwart = ls_cfg-bwart
                      tvarv = ls_cfg-tvarv_legacy ) INTO TABLE mt_plant.

    ENDLOOP.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Billing history, old material rollup, legacy history
*&---------------------------------------------------------------------*
  METHOD load_history.

    CLEAR mt_hist.

    mt_hist = read_billing( it_werks = it_werks
                            it_matnr = it_matnr
                            iv_from  = iv_from
                            iv_to    = iv_to ).

    IF mt_hist IS INITIAL AND iv_legacy = abap_false.
      MESSAGE i007(zpp_pfcst).
    ENDIF.

    add_old_material( EXPORTING it_werks = it_werks
                                it_matnr = it_matnr
                                iv_from  = iv_from
                                iv_to    = iv_to
                      CHANGING  ct_hist  = mt_hist ).

    IF iv_legacy = abap_true.
      check_legacy_auth( ).
      add_legacy( EXPORTING it_werks = it_werks
                            it_matnr = it_matnr
                            iv_from  = iv_from
                            iv_to    = iv_to
                  CHANGING  ct_hist  = mt_hist ).
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Invoiced quantity by plant, material and calendar month
*&---------------------------------------------------------------------*
  METHOD read_billing.

    CLEAR rt_hist.

    DATA lt_date TYPE RANGE OF dats.
    lt_date = VALUE #( ( sign = 'I' option = 'BT'
                         low  = iv_from high = iv_to ) ).

    SELECT k~vbeln, k~fkdat, p~werks, p~matnr, p~fkimg, p~meins
      FROM vbrk AS k INNER JOIN vbrp AS p ON p~vbeln = k~vbeln
     WHERE k~fkdat  IN @lt_date
       AND k~fksto  <> 'X'
       AND k~vbtyp  <> 'U'
       AND p~werks  IN @it_werks
       AND p~matnr  IN @it_matnr
    " ASSUMPTION: FS quarterly sheet says SHKZG NE blank; annual sheet and Adhesive v2 both
    " use SHKZG = blank, which is the correct reading. Confirmed in system 21.08.2026.
       AND p~shkzg  = @space
      INTO TABLE @DATA(lt_bill).

    LOOP AT lt_bill INTO DATA(ls_bill).

      DATA(lv_ym) = CONV ty_yrmon( ls_bill-fkdat(6) ).

      READ TABLE rt_hist ASSIGNING FIELD-SYMBOL(<ls_h>)
        WITH TABLE KEY werks = ls_bill-werks
                       matnr = ls_bill-matnr
                       yrmon = lv_ym.
      IF sy-subrc <> 0.
        INSERT VALUE #( werks = ls_bill-werks
                        matnr = ls_bill-matnr
                        yrmon = lv_ym ) INTO TABLE rt_hist ASSIGNING <ls_h>.
      ENDIF.

      <ls_h>-qty = <ls_h>-qty + ls_bill-fkimg.

    ENDLOOP.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Superseded material codes. Their goods issues are absorbed into the
*& buckets of the successor code, from MATDOC, with the movement type
*& taken from the plant configuration row.
*&---------------------------------------------------------------------*
  METHOD add_old_material.

    SELECT werks, new_matnr, old_matnr1, old_matnr2
      FROM zppt_pnt_mtrk
      WHERE werks     IN @it_werks
        AND new_matnr IN @it_matnr
      INTO TABLE @DATA(lt_trk).

    IF lt_trk IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_old TYPE tt_old.

    LOOP AT lt_trk INTO DATA(ls_trk).

      READ TABLE mt_plant INTO DATA(ls_plant)
        WITH TABLE KEY werks = ls_trk-werks.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF ls_trk-old_matnr1 IS NOT INITIAL
        AND ls_trk-old_matnr1 <> ls_trk-new_matnr.
        INSERT VALUE #( werks     = ls_trk-werks
                        matnr     = ls_trk-old_matnr1
                        new_matnr = ls_trk-new_matnr
                        bwart     = ls_plant-bwart ) INTO TABLE lt_old.
      ENDIF.

      IF ls_trk-old_matnr2 IS NOT INITIAL
        AND ls_trk-old_matnr2 <> ls_trk-new_matnr.
        INSERT VALUE #( werks     = ls_trk-werks
                        matnr     = ls_trk-old_matnr2
                        new_matnr = ls_trk-new_matnr
                        bwart     = ls_plant-bwart ) INTO TABLE lt_old.
      ENDIF.

    ENDLOOP.

    IF lt_old IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_date TYPE RANGE OF dats.
    lt_date = VALUE #( ( sign = 'I' option = 'BT'
                         low  = iv_from high = iv_to ) ).

*   ASSUMPTION: reversal documents are not excluded here. MATDOC-CANCELLED
*   is not confirmed on this release and an unknown field fails
*   activation. Add the condition once the field name is verified in SE11.
    IF lt_old IS NOT INITIAL.
      SELECT werks, matnr, budat, menge
        FROM matdoc
        FOR ALL ENTRIES IN @lt_old
        WHERE werks = @lt_old-werks
          AND matnr = @lt_old-matnr
          AND bwart = @lt_old-bwart
          AND budat IN @lt_date
        INTO TABLE @DATA(lt_doc).
    ENDIF.

    LOOP AT lt_doc INTO DATA(ls_doc).

      READ TABLE lt_old INTO DATA(ls_old)
        WITH KEY werks = ls_doc-werks matnr = ls_doc-matnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_ym) = CONV ty_yrmon( ls_doc-budat(6) ).

      READ TABLE ct_hist ASSIGNING FIELD-SYMBOL(<ls_h>)
        WITH TABLE KEY werks = ls_old-werks
                       matnr = ls_old-new_matnr
                       yrmon = lv_ym.
      IF sy-subrc <> 0.
        INSERT VALUE #( werks = ls_old-werks
                        matnr = ls_old-new_matnr
                        yrmon = lv_ym ) INTO TABLE ct_hist ASSIGNING <ls_h>.
      ENDIF.

      <ls_h>-qty = <ls_h>-qty + ls_doc-menge.

    ENDLOOP.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Uploaded legacy history, twelve months to a row
*&---------------------------------------------------------------------*
  METHOD add_legacy.

    SELECT werks, matnr, gjahr, meins,
           m01, m02, m03, m04, m05, m06,
           m07, m08, m09, m10, m11, m12
      FROM zppt_pnt_shist
      WHERE werks IN @it_werks
        AND matnr IN @it_matnr
      INTO TABLE @DATA(lt_leg).

    LOOP AT lt_leg INTO DATA(ls_leg).

*     GJAHR on the history table is the year the financial year starts
*     in, so M01 is April of GJAHR and M12 is March of GJAHR + 1.
      DATA(lv_fyear) = fyear_of_gjahr( ls_leg-gjahr ).

      DO 12 TIMES.

        DATA(lv_i)  = CONV ty_mm( sy-index ).
        DATA(lv_ym) = period_yrmon( iv_fyear  = lv_fyear
                                    iv_offset = sy-index ).

        DATA(ls_pr) = zcl_pp_pfcst_util=>get_period_range(
                        iv_fyear  = lv_fyear
                        iv_period = CONV poper( sy-index ) ).

        CHECK ls_pr-date_from >= iv_from AND ls_pr-date_from <= iv_to.

        ASSIGN COMPONENT |M{ lv_i }| OF STRUCTURE ls_leg
          TO FIELD-SYMBOL(<lv_q>).
        CHECK sy-subrc = 0.
        CHECK <lv_q> IS NOT INITIAL.

        READ TABLE ct_hist ASSIGNING FIELD-SYMBOL(<ls_h>)
          WITH TABLE KEY werks = ls_leg-werks
                         matnr = ls_leg-matnr
                         yrmon = lv_ym.
        IF sy-subrc <> 0.
          INSERT VALUE #( werks = ls_leg-werks
                          matnr = ls_leg-matnr
                          yrmon = lv_ym ) INTO TABLE ct_hist ASSIGNING <ls_h>.
        ENDIF.

        <ls_h>-qty = <ls_h>-qty + <lv_q>.

      ENDDO.

    ENDLOOP.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& The legacy checkbox is restricted to the users listed in the TVARVC
*& variable named by the plant configuration row.
*&---------------------------------------------------------------------*
  METHOD check_legacy_auth.

    DATA lr_name TYPE RANGE OF rvari_vnam.

    LOOP AT mt_plant INTO DATA(ls_plant).
      IF ls_plant-tvarv IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = 'EQ'
                        low  = ls_plant-tvarv ) TO lr_name.
      ENDIF.
    ENDLOOP.

    IF lr_name IS INITIAL.
      MESSAGE e027(zpp_pfcst).
    ENDIF.

    SELECT name, low
      FROM tvarvc
      WHERE name IN @lr_name
      INTO TABLE @DATA(lt_var).

    READ TABLE lt_var TRANSPORTING NO FIELDS WITH KEY low = sy-uname.
    IF sy-subrc <> 0.
      MESSAGE e027(zpp_pfcst).
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Plant and material pairs to be forecast: everything with sales
*& history plus everything with a product category, less the exclusions
*& and less the superseded codes.
*&---------------------------------------------------------------------*
  METHOD build_scope.

    CLEAR rt_scope.

    LOOP AT mt_hist INTO DATA(ls_hist).
      APPEND VALUE #( werks = ls_hist-werks
                      matnr = ls_hist-matnr ) TO rt_scope.
    ENDLOOP.

    SELECT werks, matnr
      FROM zppt_pnt_pcat
      WHERE werks IN @it_werks
        AND matnr IN @it_matnr
      INTO TABLE @DATA(lt_cat).

    LOOP AT lt_cat INTO DATA(ls_cat).
      APPEND VALUE #( werks = ls_cat-werks
                      matnr = ls_cat-matnr ) TO rt_scope.
    ENDLOOP.

    SORT rt_scope BY werks matnr.
    DELETE ADJACENT DUPLICATES FROM rt_scope COMPARING werks matnr.

    SELECT werks, matnr
      FROM zppt_pnt_mexc
      WHERE werks IN @it_werks
        AND matnr IN @it_matnr
      INTO TABLE @DATA(lt_exc).

    LOOP AT lt_exc INTO DATA(ls_exc).
      READ TABLE rt_scope TRANSPORTING NO FIELDS
        WITH KEY werks = ls_exc-werks matnr = ls_exc-matnr BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE rt_scope INDEX sy-tabix.
*       Only worth telling the user when the material was asked for by
*       name; over a whole plant the exclusion list is routine.
        IF it_matnr IS NOT INITIAL.
          MESSAGE i022(zpp_pfcst) WITH ls_exc-matnr ls_exc-werks.
        ENDIF.
      ENDIF.
    ENDLOOP.

*   A superseded code never appears in its own right. Its history has
*   been absorbed into the successor, so leaving it in would forecast
*   the same sales twice.
    SELECT werks, old_matnr1, old_matnr2
      FROM zppt_pnt_mtrk
      WHERE werks IN @it_werks
      INTO TABLE @DATA(lt_trk).

    LOOP AT lt_trk INTO DATA(ls_trk).
      IF ls_trk-old_matnr1 IS NOT INITIAL.
        DELETE rt_scope WHERE werks = ls_trk-werks
                          AND matnr = ls_trk-old_matnr1.
      ENDIF.
      IF ls_trk-old_matnr2 IS NOT INITIAL.
        DELETE rt_scope WHERE werks = ls_trk-werks
                          AND matnr = ls_trk-old_matnr2.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Every master data read for the whole scope, in one place, so that no
*& mode ever selects inside its own loop.
*&---------------------------------------------------------------------*
  METHOD load_master.

    CLEAR: mt_mat, mt_mvgr, mt_cat.

    IF mt_scope IS INITIAL.
      RETURN.
    ENDIF.

    IF mt_scope IS NOT INITIAL.
      SELECT matnr, matkl, meins, gewei, brgew, ntgew, volum, voleh
        FROM mara
        FOR ALL ENTRIES IN @mt_scope
        WHERE matnr = @mt_scope-matnr
        INTO TABLE @DATA(lt_mara).
    ENDIF.

    IF lt_mara IS INITIAL.
      RETURN.
    ENDIF.

    IF lt_mara IS NOT INITIAL.
      SELECT matnr, maktx
        FROM makt
        FOR ALL ENTRIES IN @lt_mara
        WHERE matnr = @lt_mara-matnr
          AND spras = @sy-langu
        INTO TABLE @DATA(lt_makt).
    ENDIF.

    IF lt_mara IS NOT INITIAL.
      SELECT matnr, meinh, umrez, umren
        FROM marm
        FOR ALL ENTRIES IN @lt_mara
        WHERE matnr = @lt_mara-matnr
        INTO TABLE @DATA(lt_marm).
    ENDIF.

    SORT lt_makt BY matnr.
    SORT lt_marm BY matnr meinh.

*   PACK SIZE is MARM-UMREN of the first alternative unit of measure,
*   per the FS: "Pass ALV MATNR to MARM-MATNR where MEINH is not equal
*   to ALV UOM and take MARM-UMREN. If the MEINH is equal to ML or GM,
*   then divide the value with 1000." It is filled in the MARM loop
*   below, not here.
    LOOP AT lt_mara INTO DATA(ls_mara).

      DATA(ls_mat) = VALUE ty_mat( matnr   = ls_mara-matnr
                                   matkl   = ls_mara-matkl
                                   meins   = ls_mara-meins
                                   gewei   = ls_mara-gewei
                                   brgew   = ls_mara-brgew
                                   ntgew   = ls_mara-ntgew ).

      READ TABLE lt_makt INTO DATA(ls_makt)
        WITH KEY matnr = ls_mara-matnr BINARY SEARCH.
      IF sy-subrc = 0.
        ls_mat-maktx = ls_makt-maktx.
      ENDIF.

      INSERT ls_mat INTO TABLE mt_mat.

    ENDLOOP.

    LOOP AT lt_marm INTO DATA(ls_marm).

      READ TABLE mt_mat ASSIGNING FIELD-SYMBOL(<ls_mat>)
        WITH TABLE KEY matnr = ls_marm-matnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF ls_marm-meinh = <ls_mat>-meins.
        CONTINUE.
      ENDIF.
*     The first alternative unit decides - lt_marm is sorted by material
*     and unit, so a second one is skipped once pack size is filled.
      IF <ls_mat>-pack_sz IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      <ls_mat>-pack_sz = ls_marm-umren.

      IF ls_marm-meinh = 'ML' OR ls_marm-meinh = 'GM'.
        <ls_mat>-pack_sz = <ls_mat>-pack_sz / 1000.
      ENDIF.

    ENDLOOP.

*   Sales organisation comes from the plant configuration row, so the
*   MVKE driver carries the plant's VKORG rather than a literal.
    TYPES: BEGIN OF ty_drv,
             vkorg TYPE vkorg,
             matnr TYPE matnr,
           END OF ty_drv.
    DATA lt_drv TYPE SORTED TABLE OF ty_drv WITH UNIQUE KEY vkorg matnr.

    LOOP AT mt_scope INTO DATA(ls_scope).
      READ TABLE mt_plant INTO DATA(ls_plant)
        WITH TABLE KEY werks = ls_scope-werks.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      INSERT VALUE #( vkorg = ls_plant-vkorg
                      matnr = ls_scope-matnr ) INTO TABLE lt_drv.
    ENDLOOP.

    IF lt_drv IS NOT INITIAL.
      SELECT matnr, vkorg, vtweg, mvgr1, mvgr2, mvgr3, mvgr4, mvgr5,
             aumng
        FROM mvke
        FOR ALL ENTRIES IN @lt_drv
        WHERE matnr = @lt_drv-matnr
          AND vkorg = @lt_drv-vkorg
        INTO TABLE @DATA(lt_mvke).
    ENDIF.

*   One row per material and sales organisation - the first distribution
*   channel decides, the material groups do not differ between them.
    SORT lt_mvke BY matnr vkorg vtweg.
    DELETE ADJACENT DUPLICATES FROM lt_mvke COMPARING matnr vkorg.

    IF lt_mvke IS NOT INITIAL.
      SELECT mvgr1, bezei
        FROM tvm1t
        FOR ALL ENTRIES IN @lt_mvke
        WHERE spras = @sy-langu
          AND mvgr1 = @lt_mvke-mvgr1
        INTO TABLE @DATA(lt_t1).
    ENDIF.

    IF lt_mvke IS NOT INITIAL.
      SELECT mvgr2, bezei
        FROM tvm2t
        FOR ALL ENTRIES IN @lt_mvke
        WHERE spras = @sy-langu
          AND mvgr2 = @lt_mvke-mvgr2
        INTO TABLE @DATA(lt_t2).
    ENDIF.

    IF lt_mvke IS NOT INITIAL.
      SELECT mvgr3, bezei
        FROM tvm3t
        FOR ALL ENTRIES IN @lt_mvke
        WHERE spras = @sy-langu
          AND mvgr3 = @lt_mvke-mvgr3
        INTO TABLE @DATA(lt_t3).
    ENDIF.

    IF lt_mvke IS NOT INITIAL.
      SELECT mvgr4, bezei
        FROM tvm4t
        FOR ALL ENTRIES IN @lt_mvke
        WHERE spras = @sy-langu
          AND mvgr4 = @lt_mvke-mvgr4
        INTO TABLE @DATA(lt_t4).
    ENDIF.

    IF lt_mvke IS NOT INITIAL.
      SELECT mvgr5, bezei
        FROM tvm5t
        FOR ALL ENTRIES IN @lt_mvke
        WHERE spras = @sy-langu
          AND mvgr5 = @lt_mvke-mvgr5
        INTO TABLE @DATA(lt_t5).
    ENDIF.

    SORT lt_t1 BY mvgr1.
    SORT lt_t2 BY mvgr2.
    SORT lt_t3 BY mvgr3.
    SORT lt_t4 BY mvgr4.
    SORT lt_t5 BY mvgr5.

    LOOP AT lt_mvke INTO DATA(ls_mvke).

      DATA(ls_grp) = VALUE ty_mvgr( vkorg = ls_mvke-vkorg
                                    matnr = ls_mvke-matnr
                                    mvgr1 = ls_mvke-mvgr1
                                    mvgr2 = ls_mvke-mvgr2
                                    mvgr3 = ls_mvke-mvgr3
                                    mvgr4 = ls_mvke-mvgr4
                                    mvgr5 = ls_mvke-mvgr5 ).

*     QTY / CARTON is MVKE-AUMNG, per the FS: "Pass VBRP-MATNR to
*     MVKE-MATNR for MVGR1 is not equal to blank and VKORG=<config>
*     and take AUMNG."
      IF ls_mvke-mvgr1 IS NOT INITIAL.
        ls_grp-qty_ctn = ls_mvke-aumng.
      ENDIF.

      READ TABLE lt_t1 INTO DATA(ls_t1)
        WITH KEY mvgr1 = ls_mvke-mvgr1 BINARY SEARCH.
      IF sy-subrc = 0.
        ls_grp-mvgr1_txt = ls_t1-bezei.
      ENDIF.
      READ TABLE lt_t2 INTO DATA(ls_t2)
        WITH KEY mvgr2 = ls_mvke-mvgr2 BINARY SEARCH.
      IF sy-subrc = 0.
        ls_grp-mvgr2_txt = ls_t2-bezei.
      ENDIF.
      READ TABLE lt_t3 INTO DATA(ls_t3)
        WITH KEY mvgr3 = ls_mvke-mvgr3 BINARY SEARCH.
      IF sy-subrc = 0.
        ls_grp-mvgr3_txt = ls_t3-bezei.
      ENDIF.
      READ TABLE lt_t4 INTO DATA(ls_t4)
        WITH KEY mvgr4 = ls_mvke-mvgr4 BINARY SEARCH.
      IF sy-subrc = 0.
        ls_grp-mvgr4_txt = ls_t4-bezei.
      ENDIF.
      READ TABLE lt_t5 INTO DATA(ls_t5)
        WITH KEY mvgr5 = ls_mvke-mvgr5 BINARY SEARCH.
      IF sy-subrc = 0.
        ls_grp-mvgr5_txt = ls_t5-bezei.
      ENDIF.

      INSERT ls_grp INTO TABLE mt_mvgr.

    ENDLOOP.

    IF mt_scope IS NOT INITIAL.
      SELECT werks, matnr, prod_cat, load_fct, mts_mto
        FROM zppt_pnt_pcat
        FOR ALL ENTRIES IN @mt_scope
        WHERE werks = @mt_scope-werks
          AND matnr = @mt_scope-matnr
        INTO TABLE @DATA(lt_pcat).
    ENDIF.

    LOOP AT lt_pcat INTO DATA(ls_pcat).
      INSERT CORRESPONDING ty_cat( ls_pcat ) INTO TABLE mt_cat.
    ENDLOOP.

" ASSUMPTION: ZPP_BRAND not confirmed to exist - enable once the
" structure is supplied. Brand stays empty until then, and the read
" belongs here, prefetched for the whole scope, never inside a loop.
"    IF mt_scope IS NOT INITIAL.
"      SELECT werks, matnr, brand
"        FROM zpp_brand
"        FOR ALL ENTRIES IN @mt_scope
"        WHERE werks = @mt_scope-werks
"          AND matnr = @mt_scope-matnr
"        INTO TABLE @DATA(lt_brand).
"    ENDIF.

" ASSUMPTION: DPL has no source table or field anywhere in the FS -
" enable once the structure is supplied. Value in Crores stays zero
" until then.
"    IF mt_scope IS NOT INITIAL.
"      SELECT matnr, dpl
"        FROM <dpl source>
"        FOR ALL ENTRIES IN @mt_scope
"        WHERE matnr = @mt_scope-matnr
"        INTO TABLE @DATA(lt_dpl).
"    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& The master data columns the three modes share
*&---------------------------------------------------------------------*
  METHOD build_common.

    rs_common-werks = iv_werks.
    rs_common-matnr = iv_matnr.

    DATA lv_vkorg TYPE vkorg.

    READ TABLE mt_plant INTO DATA(ls_plant)
      WITH TABLE KEY werks = iv_werks.
    IF sy-subrc = 0.
      rs_common-name1 = ls_plant-name1.
      lv_vkorg        = ls_plant-vkorg.
    ENDIF.

    READ TABLE mt_mat INTO DATA(ls_mat)
      WITH TABLE KEY matnr = iv_matnr.
    IF sy-subrc = 0.
      rs_common-maktx   = ls_mat-maktx.
      rs_common-matkl   = ls_mat-matkl.
      rs_common-meins   = ls_mat-meins.
      rs_common-gewei   = ls_mat-gewei.
      rs_common-brgew   = ls_mat-brgew.
      rs_common-ntgew   = ls_mat-ntgew.
      rs_common-pack_sz = ls_mat-pack_sz.
    ENDIF.

    READ TABLE mt_mvgr INTO DATA(ls_grp)
      WITH TABLE KEY vkorg = lv_vkorg matnr = iv_matnr.
    IF sy-subrc = 0.
      rs_common-qty_ctn   = ls_grp-qty_ctn.
      rs_common-mvgr1     = ls_grp-mvgr1.
      rs_common-mvgr2     = ls_grp-mvgr2.
      rs_common-mvgr3     = ls_grp-mvgr3.
      rs_common-mvgr4     = ls_grp-mvgr4.
      rs_common-mvgr5     = ls_grp-mvgr5.
      rs_common-mvgr1_txt = ls_grp-mvgr1_txt.
      rs_common-mvgr2_txt = ls_grp-mvgr2_txt.
      rs_common-mvgr3_txt = ls_grp-mvgr3_txt.
      rs_common-mvgr4_txt = ls_grp-mvgr4_txt.
      rs_common-mvgr5_txt = ls_grp-mvgr5_txt.
    ENDIF.

    READ TABLE mt_cat INTO DATA(ls_cat)
      WITH KEY werks = iv_werks matnr = iv_matnr.
    IF sy-subrc = 0.
      rs_common-prod_cat = ls_cat-prod_cat.
      rs_common-load_fct = ls_cat-load_fct.
      rs_common-mts_mto  = ls_cat-mts_mto.
    ELSE.
*     The plant and material are counted and reported once, after the
*     run, rather than a popup for every row.
      mv_nocat = mv_nocat + 1.
      IF ms_nocat IS INITIAL.
        ms_nocat-werks = iv_werks.
        ms_nocat-matnr = iv_matnr.
      ENDIF.
    ENDIF.

*   A load factor of zero would wipe out the forecast, so an unmaintained
*   factor is read as no growth rather than as nothing to make.
    IF rs_common-load_fct IS INITIAL.
      rs_common-load_fct = 1.
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
  METHOD hist_qty.

    READ TABLE mt_hist INTO DATA(ls_hist)
      WITH TABLE KEY werks = iv_werks
                     matnr = iv_matnr
                     yrmon = iv_yrmon.
    IF sy-subrc = 0.
      rv_qty = ls_hist-qty.
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Year and month of a period offset. An offset below 1 rolls back into
*& the previous financial year, above 12 into the next one, so that the
*& three months before Q1 resolve correctly.
*&---------------------------------------------------------------------*
  METHOD period_yrmon.

    DATA(lv_fyear)  = iv_fyear.
    DATA(lv_offset) = iv_offset.
    DATA(ls_range)  = zcl_pp_pfcst_util=>get_fyear_range( iv_fyear ).

    WHILE lv_offset < 1.
      ls_range = zcl_pp_pfcst_util=>shift_range_years( is_range = ls_range
                                                       iv_years = -1 ).
      lv_fyear = zcl_pp_pfcst_util=>get_fyear_from_date( ls_range-date_from ).
      lv_offset = lv_offset + 12.
    ENDWHILE.

    WHILE lv_offset > 12.
      ls_range = zcl_pp_pfcst_util=>shift_range_years( is_range = ls_range
                                                       iv_years = 1 ).
      lv_fyear = zcl_pp_pfcst_util=>get_fyear_from_date( ls_range-date_from ).
      lv_offset = lv_offset - 12.
    ENDWHILE.

    DATA(ls_per) = zcl_pp_pfcst_util=>get_period_range(
                     iv_fyear  = lv_fyear
                     iv_period = CONV poper( lv_offset ) ).

    rv_yrmon = ls_per-date_from(6).

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& The financial year that starts in the given year, as YYYY-YYYY
*&---------------------------------------------------------------------*
  METHOD fyear_of_gjahr.

    DATA(lv_next) = CONV gjahr( iv_gjahr + 1 ).
    rv_fyear = |{ iv_gjahr }-{ lv_next }|.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Change authorisation, checked once per plant before anything is saved
*&---------------------------------------------------------------------*
  METHOD check_save_auth.

    LOOP AT it_data INTO DATA(ls_scope).
      IF zcl_pp_pfcst_util=>check_plant_auth( iv_werks = ls_scope-werks
                                              iv_actvt = gc_actvt_save )
         = abap_false.
        MESSAGE e023(zpp_pfcst) WITH ls_scope-werks.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


*&---------------------------------------------------------------------*
  METHOD lock_table.

    CALL FUNCTION 'ENQUEUE_E_TABLE'
      EXPORTING  mode_rstable   = 'E'
                 tabname        = iv_tabname
      EXCEPTIONS foreign_lock   = 1
                 system_failure = 2
                 OTHERS         = 3.

    IF sy-subrc = 0.
      rv_ok = abap_true.
    ELSE.
      rv_ok = abap_false.
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
  METHOD unlock_table.

    CALL FUNCTION 'DEQUEUE_E_TABLE'
      EXPORTING mode_rstable = 'E'
                tabname      = iv_tabname.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Save the annual forecast. An existing row keeps its forecast number.
*&---------------------------------------------------------------------*
  METHOD save_annual.

    CONSTANTS lc_tab TYPE tabname VALUE 'ZPPT_PNT_FYR'.

    DATA: lt_row   TYPE STANDARD TABLE OF zppt_pnt_fyr,
          lt_scope TYPE tt_scope,
          lv_ins   TYPE i,
          lv_werks TYPE werks_d.

    CLEAR rv_fcst_no.

    IF it_data IS INITIAL.
      MESSAGE e011(zpp_pfcst).
    ENDIF.
    IF zcl_pp_pfcst_util=>is_fyear_valid( iv_fyear ) = abap_false.
      MESSAGE e002(zpp_pfcst) WITH iv_fyear.
    ENDIF.

    LOOP AT it_data INTO DATA(ls_data).
      APPEND VALUE #( werks = ls_data-werks
                      matnr = ls_data-matnr ) TO lt_scope.
    ENDLOOP.

    SORT lt_scope BY werks matnr.
    DELETE ADJACENT DUPLICATES FROM lt_scope COMPARING werks matnr.

    check_save_auth( lt_scope ).

    IF it_data IS NOT INITIAL.
      SELECT werks, matnr, fcst_no, ernam, erdat
        FROM zppt_pnt_fyr
        FOR ALL ENTRIES IN @it_data
        WHERE werks = @it_data-werks
          AND matnr = @it_data-matnr
          AND fyear = @iv_fyear
        INTO TABLE @DATA(lt_old).
    ENDIF.

    SORT lt_old BY werks matnr.

    IF lock_table( lc_tab ) = abap_false.
      MESSAGE e029(zpp_pfcst).
    ENDIF.

    LOOP AT it_data INTO ls_data.

      DATA(ls_db) = CORRESPONDING zppt_pnt_fyr( ls_data ).
      ls_db-fyear = iv_fyear.

      READ TABLE lt_old INTO DATA(ls_old)
        WITH KEY werks = ls_data-werks matnr = ls_data-matnr BINARY SEARCH.

      IF sy-subrc = 0 AND ls_old-fcst_no IS NOT INITIAL.
        ls_db-fcst_no = ls_old-fcst_no.
        ls_db-ernam   = ls_old-ernam.
        ls_db-erdat   = ls_old-erdat.
        ls_db-aenam   = sy-uname.
        ls_db-aedat   = sy-datum.
      ELSE.
        ls_db-fcst_no = zcl_pp_pfcst_util=>get_next_fcst_no( iv_fyear ).
        IF ls_db-fcst_no IS INITIAL.
          unlock_table( lc_tab ).
          MESSAGE e021(zpp_pfcst).
        ENDIF.
        ls_db-ernam = sy-uname.
        ls_db-erdat = sy-datum.
        lv_ins = lv_ins + 1.
      ENDIF.

      APPEND ls_db TO lt_row.

      IF rv_fcst_no IS INITIAL.
        rv_fcst_no = ls_db-fcst_no.
        lv_werks   = ls_db-werks.
      ENDIF.

    ENDLOOP.

    MODIFY zppt_pnt_fyr FROM TABLE @lt_row.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      unlock_table( lc_tab ).
      IF lv_ins > 0.
        MESSAGE i010(zpp_pfcst) WITH rv_fcst_no lv_werks.
      ELSE.
        MESSAGE i030(zpp_pfcst) WITH rv_fcst_no lv_werks.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
      CLEAR rv_fcst_no.
      unlock_table( lc_tab ).
      MESSAGE e029(zpp_pfcst).
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Save the quarterly forecast
*&---------------------------------------------------------------------*
  METHOD save_quarter.

    CONSTANTS lc_tab TYPE tabname VALUE 'ZPPT_PNT_FQT'.

    DATA: lt_row   TYPE STANDARD TABLE OF zppt_pnt_fqt,
          lt_scope TYPE tt_scope,
          lv_ins   TYPE i,
          lv_werks TYPE werks_d.

    CLEAR rv_fcst_no.

    IF it_data IS INITIAL.
      MESSAGE e011(zpp_pfcst).
    ENDIF.

    LOOP AT it_data INTO DATA(ls_data).
      APPEND VALUE #( werks = ls_data-werks
                      matnr = ls_data-matnr ) TO lt_scope.
    ENDLOOP.

    SORT lt_scope BY werks matnr.
    DELETE ADJACENT DUPLICATES FROM lt_scope COMPARING werks matnr.

    check_save_auth( lt_scope ).

    IF it_data IS NOT INITIAL.
      SELECT werks, matnr, gjahr, quarter, fcst_no, ernam, erdat
        FROM zppt_pnt_fqt
        FOR ALL ENTRIES IN @it_data
        WHERE werks   = @it_data-werks
          AND matnr   = @it_data-matnr
          AND gjahr   = @it_data-gjahr
          AND quarter = @it_data-quarter
        INTO TABLE @DATA(lt_old).
    ENDIF.

    SORT lt_old BY werks matnr gjahr quarter.

    IF lock_table( lc_tab ) = abap_false.
      MESSAGE e029(zpp_pfcst).
    ENDIF.

    LOOP AT it_data INTO ls_data.

      DATA(ls_db) = CORRESPONDING zppt_pnt_fqt( ls_data ).

      READ TABLE lt_old INTO DATA(ls_old)
        WITH KEY werks   = ls_data-werks
                 matnr   = ls_data-matnr
                 gjahr   = ls_data-gjahr
                 quarter = ls_data-quarter BINARY SEARCH.

      IF sy-subrc = 0 AND ls_old-fcst_no IS NOT INITIAL.
        ls_db-fcst_no = ls_old-fcst_no.
        ls_db-ernam   = ls_old-ernam.
        ls_db-erdat   = ls_old-erdat.
        ls_db-aenam   = sy-uname.
        ls_db-aedat   = sy-datum.
      ELSE.
        IF ls_db-fcst_no IS INITIAL.
          ls_db-fcst_no = zcl_pp_pfcst_util=>get_next_fcst_no(
                            fyear_of_gjahr( ls_data-gjahr ) ).
        ENDIF.
        IF ls_db-fcst_no IS INITIAL.
          unlock_table( lc_tab ).
          MESSAGE e021(zpp_pfcst).
        ENDIF.
        ls_db-ernam = sy-uname.
        ls_db-erdat = sy-datum.
        lv_ins = lv_ins + 1.
      ENDIF.

      APPEND ls_db TO lt_row.

      IF rv_fcst_no IS INITIAL.
        rv_fcst_no = ls_db-fcst_no.
        lv_werks   = ls_db-werks.
      ENDIF.

    ENDLOOP.

    MODIFY zppt_pnt_fqt FROM TABLE @lt_row.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      unlock_table( lc_tab ).
      IF lv_ins > 0.
        MESSAGE i010(zpp_pfcst) WITH rv_fcst_no lv_werks.
      ELSE.
        MESSAGE i030(zpp_pfcst) WITH rv_fcst_no lv_werks.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
      CLEAR rv_fcst_no.
      unlock_table( lc_tab ).
      MESSAGE e029(zpp_pfcst).
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Save the monthly forecast
*&---------------------------------------------------------------------*
  METHOD save_month.

    CONSTANTS lc_tab TYPE tabname VALUE 'ZPPT_PNT_FMN'.

    DATA: lt_row   TYPE STANDARD TABLE OF zppt_pnt_fmn,
          lt_scope TYPE tt_scope,
          lv_ins   TYPE i,
          lv_werks TYPE werks_d.

    CLEAR rv_fcst_no.

    IF it_data IS INITIAL.
      MESSAGE e011(zpp_pfcst).
    ENDIF.

    LOOP AT it_data INTO DATA(ls_data).
      APPEND VALUE #( werks = ls_data-werks
                      matnr = ls_data-matnr ) TO lt_scope.
    ENDLOOP.

    SORT lt_scope BY werks matnr.
    DELETE ADJACENT DUPLICATES FROM lt_scope COMPARING werks matnr.

    check_save_auth( lt_scope ).

    IF it_data IS NOT INITIAL.
      SELECT werks, matnr, gjahr, period, fcst_no, ernam, erdat
        FROM zppt_pnt_fmn
        FOR ALL ENTRIES IN @it_data
        WHERE werks  = @it_data-werks
          AND matnr  = @it_data-matnr
          AND gjahr  = @it_data-gjahr
          AND period = @it_data-period
        INTO TABLE @DATA(lt_old).
    ENDIF.

    SORT lt_old BY werks matnr gjahr period.

    IF lock_table( lc_tab ) = abap_false.
      MESSAGE e029(zpp_pfcst).
    ENDIF.

    LOOP AT it_data INTO ls_data.

      DATA(ls_db) = CORRESPONDING zppt_pnt_fmn( ls_data ).

      READ TABLE lt_old INTO DATA(ls_old)
        WITH KEY werks  = ls_data-werks
                 matnr  = ls_data-matnr
                 gjahr  = ls_data-gjahr
                 period = ls_data-period BINARY SEARCH.

      IF sy-subrc = 0 AND ls_old-fcst_no IS NOT INITIAL.
        ls_db-fcst_no = ls_old-fcst_no.
        ls_db-ernam   = ls_old-ernam.
        ls_db-erdat   = ls_old-erdat.
        ls_db-aenam   = sy-uname.
        ls_db-aedat   = sy-datum.
      ELSE.
        IF ls_db-fcst_no IS INITIAL.
          ls_db-fcst_no = zcl_pp_pfcst_util=>get_next_fcst_no(
                            fyear_of_gjahr( ls_data-gjahr ) ).
        ENDIF.
        IF ls_db-fcst_no IS INITIAL.
          unlock_table( lc_tab ).
          MESSAGE e021(zpp_pfcst).
        ENDIF.
        ls_db-ernam = sy-uname.
        ls_db-erdat = sy-datum.
        lv_ins = lv_ins + 1.
      ENDIF.

      APPEND ls_db TO lt_row.

      IF rv_fcst_no IS INITIAL.
        rv_fcst_no = ls_db-fcst_no.
        lv_werks   = ls_db-werks.
      ENDIF.

    ENDLOOP.

    MODIFY zppt_pnt_fmn FROM TABLE @lt_row.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      unlock_table( lc_tab ).
      IF lv_ins > 0.
        MESSAGE i010(zpp_pfcst) WITH rv_fcst_no lv_werks.
      ELSE.
        MESSAGE i030(zpp_pfcst) WITH rv_fcst_no lv_werks.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
      CLEAR rv_fcst_no.
      unlock_table( lc_tab ).
      MESSAGE e029(zpp_pfcst).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
