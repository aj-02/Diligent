METHOD if_ex_me_process_po_cust~check.
*......................................................................*
* Version Create/Change Owner     TR           CR/ID                   *
* Date:                                                                *
* Reason:                                                              *
*......................................................................*
* <001> Saurabh Saumya     DEVK954730   Task - DEVK954937              *
* Date: 20.01.2026                                                     *
* Reason: Validation for PIR if its's created manually the Net Price   *
*         field shoudld be disabled                                    *
*......................................................................*
* <002> Arnav Johri                     WRICEF 050_BRD_FS              *
* Date: 19.08.2026                                                     *
* Reason: Budget control on indirect purchase. Blocks the PO when the  *
*         account assigned value exceeds Budget + Additional Budget    *
*         held in ZMM_PO_BUDGET for plant / purchasing group / year.   *
*......................................................................*

    INCLUDE mm_messages_mac. " Required for mmpur macros


    TYPES: BEGIN OF ty_material_key,
             ebelp TYPE ebelp,
             matnr TYPE matnr,
             bwkey TYPE bwkey,
             bwtar TYPE mbew-bwtar,
           END OF ty_material_key,

           tt_material_keys TYPE SORTED TABLE OF ty_material_key
                 WITH UNIQUE KEY ebelp matnr bwkey bwtar.

    CONSTANTS: c_po_doctype TYPE rvari_vnam VALUE 'ZPO_DOCTYPE',
               c_selopt     TYPE rsscr_kind VALUE 'S'.

    DATA: lo_services    TYPE REF TO if_services_mm,
          lt_esll        TYPE mmsrv_esll,
          lt_accountings TYPE purchase_order_accountings.

    SELECT sign, opti, low, high
      INTO TABLE @DATA(lt_po_doctyp)
      FROM tvarvc
      WHERE name = @c_po_doctype
        AND type = @c_selopt.

***Start change by archna gupta
*    SELECT ebeln, ebelp, packno
*       FROM ekpo
*      INTO TABLE @DATA(lt_ekpo).
**      where ebeln =
*    IF lt_ekpo IS NOT INITIAL.
*      SELECT srvpos, packno FROM esll
*                      INTO TABLE @DATA(lt_esll)
*        FOR ALL ENTRIES IN @lt_ekpo
*        WHERE packno = @lt_ekpo-packno.
*    ENDIF.
*    IF lt_esll IS NOT INITIAL.
*      SELECT packno, ps_psp_pnr FROM eskn INTO TABLE @DATA(lt_eskn)
*        FOR ALL ENTRIES IN @lt_esll
*        WHERE  packno = @lt_esll-packno.
*    ENDIF.
*    LOOP AT lt_eskn INTO DATA(ls_eskn).
*    ENDLOOP


**    End of change archna gupta


    "change on

*    DATA(ls_header) = im_header->get_data( ).
    DATA  ls_header  TYPE mepoheader.
    ls_header = im_header->get_data( ).

****    IF line_exists( lt_po_doctyp[ low = ls_header-bsart ] ).
    " Retrieve all items from the STO
    "start change on 28-01-26
*    DATA(lt_items) = im_header->get_items( ).
    "this code is copy paste from below code line no 398
    DATA  lt_items TYPE purchase_order_items.
    lt_items = im_header->get_items( ).
    "end change on 28-01-26
    "start chaneg on 28-01-26.
    "code shifted from line no 310 to 75
    DATA : ls_item  TYPE purchase_order_item.
    "end change on 28-01-26
    DATA(lt_material_keys) = VALUE tt_material_keys(
                                    FOR ls_items IN lt_items
                                    LET ls_data = ls_items-item->get_data( ) IN
                                    ( ebelp = ls_data-ebelp matnr = ls_data-matnr bwkey = ls_data-werks bwtar = ls_data-bwtar )
                                  ).

    IF lt_material_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT matnr, bwkey, bwtar, vprsv, stprs
      FROM mbew
      FOR ALL ENTRIES IN @lt_material_keys
      WHERE matnr = @lt_material_keys-matnr
        AND bwkey = @lt_material_keys-bwkey
        AND bwtar = @lt_material_keys-bwtar
      INTO TABLE @DATA(lt_mbew_data).

    DATA : gv_error_raised TYPE char1.

***- begin of changes by Hemang to control multiple messages on 13/05/2026 Req By: Juanid
*    IF gv_error_raised = 'X'.
*      "do nothing | If needed add error message later
*    ELSE.

    " Validate results back in the item loop
    mmpur_context mmcnt_context_badi.

    LOOP AT lt_items INTO DATA(ls_item_ref).

      DATA(ls_item_data) = ls_item_ref-item->get_data( ).
      DATA(ls_head) = ls_item_ref-item->get_header( ).

      DATA(ls_mbew) = VALUE #( lt_mbew_data[ matnr = ls_item_data-matnr
                                             bwkey = ls_item_data-werks
                                             bwtar = ls_item_data-bwtar ] OPTIONAL ).
      lt_accountings = ls_item_ref-item->get_accountings( ).

      IF ls_item_data-id IS NOT INITIAL.
        mmpur_remove_msg_by_context ls_item_data-id mmcnt_context_badi.
      ENDIF.

      LOOP AT lt_accountings INTO DATA(ls_accounting).
        DATA(ls_acc_data) = ls_accounting-accounting->get_data( ).
      ENDLOOP.

****        IF ls_item_data-pstyp = '9'.
****          TRY.
****              lo_services ?= ls_item_ref-item.
****              CALL METHOD lo_services->get_srv_data
****                EXPORTING
****                  im_packno = ls_item_data-packno
****                IMPORTING
****                  ex_esll   = lt_esll.
****
****              " Collect WBS elements from service lines
****              LOOP AT lt_esll INTO DATA(ls_esll) WHERE ps_psp_pnr IS NOT INITIAL.
****                APPEND ls_esll-ps_psp_pnr TO lt_wbs_check.
****              ENDLOOP.
****            CATCH cx_sy_move_cast_error.
****              CONTINUE.
****          ENDTRY.
****        ENDIF.

      "++ Begin of changes by Hemang Joshi on 12/02/2026 req by : Sidhesh Rai
      "skip validation for valuation type other then those maintained in tvarvc
      "Changed by UDAYABAP03 on 15.04.2026
      IF line_exists( lt_po_doctyp[ low = ls_header-bsart ] ).
*      IF line_exists( lt_val_typ[ low = ls_mbew-bwtar ] ).
        "Changed by UDAYABAP03 on 15.04.2026

        "++ END of changes by Hemang Joshi on 12/02/2026 req by : Sidhesh Rai

        " Check logic: Standard Price = 0 and Price Control = 'S'
        IF ls_mbew-vprsv = 'S' AND ls_mbew-stprs = 0.
          " Raise modern Error Message

          mmpur_business_obj_id ls_item_data-id.

          mmpur_metafield mmmfd_matnr.

          mmpur_message_forced:
             'E' 'ZMM_MSGS' '007' ls_item_data-ebelp ls_item_data-werks '' ''.


          " Mark the item as invalid to block saving
          ls_item_ref-item->invalidate( ).
          ch_failed = abap_true.

          gv_error_raised = 'X'.  "++ added by Hemang req BY Junaid on 13/05/2026
        ENDIF.
      ENDIF..


    ENDLOOP.
**    ENDIF.
****    ENDIF.

***BOC #001
*
*    DATA(ls_header1) = im_header->get_data( ).
*    DATA(lt_items1)  = im_header->get_items( ).
*
*    LOOP AT lt_items1 INTO DATA(ls_wrap).
*
*      DATA(lo_item) = ls_wrap-item.
*      DATA(ls_item1) = lo_item->get_data( ).
*
*      " Skip items without PIR
*      IF ls_item1-infnr IS INITIAL.
*        CONTINUE.
*      ENDIF.
*
*      " 1) Decide PIR mode (MANUAL/AUTO)
*      DATA lv_mode TYPE char10.
*
*      me->determine_pir_mode(
*        EXPORTING iv_infnr = ls_item1-infnr
*                  iv_ebeln = ls_item1-ebeln
*                  iv_ebelp = ls_item1-ebelp
*        IMPORTING ev_mode  = lv_mode ).
*
*      IF lv_mode = 'AUTO'.
*        CONTINUE. " For auto PIR, price change is allowed
*      ENDIF.
*
*      " 2) Read current conditions (runtime type inferred)
*      CALL METHOD lo_item->get_conditions
*        IMPORTING
*          ex_conditions = DATA(lt_now).
*
*      " 3) Read baseline
*      READ TABLE me->mt_base_cond INTO DATA(ls_base)
*           WITH KEY ebelp = ls_item1-ebelp.
*      IF sy-subrc <> 0 OR ls_base-cond_ref IS INITIAL.
*        " No baseline yet (e.g., first check) -> initialize now and skip once
*        DATA lr_copy TYPE REF TO data.
*        CREATE DATA lr_copy LIKE lt_now.
*        ASSIGN lr_copy->* TO FIELD-SYMBOL(<lt_copy_init>).
*        <lt_copy_init> = lt_now.
*        INSERT VALUE lty_base_cond( ebelp = ls_item1-ebelp cond_ref = lr_copy )
*          INTO TABLE me->mt_base_cond.
*        CONTINUE.
*      ENDIF.
*
*      ASSIGN ls_base-cond_ref->* TO FIELD-SYMBOL(<lt_old>).
*      IF <lt_old> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      " 4) Compare only protected KSCHL rows
*      DATA(lv_changed) = abap_false.
*
*      LOOP AT lt_now ASSIGNING FIELD-SYMBOL(<wa_now>).
*
*        " KSCHL of current row
*        ASSIGN COMPONENT 'KSCHL' OF STRUCTURE <wa_now> TO FIELD-SYMBOL(<kschl_now>).
*        IF <kschl_now> IS NOT ASSIGNED.
*          CONTINUE.
*        ENDIF.
*
*        " Check if this KSCHL is protected
*        READ TABLE me->mt_prot_kschl WITH TABLE KEY table_line = <kschl_now> TRANSPORTING NO FIELDS.
*        IF sy-subrc <> 0.
*          CONTINUE.
*        ENDIF.
*
*        " Find same KSCHL in baseline
*        DATA(lv_found) = abap_false.
*        LOOP AT <lt_old> ASSIGNING FIELD-SYMBOL(<wa_old>).
*          ASSIGN COMPONENT 'KSCHL' OF STRUCTURE <wa_old> TO FIELD-SYMBOL(<kschl_old>).
*          IF <kschl_old> IS ASSIGNED AND <kschl_old> = <kschl_now>.
*            lv_found = abap_true.
*
*            " Compare price-relevant fields
*            ASSIGN COMPONENT 'KBETR' OF STRUCTURE <wa_now> TO FIELD-SYMBOL(<kbetr_now>).
*            ASSIGN COMPONENT 'KBETR' OF STRUCTURE <wa_old> TO FIELD-SYMBOL(<kbetr_old>).
*
*            ASSIGN COMPONENT 'KPEIN' OF STRUCTURE <wa_now> TO FIELD-SYMBOL(<kpein_now>).
*            ASSIGN COMPONENT 'KPEIN' OF STRUCTURE <wa_old> TO FIELD-SYMBOL(<kpein_old>).
*
*            ASSIGN COMPONENT 'KMEIN' OF STRUCTURE <wa_now> TO FIELD-SYMBOL(<kmein_now>).
*            ASSIGN COMPONENT 'KMEIN' OF STRUCTURE <wa_old> TO FIELD-SYMBOL(<kmein_old>).
*
*            ASSIGN COMPONENT 'KWERT' OF STRUCTURE <wa_now> TO FIELD-SYMBOL(<kwert_now>).
*            ASSIGN COMPONENT 'KWERT' OF STRUCTURE <wa_old> TO FIELD-SYMBOL(<kwert_old>).
*
*            IF ( <kbetr_now> IS ASSIGNED AND <kbetr_old> IS ASSIGNED AND <kbetr_now> <> <kbetr_old> )
*            OR ( <kpein_now> IS ASSIGNED AND <kpein_old> IS ASSIGNED AND <kpein_now> <> <kpein_old> )
*            OR ( <kmein_now> IS ASSIGNED AND <kmein_old> IS ASSIGNED AND <kmein_now> <> <kmein_old> )
*            OR ( <kwert_now> IS ASSIGNED AND <kwert_old> IS ASSIGNED AND <kwert_now> <> <kwert_old> ).
*              lv_changed = abap_true.
*            ENDIF.
*
*            EXIT. " matched base row checked
*          ENDIF.
*        ENDLOOP.
*
*        " Protected KSCHL newly added (not in baseline) -> changed
*        IF lv_found = abap_false.
*          lv_changed = abap_true.
*        ENDIF.
*
*        IF lv_changed = abap_true.
*          EXIT.
*        ENDIF.
*
*      ENDLOOP.
*
*      " 5) If changed and PIR=MANUAL -> block save with purchasing error
*      IF lv_changed = abap_true.
*        " Message 001 in your Z class: "Price conditions in PO cannot be changed, PIR was created manually"
*        MESSAGE 'Price conditions in PO cannot be changed, PIR was created manually' TYPE 'E'. "mmpur_message_forced 'E' 'ZMM_MSGS' '001' ls_item1-ebelp '' '' ''.
*      ENDIF.
*
*    ENDLOOP.

*EOC #001
*****************************Retrofit Code*****************************************

    DATA: lv_bsart TYPE esart,
          lv_lifnr TYPE lifnr,
          lv_ktokk TYPE ktokk.
*
*    DATA  : ls_poitem TYPE mepoitem,
********************************************Begin of changes*Added by Raj on 11.07.2024*******
    DATA  : gs_poitem  TYPE mepoitem."Added by Raj on 08.07.2024
    TYPES : BEGIN OF ty_ekpp,
              creationdate TYPE ekpo-creationdate,
              creationtime TYPE ekpo-creationtime,
              ebeln        TYPE ekpo-ebeln,
              ebelp        TYPE ekpo-ebelp,
              werks        TYPE ekpo-werks,
              matnr        TYPE ekpo-matnr,
              ktmng        TYPE ekpo-ktmng,
              netpr        TYPE ekpo-netpr,
              bstyp        TYPE ekpo-bstyp,
              tsl          TYPE string,
            END OF ty_ekpp.

    DATA : it_ekpp TYPE STANDARD TABLE OF ty_ekpp,
           wa_ekpp TYPE ty_ekpp.
    DATA : lv_konnr TYPE ekko-konnr."Added by Raj on 08.07.2024
    DATA : lv_ktpnr TYPE ekpo-ebelp."Added by Raj on 08.07.2024
    DATA : lv_netpr  TYPE ekpo-netpr."Added by Raj on 08.07.2024
    DATA :gs_switch(1) TYPE c."Added by Raj on 08.07.2024
    CONSTANTS :c_tvarvc_mts TYPE rvari_vnam VALUE 'ZMM_PO_TYPES',  "Added by Raj on 08.07.2024
               c_type_mts   TYPE rsscr_kind VALUE 'S'.            "Added by Raj on 08.07.2024
    TYPES: BEGIN OF ty_tvarv,
             sign TYPE tvarv_sign,
             opti TYPE tvarv_opti,
             low  TYPE tvarv_val,
             high TYPE tvarv_val,
           END OF ty_tvarv.
    DATA: it_type TYPE STANDARD TABLE OF ty_tvarv, "Added by Raj on 08.07.2024
          wa_type TYPE ty_tvarv.    "Added by Raj on 08.07.2024
*********************************************End of changes*Added by Raj on 11.07.2024****************


    DATA  : ls_detail  TYPE mepoitem,
            lt_details TYPE tab_mepoitem.
    " start change on 28-01-26
*            ls_header  TYPE mepoheader.
    " end  change on 28-01-26
    "start chaneg on 28-01-26
*    DATA  : lt_items TYPE purchase_order_items,
    "end change on 28-01-26
    "start change on 28-01-26
    "code shifted on line no 74
*     Data : ls_item  TYPE purchase_order_item.
    "end chaneg on 28-01-26
    DATA lv_pstyp TYPE pstyp.
*    TYPES: ty_bsart TYPE RANGE OF ekko-bsart.
*    DATA : rt_bsart    TYPE ty_bsart,
*           rw_bsart    TYPE LINE OF ty_bsart,
*           ls_head     TYPE REF TO if_purchase_order_mm,
*           ls_headdata TYPE mepoheader.
*    DATA: lv_vprsv   TYPE mbew-vprsv VALUE 'S',
*          lv_vprsv1  TYPE mbew-vprsv,
*          lv_tvarvc1 TYPE tvarvc-name VALUE 'ZPO_STO_TYPE_DEL_FLAG'.

    FIELD-SYMBOLS <fs_zdomes> TYPE ANY TABLE.

    lt_items  = im_header->get_items( ).
    REFRESH lt_details.
    LOOP AT lt_items INTO ls_item.
      ls_detail = ls_item-item->get_data( ).
      APPEND ls_detail TO lt_details.
    ENDLOOP.

***** Added by MR on 10/09/2022

    "---Get Head Deep-Structure
*    ls_head     = im_header->get_header( ).
    "---Get Header Data
*    ls_headdata  = ls_head->get_data( ).,
***    ls_headdata  = im_header->get_data( ).
***
***    SELECT low, high
***           FROM tvarvc
***           INTO TABLE @DATA(lt_bsart)
***           WHERE name = @lv_tvarvc1.
***    LOOP AT lt_bsart INTO DATA(lw_bsart).
***      rw_bsart-sign   = 'I'.
***      rw_bsart-option = 'EQ'.
***      rw_bsart-low    = lw_bsart-low.
***      APPEND rw_bsart TO rt_bsart.
***      CLEAR rw_bsart.
***    ENDLOOP.
***
***    CHECK rt_bsart IS NOT INITIAL.
***
***    IF ls_headdata-bsart IN rt_bsart.
****      IF ls_mepoitem-bwtar IS NOT INITIAL.
****      LOOP AT lt_details INTO DATA(ls_details).
***      LOOP AT lt_items INTO ls_item.
***        DATA(ls_details) = ls_item-item->get_data( ).
***
***        SELECT SINGLE *
***              INTO @DATA(lw_mbew)
***              FROM mbew
***              WHERE matnr = @ls_details-matnr
***              AND   bwkey = @ls_details-werks
***              AND   bwtar = @ls_details-bwtar
***              AND   vprsv = @lv_vprsv.
***        IF sy-subrc = 0.
***          MESSAGE w398(00) WITH 'Stardard Price for material' ls_details-matnr 'is zero'.
***          IF sy-tcode = 'ME21N'.
***            ls_details-loekz = 'S'.
***          ELSE.
***            ls_details-loekz = 'L'.
***          ENDIF.
***
****          ls_item-item-my_cust_firewall_on = 'X'.
***          DATA: l_parent  TYPE REF TO cl_po_header_handle_mm, "IF_MESSAGE_OBJ_MM,
***                my_parent TYPE REF TO if_message_obj_mm. "
***
****
***
***          my_parent = im_header->if_message_obj_mm~get_parent( ).
***
***          mmpur_dynamic_cast l_parent my_parent.
***
***
***          CHECK NOT l_parent IS INITIAL.
****          CHECK "l_parent->my_ibs_firewall_on EQ mmpur_yes OR
***                l_parent->my_cust_firewall_on = mmpur_yes.
***
***          "---Change line item with Set method
***          CALL METHOD ls_item-item->set_data
***            EXPORTING
***              im_data = ls_details.
***
***        ENDIF.
***      ENDLOOP.
***    ENDIF.

***** End of Addition bt MR

    READ TABLE lt_details INTO ls_detail INDEX 1.
    LOOP AT lt_details TRANSPORTING NO FIELDS
       WHERE ( werks NE ls_detail-werks ).
      EXIT.
    ENDLOOP.
    IF ( syst-subrc = 0 ) .

      MESSAGE 'MULTIPLE PLANT NOT ALLOW' TYPE 'E'.
      ch_failed = 'X'.
    ENDIF.

    IF gv_lifnr IS NOT INITIAL AND
       gv_bukrs IS NOT INITIAL.
      SELECT SINGLE lifnr
               INTO lv_lifnr
                 FROM lfb1
                   WHERE lifnr = gv_lifnr
                     AND bukrs = gv_bukrs.
      IF sy-subrc NE 0.
        MESSAGE e024(zmm) WITH gv_lifnr gv_bukrs.
      ENDIF.
    ENDIF.
*    IF gv_bwtar EQ 'LOCAL' AND gv_bsart EQ 'ZSTO'.
    IF gv_bwtar EQ 'LOCAL' AND gv_bsart EQ 'ZCBW'.
      MESSAGE e027(zmm) WITH gv_bwtar gv_bsart.
    ENDIF.
*    IF gv_bsart eq 'ZUB'.
*      CALL FUNCTION 'POPUP_TO_CONFIRM'
*        EXPORTING
*         TITLEBAR                    = 'Invoice selection '
**         DIAGNOSE_OBJECT             = ' '
*          text_question               = 'hello'
*         TEXT_BUTTON_1               = 'Yes'
**         ICON_BUTTON_1               = ' '
*         TEXT_BUTTON_2               = 'No'
**         ICON_BUTTON_2               = ' '
**         DEFAULT_BUTTON              = '1'
**         DISPLAY_CANCEL_BUTTON       = 'X'
**         USERDEFINED_F1_HELP         = ' '
**         START_COLUMN                = 25
**         START_ROW                   = 6
**         POPUP_TYPE                  =
**         IV_QUICKINFO_BUTTON_1       = ' '
**         IV_QUICKINFO_BUTTON_2       = ' '
**       IMPORTING
**         ANSWER                      =
**       TABLES
**         PARAMETER                   =
**       EXCEPTIONS
**         TEXT_NOT_FOUND              = 1
**         OTHERS                      = 2
*                .
*      IF sy-subrc <> 0.
** Implement suitable error handling here
*      ENDIF.
*
*
**      MESSAGE e009(zmm) DISPLAY LIKE 'I' WITH gv_bsart gv_bsart.
*    ENDIF.
*&---------------------------------------------------------------------------
*& CR          : CR-5072
*& Author      : Bhushan Bhalerao
*& Company     : AIS, Pune
*& Description : STO Price - Check on FRA1
*&---------------------------------------------------------------------------
*---BOC CR-5072
    DATA : lt_conditions TYPE mmpur_tkomv,
           lo_po_doc     TYPE REF TO if_purchasing_document,
           ls_poheader   TYPE mepoheader.

    ls_poheader  = im_header->get_data( ).
    lo_po_doc ?= im_header.

****** Added changes for check of Release Strategy by Carina Jose on 11.06.2022

    CONSTANTS:
      c_tvarvc_name TYPE rvari_vnam VALUE 'Z_POTYPES_VALI',
      c_type_user   TYPE rsscr_kind VALUE 'S'.

    TYPES :BEGIN OF ty_tvarvc,
             low TYPE tvarvc-low,
           END OF ty_tvarvc.
    DATA : it_tvarvc TYPE STANDARD TABLE OF ty_tvarvc,
           wa_tvarvc TYPE ty_tvarvc.
    SELECT low
      INTO TABLE it_tvarvc
      FROM tvarvc
      WHERE name = c_tvarvc_name.

    READ TABLE it_tvarvc INTO wa_tvarvc WITH KEY low = ls_poheader-bsart.
    IF sy-subrc <> '0'.
      IF ls_detail-loekz NE 'L'.
        IF ls_poheader-frggr IS INITIAL AND ls_poheader-frgsx IS INITIAL.
          MESSAGE 'Please Configure Release Strategy' TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
****** End of changes by Carina Jose on 11.06.2022



********Added changes to allow hold for past date Po 30-08-2022 (Squirrel Manoj)
*    SELECT SINGLE low FROM tvarvc INTO @DATA(lv_holdtcode) WHERE name = 'ZMM_HOLDPO_TCODE'.
*    IF sy-tcode = lv_holdtcode. "'ME22N'
*
*      FIELD-SYMBOLS: <fs_ekko> TYPE ekko.
*      ASSIGN ('(SAPLMEPO)EKKO') TO <fs_ekko>.
*
*      SELECT SINGLE low FROM tvarvc INTO @DATA(zpo_hold_doctyp) WHERE name = 'ZPO_HOLD_DOCTYP'.
*      IF zpo_hold_doctyp IS NOT INITIAL.
*        SELECT SINGLE * FROM ekko INTO @DATA(ls_ekko) WHERE ebeln = @ls_poheader-ebeln.
*        IF ls_ekko IS NOT INITIAL.
*          IF ( ls_ekko-memorytype = 'H' AND ls_ekko-bsart = zpo_hold_doctyp ).
*
*          ELSE.
**            IF <fs_ekko> IS ASSIGNED.
**              IF <fs_ekko>-bedat < sy-datum.
**                MESSAGE 'Document date is in past' TYPE 'E'.
**                ch_failed = abap_true.
**              ELSEIF <fs_ekko>-bedat > sy-datum.
**                MESSAGE 'Document date is in future' TYPE 'E'.
**                ch_failed = abap_true.
**              ENDIF.
**            ENDIF.
*            exit.
*
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*******End of changes by (Squirrel Manoj)

    CALL METHOD lo_po_doc->get_tkomv
      IMPORTING
        ex_tkomv = lt_conditions.

    SELECT name, low
           FROM tvarvc
           INTO TABLE @DATA(lt_tvarvc)
           WHERE name IN ('Z_PO_FRA1_DOCTYPE','Z_PO_FRA1_COND').

    READ TABLE lt_tvarvc INTO DATA(lv_tvarvc) WITH KEY name = 'Z_PO_FRA1_DOCTYPE'
                                                       low  = ls_poheader-bsart.
    IF sy-subrc = 0. "ls_poheader-bsart = lv_tvarvc-low.
      CLEAR lv_tvarvc.
*      READ TABLE lt_tvarvc INTO lv_tvarvc WITH KEY name = 'Z_PO_FRA1_COND'.
      LOOP AT lt_tvarvc INTO lv_tvarvc WHERE name = 'Z_PO_FRA1_COND'.
        READ TABLE lt_conditions INTO DATA(ls_cond) WITH KEY kschl = lv_tvarvc-low.
        IF sy-subrc IS NOT INITIAL.
          MESSAGE 'Please enter required condition' TYPE 'E'.
          ch_failed = abap_true.
        ELSEIF sy-subrc IS INITIAL AND ls_cond-kbetr IS INITIAL.
          MESSAGE 'Please enter required condition' TYPE 'E'.
          ch_failed = abap_true.
        ENDIF.
      ENDLOOP.
    ENDIF.
*---EOC CR-5072

*&---------------------------------------------------------------------*
*BOC <002> Budget control on indirect purchase By Arnav on 19.08.2026
*& WRICEF 050_BRD_FS
*&
*& Placed here deliberately - it must stay ABOVE the CHECK statements
*& that follow, because CHECK exits the method and would skip this for
*& ME29N and for gv_pstyp = 'U'.
*&
*& Uses ls_header and lt_details, both already built above.
*&
*& Correction 03/09/26 - switched from mmpur_message_forced to a plain
*& MESSAGE statement. mmpur_message_forced only hands the text to the
*& purchasing message collector and something downstream decides whether
*& to render it; in QAS it was collected and never displayed, so the PO
*& was offered for Hold with no explanation. Eight other validations in
*& this same method already use raw MESSAGE TYPE 'E' and work in QAS.
*&
*& ch_failed is set BEFORE each MESSAGE. A type E message returns to the
*& screen immediately, so anything after it never runs.
*&---------------------------------------------------------------------*

    DATA: lv_bud_gjahr    TYPE gjahr,
          lv_bud_werks    TYPE werks_d,
          lv_bud_current  TYPE zmm_po_budget-budget,
          lv_bud_consumed TYPE zmm_po_budget-budget,
          lv_bud_allowed  TYPE zmm_po_budget-budget,
          lv_bud_from     TYPE bedat,
          lv_bud_to       TYPE bedat.

    IF sy-tcode = 'ME21N' OR sy-tcode = 'ME22N'.

*     Budget year from the document date.
*     OPEN POINT: calendar year assumed, the FS does not state which.
      lv_bud_gjahr = ls_header-bedat(4).

*     Value of the account assigned items in this document. Only KNTTP = K
*     counts per the FS, and deleted items are ignored. Multiple plants in
*     one document are already rejected above, so one plant is enough.
      CLEAR: lv_bud_current, lv_bud_werks.

      LOOP AT lt_details INTO DATA(ls_bud_item)
           WHERE knttp = 'K'
             AND loekz = space.
        lv_bud_werks   = ls_bud_item-werks.
        lv_bud_current = lv_bud_current + ls_bud_item-effwr.
      ENDLOOP.

*     Nothing account assigned - document is not budget relevant
      IF lv_bud_werks IS NOT INITIAL.

        SELECT SINGLE budget, add_budget, waers
          FROM zmm_po_budget
          INTO @DATA(ls_bud_master)
          WHERE werks = @lv_bud_werks
            AND ekgrp = @ls_header-ekgrp
            AND gjahr = @lv_bud_gjahr.

        IF sy-subrc <> 0.

*         OPEN POINT: no budget maintained. Blocking is assumed.
*         Changed 03/09/26 - collector route replaced by plain MESSAGE.
*          mmpur_message_forced 'E' 'ZMM_BUDGET' '002'
*                               lv_bud_werks ls_header-ekgrp lv_bud_gjahr ''.
          ch_failed = abap_true.
          MESSAGE e002(zmm_budget) WITH lv_bud_werks ls_header-ekgrp lv_bud_gjahr.

        ELSEIF ls_header-waers IS NOT INITIAL
           AND ls_bud_master-waers IS NOT INITIAL
           AND ls_header-waers <> ls_bud_master-waers.

*         OPEN POINT: no currency conversion, a mismatch is reported.
*         Changed 03/09/26 - collector route replaced by plain MESSAGE.
*          mmpur_message_forced 'E' 'ZMM_BUDGET' '008'
*                               ls_header-waers ls_bud_master-waers '' ''.
          ch_failed = abap_true.
          MESSAGE e008(zmm_budget) WITH ls_header-waers ls_bud_master-waers.

        ELSE.

          lv_bud_allowed = ls_bud_master-budget + ls_bud_master-add_budget.

          lv_bud_from = |{ lv_bud_gjahr }0101|.
          lv_bud_to   = |{ lv_bud_gjahr }1231|.

*         Value already committed by OTHER documents in the same year. The
*         document being saved is excluded - without this a change through
*         ME22N counts its own value twice, once from the database and once
*         from the document in memory.
*         KNOWN GAP 03/09/26, deliberately NOT fixed here: there is no
*         k~bstyp restriction, so contracts and scheduling agreements are
*         counted as consumed budget, and EFFWR is summed across document
*         currencies. Both need a separate decision - see ISSUES.md.
          SELECT SUM( p~effwr )
            FROM ekko AS k
            INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
            INTO @lv_bud_consumed
            WHERE k~ekgrp  = @ls_header-ekgrp
              AND k~bedat BETWEEN @lv_bud_from AND @lv_bud_to
              AND k~ebeln <> @ls_header-ebeln
              AND k~loekz  = @space
              AND p~werks  = @lv_bud_werks
              AND p~knttp  = 'K'
              AND p~loekz  = @space.

          lv_bud_consumed = lv_bud_consumed + lv_bud_current.

          IF lv_bud_consumed > lv_bud_allowed.

*           Changed 03/09/26 - collector route replaced by plain MESSAGE.
*            mmpur_message_forced 'E' 'ZMM_BUDGET' '001' '' '' '' ''.
            ch_failed = abap_true.
            MESSAGE e001(zmm_budget).

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

*EOC <002> Budget control on indirect purchase By Arnav on 19.08.2026
*&---------------------------------------------------------------------*

    CHECK sy-tcode NE 'ME29N'.
    CHECK gv_pstyp NE 'U'.
    IF gv_bsart EQ 'SERV' OR gv_bsart EQ 'SCON'.
      IF gv_pstyp IS INITIAL.
*        ls_poitem  = im_header->get_items( ).
*        lv_pstyp   = ls_poitem-pstyp.
      ENDIF.
      SELECT SINGLE bsart INTO lv_bsart
        FROM zmm_po_vendor
          WHERE ktokk = gv_ktokk
            AND bsart = gv_bsart
            AND pstyp = gv_pstyp.
      IF lv_bsart IS INITIAL.
        MESSAGE e021(zmm) WITH gv_lifnr gv_bsart.
      ENDIF.
    ELSE.
      IF gv_ktokk IS NOT INITIAL AND gv_mtart IS NOT INITIAL AND gv_bsart IS NOT INITIAL.
        SELECT SINGLE ktokk
          INTO lv_ktokk
            FROM zmm_po_vendor
              WHERE ktokk = gv_ktokk
                AND mtart = gv_mtart
                AND bsart = gv_bsart.
        IF lv_ktokk IS INITIAL.
          MESSAGE e021(zmm) WITH gv_lifnr gv_bsart gv_mtart.
        ENDIF.
      ENDIF.
    ENDIF.

*************Begin of changes Added by Raj on 11.07.2024**************************

*       IF sy-tcode = 'ME21N'.
*
*      SELECT SINGLE low FROM tvarvc INTO gs_switch WHERE name = 'ZMM_CON_SWITCH' AND type = 'P'.
*      IF gs_switch = abap_true.
*
*        SELECT sign
*           opti
*           low
*           high INTO TABLE it_type
*                     FROM tvarvc
*                     WHERE name = c_tvarvc_mts AND
*                           type =  c_type_mts.
*
*        READ TABLE it_type INTO wa_type WITH KEY low = gv_bsart.
*        IF sy-subrc = 0.
*
*
*          LOOP AT  lt_details INTO gs_poitem.
*
*            LOOP AT lt_conditions INTO DATA(wa_con) WHERE kposn = gs_poitem-ebelp.
*
*              SELECT ebeln,lifnr,bstyp,kdatb,kdate FROM ekko INTO TABLE @DATA(it_ekko) WHERE lifnr = @gv_lifnr AND bstyp = 'K'.
*
*              IF it_ekko IS NOT INITIAL.
*
*                SELECT ebeln,ebelp,matnr,werks,ktmng,netpr,bstyp,creationdate,creationtime FROM ekpo INTO TABLE @DATA(it_ekpo) FOR ALL ENTRIES IN @it_ekko
*                 WHERE ebeln = @it_ekko-ebeln AND matnr =  @gs_poitem-matnr AND werks = @gs_poitem-werks AND bstyp = 'K' AND loekz NE 'L'.
*
*              ENDIF.
*
*
*              LOOP AT it_ekpo INTO DATA(wa_ekpos).
*                MOVE-CORRESPONDING wa_ekpos TO wa_ekpp.
*                CONCATENATE wa_ekpos-creationdate wa_ekpos-creationtime INTO wa_ekpp-tsl.
*                APPEND wa_ekpp TO it_ekpp.
*                CLEAR : wa_ekpos,wa_ekpp.
*              ENDLOOP.
*
*
*              SORT it_ekpp BY tsl DESCENDING.
*              READ TABLE it_ekpp INTO wa_ekpp INDEX 1.
*
*              lv_konnr = wa_ekpp-ebeln.
*              lv_ktpnr = wa_ekpp-ebelp.
*
*              IF lv_konnr IS NOT INITIAL.
*                SELECT kschl,evrtn,evrtp,datbi,datab,knumh FROM a016 INTO TABLE @DATA(it_a016) WHERE evrtn = @lv_konnr AND evrtp = @lv_ktpnr.
*              ENDIF.
*
*              SORT it_a016 BY datab   DESCENDING.
*              SORT it_a016 BY knumh  DESCENDING.
*
*              READ TABLE it_a016 INTO DATA(wa_a016) INDEX 1.
*              SELECT KNUMH,KOPOS,KAPPL,KSCHL,kbetr FROM konp INTO table @DATA(it_konp) WHERE knumh = @wa_a016-knumh.
*
*
*       if gs_poitem-konnr is not INITIAL.                     "QTY VALIDATIONS
*          IF gs_poitem-menge LE wa_ekpp-ktmng .
*          ELSE.
*            MESSAGE e052(zmm) with gs_poitem-ebelp.
*          ENDIF.
*      ENDIF.
*
*              IF lv_konnr IS NOT INITIAL.                      "PRICE VALIDATIONS
*                READ TABLE it_konp into data(wa_konp) with key kschl = wa_con-kschl.
*                IF  wa_con-kbetr NE wa_konp-kbetr.
*                  MESSAGE e053(zmm) WITH gs_poitem-ebelp.
*                  CLEAR : wa_con.
*                ENDIF.
**              ENDLOOP.
*            endif.
*              CLEAR : wa_con,wa_konp.
*          ENDLOOP.
*          CLEAR : gs_poitem,lv_konnr,wa_con,lv_ktpnr.
*          REFRESH : it_ekko,it_ekpo,it_ekpp,it_a016 .
*     ENDLOOP.
*            ENDIF.
*
*
**        ENDIF.
*      ENDIF.
*    ENDIF.

***********************
    IF sy-tcode = 'ME21N'.

      TYPES : BEGIN OF ty_konps,
                kschl TYPE konp-kschl,
                kbetr TYPE konp-kbetr,
              END OF ty_konps.

      DATA : it_konps TYPE STANDARD TABLE OF ty_konps,
             wa_konps TYPE ty_konps.


******************Begin of ATC changes 13/02/26   UDAYABAP03*************
*      SELECT SINGLE low FROM tvarvc INTO gs_switch WHERE name = 'ZMM_CON_SWITCH' AND type = 'P'.
      SELECT low FROM tvarvc INTO gs_switch UP TO 1 ROWS WHERE name = 'ZMM_CON_SWITCH' AND type = 'P' ORDER BY PRIMARY KEY.
      ENDSELECT.
******************End of ATC changes 13/02/26   UDAYABAP03*************
      IF gs_switch = abap_true.

        SELECT sign
          opti
          low
          high INTO TABLE it_type
                    FROM tvarvc
                    WHERE name = c_tvarvc_mts AND
                          type =  c_type_mts.

        READ TABLE it_type INTO wa_type WITH KEY low = gv_bsart.
        IF sy-subrc = 0.


          LOOP AT  lt_details INTO gs_poitem.

            SELECT ebeln,lifnr,bstyp,kdatb,kdate FROM ekko INTO TABLE @DATA(it_ekko) WHERE lifnr = @gv_lifnr AND bstyp = 'K'.

            IF it_ekko IS NOT INITIAL.

              SELECT ebeln,ebelp,matnr,werks,ktmng,netpr,bstyp,creationdate,creationtime FROM ekpo INTO TABLE @DATA(it_ekpo) FOR ALL ENTRIES IN @it_ekko
               WHERE ebeln = @it_ekko-ebeln AND matnr =  @gs_poitem-matnr AND werks = @gs_poitem-werks AND bstyp = 'K' AND loekz NE 'L'.

            ENDIF.


            LOOP AT it_ekpo INTO DATA(wa_ekpos).
              MOVE-CORRESPONDING wa_ekpos TO wa_ekpp.
              CONCATENATE wa_ekpos-creationdate wa_ekpos-creationtime INTO wa_ekpp-tsl.
              APPEND wa_ekpp TO it_ekpp.
              CLEAR : wa_ekpos,wa_ekpp.
            ENDLOOP.


            SORT it_ekpp BY tsl DESCENDING.
            READ TABLE it_ekpp INTO wa_ekpp INDEX 1.

            lv_konnr = wa_ekpp-ebeln.
            lv_ktpnr = wa_ekpp-ebelp.

            IF lv_konnr IS NOT INITIAL.
******************begin of ATC changes 13/02/26   UDAYABAP03*************
*              SELECT kschl,evrtn,evrtp,datbi,datab,knumh FROM a016 INTO TABLE @DATA(it_a016) WHERE evrtn = @lv_konnr AND evrtp = @lv_ktpnr.
              SELECT kschl,evrtn,evrtp,datbi,datab,knumh FROM a016 INTO TABLE @DATA(it_a016) WHERE evrtn = @lv_konnr AND evrtp = @lv_ktpnr ORDER BY PRIMARY KEY.
******************end of ATC changes 13/02/26   UDAYABAP03*************
            ENDIF.

            SORT it_a016 BY datab   DESCENDING.
            SORT it_a016 BY knumh  DESCENDING.

            READ TABLE it_a016 INTO DATA(wa_a016) INDEX 1.
            SELECT knumh,kopos,kappl,kschl,kbetr FROM konp INTO TABLE @DATA(it_konp) WHERE knumh = @wa_a016-knumh.


            REFRESH : it_konps.
            LOOP AT lt_conditions INTO DATA(wa_con) WHERE kposn = gs_poitem-ebelp AND kposn = gs_poitem-ebelp.
              READ TABLE  it_konp INTO DATA(wa_konp) WITH KEY kschl = wa_con-kschl.
              wa_konps-kschl = wa_con-kschl.
              wa_konps-kbetr = wa_konp-kbetr.
              APPEND wa_konps TO it_konps.
              CLEAR : wa_konps,wa_konp.
            ENDLOOP.

*  endloop.
            IF lv_konnr IS NOT INITIAL.

              IF gs_poitem-konnr IS NOT INITIAL.                     "QTY VALIDATIONS
                IF gs_poitem-menge LE wa_ekpp-ktmng .
                ELSE.
                  MESSAGE e052(zmm) WITH gs_poitem-ebelp.
                ENDIF.
              ENDIF.


*      loop at it_konp into wa_knop.
*        READ TABLE lt_conditions with key kschl = wa_konp-kschl.
*
*        ENDLOOP.

              READ TABLE it_ekko INTO DATA(wa_ekko) WITH KEY ebeln  = lv_konnr. "To get the validity end date consideration check of contract
              IF wa_ekko-kdate GE sy-datum.
                LOOP AT lt_conditions INTO wa_con WHERE kposn = gs_poitem-ebelp AND kposn = gs_poitem-ebelp.
                  IF wa_con-kschl NE 'NAVS'.  " To Skip the NAVS condition type for all NC tax codes.Because of all the NC tax codes contains always NAVS condition type that time system will capture the some amount according to NC tax.
                    READ TABLE it_konp INTO wa_konp WITH KEY kschl = wa_con-kschl.
                    IF sy-subrc = 0.
                      IF wa_con-kbetr IS NOT INITIAL.
                        IF  wa_con-kbetr NE wa_konp-kbetr.
                          MESSAGE e053(zmm) WITH gs_poitem-ebelp.
                          CLEAR : wa_con,wa_konp.
                        ENDIF.
                      ENDIF.
                    ELSE.
                      IF wa_con-kbetr NE 0.
                        READ TABLE it_konps INTO wa_konps WITH KEY kschl =  wa_con-kschl.

                        IF  wa_con-kbetr NE wa_konps-kbetr.
                          MESSAGE e053(zmm) WITH gs_poitem-ebelp.
                          CLEAR : wa_con,wa_konps.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                  CLEAR : wa_konp,wa_con.
                ENDLOOP.
              ENDIF.
              REFRESH : it_konp,it_konps.
            ENDIF.
            CLEAR : gs_poitem.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''''
"BOC CR_025 PR Validation for Manual PO by UDAYABAP03 28.07.2026
    IF sy-tcode = 'ME21N' OR sy-tcode = 'ME22N'.
      LOOP AT lt_details INTO DATA(ls_item1).
        SELECT SINGLE infnr, ekorg, bstyp, effpr
        FROM eine
        WHERE infnr = @ls_item1-infnr
        AND ekorg = @ls_header-ekorg
        AND werks = @ls_item1-werks
        AND bstyp IS INITIAL   "Manual PO
        INTO @DATA(ls_eine).
        IF sy-subrc = 0.
          IF ls_eine-effpr <> ls_item1-netpr.
            MESSAGE 'Changing Net Price is not allowed for this PO' TYPE 'E'.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ENDMETHOD.
