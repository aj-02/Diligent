CLASS zcl_mm_po_budget_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

*"* Budget check for indirect purchase
*"* Astral / UDAY / WRICEF 050_BRD_FS
*"*
*"* Pure logic - deliberately has no dependency on the BAdI interface, so the
*"* same class serves the ME21N / ME22N BAdI implementation and, later, the
*"* scheduling agreement enhancement for ME31L / ME32L.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_item,
             ebelp TYPE ebelp,
             werks TYPE werks_d,
             knttp TYPE knttp,
             loekz TYPE eloek,
             effwr TYPE bwert,
           END OF ty_item,
           tt_item TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    CONSTANTS: gc_msgid   TYPE symsgid VALUE 'ZMM_BUDGET',
               gc_knttp_k TYPE knttp   VALUE 'K'.

    "! Budget check for one purchasing document.
    "! Returns messages; an empty table means the document may be saved.
    "! One check is performed per plant in the document, because plant is an
    "! item field while purchasing group is a header field - a single document
    "! can therefore consume several budgets at once.
    CLASS-METHODS check_document
      IMPORTING iv_ebeln      TYPE ebeln
                iv_ekgrp      TYPE ekgrp
                iv_bedat      TYPE bedat
                iv_waers      TYPE waers
                it_item       TYPE tt_item
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_plant,
             werks TYPE werks_d,
             value TYPE bwert,
           END OF ty_plant,
           tt_plant TYPE SORTED TABLE OF ty_plant WITH UNIQUE KEY werks.

    "! Budget + Additional Budget from ZMM_PO_BUDGET.
    CLASS-METHODS get_allowed
      IMPORTING iv_werks        TYPE werks_d
                iv_ekgrp        TYPE ekgrp
                iv_gjahr        TYPE gjahr
      EXPORTING ev_allowed      TYPE bwert
                ev_waers        TYPE waers
      RETURNING VALUE(rv_found) TYPE abap_bool.

    "! Value already committed by other documents in the same year.
    "! The document being saved is excluded, otherwise a change through ME22N
    "! would count its own value twice - once from the database and once from
    "! the document in memory. This is the double-count defect in the FS.
    CLASS-METHODS get_consumed
      IMPORTING iv_werks        TYPE werks_d
                iv_ekgrp        TYPE ekgrp
                iv_gjahr        TYPE gjahr
                iv_exclude      TYPE ebeln
      RETURNING VALUE(rv_value) TYPE bwert.

    CLASS-METHODS add_msg
      IMPORTING iv_type   TYPE bapi_mtype DEFAULT 'E'
                iv_number TYPE symsgno
                iv_v1     TYPE any OPTIONAL
                iv_v2     TYPE any OPTIONAL
                iv_v3     TYPE any OPTIONAL
                iv_v4     TYPE any OPTIONAL
      CHANGING  ct_msg    TYPE bapiret2_t.

ENDCLASS.


CLASS zcl_mm_po_budget_check IMPLEMENTATION.

  METHOD check_document.

    DATA lt_plant TYPE tt_plant.

    " Year of the budget bucket, taken from the document date.
    " OPEN POINT: the FS does not say whether this is the calendar year or
    " the fiscal year. Calendar year is assumed.
    DATA(lv_gjahr) = CONV gjahr( iv_bedat(4) ).

    " Only account assigned (consumption) items count, and only live ones.
    LOOP AT it_item INTO DATA(ls_item)
         WHERE knttp = gc_knttp_k
           AND loekz = space.

      READ TABLE lt_plant ASSIGNING FIELD-SYMBOL(<ls_p>)
        WITH TABLE KEY werks = ls_item-werks.
      IF sy-subrc <> 0.
        INSERT VALUE #( werks = ls_item-werks ) INTO TABLE lt_plant
          ASSIGNING <ls_p>.
      ENDIF.
      <ls_p>-value = <ls_p>-value + ls_item-effwr.

    ENDLOOP.

    IF lt_plant IS INITIAL.
      " Nothing account assigned in this document - not budget relevant
      RETURN.
    ENDIF.

    LOOP AT lt_plant INTO DATA(ls_plant).

      DATA: lv_allowed TYPE bwert,
            lv_waers   TYPE waers.

      IF get_allowed( EXPORTING iv_werks   = ls_plant-werks
                                iv_ekgrp   = iv_ekgrp
                                iv_gjahr   = lv_gjahr
                      IMPORTING ev_allowed = lv_allowed
                                ev_waers   = lv_waers ) = abap_false.
        " OPEN POINT: no budget row exists. Blocking is assumed. If the
        " business wants documents to pass when no budget is maintained,
        " replace the message below with CONTINUE.
        add_msg( EXPORTING iv_number = 002
                           iv_v1     = ls_plant-werks
                           iv_v2     = iv_ekgrp
                           iv_v3     = lv_gjahr
                 CHANGING  ct_msg    = rt_msg ).
        CONTINUE.
      ENDIF.

      " OPEN POINT: budget and document currency are assumed to match.
      " No conversion is performed - a mismatch is reported instead.
      IF iv_waers IS NOT INITIAL AND lv_waers IS NOT INITIAL
         AND iv_waers <> lv_waers.
        add_msg( EXPORTING iv_number = 008 iv_v1 = iv_waers iv_v2 = lv_waers
                 CHANGING  ct_msg = rt_msg ).
        CONTINUE.
      ENDIF.

      DATA(lv_consumed) = get_consumed( iv_werks   = ls_plant-werks
                                        iv_ekgrp   = iv_ekgrp
                                        iv_gjahr   = lv_gjahr
                                        iv_exclude = iv_ebeln )
                          + ls_plant-value.

      IF lv_consumed > lv_allowed.

        add_msg( EXPORTING iv_number = 001 CHANGING ct_msg = rt_msg ).

        add_msg( EXPORTING iv_type   = 'I'
                           iv_number = 004
                           iv_v1     = ls_plant-werks
                           iv_v2     = |{ lv_consumed NUMBER = USER }|
                           iv_v3     = |{ lv_allowed NUMBER = USER }|
                           iv_v4     = lv_waers
                 CHANGING  ct_msg    = rt_msg ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_allowed.

    CLEAR: ev_allowed, ev_waers.

    SELECT SINGLE budget, add_budget, waers
      FROM zmm_po_budget
      INTO @DATA(ls_bud)
      WHERE werks = @iv_werks
        AND ekgrp = @iv_ekgrp
        AND gjahr = @iv_gjahr.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ev_allowed = ls_bud-budget + ls_bud-add_budget.
    ev_waers   = ls_bud-waers.
    rv_found   = abap_true.

  ENDMETHOD.


  METHOD get_consumed.

    DATA(lv_from) = CONV bedat( |{ iv_gjahr }0101| ).
    DATA(lv_to)   = CONV bedat( |{ iv_gjahr }1231| ).

    SELECT SUM( p~effwr )
      FROM ekko AS k
      INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
      INTO @rv_value
      WHERE k~ekgrp  = @iv_ekgrp
        AND k~bedat BETWEEN @lv_from AND @lv_to
        AND k~ebeln <> @iv_exclude
        AND k~loekz  = @space
        AND p~werks  = @iv_werks
        AND p~knttp  = @gc_knttp_k
        AND p~loekz  = @space.

  ENDMETHOD.


  METHOD add_msg.

    DATA(ls_msg) = VALUE bapiret2( id         = gc_msgid
                                   type       = iv_type
                                   number     = iv_number
                                   message_v1 = iv_v1
                                   message_v2 = iv_v2
                                   message_v3 = iv_v3
                                   message_v4 = iv_v4 ).

    MESSAGE ID ls_msg-id TYPE 'S' NUMBER ls_msg-number
      WITH iv_v1 iv_v2 iv_v3 iv_v4 INTO ls_msg-message.

    APPEND ls_msg TO ct_msg.

  ENDMETHOD.

ENDCLASS.
