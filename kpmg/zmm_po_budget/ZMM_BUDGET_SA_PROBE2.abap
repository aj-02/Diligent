*&---------------------------------------------------------------------*
*& PROBE 2 - where the value lives on a scheduling agreement
*& SAPMM06E - paste at the anchor where XEKPO is populated,
*&            NOT at the start of FORM BUCHEN
*& Budget control on indirect purchase - WRICEF 050_BRD_FS
*& Arnav Johri, 24.08.2026
*&
*& PROBE 1 established: XEKPO-EFFWR and XEKPO-NETWR are both empty on a
*& scheduling agreement, and XEKPO-NETPR is populated. So a value is
*& derivable, and the only open question is WHICH QUANTITY to multiply
*& the price by.
*&
*& Two candidates, both computed below per item:
*&   V_TGT   KTMNG * NETPR / PEINH        the framework / target value
*&   V_SCH   sum(XEKET-MENGE) * NETPR / PEINH   what is actually scheduled
*&
*& PEINH is in the formula because NETPR is a price PER PRICE UNIT.
*& Leaving it out silently multiplies the value by 10 or 100 on any
*& material priced per 100.
*&
*& If XEKET is not a global in this program the block will not compile.
*& Comment out the inner LOOP marked ---- XEKET ---- and report back;
*& the same watchpoint trick will find the right schedule line table.
*&
*& Reads only. Changes nothing, blocks nothing, writes nothing.
*& DELETE the whole block, including BREAK-POINT, when finished.
*&---------------------------------------------------------------------*

*BOC PROBE 2 - budget control scheduling agreements  Arnav 24.08.2026

  TYPES: BEGIN OF ty_dbg2,
           ebelp TYPE ekpo-ebelp,   " item
           werks TYPE ekpo-werks,   " plant
           knttp TYPE ekpo-knttp,   " must be K to be counted
           loekz TYPE ekpo-loekz,   " deletion indicator
           menge TYPE ekpo-menge,   " order quantity, expected 0 on an SA
           ktmng TYPE ekpo-ktmng,   " target quantity
           netpr TYPE ekpo-netpr,   " net price  - confirmed populated
           peinh TYPE ekpo-peinh,   " price unit
           netwr TYPE ekpo-netwr,   " confirmed empty
           effwr TYPE ekpo-effwr,   " confirmed empty
           zwert TYPE ekpo-zwert,   " target value, if maintained
           lines TYPE i,            " how many schedule lines this item has
           sched TYPE ekpo-menge,   " total scheduled quantity
           v_tgt TYPE ekpo-netwr,   " CANDIDATE 1  target value
           v_sch TYPE ekpo-netwr,   " CANDIDATE 2  scheduled value
         END OF ty_dbg2.

  DATA: lt_dbg2       TYPE STANDARD TABLE OF ty_dbg2 WITH DEFAULT KEY,
        ls_dbg2       TYPE ty_dbg2,
        ls_p2_item    LIKE LINE OF xekpo,
        ls_p2_eket    LIKE LINE OF xeket,
        lv_p2_peinh   TYPE ekpo-peinh,
        lv_p2_sched   TYPE ekpo-menge,
        lv_p2_lines   TYPE i,
        lv_p2_items   TYPE i,
        lv_p2_kitems  TYPE i,
        lv_p2_eketall TYPE i,
        lv_p2_ktwrt   TYPE ekko-ktwrt,   " header target value
        lv_p2_bstyp   TYPE ekko-bstyp,   " L = scheduling agreement
        lv_p2_tot_tgt TYPE ekpo-netwr,   " CANDIDATE 1 total, K items only
        lv_p2_tot_sch TYPE ekpo-netwr,   " CANDIDATE 2 total, K items only
        lv_p2_tot_zwt TYPE ekpo-netwr.   " CANDIDATE 3 total, K items only

  CLEAR: lt_dbg2, lv_p2_items, lv_p2_kitems, lv_p2_eketall,
         lv_p2_tot_tgt, lv_p2_tot_sch, lv_p2_tot_zwt.

  lv_p2_bstyp = ekko-bstyp.
  lv_p2_ktwrt = ekko-ktwrt.

  DESCRIBE TABLE xekpo LINES lv_p2_items.
  DESCRIBE TABLE xeket LINES lv_p2_eketall.

  LOOP AT xekpo INTO ls_p2_item.

    CLEAR: ls_dbg2, lv_p2_sched, lv_p2_lines.

    lv_p2_peinh = ls_p2_item-peinh.
    IF lv_p2_peinh IS INITIAL.
      lv_p2_peinh = 1.
    ENDIF.

*   ------------------------------ XEKET ------------------------------
*   Comment this loop out if XEKET is unknown in this program.
    LOOP AT xeket INTO ls_p2_eket WHERE ebelp = ls_p2_item-ebelp.
      lv_p2_lines = lv_p2_lines + 1.
      lv_p2_sched = lv_p2_sched + ls_p2_eket-menge.
    ENDLOOP.
*   ------------------------------ XEKET ------------------------------

    ls_dbg2-ebelp = ls_p2_item-ebelp.
    ls_dbg2-werks = ls_p2_item-werks.
    ls_dbg2-knttp = ls_p2_item-knttp.
    ls_dbg2-loekz = ls_p2_item-loekz.
    ls_dbg2-menge = ls_p2_item-menge.
    ls_dbg2-ktmng = ls_p2_item-ktmng.
    ls_dbg2-netpr = ls_p2_item-netpr.
    ls_dbg2-peinh = ls_p2_item-peinh.
    ls_dbg2-netwr = ls_p2_item-netwr.
    ls_dbg2-effwr = ls_p2_item-effwr.
    ls_dbg2-zwert = ls_p2_item-zwert.
    ls_dbg2-lines = lv_p2_lines.
    ls_dbg2-sched = lv_p2_sched.

    ls_dbg2-v_tgt = ls_p2_item-ktmng * ls_p2_item-netpr / lv_p2_peinh.
    ls_dbg2-v_sch = lv_p2_sched      * ls_p2_item-netpr / lv_p2_peinh.

    APPEND ls_dbg2 TO lt_dbg2.

*   Totals over exactly the items the budget check would count
    IF ls_p2_item-knttp = 'K' AND ls_p2_item-loekz = space.
      lv_p2_kitems  = lv_p2_kitems + 1.
      lv_p2_tot_tgt = lv_p2_tot_tgt + ls_dbg2-v_tgt.
      lv_p2_tot_sch = lv_p2_tot_sch + ls_dbg2-v_sch.
      lv_p2_tot_zwt = lv_p2_tot_zwt + ls_p2_item-zwert.
    ENDIF.

  ENDLOOP.

* Read LT_DBG2 and the three LV_P2_TOT_* totals, then delete this block.
  BREAK-POINT.

*EOC PROBE 2 - budget control scheduling agreements
