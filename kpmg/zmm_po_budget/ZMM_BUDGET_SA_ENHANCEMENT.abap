*&---------------------------------------------------------------------*
*& Implicit enhancement - SAPMM06E
*& Budget control on indirect purchase - WRICEF 050_BRD_FS
*& Author  Arnav Johri, 24.08.2026
*&
*& PASTE AT
*&   The anchor where XEKPO is populated - the one found with the
*&   watchpoint. NOT the start of FORM BUCHEN, where XEKPO is still empty.
*&
*& CLASSIC OPEN SQL ONLY
*&   SAPMM06E is an old program, so the syntax check does not run in
*&   strict mode from 7.40. The new Open SQL syntax is rejected with
*&   "the ABAP SQL statement uses additions that can only be used ...".
*&   Everything below therefore uses the classic form:
*&     - no commas in the field list
*&     - no @ before host variables
*&     - no inline @DATA( ) declarations
*&     - no string templates or && , offsets are used instead
*&   Keep to this if anything is added here later.
*&
*& THE VALUE OF AN SA ITEM
*&   EFFWR and NETWR are both empty on a scheduling agreement and NETPR
*&   is populated, so the value has to be derived. The first non zero of
*&   these wins, per item, and the SAME order is applied to the consumed
*&   history so both are measured the same way:
*&
*&     1  EFFWR                            effective value - the FS field
*&     2  NETWR                            net order value
*&     3  ZWERT                            target value
*&     4  KTMNG * NETPR / PEINH            target qty  x price
*&     5  sum(EKET-MENGE) * NETPR / PEINH  scheduled qty x price
*&
*&   PEINH is in the formula because NETPR is a price PER PRICE UNIT.
*&
*& OPEN POINT - see NOTES.md
*&   Whether an SA should consume its target value at creation or its
*&   scheduled value as lines are released is not stated in the FS.
*&
*& TO TEST THE BLOCK MESSAGE
*&   Maintain a row in ZMM_PO_BUDGET (SM30) for the plant / purchasing
*&   group / year of the test SA with a deliberately small BUDGET, then
*&   save an SA worth more. Without a row you get message 002 instead.
*&---------------------------------------------------------------------*

*BOC Budget control on indirect purchase - scheduling agreements
*    WRICEF 050_BRD_FS  By Arnav on 24.08.2026

  TYPES: BEGIN OF ty_sab_row,
           ebeln TYPE ekpo-ebeln,
           ebelp TYPE ekpo-ebelp,
           effwr TYPE ekpo-effwr,
           netwr TYPE ekpo-netwr,
           zwert TYPE ekpo-zwert,
           ktmng TYPE ekpo-ktmng,
           netpr TYPE ekpo-netpr,
           peinh TYPE ekpo-peinh,
         END OF ty_sab_row.

  TYPES: BEGIN OF ty_sab_sched,
           ebeln TYPE eket-ebeln,
           ebelp TYPE eket-ebelp,
           menge TYPE eket-menge,
         END OF ty_sab_sched.

  DATA: lt_sab_hist     TYPE STANDARD TABLE OF ty_sab_row WITH DEFAULT KEY,
        lt_sab_need     TYPE STANDARD TABLE OF ty_sab_row WITH DEFAULT KEY,
        lt_sab_sched    TYPE STANDARD TABLE OF ty_sab_sched WITH DEFAULT KEY,
        ls_sab_hist     TYPE ty_sab_row,
        ls_sab_sched    TYPE ty_sab_sched,
        ls_sab_item     LIKE LINE OF xekpo,
        ls_sab_eket     LIKE LINE OF xeket,
        ls_sab_master   TYPE zmm_po_budget,
        lv_sab_gjahr    TYPE gjahr,
        lv_sab_werks    TYPE werks_d,
        lv_sab_ekgrp    TYPE ekko-ekgrp,
        lv_sab_ebeln    TYPE ekko-ebeln,
        lv_sab_waers    TYPE ekko-waers,
        lv_sab_peinh    TYPE ekpo-peinh,
        lv_sab_qty      TYPE ekpo-menge,
        lv_sab_val      TYPE ekpo-netwr,
        lv_sab_current  TYPE zmm_po_budget-budget,
        lv_sab_consumed TYPE zmm_po_budget-budget,
        lv_sab_allowed  TYPE zmm_po_budget-budget,
        lv_sab_from     TYPE bedat,
        lv_sab_to       TYPE bedat.

  IF sy-tcode = 'ME31L' OR sy-tcode = 'ME32L'.
* Widen here if the old style PO and contract transactions are also to
* be covered. They bypass the BAdI too, so today they are unchecked.
* OR sy-tcode = 'ME21' OR sy-tcode = 'ME22'
* OR sy-tcode = 'ME31K' OR sy-tcode = 'ME32K'

    CLEAR: lt_sab_hist, lt_sab_need, lt_sab_sched,
           lv_sab_current, lv_sab_consumed, lv_sab_werks.

*   Header fields are copied to local variables. EKKO appears in the
*   FROM clause below, so referring to the work area EKKO-... inside the
*   same WHERE clause would be ambiguous.
    lv_sab_ekgrp = ekko-ekgrp.
    lv_sab_ebeln = ekko-ebeln.
    lv_sab_waers = ekko-waers.

*   OPEN POINT: calendar year assumed, as in the PO block.
    IF ekko-bedat IS NOT INITIAL.
      lv_sab_gjahr = ekko-bedat(4).
    ELSE.
      lv_sab_gjahr = sy-datum(4).
    ENDIF.

*   ================================================================
*   1  Value of the account assigned items in THIS document
*   ================================================================
    LOOP AT xekpo INTO ls_sab_item
         WHERE knttp = 'K'
           AND loekz = space.

      lv_sab_werks = ls_sab_item-werks.

      lv_sab_peinh = ls_sab_item-peinh.
      IF lv_sab_peinh IS INITIAL.
        lv_sab_peinh = 1.
      ENDIF.

      CLEAR lv_sab_val.

      IF ls_sab_item-effwr <> 0.
        lv_sab_val = ls_sab_item-effwr.
      ELSEIF ls_sab_item-netwr <> 0.
        lv_sab_val = ls_sab_item-netwr.
      ELSEIF ls_sab_item-zwert <> 0.
        lv_sab_val = ls_sab_item-zwert.
      ELSEIF ls_sab_item-ktmng <> 0.
        lv_sab_val = ls_sab_item-ktmng * ls_sab_item-netpr / lv_sab_peinh.
      ELSE.
*       Nothing at item level - fall back to the schedule lines
        CLEAR lv_sab_qty.
        LOOP AT xeket INTO ls_sab_eket WHERE ebelp = ls_sab_item-ebelp.
          lv_sab_qty = lv_sab_qty + ls_sab_eket-menge.
        ENDLOOP.
        lv_sab_val = lv_sab_qty * ls_sab_item-netpr / lv_sab_peinh.
      ENDIF.

      lv_sab_current = lv_sab_current + lv_sab_val.

    ENDLOOP.

*   Nothing account assigned - the document is not budget relevant.
*   NOTE: there is no "multiple plant not allowed" check on this path,
*   so the LAST plant found wins. If an SA can carry items for more than
*   one plant this needs a per plant bucket. Confirm functionally.
    IF lv_sab_werks IS NOT INITIAL.

*     ==============================================================
*     2  The budget row
*     ==============================================================
      SELECT SINGLE budget add_budget waers
        FROM zmm_po_budget
        INTO CORRESPONDING FIELDS OF ls_sab_master
        WHERE werks = lv_sab_werks
          AND ekgrp = lv_sab_ekgrp
          AND gjahr = lv_sab_gjahr.

      IF sy-subrc <> 0.

*       OPEN POINT: no budget maintained. Blocking is assumed, as in the
*       PO block. Change to type 'W' if documents should pass instead.
        MESSAGE e002(zmm_budget)
           WITH lv_sab_werks lv_sab_ekgrp lv_sab_gjahr.

      ELSEIF lv_sab_waers IS NOT INITIAL
         AND ls_sab_master-waers IS NOT INITIAL
         AND lv_sab_waers <> ls_sab_master-waers.

*       OPEN POINT: no currency conversion. A mismatch is reported.
        MESSAGE e008(zmm_budget)
           WITH lv_sab_waers ls_sab_master-waers.

      ELSE.

        lv_sab_allowed = ls_sab_master-budget + ls_sab_master-add_budget.

*       Year boundaries by offset - no string templates in this program
        CLEAR: lv_sab_from, lv_sab_to.
        lv_sab_from(4)   = lv_sab_gjahr.
        lv_sab_from+4(4) = '0101'.
        lv_sab_to(4)     = lv_sab_gjahr.
        lv_sab_to+4(4)   = '1231'.

*       ============================================================
*       3  Value already committed by OTHER documents in the year
*
*       The rows are read and valued in ABAP rather than summed in SQL,
*       because SUM( effwr ) returns zero for scheduling agreements and
*       would make SA spend invisible to the running total. The same
*       order of precedence as section 1 is applied here.
*
*       No BSTYP restriction, so purchase orders, contracts and other
*       scheduling agreements all draw on the same bucket.
*       This document is excluded, otherwise a change through ME32L
*       counts its own value twice - once from the database and once
*       from the document in memory.
*       ============================================================
        SELECT p~ebeln p~ebelp p~effwr p~netwr
               p~zwert p~ktmng p~netpr p~peinh
          FROM ekko AS k
          INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
          INTO TABLE lt_sab_hist
          WHERE k~ekgrp  = lv_sab_ekgrp
            AND k~bedat BETWEEN lv_sab_from AND lv_sab_to
            AND k~ebeln <> lv_sab_ebeln
            AND k~loekz  = space
            AND p~werks  = lv_sab_werks
            AND p~knttp  = 'K'
            AND p~loekz  = space.

*       Only rows carrying no value at item level need schedule lines
        LOOP AT lt_sab_hist INTO ls_sab_hist.
          IF ls_sab_hist-effwr = 0
         AND ls_sab_hist-netwr = 0
         AND ls_sab_hist-zwert = 0
         AND ls_sab_hist-ktmng = 0.
            APPEND ls_sab_hist TO lt_sab_need.
          ENDIF.
        ENDLOOP.

        IF lt_sab_need IS NOT INITIAL.
          SELECT ebeln ebelp menge
            FROM eket
            INTO TABLE lt_sab_sched
            FOR ALL ENTRIES IN lt_sab_need
            WHERE ebeln = lt_sab_need-ebeln
              AND ebelp = lt_sab_need-ebelp.
        ENDIF.

        LOOP AT lt_sab_hist INTO ls_sab_hist.

          lv_sab_peinh = ls_sab_hist-peinh.
          IF lv_sab_peinh IS INITIAL.
            lv_sab_peinh = 1.
          ENDIF.

          CLEAR lv_sab_val.

          IF ls_sab_hist-effwr <> 0.
            lv_sab_val = ls_sab_hist-effwr.
          ELSEIF ls_sab_hist-netwr <> 0.
            lv_sab_val = ls_sab_hist-netwr.
          ELSEIF ls_sab_hist-zwert <> 0.
            lv_sab_val = ls_sab_hist-zwert.
          ELSEIF ls_sab_hist-ktmng <> 0.
            lv_sab_val = ls_sab_hist-ktmng * ls_sab_hist-netpr / lv_sab_peinh.
          ELSE.
            CLEAR lv_sab_qty.
            LOOP AT lt_sab_sched INTO ls_sab_sched
                 WHERE ebeln = ls_sab_hist-ebeln
                   AND ebelp = ls_sab_hist-ebelp.
              lv_sab_qty = lv_sab_qty + ls_sab_sched-menge.
            ENDLOOP.
            lv_sab_val = lv_sab_qty * ls_sab_hist-netpr / lv_sab_peinh.
          ENDIF.

          lv_sab_consumed = lv_sab_consumed + lv_sab_val.

        ENDLOOP.

        lv_sab_consumed = lv_sab_consumed + lv_sab_current.

*       ============================================================
*       4  The check
*       ============================================================
        IF lv_sab_consumed > lv_sab_allowed.
          MESSAGE e001(zmm_budget).
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

*EOC Budget control on indirect purchase - scheduling agreements
