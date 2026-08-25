*&---------------------------------------------------------------------*
*& PROBE ONLY - implicit enhancement, SAPMM06E, start of FORM BUCHEN
*& Budget control on indirect purchase - WRICEF 050_BRD_FS
*& Arnav Johri, 24.08.2026
*&
*& Reads values and stops. Changes nothing, blocks nothing, writes
*& nothing. Purpose is to answer one question: which amount field is
*& actually populated on a scheduling agreement item.
*&
*& The BREAK-POINT statement at the bottom is compiled into the code, so
*& it stops whether or not editor breakpoints are behaving. That is the
*& point of it. DELETE IT once you have read the values.
*&
*& If the development box is shared, use   BREAK <your-sap-user>.
*& instead of BREAK-POINT. so only your sessions stop.
*&---------------------------------------------------------------------*

*BOC PROBE - budget control scheduling agreements  Arnav 24.08.2026

  TYPES: BEGIN OF ty_dbg_line,
           ebelp TYPE ekpo-ebelp,   " item
           werks TYPE ekpo-werks,   " plant
           knttp TYPE ekpo-knttp,   " acct assignment, must be K
           loekz TYPE ekpo-loekz,   " deletion indicator
           menge TYPE ekpo-menge,   " quantity
           ktmng TYPE ekpo-ktmng,   " target quantity (outline agreement)
           netpr TYPE ekpo-netpr,   " net price
           netwr TYPE ekpo-netwr,   " net order value
           brtwr TYPE ekpo-brtwr,   " gross order value
           effwr TYPE ekpo-effwr,   " effective value  <-- the FS field
           zwert TYPE ekpo-zwert,   " target value (outline agreement)
         END OF ty_dbg_line.

  DATA: lt_dbg_items   TYPE STANDARD TABLE OF ty_dbg_line WITH DEFAULT KEY,
        ls_dbg_line    TYPE ty_dbg_line,
        ls_dbg_item    LIKE LINE OF xekpo,
        lv_dbg_tcode   TYPE sy-tcode,
        lv_dbg_ebeln   TYPE ekko-ebeln,
        lv_dbg_ekgrp   TYPE ekko-ekgrp,
        lv_dbg_bedat   TYPE ekko-bedat,
        lv_dbg_waers   TYPE ekko-waers,
        lv_dbg_bstyp   TYPE ekko-bstyp,
        lv_dbg_gjahr   TYPE gjahr,
        lv_dbg_all     TYPE i,
        lv_dbg_k       TYPE i,
        lv_dbg_effwr   TYPE ekpo-effwr,
        lv_dbg_netwr   TYPE ekpo-netwr,
        lv_dbg_brtwr   TYPE ekpo-brtwr,
        lv_dbg_zwert   TYPE ekpo-zwert.

  CLEAR: lt_dbg_items, lv_dbg_all, lv_dbg_k,
         lv_dbg_effwr, lv_dbg_netwr, lv_dbg_brtwr, lv_dbg_zwert.

* ------------------------------------------------ header work area ---
  lv_dbg_tcode = sy-tcode.
  lv_dbg_ebeln = ekko-ebeln.
  lv_dbg_ekgrp = ekko-ekgrp.
  lv_dbg_bedat = ekko-bedat.
  lv_dbg_waers = ekko-waers.
  lv_dbg_bstyp = ekko-bstyp.

  IF ekko-bedat IS NOT INITIAL.
    lv_dbg_gjahr = ekko-bedat(4).
  ENDIF.

* ------------------------------------------------ item table ---------
  DESCRIBE TABLE xekpo LINES lv_dbg_all.

  LOOP AT xekpo INTO ls_dbg_item.

    CLEAR ls_dbg_line.
    ls_dbg_line-ebelp = ls_dbg_item-ebelp.
    ls_dbg_line-werks = ls_dbg_item-werks.
    ls_dbg_line-knttp = ls_dbg_item-knttp.
    ls_dbg_line-loekz = ls_dbg_item-loekz.
    ls_dbg_line-menge = ls_dbg_item-menge.
    ls_dbg_line-ktmng = ls_dbg_item-ktmng.
    ls_dbg_line-netpr = ls_dbg_item-netpr.
    ls_dbg_line-netwr = ls_dbg_item-netwr.
    ls_dbg_line-brtwr = ls_dbg_item-brtwr.
    ls_dbg_line-effwr = ls_dbg_item-effwr.
    ls_dbg_line-zwert = ls_dbg_item-zwert.
    APPEND ls_dbg_line TO lt_dbg_items.

*   Totals over the items the budget check would actually count
    IF ls_dbg_item-knttp = 'K' AND ls_dbg_item-loekz = space.
      lv_dbg_k     = lv_dbg_k + 1.
      lv_dbg_effwr = lv_dbg_effwr + ls_dbg_item-effwr.
      lv_dbg_netwr = lv_dbg_netwr + ls_dbg_item-netwr.
      lv_dbg_brtwr = lv_dbg_brtwr + ls_dbg_item-brtwr.
      lv_dbg_zwert = lv_dbg_zwert + ls_dbg_item-zwert.
    ENDIF.

  ENDLOOP.

* Stops here. Read LT_DBG_ITEMS and the LV_DBG_* totals, then delete
* this statement and the block above it.
  BREAK-POINT.

*EOC PROBE - budget control scheduling agreements
