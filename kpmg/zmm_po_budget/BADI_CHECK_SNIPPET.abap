*&---------------------------------------------------------------------*
*& ZME_PROCESS_PO_CUST  ~  IF_EX_ME_PROCESS_PO_CUST~CHECK
*& Budget control on indirect purchase - WRICEF 050_BRD_FS
*&
*& INSERT POINT
*&   Immediately BEFORE the existing line:   CHECK sy-tcode NE 'ME29N'.
*&
*& The block is ALREADY in the system. Replace it in place between its own
*& *BOC <002> / *EOC <002> markers. Do not paste a second copy.
*&
*& Relies on variables the method already builds:
*&   ls_header   TYPE mepoheader   (ebeln, ekgrp, bedat, waers)
*&   lt_details  TYPE tab_mepoitem (werks, knttp, loekz, effwr)
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
