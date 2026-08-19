*&---------------------------------------------------------------------*
*& Class         ZCL_SD_SCHEME_SETTLE
*& Package       ZSD_SCHEME
*& Description   Scheme (Pipes) - business volume determination, early
*&               bird, cascading, CN calculation and settlement posting.
*&
*& Created by    Arnav Johri
*& Reference     FS "Scheme - Pipes" V.01 10.08.2026, assumptions A15-A32
*&
*& Field-mapping note (Q2)
*&   The FS maps sold-to to VBRP-KUNAG_ANA and distribution channel to
*&   VBRP-VTWEG_AUFT. Those are analytical fields that may not be active
*&   in this system, so VBRK-KUNAG and VBRK-VTWEG are used instead. They
*&   carry the same value as recorded on the billing document (A19) and
*&   are guaranteed to exist. Change here only if Q2 comes back saying
*&   the analytical fields are active and required.
*&
*&   KNA1-ZZ1_LOC1_CUS / ZZ1_LOC2_CUS / ZZ1_SP_CODE_CUS are customer
*&   extension fields whose existence is also open under Q2. They are
*&   read through ASSIGN COMPONENT so that this class compiles and runs
*&   whether or not the fields have been created.
*&---------------------------------------------------------------------*
CLASS zcl_sd_scheme_settle DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: tt_res TYPE STANDARD TABLE OF zsds_schm_res WITH DEFAULT KEY.

    CONSTANTS: gc_msgid TYPE symsgid  VALUE 'ZSD_SCHEME',
               gc_auth  TYPE xuobject VALUE 'ZSD_SCHM_ST'.

    "! Simulate. Reads schemes, determines volume per period and customer,
    "! computes early bird, cascading and CN value. Posts nothing.
    METHODS simulate
      IMPORTING ir_scheme_no  TYPE ANY TABLE
                ir_kunnr      TYPE ANY TABLE OPTIONAL
                iv_date_from  TYPE dats
                iv_date_to    TYPE dats
                iv_only_open  TYPE abap_bool DEFAULT abap_true
      EXPORTING et_res        TYPE tt_res
                et_msg        TYPE bapiret2_t.

    "! Post the selected lines: credit memo request, then credit memo,
    "! then update the settlement log. Idempotent (A31).
    METHODS post
      IMPORTING iv_test       TYPE abap_bool DEFAULT abap_false
      CHANGING  ct_res        TYPE tt_res
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    CLASS-METHODS check_post_authority
      IMPORTING iv_vkorg     TYPE vkorg
      RETURNING VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_bill,
             vbeln TYPE vbeln_vf,
             posnr TYPE posnr_vf,
             fkdat TYPE fkdat,
             fkart TYPE fkart,
             kunag TYPE kunag,
             vtweg TYPE vtweg,
             waerk TYPE waerk,
             matnr TYPE matnr,
             spart TYPE spart,
             werks TYPE werks_d,
             wkreg TYPE regio,
             mvgr1 TYPE mvgr1,
             mvgr2 TYPE mvgr2,
             mvgr3 TYPE mvgr3,
             mvgr4 TYPE mvgr4,
             mvgr5 TYPE mvgr5,
             kvgr1 TYPE kvgr1,
             kvgr2 TYPE kvgr2,
             netwr TYPE netwr,
             fkimg TYPE fkimg,
             meins TYPE meins,
             vrkme TYPE vrkme,
           END OF ty_bill,
           tt_bill TYPE STANDARD TABLE OF ty_bill WITH DEFAULT KEY,

           BEGIN OF ty_cust,
             kunnr  TYPE kunnr,
             parent TYPE kunnr,
             name1  TYPE name1_gp,
             loc1   TYPE char20,
             loc2   TYPE char20,
           END OF ty_cust,
           tt_cust  TYPE SORTED TABLE OF ty_cust WITH UNIQUE KEY kunnr,
           tt_kunnr TYPE STANDARD TABLE OF kunnr WITH DEFAULT KEY,

           "! Generic range line used to fan ZSDT_SCHM_RNG rows out into
           "! the typed range tables below.
           BEGIN OF ty_range,
             sign   TYPE char1,
             option TYPE char2,
             low    TYPE char40,
             high   TYPE char40,
           END OF ty_range.

    DATA: ms_hdr  TYPE zsdt_schm_hdr,
          ms_cfg  TYPE zsdt_schm_cfg,
          mt_cust TYPE tt_cust.

    " Range tables built from ZSDT_SCHM_RNG. The field set is fixed, so no
    " dynamic SQL is needed anywhere in this class.
    DATA: mr_mvgr1 TYPE RANGE OF mvgr1,
          mr_mvgr2 TYPE RANGE OF mvgr2,
          mr_mvgr3 TYPE RANGE OF mvgr3,
          mr_mvgr4 TYPE RANGE OF mvgr4,
          mr_mvgr5 TYPE RANGE OF mvgr5,
          mr_regio TYPE RANGE OF regio,
          mr_kunnr TYPE RANGE OF kunnr,
          mr_kvgr1 TYPE RANGE OF kvgr1,
          mr_kvgr2 TYPE RANGE OF kvgr2.

    METHODS build_ranges
      IMPORTING iv_scheme_no TYPE zde_schm_no.

    METHODS read_billing
      IMPORTING iv_from        TYPE dats
                iv_to          TYPE dats
      RETURNING VALUE(rt_bill) TYPE tt_bill.

    METHODS read_customers
      IMPORTING it_bill TYPE tt_bill.

    METHODS settle_period
      IMPORTING is_per   TYPE zsds_schm_per
                it_bill  TYPE tt_bill
      CHANGING  ct_res   TYPE tt_res.

    METHODS calc_cascading
      IMPORTING iv_kunnr        TYPE kunnr
                is_per          TYPE zsds_schm_per
      RETURNING VALUE(rv_value) TYPE zsdt_schm_setl-casc_val.

    METHODS is_ratio_met
      IMPORTING it_bill      TYPE tt_bill
                iv_kunnr     TYPE kunnr
      RETURNING VALUE(rv_ok) TYPE abap_bool.

    METHODS create_credit_memo_req
      IMPORTING is_res         TYPE zsds_schm_res
      EXPORTING ev_vbeln       TYPE vbeln_va
      RETURNING VALUE(rt_msg)  TYPE bapiret2_t.

    METHODS create_credit_memo
      IMPORTING iv_order      TYPE vbeln_va
      EXPORTING ev_vbeln      TYPE vbeln_vf
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    METHODS read_config
      IMPORTING iv_vkorg      TYPE vkorg
      RETURNING VALUE(rv_ok)  TYPE abap_bool.

    METHODS add_msg
      IMPORTING iv_type   TYPE bapi_mtype DEFAULT 'E'
                iv_number TYPE symsgno
                iv_v1     TYPE any OPTIONAL
                iv_v2     TYPE any OPTIONAL
                iv_v3     TYPE any OPTIONAL
      CHANGING  ct_msg    TYPE bapiret2_t.

ENDCLASS.


CLASS zcl_sd_scheme_settle IMPLEMENTATION.

*&---------------------------------------------------------------------*
  METHOD simulate.

    CLEAR: et_res, et_msg.

    SELECT * FROM zsdt_schm_hdr INTO TABLE @DATA(lt_hdr)
      WHERE scheme_no IN @ir_scheme_no
        AND del_ind    = @space
        AND status    <> @zcl_sd_scheme=>gc_status-new
        AND valid_from <= @iv_date_to
        AND valid_to   >= @iv_date_from
      ORDER BY scheme_no.

    IF sy-subrc <> 0.
      add_msg( EXPORTING iv_type = 'I' iv_number = 029 CHANGING ct_msg = et_msg ).
      RETURN.
    ENDIF.

    LOOP AT lt_hdr INTO ms_hdr.

      " Only schemes the user may at least display
      IF zcl_sd_scheme=>check_authority( iv_vkorg = ms_hdr-vkorg
                                         iv_vtweg = ms_hdr-vtweg
                                         iv_spart = ms_hdr-spart
                                         iv_actvt = '03' ) = abap_false.
        CONTINUE.
      ENDIF.

      build_ranges( ms_hdr-scheme_no ).

      " Customer restriction from the selection screen narrows the scheme's
      " own customer range, it never widens it
      IF ir_kunnr IS SUPPLIED AND ir_kunnr IS NOT INITIAL.
        LOOP AT ir_kunnr ASSIGNING FIELD-SYMBOL(<ls_k>).
          APPEND INITIAL LINE TO mr_kunnr ASSIGNING FIELD-SYMBOL(<ls_r>).
          MOVE-CORRESPONDING <ls_k> TO <ls_r>.
        ENDLOOP.
      ENDIF.

      DATA(lt_per) = zcl_sd_scheme=>get_periods(
                       iv_type = ms_hdr-scheme_type
                       iv_from = ms_hdr-valid_from
                       iv_to   = ms_hdr-valid_to ).

      " Whole-validity read once, then split by period in ABAP - one
      " database hit per scheme instead of one per period
      DATA(lt_bill) = read_billing( iv_from = ms_hdr-valid_from
                                    iv_to   = ms_hdr-valid_to ).
      IF lt_bill IS INITIAL.
        CONTINUE.
      ENDIF.

      read_customers( lt_bill ).

      LOOP AT lt_per INTO DATA(ls_per).
        " Skip periods outside the requested settlement window
        IF ls_per-per_to < iv_date_from OR ls_per-per_from > iv_date_to.
          CONTINUE.
        ENDIF.
        settle_period( EXPORTING is_per  = ls_per
                                 it_bill = lt_bill
                       CHANGING  ct_res  = et_res ).
      ENDLOOP.

    ENDLOOP.

    " Drop everything already posted unless the caller wants the full picture
    IF iv_only_open = abap_true.
      DELETE et_res WHERE status = 'P' OR status = 'B'.
    ENDIF.

    IF et_res IS INITIAL.
      add_msg( EXPORTING iv_type = 'I' iv_number = 029 CHANGING ct_msg = et_msg ).
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Ranges (A05). Every selection field is known at design time, so the
*& generic ZSDT_SCHM_RNG rows are distributed into typed range tables.
*& Zone / Sub-Zone (Q8) are read here too - when the source fields are
*& confirmed, only this method and the volume SELECT need extending.
*&---------------------------------------------------------------------*
  METHOD build_ranges.

    CLEAR: mr_mvgr1, mr_mvgr2, mr_mvgr3, mr_mvgr4, mr_mvgr5,
           mr_regio, mr_kunnr, mr_kvgr1, mr_kvgr2.

    SELECT sign, opti, low, high, fieldname
      FROM zsdt_schm_rng
      INTO TABLE @DATA(lt_rng)
      WHERE scheme_no = @iv_scheme_no.

    LOOP AT lt_rng INTO DATA(ls_rng).

      DATA(ls_line) = VALUE ty_range( sign   = ls_rng-sign
                                      option = ls_rng-opti
                                      low    = ls_rng-low
                                      high   = ls_rng-high ).

      CASE ls_rng-fieldname.
        WHEN 'MVGR1'. APPEND CORRESPONDING #( ls_line ) TO mr_mvgr1.
        WHEN 'MVGR2'. APPEND CORRESPONDING #( ls_line ) TO mr_mvgr2.
        WHEN 'MVGR3'. APPEND CORRESPONDING #( ls_line ) TO mr_mvgr3.
        WHEN 'MVGR4'. APPEND CORRESPONDING #( ls_line ) TO mr_mvgr4.
        WHEN 'MVGR5'. APPEND CORRESPONDING #( ls_line ) TO mr_mvgr5.
        WHEN 'REGIO'. APPEND CORRESPONDING #( ls_line ) TO mr_regio.
        WHEN 'KUNNR'. APPEND CORRESPONDING #( ls_line ) TO mr_kunnr.
        WHEN 'KVGR1'. APPEND CORRESPONDING #( ls_line ) TO mr_kvgr1.
        WHEN 'KVGR2'. APPEND CORRESPONDING #( ls_line ) TO mr_kvgr2.
        WHEN 'ZONE1' OR 'ZONE2'.
          " Provisioned, not yet mapped to a source field - Q8 (A06)
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    " Customer numbers are stored with leading zeros in KNA1 / VBRK
    LOOP AT mr_kunnr ASSIGNING FIELD-SYMBOL(<ls_kun>).
      <ls_kun>-low  = |{ <ls_kun>-low  ALPHA = IN }|.
      <ls_kun>-high = |{ <ls_kun>-high ALPHA = IN }|.
    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Business volume base (A15 - A20)
*&---------------------------------------------------------------------*
  METHOD read_billing.

    " Billing types that count, from configuration - never hardcoded (A17)
    SELECT fkart, vz_sign FROM zsdt_schm_fka
      INTO TABLE @DATA(lt_fka)
      WHERE vkorg = @ms_hdr-vkorg.

    IF lt_fka IS INITIAL.
      RETURN.
    ENDIF.

    DATA lr_fkart TYPE RANGE OF fkart.
    lr_fkart = VALUE #( FOR ls IN lt_fka ( sign = 'I' option = 'EQ' low = ls-fkart ) ).

    SELECT k~vbeln, p~posnr, k~fkdat, k~fkart, k~kunag, k~vtweg, k~waerk,
           p~matnr, p~spart, p~werks, p~wkreg,
           p~mvgr1, p~mvgr2, p~mvgr3, p~mvgr4, p~mvgr5,
           p~kvgr1, p~kvgr2, p~netwr, p~fkimg, p~meins, p~vrkme
      FROM vbrk AS k
      INNER JOIN vbrp AS p ON p~vbeln = k~vbeln
      INTO CORRESPONDING FIELDS OF TABLE @rt_bill
      WHERE k~fkdat BETWEEN @iv_from AND @iv_to
        AND k~vkorg  = @ms_hdr-vkorg
        AND k~vtweg  = @ms_hdr-vtweg
        AND k~fksto  = @space              "cancelled excluded          (A16)
        AND k~rfbsk  = 'C'                 "posted to accounting        (A16)
        AND k~fkart IN @lr_fkart           "configured billing types    (A17)
        AND k~kunag IN @mr_kunnr
        AND p~spart  = @ms_hdr-spart
        AND p~wkreg IN @mr_regio
        AND p~mvgr1 IN @mr_mvgr1
        AND p~mvgr2 IN @mr_mvgr2
        AND p~mvgr3 IN @mr_mvgr3
        AND p~mvgr4 IN @mr_mvgr4
        AND p~mvgr5 IN @mr_mvgr5
        AND p~kvgr1 IN @mr_kvgr1
        AND p~kvgr2 IN @mr_kvgr2.

    " Returns and credit memos net off (A17)
    LOOP AT rt_bill ASSIGNING FIELD-SYMBOL(<ls_bill>).
      READ TABLE lt_fka INTO DATA(ls_fka) WITH KEY fkart = <ls_bill>-fkart.
      IF sy-subrc = 0 AND ls_fka-vz_sign = '-'.
        <ls_bill>-netwr = <ls_bill>-netwr * -1.
        <ls_bill>-fkimg = <ls_bill>-fkimg * -1.
      ENDIF.

      " Quantity in base unit of measure (A11)
      IF <ls_bill>-vrkme <> <ls_bill>-meins AND <ls_bill>-fkimg <> 0.
        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING  i_matnr              = <ls_bill>-matnr
                     i_in_me              = <ls_bill>-vrkme
                     i_out_me             = <ls_bill>-meins
                     i_menge              = <ls_bill>-fkimg
          IMPORTING  e_menge              = <ls_bill>-fkimg
          EXCEPTIONS error_in_application = 1
                     error                = 2
                     OTHERS               = 3.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Customer attributes. The ZZ1_* extension fields are read dynamically
*& so that a missing field degrades to blank instead of a syntax error (Q2).
*&---------------------------------------------------------------------*
  METHOD read_customers.

    CLEAR mt_cust.

    DATA(lt_kunnr) = VALUE tt_kunnr( FOR ls IN it_bill ( ls-kunag ) ).
    SORT lt_kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_kunnr.
    CHECK lt_kunnr IS NOT INITIAL.

    SELECT * FROM kna1 INTO TABLE @DATA(lt_kna1)
      FOR ALL ENTRIES IN @lt_kunnr
      WHERE kunnr = @lt_kunnr-table_line.

    LOOP AT lt_kna1 ASSIGNING FIELD-SYMBOL(<ls_kna1>).

      DATA(ls_cust) = VALUE ty_cust( kunnr = <ls_kna1>-kunnr
                                     name1 = <ls_kna1>-name1 ).

      ASSIGN COMPONENT 'ZZ1_SP_CODE_CUS' OF STRUCTURE <ls_kna1> TO FIELD-SYMBOL(<lv_par>).
      IF sy-subrc = 0 AND <lv_par> IS NOT INITIAL.
        ls_cust-parent = |{ <lv_par> ALPHA = IN }|.
      ENDIF.

      ASSIGN COMPONENT 'ZZ1_LOC1_CUS' OF STRUCTURE <ls_kna1> TO FIELD-SYMBOL(<lv_l1>).
      IF sy-subrc = 0. ls_cust-loc1 = <lv_l1>. ENDIF.

      ASSIGN COMPONENT 'ZZ1_LOC2_CUS' OF STRUCTURE <ls_kna1> TO FIELD-SYMBOL(<lv_l2>).
      IF sy-subrc = 0. ls_cust-loc2 = <lv_l2>. ENDIF.

      " Where the customer has no parent it is its own settlement partner
      IF ls_cust-parent IS INITIAL.
        ls_cust-parent = ls_cust-kunnr.
      ENDIF.

      INSERT ls_cust INTO TABLE mt_cust.

    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& One settlement period: aggregate, test the target, compute the CN.
*&---------------------------------------------------------------------*
  METHOD settle_period.

    TYPES: BEGIN OF ty_agg,
             kunnr TYPE kunnr,
             vol   TYPE netwr,
             qty   TYPE fkimg,
             waerk TYPE waerk,
           END OF ty_agg.

    DATA: lt_agg    TYPE SORTED TABLE OF ty_agg WITH UNIQUE KEY kunnr,
          lt_agg_eb TYPE SORTED TABLE OF ty_agg WITH UNIQUE KEY kunnr.

    LOOP AT it_bill INTO DATA(ls_bill) WHERE fkdat >= is_per-per_from
                                         AND fkdat <= is_per-per_to.

      " Settlement partner: parent where parent/child aggregation is on (A07)
      DATA(lv_part) = ls_bill-kunag.
      IF ms_hdr-par_child = abap_true.
        READ TABLE mt_cust INTO DATA(ls_c) WITH TABLE KEY kunnr = ls_bill-kunag.
        IF sy-subrc = 0.
          lv_part = ls_c-parent.
        ENDIF.
      ENDIF.

      READ TABLE lt_agg ASSIGNING FIELD-SYMBOL(<ls_agg>) WITH TABLE KEY kunnr = lv_part.
      IF sy-subrc <> 0.
        INSERT VALUE #( kunnr = lv_part waerk = ls_bill-waerk )
          INTO TABLE lt_agg ASSIGNING <ls_agg>.
      ENDIF.
      <ls_agg>-vol = <ls_agg>-vol + ls_bill-netwr.
      <ls_agg>-qty = <ls_agg>-qty + ls_bill-fkimg.

      " Early bird window is a sub-window of the same period (A22)
      IF ms_hdr-early_bird = abap_true
      AND ls_bill-fkdat >= ms_hdr-eb_date_fr
      AND ls_bill-fkdat <= ms_hdr-eb_date_to.
        READ TABLE lt_agg_eb ASSIGNING FIELD-SYMBOL(<ls_eb>) WITH TABLE KEY kunnr = lv_part.
        IF sy-subrc <> 0.
          INSERT VALUE #( kunnr = lv_part waerk = ls_bill-waerk )
            INTO TABLE lt_agg_eb ASSIGNING <ls_eb>.
        ENDIF.
        <ls_eb>-vol = <ls_eb>-vol + ls_bill-netwr.
        <ls_eb>-qty = <ls_eb>-qty + ls_bill-fkimg.
      ENDIF.

    ENDLOOP.

    LOOP AT lt_agg INTO DATA(ls_agg).

      DATA(ls_res) = VALUE zsds_schm_res( ).
      MOVE-CORRESPONDING ms_hdr TO ls_res.
      ls_res-period_seq = is_per-period_seq.
      ls_res-per_from   = is_per-per_from.
      ls_res-per_to     = is_per-per_to.
      ls_res-kunnr      = ls_agg-kunnr.
      ls_res-bus_vol    = ls_agg-vol.
      ls_res-bus_qty    = ls_agg-qty.
      ls_res-waers      = COND #( WHEN ls_agg-waerk IS NOT INITIAL
                                  THEN ls_agg-waerk ELSE ms_hdr-waers ).

      READ TABLE mt_cust INTO DATA(ls_cust) WITH TABLE KEY kunnr = ls_agg-kunnr.
      IF sy-subrc = 0.
        ls_res-name1 = ls_cust-name1.
        ls_res-loc1  = ls_cust-loc1.
        ls_res-loc2  = ls_cust-loc2.
      ENDIF.

      "--- target achievement (A09 - A13) --------------------------------
      DATA(lv_met) = abap_false.
      CASE ms_hdr-scheme_cat.
        WHEN zcl_sd_scheme=>gc_category-value.
          lv_met = xsdbool( ls_agg-vol >= ms_hdr-target_val ).
        WHEN zcl_sd_scheme=>gc_category-quantity.
          lv_met = xsdbool( ls_agg-qty >= ms_hdr-target_qty ).
        WHEN zcl_sd_scheme=>gc_category-ratio.
          lv_met = is_ratio_met( it_bill = it_bill iv_kunnr = ls_agg-kunnr ).
        WHEN zcl_sd_scheme=>gc_category-val_ratio.
          lv_met = xsdbool( ls_agg-vol >= ms_hdr-target_val
                        AND is_ratio_met( it_bill = it_bill
                                          iv_kunnr = ls_agg-kunnr ) = abap_true ).
      ENDCASE.
      ls_res-target_met = lv_met.

      "--- main credit note (A21) ---------------------------------------
      IF lv_met = abap_true.
        ls_res-main_cn = ls_agg-vol * ms_hdr-scheme_pct / 100.
      ENDIF.

      "--- early bird (A22, A23) ----------------------------------------
      IF ms_hdr-early_bird = abap_true.
        READ TABLE lt_agg_eb INTO DATA(ls_eb) WITH TABLE KEY kunnr = ls_agg-kunnr.
        IF sy-subrc = 0.
          DATA(lv_eb_target) = ms_hdr-eb_target.
          IF ms_hdr-eb_tgt_typ = 'P'.
            " percentage of the main target (A23)
            lv_eb_target = ms_hdr-target_val * ms_hdr-eb_target / 100.
          ENDIF.
          IF ls_eb-vol >= lv_eb_target.
            ls_res-eb_amount = ls_eb-vol * ms_hdr-eb_pct / 100.
          ENDIF.
        ENDIF.
      ENDIF.

      "--- cascading (A24) ----------------------------------------------
      IF ms_hdr-cascading = abap_true.
        ls_res-casc_val = calc_cascading( iv_kunnr = ls_agg-kunnr
                                          is_per   = is_per ).
      ENDIF.

      "--- final CN value (A25) -----------------------------------------
      " NOTE: the FS reads "Business volume + Early bird - Cascading".
      " Taken literally that credits the gross sales value. The scheme
      " amount is used instead - open under Q4.
      ls_res-cn_value = ls_res-main_cn + ls_res-eb_amount - ls_res-casc_val.

      IF ls_res-cn_value <= 0.
        ls_res-cn_value = 0.
        ls_res-status   = 'X'.                            "nothing payable (A27)
      ELSE.
        ls_res-status   = 'O'.
      ENDIF.

      " Carry forward anything already settled so the ALV shows the truth
      " and posting can never repeat itself (A31)
      SELECT SINGLE cn_order, cn_invoice, status, message
        FROM zsdt_schm_setl
        INTO ( @ls_res-cn_order, @ls_res-cn_invoice,
               @DATA(lv_status), @ls_res-message )
        WHERE scheme_no  = @ms_hdr-scheme_no
          AND period_seq = @is_per-period_seq
          AND kunnr      = @ls_agg-kunnr.
      IF sy-subrc = 0 AND lv_status CA 'PB'.
        ls_res-status = lv_status.
      ENDIF.

      ls_res-light = SWITCH #( ls_res-status
                               WHEN 'P' OR 'B' THEN '3'
                               WHEN 'E'        THEN '1'
                               ELSE                 '2' ).

      APPEND ls_res TO ct_res.

    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Ratio based achievement (A12): every product line must independently
*& reach its own share of the target.
*&---------------------------------------------------------------------*
  METHOD is_ratio_met.

    SELECT matnr, ratio_pct FROM zsdt_schm_rat
      INTO TABLE @DATA(lt_rat)
      WHERE scheme_no = @ms_hdr-scheme_no.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_ok = abap_true.

    LOOP AT lt_rat INTO DATA(ls_rat).

      DATA(lv_vol) = REDUCE netwr(
        INIT v = CONV netwr( 0 )
        FOR ls IN it_bill WHERE ( matnr = ls_rat-matnr AND kunag = iv_kunnr )
        NEXT v = v + ls-netwr ).

      DATA(lv_target) = ms_hdr-target_val * ls_rat-ratio_pct / 100.

      IF lv_vol < lv_target.
        rv_ok = abap_false.
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Cascading (A24). Sum of credit notes already posted for this customer
*& under OTHER schemes whose period overlaps this one.
*&
*& Q5 OPEN: the exact scope is not defined in the FS. The rule applied
*& here is - same customer, same sales area, overlapping period, any other
*& scheme, posted or billed only. This is the ONLY place the rule lives;
*& when Q5 is answered, this method is the single point of change.
*&---------------------------------------------------------------------*
  METHOD calc_cascading.

    SELECT SUM( s~cn_value )
      FROM zsdt_schm_setl AS s
      INNER JOIN zsdt_schm_hdr AS h ON h~scheme_no = s~scheme_no
      INTO @rv_value
      WHERE s~kunnr      = @iv_kunnr
        AND s~scheme_no <> @ms_hdr-scheme_no
        AND s~status     IN ( 'P', 'B' )
        AND s~per_from  <= @is_per-per_to
        AND s~per_to    >= @is_per-per_from
        AND h~vkorg      = @ms_hdr-vkorg
        AND h~vtweg      = @ms_hdr-vtweg
        AND h~spart      = @ms_hdr-spart
        AND h~del_ind    = @space.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Posting (A28 - A32). Order of work per line:
*&   1. re-check that it is not already posted   (idempotency, A31)
*&   2. credit memo request
*&   3. credit memo
*&   4. settlement log
*& Each line commits on its own, so one failure never rolls back the rest.
*&---------------------------------------------------------------------*
  METHOD post.

    DATA: lv_posted TYPE i,
          lv_error  TYPE i.

    LOOP AT ct_res ASSIGNING FIELD-SYMBOL(<ls_res>) WHERE mark = abap_true.

      IF <ls_res>-status CA 'PB'.
        add_msg( EXPORTING iv_type = 'W' iv_number = 027
                           iv_v1 = <ls_res>-scheme_no
                           iv_v2 = <ls_res>-kunnr
                           iv_v3 = <ls_res>-period_seq
                 CHANGING  ct_msg = rt_msg ).
        CONTINUE.
      ENDIF.

      IF <ls_res>-cn_value <= 0.
        CONTINUE.                                                     "(A27)
      ENDIF.

      IF check_post_authority( <ls_res>-vkorg ) = abap_false.
        add_msg( EXPORTING iv_number = 028 CHANGING ct_msg = rt_msg ).
        <ls_res>-status = 'E'.
        lv_error = lv_error + 1.
        CONTINUE.
      ENDIF.

      IF read_config( <ls_res>-vkorg ) = abap_false.
        add_msg( EXPORTING iv_number = 023 iv_v1 = <ls_res>-vkorg
                 CHANGING  ct_msg = rt_msg ).
        <ls_res>-status = 'E'.
        lv_error = lv_error + 1.
        CONTINUE.
      ENDIF.

      " Belt and braces against a parallel run: lock the scheme line
      CALL FUNCTION 'ENQUEUE_EZSDT_SCHM_HDR'
        EXPORTING  scheme_no    = <ls_res>-scheme_no
        EXCEPTIONS foreign_lock = 1 OTHERS = 2.
      IF sy-subrc <> 0.
        <ls_res>-status  = 'E'.
        <ls_res>-message = |Scheme { <ls_res>-scheme_no } is locked|.
        lv_error = lv_error + 1.
        CONTINUE.
      ENDIF.

      IF iv_test = abap_true.
        <ls_res>-message = 'Test run - no document created'.
        CALL FUNCTION 'DEQUEUE_EZSDT_SCHM_HDR'
          EXPORTING scheme_no = <ls_res>-scheme_no.
        CONTINUE.
      ENDIF.

      "--- credit memo request ------------------------------------------
      DATA lv_order TYPE vbeln_va.
      DATA(lt_m1) = create_credit_memo_req( EXPORTING is_res   = <ls_res>
                                            IMPORTING ev_vbeln = lv_order ).
      APPEND LINES OF lt_m1 TO rt_msg.

      IF lv_order IS INITIAL.
        <ls_res>-status  = 'E'.
        <ls_res>-message = VALUE #( lt_m1[ type = 'E' ]-message OPTIONAL ).
        lv_error = lv_error + 1.
        MODIFY zsdt_schm_setl FROM @( CORRESPONDING zsdt_schm_setl( <ls_res> ) ).
        COMMIT WORK AND WAIT.
        CALL FUNCTION 'DEQUEUE_EZSDT_SCHM_HDR'
          EXPORTING scheme_no = <ls_res>-scheme_no.
        CONTINUE.
      ENDIF.

      <ls_res>-cn_order = lv_order.
      <ls_res>-status   = 'P'.

      "--- credit memo ---------------------------------------------------
      DATA lv_invoice TYPE vbeln_vf.
      DATA(lt_m2) = create_credit_memo( EXPORTING iv_order = lv_order
                                        IMPORTING ev_vbeln = lv_invoice ).
      APPEND LINES OF lt_m2 TO rt_msg.

      IF lv_invoice IS NOT INITIAL.
        <ls_res>-cn_invoice = lv_invoice.
        <ls_res>-status     = 'B'.
        add_msg( EXPORTING iv_type = 'S' iv_number = 026
                           iv_v1 = lv_order iv_v2 = lv_invoice
                 CHANGING  ct_msg = rt_msg ).
      ELSE.
        " Request created but not billed - keep status P so the next run
        " picks up the billing without creating a second request (A31)
        <ls_res>-message = VALUE #( lt_m2[ type = 'E' ]-message OPTIONAL ).
      ENDIF.

      "--- settlement log ------------------------------------------------
      DATA(ls_setl) = CORRESPONDING zsdt_schm_setl( <ls_res> ).
      ls_setl-post_date = sy-datum.
      ls_setl-post_time = sy-uzeit.
      ls_setl-post_user = sy-uname.
      MODIFY zsdt_schm_setl FROM @ls_setl.

      " Scheme moves to partially settled (A33)
      UPDATE zsdt_schm_hdr SET status = @zcl_sd_scheme=>gc_status-part_setl
        WHERE scheme_no = @<ls_res>-scheme_no
          AND status    = @zcl_sd_scheme=>gc_status-released.

      COMMIT WORK AND WAIT.
      lv_posted = lv_posted + 1.

      CALL FUNCTION 'DEQUEUE_EZSDT_SCHM_HDR'
        EXPORTING scheme_no = <ls_res>-scheme_no.

      <ls_res>-light = COND #( WHEN <ls_res>-status = 'E' THEN '1' ELSE '3' ).
      CLEAR <ls_res>-mark.

    ENDLOOP.

    add_msg( EXPORTING iv_type = 'S' iv_number = 032
                       iv_v1 = lv_posted iv_v2 = lv_error
             CHANGING  ct_msg = rt_msg ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Credit memo request (A29, A30). BAPI_SALESORDER_CREATEFROMDAT2 is a
*& released BAPI; the FS named SD_SALESDOCUMENT_CREATE which is not
*& released for customer use. Functionally identical.
*&---------------------------------------------------------------------*
  METHOD create_credit_memo_req.

    DATA: ls_header  TYPE bapisdhd1,
          lt_item    TYPE STANDARD TABLE OF bapisditm,
          lt_itemx   TYPE STANDARD TABLE OF bapisditmx,
          lt_partner TYPE STANDARD TABLE OF bapiparnr,
          lt_cond    TYPE STANDARD TABLE OF bapicond,
          lt_return  TYPE STANDARD TABLE OF bapiret2.

    ls_header = VALUE #( doc_type   = ms_cfg-auart
                         sales_org  = is_res-vkorg
                         distr_chan = is_res-vtweg
                         division   = is_res-spart
                         purch_no_c = is_res-scheme_no
                         doc_date   = sy-datum
                         currency   = is_res-waers ).

    APPEND VALUE bapiparnr( partn_role = 'AG'
                            partn_numb = is_res-kunnr ) TO lt_partner.

    APPEND VALUE bapisditm( itm_number = '000010'
                            material   = ms_cfg-matnr
                            target_qty = 1000                "1,000 = qty 1
                            plant      = space ) TO lt_item.

    APPEND VALUE bapisditmx( itm_number = '000010'
                             updateflag = 'I'
                             material   = abap_true
                             target_qty = abap_true ) TO lt_itemx.

    " Settlement value carried in the manual condition from config (A29)
    APPEND VALUE bapicond( itm_number = '000010'
                           cond_type  = ms_cfg-kschl
                           cond_value = is_res-cn_value
                           currency   = is_res-waers
                           cond_p_unt = 1 ) TO lt_cond.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING order_header_in  = ls_header
      IMPORTING salesdocument    = ev_vbeln
      TABLES    return           = lt_return
                order_items_in   = lt_item
                order_items_inx  = lt_itemx
                order_partners   = lt_partner
                order_conditions_in = lt_cond.

    APPEND LINES OF lt_return TO rt_msg.

    IF ev_vbeln IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      add_msg( EXPORTING iv_number = 024
                         iv_v1 = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL )
               CHANGING  ct_msg = rt_msg ).
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = abap_true.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Credit memo (A30). BAPI_BILLINGDOC_CREATEMULTIPLE replaces the FS's
*& RV_INVOICE_CREATE, which is an internal module.
*&---------------------------------------------------------------------*
  METHOD create_credit_memo.

    DATA: lt_billdata TYPE STANDARD TABLE OF bapivbrk,
          lt_success  TYPE STANDARD TABLE OF bapivbrksuccess,
          lt_return   TYPE STANDARD TABLE OF bapiret1.

    APPEND VALUE bapivbrk( ref_doc    = iv_order
                           ref_doc_ca = 'C'                "order related
                           doc_type   = ms_cfg-auart
                           ordbilltyp = ms_cfg-fkart
                           bill_date  = sy-datum ) TO lt_billdata.

    CALL FUNCTION 'BAPI_BILLINGDOC_CREATEMULTIPLE'
      EXPORTING  creatorde  = sy-uname
      TABLES     billingdatain = lt_billdata
                 return        = lt_return
                 success       = lt_success.

    LOOP AT lt_return INTO DATA(ls_ret).
      APPEND CORRESPONDING bapiret2( ls_ret ) TO rt_msg.
    ENDLOOP.

    READ TABLE lt_success INTO DATA(ls_succ) INDEX 1.
    IF sy-subrc = 0 AND ls_succ-bill_doc IS NOT INITIAL.
      ev_vbeln = ls_succ-bill_doc.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = abap_true.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      add_msg( EXPORTING iv_number = 025 iv_v1 = iv_order
                         iv_v2 = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL )
               CHANGING  ct_msg = rt_msg ).
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD read_config.

    IF ms_cfg-vkorg = iv_vkorg.
      rv_ok = abap_true.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM zsdt_schm_cfg INTO @ms_cfg
      WHERE vkorg = @iv_vkorg.

    rv_ok = xsdbool( sy-subrc = 0 AND ms_cfg-auart IS NOT INITIAL
                                  AND ms_cfg-fkart IS NOT INITIAL
                                  AND ms_cfg-matnr IS NOT INITIAL ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD check_post_authority.

    rv_ok = abap_true.

    AUTHORITY-CHECK OBJECT gc_auth
      ID 'VKORG' FIELD iv_vkorg
      ID 'ACTVT' FIELD '16'.

    IF sy-subrc <> 0.
      rv_ok = abap_false.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD add_msg.

    DATA(ls_msg) = VALUE bapiret2( id = gc_msgid type = iv_type number = iv_number
                                   message_v1 = iv_v1 message_v2 = iv_v2
                                   message_v3 = iv_v3 ).

    MESSAGE ID ls_msg-id TYPE 'S' NUMBER ls_msg-number
      WITH iv_v1 iv_v2 iv_v3 INTO ls_msg-message.

    APPEND ls_msg TO ct_msg.

  ENDMETHOD.

ENDCLASS.
