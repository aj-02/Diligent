*&---------------------------------------------------------------------*
*& ZME_PROCESS_PO_CUST  ~  IF_EX_ME_PROCESS_PO_CUST~CHECK
*& Budget control on indirect purchase - WRICEF 050_BRD_FS
*&
*& INSERT POINT
*&   Immediately BEFORE the existing line:   CHECK sy-tcode NE 'ME29N'.
*&
*&   It must go before that line. CHECK exits the method when false, so
*&   anything placed after it is skipped for ME29N and for gv_pstyp = U.
*&
*& Relies on variables the method already builds:
*&   ls_header   TYPE mepoheader            (ebeln, ekgrp, bedat, waers)
*&   lt_items    TYPE purchase_order_items  (item references)
*&   INCLUDE mm_messages_mac is already at the top, so mmpur_* is available
*&   mmpur_context mmcnt_context_badi is already set earlier in the method
*&
*& If the block is ALREADY in the system, replace it in place between its
*& own *BOC <002> / *EOC <002> markers. Do not paste a second copy.
*&---------------------------------------------------------------------*

*BOC <002> Budget control on indirect purchase By Arnav on 19.08.2026
*& WRICEF 050_BRD_FS
*&
*& Placed here deliberately - it must stay ABOVE the CHECK statements
*& that follow, because CHECK exits the method and would skip this for
*& ME29N and for gv_pstyp = 'U'.
*&
*& Uses ls_header and lt_items, both already built above.
*&
*& Correction 03/09/26 - the message was collected but never displayed.
*& mmpur_message_forced only adds the text to the purchasing message
*& collector. ME21N renders a collected message against the document
*& object that owns it, and mmpur_remove_msg_by_context above re-keys the
*& BAdI messages by object id on every CHECK call, so a message with no
*& object id is dropped before it ever reaches the log display. The
*& ZMM_MSGS 007 block higher up in this method sets the id and calls
*& invalidate( ); this block now does the same.
*&---------------------------------------------------------------------*

    DATA: lv_bud_gjahr    TYPE gjahr,
          lv_bud_werks    TYPE werks_d,
          lv_bud_current  TYPE zmm_po_budget-budget,
          lv_bud_consumed TYPE zmm_po_budget-budget,
          lv_bud_allowed  TYPE zmm_po_budget-budget,
          lv_bud_from     TYPE bedat,
          lv_bud_to       TYPE bedat.

*   Added 03/09/26 - the object the budget message is reported against.
    DATA: ls_bud_ref   TYPE LINE OF purchase_order_items,
          ls_bud_data  TYPE mepoitem,
          lv_bud_objid TYPE mepoitem-id.
    DATA  lo_bud_item  LIKE ls_bud_ref-item.

    IF sy-tcode = 'ME21N' OR sy-tcode = 'ME22N'.

*     Budget year from the document date.
*     OPEN POINT: calendar year assumed, the FS does not state which.
      lv_bud_gjahr = ls_header-bedat(4).

*     Value of the account assigned items in this document. Only KNTTP = K
*     counts per the FS, and deleted items are ignored. Multiple plants in
*     one document are already rejected above, so one plant is enough.
      CLEAR: lv_bud_current, lv_bud_werks, lv_bud_objid, lo_bud_item.

*     Loop changed 03/09/26 from lt_details to lt_items. lt_details holds
*     item DATA only; the item REFERENCE is needed for invalidate( ) and
*     the item id is needed for mmpur_business_obj_id. Same rows either way.
*      LOOP AT lt_details INTO DATA(ls_bud_item)
*           WHERE knttp = 'K'
*             AND loekz = space.
*        lv_bud_werks   = ls_bud_item-werks.
*        lv_bud_current = lv_bud_current + ls_bud_item-effwr.
*      ENDLOOP.

      LOOP AT lt_items INTO ls_bud_ref.

        ls_bud_data = ls_bud_ref-item->get_data( ).

        IF ls_bud_data-knttp <> 'K' OR ls_bud_data-loekz <> space.
          CONTINUE.
        ENDIF.

        lv_bud_werks   = ls_bud_data-werks.
        lv_bud_current = lv_bud_current + ls_bud_data-effwr.

*       The first account assigned item carries the budget message.
        IF lv_bud_objid IS INITIAL.
          lv_bud_objid = ls_bud_data-id.
          lo_bud_item  = ls_bud_ref-item.
        ENDIF.

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
          mmpur_business_obj_id lv_bud_objid.  "Changes by Arnav on 03/09/26
          mmpur_message_forced 'E' 'ZMM_BUDGET' '002'
                               lv_bud_werks ls_header-ekgrp lv_bud_gjahr ''.
          IF lo_bud_item IS BOUND.
            lo_bud_item->invalidate( ).        "Changes by Arnav on 03/09/26
          ENDIF.
          ch_failed = abap_true.

        ELSEIF ls_header-waers IS NOT INITIAL
           AND ls_bud_master-waers IS NOT INITIAL
           AND ls_header-waers <> ls_bud_master-waers.

*         OPEN POINT: no currency conversion, a mismatch is reported.
          mmpur_business_obj_id lv_bud_objid.  "Changes by Arnav on 03/09/26
          mmpur_message_forced 'E' 'ZMM_BUDGET' '008'
                               ls_header-waers ls_bud_master-waers '' ''.
          IF lo_bud_item IS BOUND.
            lo_bud_item->invalidate( ).        "Changes by Arnav on 03/09/26
          ENDIF.
          ch_failed = abap_true.

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

            mmpur_business_obj_id lv_bud_objid. "Changes by Arnav on 03/09/26
            mmpur_message_forced 'E' 'ZMM_BUDGET' '001' '' '' '' ''.
            IF lo_bud_item IS BOUND.
              lo_bud_item->invalidate( ).      "Changes by Arnav on 03/09/26
            ENDIF.
            ch_failed = abap_true.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

*EOC <002> Budget control on indirect purchase By Arnav on 19.08.2026
