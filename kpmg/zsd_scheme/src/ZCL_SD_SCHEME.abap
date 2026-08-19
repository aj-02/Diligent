*&---------------------------------------------------------------------*
*& Class         ZCL_SD_SCHEME
*& Package       ZSD_SCHEME
*& Description   Scheme (Pipes) - model class.
*&               Read / validate / save / release / delete of a scheme.
*&               Used by SAPMZSD_SCHEME and by ZSD_SCHEME_UPLOAD so that
*&               the online transaction and the mass upload can never
*&               diverge in their validations (A39).
*&
*& Created by    Arnav Johri
*& Reference     FS "Scheme - Pipes" V.01 10.08.2026, assumptions A01-A42
*&---------------------------------------------------------------------*
CLASS zcl_sd_scheme DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: tt_rng TYPE STANDARD TABLE OF zsdt_schm_rng WITH DEFAULT KEY,
           tt_rat TYPE STANDARD TABLE OF zsdt_schm_rat WITH DEFAULT KEY,
           tt_per TYPE STANDARD TABLE OF zsds_schm_per WITH DEFAULT KEY.

    CONSTANTS:
      "! Processing mode
      BEGIN OF gc_mode,
        create  TYPE char1 VALUE 'H',
        change  TYPE char1 VALUE 'V',
        display TYPE char1 VALUE 'A',
      END OF gc_mode,

      "! Scheme status (A33)
      BEGIN OF gc_status,
        new       TYPE zde_schm_stat VALUE 'N',
        released  TYPE zde_schm_stat VALUE 'R',
        part_setl TYPE zde_schm_stat VALUE 'P',
        closed    TYPE zde_schm_stat VALUE 'C',
      END OF gc_status,

      "! Scheme category
      BEGIN OF gc_category,
        value     TYPE zde_schm_cat VALUE 'V',
        quantity  TYPE zde_schm_cat VALUE 'Q',
        ratio     TYPE zde_schm_cat VALUE 'R',
        val_ratio TYPE zde_schm_cat VALUE 'B',
      END OF gc_category,

      "! Scheme type = settlement periodicity (A02)
      BEGIN OF gc_type,
        daily     TYPE zde_schm_type VALUE 'D',
        monthly   TYPE zde_schm_type VALUE 'M',
        quarterly TYPE zde_schm_type VALUE 'Q',
        half_year TYPE zde_schm_type VALUE 'H',
        yearly    TYPE zde_schm_type VALUE 'Y',
      END OF gc_type,

      gc_msgid TYPE symsgid VALUE 'ZSD_SCHEME',
      gc_auth  TYPE xuobject VALUE 'ZSD_SCHM'.

    METHODS constructor
      IMPORTING iv_mode TYPE char1 DEFAULT gc_mode-display.

    "! Build a new scheme from the initial screen values.
    METHODS create_new
      IMPORTING is_ini        TYPE zsds_schm_ini
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    "! Read an existing scheme including ranges and ratio lines.
    METHODS read
      IMPORTING iv_scheme_no  TYPE zde_schm_no
                iv_lock       TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    METHODS get_header RETURNING VALUE(rs_hdr) TYPE zsdt_schm_hdr.
    METHODS get_ranges RETURNING VALUE(rt_rng) TYPE tt_rng.
    METHODS get_ratio  RETURNING VALUE(rt_rat) TYPE tt_rat.

    METHODS set_header IMPORTING is_hdr TYPE zsdt_schm_hdr.
    METHODS set_ranges IMPORTING it_rng TYPE tt_rng.
    METHODS set_ratio  IMPORTING it_rat TYPE tt_rat.

    "! Full validation. Called by the transaction and by the upload (A39).
    METHODS validate
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    "! Validate, assign the number on first save, write change documents
    "! and commit. Does nothing when iv_test = abap_true.
    METHODS save
      IMPORTING iv_test       TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    METHODS release
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    "! Physical delete while status = New, deletion indicator afterwards (A35).
    METHODS delete
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    METHODS dequeue.

    "! Change is blocked once anything has been settled (A34).
    METHODS is_change_allowed
      RETURNING VALUE(rv_allowed) TYPE abap_bool.

    "! Slice the validity into settlement periods according to the
    "! scheme type (A02). Also used by ZCL_SD_SCHEME_SETTLE.
    CLASS-METHODS get_periods
      IMPORTING iv_type       TYPE zde_schm_type
                iv_from       TYPE dats
                iv_to         TYPE dats
      RETURNING VALUE(rt_per) TYPE tt_per.

    CLASS-METHODS check_authority
      IMPORTING iv_vkorg      TYPE vkorg
                iv_vtweg      TYPE vtweg
                iv_spart      TYPE spart
                iv_actvt      TYPE activ_auth
      RETURNING VALUE(rv_ok)  TYPE abap_bool.

  PRIVATE SECTION.

    DATA: ms_hdr     TYPE zsdt_schm_hdr,
          ms_hdr_old TYPE zsdt_schm_hdr,
          mt_rng     TYPE tt_rng,
          mt_rng_old TYPE tt_rng,
          mt_rat     TYPE tt_rat,
          mt_rat_old TYPE tt_rat,
          mv_mode    TYPE char1,
          mv_new     TYPE abap_bool,
          mv_locked  TYPE abap_bool.

    METHODS enqueue
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    METHODS number_get
      RETURNING VALUE(rv_no) TYPE zde_schm_no.

    METHODS write_change_document.

    METHODS add_msg
      IMPORTING iv_type   TYPE bapi_mtype DEFAULT 'E'
                iv_number TYPE symsgno
                iv_v1     TYPE any OPTIONAL
                iv_v2     TYPE any OPTIONAL
                iv_v3     TYPE any OPTIONAL
      CHANGING  ct_msg    TYPE bapiret2_t.

    METHODS validate_header CHANGING ct_msg TYPE bapiret2_t.
    METHODS validate_ranges CHANGING ct_msg TYPE bapiret2_t.
    METHODS validate_ratio  CHANGING ct_msg TYPE bapiret2_t.

ENDCLASS.


CLASS zcl_sd_scheme IMPLEMENTATION.

*&---------------------------------------------------------------------*
  METHOD constructor.
    mv_mode = iv_mode.
  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Create a new scheme from the initial screen. The organisational data
*& and the scheme definition become part of the key and are frozen (A04).
*&---------------------------------------------------------------------*
  METHOD create_new.

    CLEAR: ms_hdr, mt_rng, mt_rat.

    IF check_authority( iv_vkorg = is_ini-vkorg
                        iv_vtweg = is_ini-vtweg
                        iv_spart = is_ini-spart
                        iv_actvt = '01' ) = abap_false.
      add_msg( EXPORTING iv_number = 016 iv_v1 = is_ini-vkorg iv_v2 = '01'
               CHANGING  ct_msg    = rt_msg ).
      RETURN.
    ENDIF.

    ms_hdr = VALUE #( scheme_type = is_ini-scheme_type
                      vkorg       = is_ini-vkorg
                      vtweg       = is_ini-vtweg
                      spart       = is_ini-spart
                      scheme_cat  = is_ini-scheme_cat
                      valid_from  = is_ini-valid_from
                      valid_to    = is_ini-valid_to
                      early_bird  = is_ini-early_bird
                      cascading   = is_ini-cascading
                      status      = gc_status-new
                      ernam       = sy-uname
                      erdat       = sy-datum
                      erzet       = sy-uzeit ).

    " Currency defaulted from the sales organisation (A14)
    SELECT SINGLE waers FROM tvko INTO @ms_hdr-waers
      WHERE vkorg = @ms_hdr-vkorg.

    mv_new    = abap_true.
    mv_mode   = gc_mode-create.
    ms_hdr_old = ms_hdr.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD read.

    SELECT SINGLE * FROM zsdt_schm_hdr INTO @ms_hdr
      WHERE scheme_no = @iv_scheme_no.

    IF sy-subrc <> 0.
      add_msg( EXPORTING iv_number = 001 iv_v1 = iv_scheme_no
               CHANGING  ct_msg    = rt_msg ).
      RETURN.
    ENDIF.

    DATA(lv_actvt) = COND activ_auth( WHEN mv_mode = gc_mode-display THEN '03' ELSE '02' ).
    IF check_authority( iv_vkorg = ms_hdr-vkorg
                        iv_vtweg = ms_hdr-vtweg
                        iv_spart = ms_hdr-spart
                        iv_actvt = lv_actvt ) = abap_false.
      add_msg( EXPORTING iv_number = 016 iv_v1 = ms_hdr-vkorg iv_v2 = lv_actvt
               CHANGING  ct_msg    = rt_msg ).
      CLEAR ms_hdr.
      RETURN.
    ENDIF.

    SELECT * FROM zsdt_schm_rng INTO TABLE @mt_rng
      WHERE scheme_no = @iv_scheme_no
      ORDER BY fieldname, seqnr.

    SELECT * FROM zsdt_schm_rat INTO TABLE @mt_rat
      WHERE scheme_no = @iv_scheme_no
      ORDER BY seqnr.

    IF iv_lock = abap_true.
      rt_msg = enqueue( ).
      IF line_exists( rt_msg[ type = 'E' ] ).
        RETURN.
      ENDIF.
    ENDIF.

    mv_new     = abap_false.
    ms_hdr_old = ms_hdr.
    mt_rng_old = mt_rng.
    mt_rat_old = mt_rat.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD get_header. rs_hdr = ms_hdr. ENDMETHOD.
  METHOD get_ranges. rt_rng = mt_rng. ENDMETHOD.
  METHOD get_ratio.  rt_rat = mt_rat. ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD set_header.
    " The key attributes from the initial screen can never be overwritten (A04)
    DATA(ls_new) = is_hdr.
    ls_new-scheme_no   = ms_hdr-scheme_no.
    ls_new-vkorg       = ms_hdr-vkorg.
    ls_new-vtweg       = ms_hdr-vtweg.
    ls_new-spart       = ms_hdr-spart.
    ls_new-scheme_type = ms_hdr-scheme_type.
    ls_new-scheme_cat  = ms_hdr-scheme_cat.
    ls_new-valid_from  = ms_hdr-valid_from.
    ls_new-valid_to    = ms_hdr-valid_to.
    ls_new-status      = ms_hdr-status.
    ls_new-ernam       = ms_hdr-ernam.
    ls_new-erdat       = ms_hdr-erdat.
    ls_new-erzet       = ms_hdr-erzet.
    ms_hdr = ls_new.
  ENDMETHOD.

  METHOD set_ranges. mt_rng = it_rng. ENDMETHOD.
  METHOD set_ratio.  mt_rat = it_rat. ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD validate.
    validate_header( CHANGING ct_msg = rt_msg ).
    validate_ranges( CHANGING ct_msg = rt_msg ).
    validate_ratio(  CHANGING ct_msg = rt_msg ).
  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD validate_header.

    IF ms_hdr-descr IS INITIAL.
      add_msg( EXPORTING iv_number = 005 CHANGING ct_msg = ct_msg ).
    ENDIF.

    IF ms_hdr-valid_from IS INITIAL OR ms_hdr-valid_to IS INITIAL.
      add_msg( EXPORTING iv_number = 003 CHANGING ct_msg = ct_msg ).
    ELSEIF ms_hdr-valid_to < ms_hdr-valid_from.
      add_msg( EXPORTING iv_number = 004 CHANGING ct_msg = ct_msg ).
    ENDIF.
    " Retrospective schemes are permitted, so no check against sy-datum (A08)

    " Organisational data must be a valid sales area
    SELECT SINGLE @abap_true FROM tvta INTO @DATA(lv_ok)
      WHERE vkorg = @ms_hdr-vkorg
        AND vtweg = @ms_hdr-vtweg
        AND spart = @ms_hdr-spart.
    IF lv_ok <> abap_true.
      add_msg( EXPORTING iv_number = 015 iv_v1 = ms_hdr-vkorg
                         iv_v2 = ms_hdr-vtweg iv_v3 = ms_hdr-spart
               CHANGING  ct_msg = ct_msg ).
    ENDIF.

    " Target per category (A10 - A13)
    CASE ms_hdr-scheme_cat.
      WHEN gc_category-value OR gc_category-val_ratio.
        IF ms_hdr-target_val IS INITIAL.
          add_msg( EXPORTING iv_number = 006 CHANGING ct_msg = ct_msg ).
        ENDIF.
      WHEN gc_category-quantity.
        IF ms_hdr-target_qty IS INITIAL.
          add_msg( EXPORTING iv_number = 007 CHANGING ct_msg = ct_msg ).
        ENDIF.
      WHEN gc_category-ratio.
        IF ms_hdr-target_val IS INITIAL AND ms_hdr-target_qty IS INITIAL.
          add_msg( EXPORTING iv_number = 006 CHANGING ct_msg = ct_msg ).
        ENDIF.
    ENDCASE.

    IF ms_hdr-scheme_pct IS INITIAL.
      add_msg( EXPORTING iv_number = 008 CHANGING ct_msg = ct_msg ).
    ELSEIF ms_hdr-scheme_pct <= 0 OR ms_hdr-scheme_pct > 100.
      add_msg( EXPORTING iv_number = 009 CHANGING ct_msg = ct_msg ).
    ENDIF.

    " Early bird (A22, A23)
    IF ms_hdr-early_bird = abap_true.
      IF ms_hdr-eb_date_fr IS INITIAL OR ms_hdr-eb_date_to IS INITIAL
         OR ms_hdr-eb_date_fr < ms_hdr-valid_from
         OR ms_hdr-eb_date_to > ms_hdr-valid_to
         OR ms_hdr-eb_date_to < ms_hdr-eb_date_fr.
        add_msg( EXPORTING iv_number = 011 CHANGING ct_msg = ct_msg ).
      ENDIF.
      IF ms_hdr-eb_target IS INITIAL OR ms_hdr-eb_pct IS INITIAL.
        add_msg( EXPORTING iv_number = 012 CHANGING ct_msg = ct_msg ).
      ENDIF.
    ELSE.
      CLEAR: ms_hdr-eb_date_fr, ms_hdr-eb_date_to,
             ms_hdr-eb_tgt_typ, ms_hdr-eb_target, ms_hdr-eb_pct.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD validate_ranges.

    IF mt_rng IS INITIAL.
      add_msg( EXPORTING iv_number = 010 CHANGING ct_msg = ct_msg ).
      RETURN.
    ENDIF.

    LOOP AT mt_rng ASSIGNING FIELD-SYMBOL(<ls_rng>).

      IF <ls_rng>-sign NA 'IE' OR <ls_rng>-low IS INITIAL.
        add_msg( EXPORTING iv_number = 021 iv_v1 = <ls_rng>-low
                           iv_v2 = <ls_rng>-fieldname
                 CHANGING  ct_msg = ct_msg ).
        CONTINUE.
      ENDIF.

      IF <ls_rng>-opti IS INITIAL.
        <ls_rng>-opti = COND #( WHEN <ls_rng>-high IS NOT INITIAL THEN 'BT'
                                WHEN <ls_rng>-low CS '*'         THEN 'CP'
                                ELSE 'EQ' ).
      ENDIF.

      " "Select All" is stored as one CP * line and is not checked further (A05)
      IF <ls_rng>-opti = 'CP'.
        CONTINUE.
      ENDIF.

      CASE <ls_rng>-fieldname.
        WHEN 'KUNNR'.
          SELECT SINGLE @abap_true FROM knvv INTO @DATA(lv_cust)
            WHERE kunnr = @<ls_rng>-low
              AND vkorg = @ms_hdr-vkorg
              AND vtweg = @ms_hdr-vtweg
              AND spart = @ms_hdr-spart.
          IF lv_cust <> abap_true.
            add_msg( EXPORTING iv_number = 022 iv_v1 = <ls_rng>-low
                     CHANGING  ct_msg = ct_msg ).
          ENDIF.
        WHEN 'REGIO'.
          SELECT SINGLE @abap_true FROM t005s INTO @DATA(lv_reg)
            WHERE land1 = 'IN' AND bland = @<ls_rng>-low.
          IF lv_reg <> abap_true.
            add_msg( EXPORTING iv_number = 021 iv_v1 = <ls_rng>-low
                               iv_v2 = <ls_rng>-fieldname
                     CHANGING  ct_msg = ct_msg ).
          ENDIF.
        WHEN OTHERS.
          " MVGR1-5 / KVGR1-2 / ZONE1-2 are checked against their own check
          " tables through the ALV F4; no additional check needed here (Q8)
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD validate_ratio.

    IF ms_hdr-scheme_cat = gc_category-ratio
    OR ms_hdr-scheme_cat = gc_category-val_ratio.

      IF mt_rat IS INITIAL.
        add_msg( EXPORTING iv_number = 014 CHANGING ct_msg = ct_msg ).
        RETURN.
      ENDIF.

      DATA(lv_total) = REDUCE zde_schm_pct( INIT s = CONV zde_schm_pct( 0 )
                                            FOR ls IN mt_rat
                                            NEXT s = s + ls-ratio_pct ).
      IF lv_total <> 100.
        add_msg( EXPORTING iv_number = 013 iv_v1 = |{ lv_total }|
                 CHANGING  ct_msg = ct_msg ).
      ENDIF.

    ELSEIF mt_rat IS NOT INITIAL.
      add_msg( EXPORTING iv_number = 034 CHANGING ct_msg = ct_msg ).
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Save. Number is drawn only at the point of a successful save so that
*& an abandoned create does not consume a number (A01).
*&---------------------------------------------------------------------*
  METHOD save.

    rt_msg = validate( ).
    IF line_exists( rt_msg[ type = 'E' ] ) OR iv_test = abap_true.
      RETURN.
    ENDIF.

    IF mv_new = abap_false AND is_change_allowed( ) = abap_false.
      add_msg( EXPORTING iv_number = 017 iv_v1 = ms_hdr-scheme_no
               CHANGING  ct_msg = rt_msg ).
      RETURN.
    ENDIF.

    IF mv_new = abap_true.
      ms_hdr-scheme_no = number_get( ).
      IF ms_hdr-scheme_no IS INITIAL.
        RETURN.
      ENDIF.
      rt_msg = enqueue( ).
      IF line_exists( rt_msg[ type = 'E' ] ).
        RETURN.
      ENDIF.
    ENDIF.

    ms_hdr-aenam = sy-uname.
    ms_hdr-aedat = sy-datum.
    ms_hdr-aezet = sy-uzeit.

    LOOP AT mt_rng ASSIGNING FIELD-SYMBOL(<ls_rng>).
      <ls_rng>-scheme_no = ms_hdr-scheme_no.
      <ls_rng>-seqnr     = sy-tabix.
    ENDLOOP.

    LOOP AT mt_rat ASSIGNING FIELD-SYMBOL(<ls_rat>).
      <ls_rat>-scheme_no = ms_hdr-scheme_no.
      <ls_rat>-seqnr     = sy-tabix.
    ENDLOOP.

    MODIFY zsdt_schm_hdr FROM ms_hdr.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      add_msg( EXPORTING iv_number = 001 iv_v1 = ms_hdr-scheme_no
               CHANGING  ct_msg = rt_msg ).
      RETURN.
    ENDIF.

    " Ranges and ratio lines are always rewritten in full - this is what
    " gives the FS's "insert, change and delete" behaviour on the ALV.
    DELETE FROM zsdt_schm_rng WHERE scheme_no = @ms_hdr-scheme_no.
    IF mt_rng IS NOT INITIAL.
      INSERT zsdt_schm_rng FROM TABLE @mt_rng.
    ENDIF.

    DELETE FROM zsdt_schm_rat WHERE scheme_no = @ms_hdr-scheme_no.
    IF mt_rat IS NOT INITIAL.
      INSERT zsdt_schm_rat FROM TABLE @mt_rat.
    ENDIF.

    write_change_document( ).

    COMMIT WORK AND WAIT.

    mv_new     = abap_false.
    ms_hdr_old = ms_hdr.
    mt_rng_old = mt_rng.
    mt_rat_old = mt_rat.

    add_msg( EXPORTING iv_type = 'S' iv_number = 018 iv_v1 = ms_hdr-scheme_no
             CHANGING  ct_msg = rt_msg ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD release.

    IF ms_hdr-status <> gc_status-new.
      add_msg( EXPORTING iv_number = 017 iv_v1 = ms_hdr-scheme_no
               CHANGING  ct_msg = rt_msg ).
      RETURN.
    ENDIF.

    IF check_authority( iv_vkorg = ms_hdr-vkorg
                        iv_vtweg = ms_hdr-vtweg
                        iv_spart = ms_hdr-spart
                        iv_actvt = '43' ) = abap_false.
      add_msg( EXPORTING iv_number = 016 iv_v1 = ms_hdr-vkorg iv_v2 = '43'
               CHANGING  ct_msg = rt_msg ).
      RETURN.
    ENDIF.

    rt_msg = validate( ).
    IF line_exists( rt_msg[ type = 'E' ] ).
      RETURN.
    ENDIF.

    ms_hdr-status = gc_status-released.
    UPDATE zsdt_schm_hdr SET status = @ms_hdr-status,
                             aenam  = @sy-uname,
                             aedat  = @sy-datum,
                             aezet  = @sy-uzeit
      WHERE scheme_no = @ms_hdr-scheme_no.

    write_change_document( ).
    COMMIT WORK AND WAIT.

    ms_hdr_old = ms_hdr.
    add_msg( EXPORTING iv_type = 'S' iv_number = 019 iv_v1 = ms_hdr-scheme_no
             CHANGING  ct_msg = rt_msg ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Deletion. Physical only while the scheme is still New; once released
*& it is a deletion indicator and the record is retained (A35).
*&---------------------------------------------------------------------*
  METHOD delete.

    IF check_authority( iv_vkorg = ms_hdr-vkorg
                        iv_vtweg = ms_hdr-vtweg
                        iv_spart = ms_hdr-spart
                        iv_actvt = '06' ) = abap_false.
      add_msg( EXPORTING iv_number = 016 iv_v1 = ms_hdr-vkorg iv_v2 = '06'
               CHANGING  ct_msg = rt_msg ).
      RETURN.
    ENDIF.

    IF is_change_allowed( ) = abap_false.
      add_msg( EXPORTING iv_number = 017 iv_v1 = ms_hdr-scheme_no
               CHANGING  ct_msg = rt_msg ).
      RETURN.
    ENDIF.

    IF ms_hdr-status = gc_status-new.
      DELETE FROM zsdt_schm_hdr WHERE scheme_no = @ms_hdr-scheme_no.
      DELETE FROM zsdt_schm_rng WHERE scheme_no = @ms_hdr-scheme_no.
      DELETE FROM zsdt_schm_rat WHERE scheme_no = @ms_hdr-scheme_no.
    ELSE.
      ms_hdr-del_ind = abap_true.
      ms_hdr-status  = gc_status-closed.
      UPDATE zsdt_schm_hdr SET del_ind = @abap_true,
                               status  = @ms_hdr-status,
                               aenam   = @sy-uname,
                               aedat   = @sy-datum,
                               aezet   = @sy-uzeit
        WHERE scheme_no = @ms_hdr-scheme_no.
    ENDIF.

    write_change_document( ).
    COMMIT WORK AND WAIT.

    add_msg( EXPORTING iv_type = 'S' iv_number = 020 iv_v1 = ms_hdr-scheme_no
             CHANGING  ct_msg = rt_msg ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& A scheme with any posted settlement is frozen (A34).
*&---------------------------------------------------------------------*
  METHOD is_change_allowed.

    rv_allowed = abap_true.

    IF ms_hdr-del_ind = abap_true.
      rv_allowed = abap_false.
      RETURN.
    ENDIF.

    SELECT SINGLE @abap_true FROM zsdt_schm_setl INTO @DATA(lv_exists)
      WHERE scheme_no = @ms_hdr-scheme_no
        AND status    IN ( 'P', 'B' ).
    IF lv_exists = abap_true.
      rv_allowed = abap_false.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Settlement periods from the scheme type (A02). The first and last
*& period are clipped to the validity dates.
*&---------------------------------------------------------------------*
  METHOD get_periods.

    DATA: lv_from TYPE dats,
          lv_to   TYPE dats,
          lv_seq  TYPE numc3.

    IF iv_from IS INITIAL OR iv_to IS INITIAL OR iv_to < iv_from.
      RETURN.
    ENDIF.

    lv_from = iv_from.

    WHILE lv_from <= iv_to.

      CASE iv_type.
        WHEN gc_type-daily.
          lv_to = lv_from.

        WHEN gc_type-monthly.
          CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
            EXPORTING day_in            = lv_from
            IMPORTING last_day_of_month = lv_to
            EXCEPTIONS OTHERS           = 1.

        WHEN gc_type-quarterly.
          DATA(lv_qtr_end_month) = ( ( ( lv_from+4(2) - 1 ) DIV 3 ) + 1 ) * 3.
          lv_to = |{ lv_from(4) }{ lv_qtr_end_month WIDTH = 2 PAD = '0' }01|.
          CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
            EXPORTING day_in            = lv_to
            IMPORTING last_day_of_month = lv_to
            EXCEPTIONS OTHERS           = 1.

        WHEN gc_type-half_year.
          DATA(lv_hy_end_month) = COND i( WHEN lv_from+4(2) <= 6 THEN 6 ELSE 12 ).
          lv_to = |{ lv_from(4) }{ lv_hy_end_month WIDTH = 2 PAD = '0' }01|.
          CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
            EXPORTING day_in            = lv_to
            IMPORTING last_day_of_month = lv_to
            EXCEPTIONS OTHERS           = 1.

        WHEN gc_type-yearly.
          lv_to = |{ lv_from(4) }1231|.

        WHEN OTHERS.
          lv_to = iv_to.
      ENDCASE.

      IF lv_to > iv_to.
        lv_to = iv_to.
      ENDIF.

      lv_seq = lv_seq + 1.
      APPEND VALUE #( period_seq = lv_seq
                      per_from   = lv_from
                      per_to     = lv_to ) TO rt_per.

      lv_from = lv_to + 1.

    ENDWHILE.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD check_authority.

    rv_ok = abap_true.

    AUTHORITY-CHECK OBJECT gc_auth
      ID 'VKORG' FIELD iv_vkorg
      ID 'VTWEG' FIELD iv_vtweg
      ID 'SPART' FIELD iv_spart
      ID 'ACTVT' FIELD iv_actvt.

    IF sy-subrc <> 0.
      rv_ok = abap_false.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD enqueue.

    IF mv_locked = abap_true.
      RETURN.
    ENDIF.

    CALL FUNCTION 'ENQUEUE_EZSDT_SCHM_HDR'
      EXPORTING  scheme_no      = ms_hdr-scheme_no
                 _scope         = '2'
      EXCEPTIONS foreign_lock   = 1
                 system_failure = 2
                 OTHERS         = 3.

    IF sy-subrc <> 0.
      add_msg( EXPORTING iv_number = 002 iv_v1 = ms_hdr-scheme_no iv_v2 = sy-msgv1
               CHANGING  ct_msg = rt_msg ).
    ELSE.
      mv_locked = abap_true.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD dequeue.

    CHECK mv_locked = abap_true.

    CALL FUNCTION 'DEQUEUE_EZSDT_SCHM_HDR'
      EXPORTING scheme_no = ms_hdr-scheme_no
                _scope    = '3'.

    mv_locked = abap_false.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD number_get.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING  nr_range_nr             = '01'
                 object                  = 'ZSDSCHEME'
      IMPORTING  number                  = rv_no
      EXCEPTIONS interval_not_found      = 1
                 number_range_not_intern = 2
                 object_not_found        = 3
                 OTHERS                  = 4.

    IF sy-subrc <> 0.
      CLEAR rv_no.
    ELSE.
      rv_no = |{ rv_no ALPHA = IN }|.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Change documents for the audit trail (A36). Generated by SCDO for
*& change document object ZSDSCHEME.
*&---------------------------------------------------------------------*
  METHOD write_change_document.

    DATA: lv_objectid TYPE cdhdr-objectid.

    lv_objectid = ms_hdr-scheme_no.

    CALL FUNCTION 'ZSDSCHEME_WRITE_DOCUMENT'
      EXPORTING objectid           = lv_objectid
                tcode              = sy-tcode
                utime              = sy-uzeit
                udate              = sy-datum
                username           = sy-uname
                upd_zsdt_schm_hdr  = 'U'
                n_zsdt_schm_hdr    = ms_hdr
                o_zsdt_schm_hdr    = ms_hdr_old
      TABLES    xzsdt_schm_rng     = mt_rng
                yzsdt_schm_rng     = mt_rng_old
                xzsdt_schm_rat     = mt_rat
                yzsdt_schm_rat     = mt_rat_old
      EXCEPTIONS OTHERS            = 1.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD add_msg.

    DATA(ls_msg) = VALUE bapiret2( id         = gc_msgid
                                   type       = iv_type
                                   number     = iv_number
                                   message_v1 = iv_v1
                                   message_v2 = iv_v2
                                   message_v3 = iv_v3 ).

    MESSAGE ID ls_msg-id TYPE 'S' NUMBER ls_msg-number
      WITH iv_v1 iv_v2 iv_v3 INTO ls_msg-message.

    APPEND ls_msg TO ct_msg.

  ENDMETHOD.

ENDCLASS.
