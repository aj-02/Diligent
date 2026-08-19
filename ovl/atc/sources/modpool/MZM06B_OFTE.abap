*--- MAIN PROGRAM: MZM06B_OFTE ---*
*eject
************************************************************************
*                                                                      *
*  Unterroutinen Banfabwicklung                                        *
*       Routinen nach Bereichen;  hier zur Textverarbeitung            *
*                                                                      *
************************************************************************
* 96632  25.02.1998  3.1I  CF  Übernahme aus Kd.auftrag bei ME51

  include mm06bfte_inline_text_pbo .  " INLINE_TEXT_PBO

  include mm06bfte_inline_text_pai .  " INLINE_TEXT_PAI
  include mm06bfte_search_char .  " SEARCH_CHAR

  include mm06bfte_txit_lesen .  " TXIT_LESEN


  include mm06bfte_text_lesen .  " TEXT_LESEN

  include mm06bfte_langtext_kennzeichen_ .  " LANGTEXT_KENNZEICHEN_SETZE

  include mm06bfte_tinlinetab_lesen .  " TINLINETAB_LESEN


  include mm06bfte_tinlinetab_fuellen .  " TINLINETAB_FUELLEN

  include mm06bfte_text_initialisieren .  " TEXT_INITIALISIEREN

  include mm06bfte_text_editieren .  " TEXT_EDITIEREN


  include mm06bfte_theadtab_fuellen .  " THEADTAB_FUELLEN

  include mm06bfte_texte_umbenennen .  " TEXTE_UMBENENNEN

  include mm06bfte_txid_lesen_position .  " TXID_LESEN_POSITION


  include mm06bfte_next_text .  " NEXT_TEXT


  include mm06bfte_positions_texte_selek .  " POSITIONS_TEXTE_SELEKTIERE

  include mm06bfte_theadtab_update .  " THEADTAB_UPDATE


  include mm06bfte_positions_texte_bearb .  " POSITIONS_TEXTE_BEARBEITEN


  include mm06bfte_unfixierte_texte_loes .  " UNFIXIERTE_TEXTE_LOESCHEN



  include mm06bfte_positions_texte_loesc .  " POSITIONS_TEXTE_LOESCHEN


  include mm06bfte_positionstext_ueber04 .  " POSITIONSTEXT_UEBERNAHME



  include mm06bfte_icdtxt_banf_update .  " ICDTXT_BANF_UPDATE


  include mm06bfte_positionstext_ueberna .  " POSITIONSTEXT_UEBERNAHME_2


  include mm06bfte_text_fcode_position .  " TEXT_FCODE_POSITION


  include mm06bfte_text_loeschen .  " TEXT_LOESCHEN


  include mm06bfte_text_markierung .  " TEXT_MARKIERUNG

  include mm06bfte_text_popup .  " TEXT_POPUP


  include mm06bfte_text_block .  " TEXT_BLOCK


  include mm06bfte_referenz_key_setzen .  " REFERENZ_KEY_SETZEN
  include mm06bfte_check_changes .  " CHECK_CHANGES
  include mm06bfte_mpn_pruefen .  " MPN_PRUEFEN
  include mm06bfte_ematn .  " EMATN

  include mm06bfte_textflag .  " TEXTFLAG

  include mm06bfte_read_item_texts .  " READ_ITEM_TEXTS

  include mm06bfte_text_refresh.
*&---------------------------------------------------------------------*
*&      Form  new_me_rel_pr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form new_me_rel_pr.

    check t_geban_new-menge le t_geban_old-menge.

    data : l_t16fk like t16fk occurs 0 with header line,
           l_16fs  type t16fs.
    refresh l_t16fk.
    clear l_t16fk.
    data : begin of ist_frga occurs 0,
             frga(1) type n,
           end of ist_frga.
    data : begin of ist_frgc occurs 0,
             frgc(2) type c,
           end of ist_frgc.


    select * appending corresponding fields of table l_t16fk
                 from t16fk
                  where frggr eq eban-frggr
                  and   frgsx eq eban-frgst.
*                  AND   frgkx NOT IN ('B','2').
    select single * from t16fs into l_16fs
                    where frggr eq eban-frggr
                    and   frgsx eq eban-frgst.
    loop at l_t16fk.
      if l_t16fk-frga8 eq 'X'.
        ist_frga-frga = 8.
        append ist_frga.
      elseif l_t16fk-frga7 eq 'X'.
        ist_frga-frga = 7.
        append ist_frga.
      elseif l_t16fk-frga6 eq 'X'.
        ist_frga-frga = 6.
        append ist_frga.
      elseif l_t16fk-frga5 eq 'X'.
        ist_frga-frga = 5.
        append ist_frga.
      elseif l_t16fk-frga4 eq 'X'.
        ist_frga-frga = 4.
        append ist_frga.
      elseif l_t16fk-frga3 eq 'X'.
        ist_frga-frga = 3.
        append ist_frga.
      elseif l_t16fk-frga2 eq 'X'.
        ist_frga-frga = 2.
        append ist_frga.
      elseif l_t16fk-frga1 eq 'X'.
        ist_frga-frga = 1.
        append ist_frga.
      endif.
    endloop.
    sort ist_frga.
    delete adjacent duplicates from ist_frga.

    loop at ist_frga.
      case ist_frga-frga.
        when 1.
          move l_16fs-frgc1 to ist_frgc-frgc.
          append ist_frgc.
          if l_16fs-frgc1 = rm06b-frgab.
            exit.
          endif.
        when 2.
          move l_16fs-frgc2 to ist_frgc-frgc.
          append ist_frgc.
          if l_16fs-frgc2 = rm06b-frgab.
            exit.
          endif.
        when 3.
          move l_16fs-frgc3 to ist_frgc-frgc.
          append ist_frgc.
          if l_16fs-frgc3 = rm06b-frgab.
            exit.
          endif.
        when 4.
          move l_16fs-frgc4 to ist_frgc-frgc.
          append ist_frgc.
          if l_16fs-frgc4 = rm06b-frgab.
            exit.
          endif.
        when 5.
          move l_16fs-frgc5 to ist_frgc-frgc.
          append ist_frgc.
          if l_16fs-frgc5 = rm06b-frgab.
            exit.
          endif.
        when 6.
          move l_16fs-frgc6 to ist_frgc-frgc.
          append ist_frgc.
          if l_16fs-frgc6 = rm06b-frgab.
            exit.
          endif.
        when 7.
          move l_16fs-frgc7 to ist_frgc-frgc.
          append ist_frgc.
          if l_16fs-frgc7 = rm06b-frgab.
            exit.
          endif.
        when 8.
          move l_16fs-frgc8 to ist_frgc-frgc.
          append ist_frgc.
          if l_16fs-frgc8 = rm06b-frgab.
            exit.
          endif.
      endcase.
    endloop.
    clear t168-steu2.
* shibu 18/8/05
* If any increase in Qty or Price then Reset Release Strategy to initial
    if g_reset_rel = 'X'.
      refresh ist_frgc.
      clear ist_frgc.
    endif.

* end of addition

    loop at ist_frgc.
*      IF t_geban_new-frgzu EQ t_geban_old-frgzu.
*        EXIT.
*      ENDIF.
      rm06b-frgab = ist_frgc-frgc.

      perform okcode_setf.
     l_new_frgzu = eban-frgzu. "27.12.2005
*     perform buchen.
    endloop.

  endform.                    " new_me_rel_pr
*&---------------------------------------------------------------------*
*&      Form  get_bdp_info
*&---------------------------------------------------------------------*
*   Check whether Input PR No having BDP clasue which is available
* in zmm_annual_limit or not, If so then do other checks
* Added by shibu on 29.06.2005
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form get_bdp_info.
    tables: zmm_bdp_level.

    if not eban-banfn is initial and
    rm06b-frgab = '01'.

      select single * from eban
        where banfn = eban-banfn.
      if sy-subrc = 0.
        select single * from zmm_annual_limit
            where bdpcode = eban-zzbdp.
*        IF sy-subrc = 0.
        select banfn bnfpo werks menge waers preis peinh  badat
        frgst frggr zzcpfno zzesclevel zzbdp frgst lfdat loekz  from
         eban into corresponding fields of table ist_eban01
             where banfn = eban-banfn.
*        ENDIF.
      endif.
    endif.

    read table ist_eban01 into wa_eban01 with key loekz = space.

    select single * from  zmm_bdp_level
       where bdpcode = wa_eban01-zzbdp.

    if sy-subrc = 0.
      g_bdp_exist = 'X'.
    else.
      g_bdp_exist = space.
    endif.

  endform.                    " get_bdp_info
*&---------------------------------------------------------------------*
*&      Form  get_pr_tot
*&---------------------------------------------------------------------*
* Calculate Total PR value.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form get_pr_tot tables it_eban01.

*    data: wa_eban01 like ist_eban01.
    data: l_ffact like tcurf-ffact.
    data: l_estprice like  eban-preis .
    data: l_dat30 like eban-badat.
    data: l_dd(2),
          l_mm(2),
          l_yy(2).
    data: l_xdat1(8),
          l_xdat2(8),
          l_gdatu1(8),
          l_gdatu2(8).
    data:  l_ukurs like tcurr-ukurs,
           l_ukurs1 like tcurr-ukurs.
    data: l_tot1 type ekpo-netwr ,
          l_tot2 type ekpo-netwr ,
          l_tot3 type ekpo-netwr.
*    data: l_totval type j_1iaddval.
    data:  l_totval type    scprcurr.
*    data: l_gtotval  type j_1iaddval .

    data: l_gtotval  type scprcurr .
    data: l_year  like  bkpf-gjahr.
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Get Fiscal Year.
    read table ist_eban01 into wa_eban01 index 1.

    call function 'FI_PERIOD_DETERMINE'
         exporting
              i_budat     = wa_eban01-lfdat
              i_periv     = 'V3'
         importing
              e_gjahr     = l_year
         exceptions
              fiscal_year = 1.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

*---------------------------------------------------------------------*

    loop  at it_eban01 into wa_eban01.
      clear:   l_ffact, l_estprice ,
               l_dat30,l_dd, l_mm,l_yy,
               l_xdat1,l_xdat2 ,l_gdatu1,l_gdatu2,
               l_ukurs,l_totval,l_gtotval .

      if wa_eban01-waers <> 'INR'.
        select single ffact into l_ffact from tcurf
              where  fcurr = wa_eban01-waers
              and    tcurr = 'INR'.
        if sy-subrc <> 0.
          l_ffact = 1.
        endif.
      else.
        l_ffact = 1.
      endif.

      if wa_eban01-peinh <> 0.
        l_estprice = ( wa_eban01-preis * l_ffact ) / wa_eban01-peinh.
      else.
        l_estprice = wa_eban01-preis * l_ffact.
      endif.

      l_dat30 = wa_eban01-badat - 30.
      l_dd = l_dat30+6(2).
      l_mm = l_dat30+4(2).
      l_yy = l_dat30+0(4).
      concatenate l_dd l_mm l_yy into l_xdat1.
      call function 'CONVERSION_EXIT_INVDT_INPUT'
           exporting
                input  = l_xdat1
           importing
                output = l_gdatu1.
****************************************************************
      clear: l_dd,l_mm,l_yy.
      l_dd = wa_eban01-badat+6(2).
      l_mm = wa_eban01-badat+4(2).
      l_yy = wa_eban01-badat+0(4).
      concatenate l_dd l_mm l_yy into l_xdat2.
      call function 'CONVERSION_EXIT_INVDT_INPUT'
           exporting
                input  = l_xdat2
           importing
                output = l_gdatu2.


      select single ukurs into l_ukurs from tcurr
   where fcurr = wa_eban01-waers and
         tcurr = 'INR' and
         kurst = 'M' and
         gdatu in
         ( select min( gdatu ) from tcurr where
         fcurr = wa_eban01-waers and
         tcurr = 'INR' and
         kurst = 'M' and
         gdatu lt l_gdatu1 and
         gdatu ge l_gdatu2 ).

      if sy-subrc <> 0.
        select single ukurs into l_ukurs from tcurr
          where fcurr = wa_eban01-waers and
                tcurr = 'INR' and
                kurst = 'M'.
        if sy-subrc <> 0.
          l_ukurs = 1.
        endif.
      endif.

      if wa_eban01-waers = 'INR'.

        l_totval = wa_eban01-menge * l_estprice.
        l_totval = l_totval / 1000.
      else.
* Division by 100000000 for Fixed Arithmetic Operation.
*        l_totval = wa_eban01-menge * l_estprice * l_ukurs / l_ffact.
        l_totval = wa_eban01-menge * l_estprice.
        l_totval = l_totval / 10000.
        l_totval = l_totval * l_ukurs / l_ffact.
        l_totval = l_totval / 10000.
*        l_totval = l_totval / 100000000.
      endif.
      l_gtotval = l_gtotval + l_totval.
**************Start of change on 02.07.03*********************

      wa_eban01-prtot = l_gtotval .
*---------------------------------------------------------------------*
* Get Finanacial  Year
*---------------------------------------------------------------------*
      call function 'FI_PERIOD_DETERMINE'
           exporting
                i_budat     = wa_eban01-lfdat
                i_periv     = 'V3'
           importing
                e_gjahr     = l_year
           exceptions
                fiscal_year = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
*---------------------------------------------------------------------*
      wa_eban01-fyear = l_year .
      modify it_eban01 from wa_eban01.
    endloop.

  endform.                    " get_pr_tot
*&---------------------------------------------------------------------*
*&      Form  get_detail_T16
*&---------------------------------------------------------------------*
*       Get Details from table T16FS AND T16FK: By Shibu
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form get_detail_t16.

*    tables zmm_bdp_level.
    data: l_found .
    data: l_cf .
    data: l_chk_role.
    data: l_di .
    data: l_cnt like sy-index .
    data: ist_annual_limit  type table of zmm_annual_limit .
    data: wa_annual_limit like zmm_annual_limit.
    data: ist_t16fs  type table of t16fs.
    data: ist_t16fk  type table of t16fk.
    data: l_fname(15).
    data: l_index .
    data: l_f.
    data: l_prval like zmm_pr_rel_value-prvalue.
    data: l_pr_tot like zmm_pr_rel_value-prvalue.
    data: l_tot_val like zmm_pr_rel_value-prvalue.
    data: l_tot_rel  like zmm_pr_rel_value-prvalue.
    data: l_year like bkpf-gjahr,
          l_lfyear like bkpf-gjahr .
*    DATA: wa_rel_val LIKE  zmm_pr_rel_value.
*    DATA: ist_rel_val TYPE TABLE OF zmm_pr_rel_value WITH HEADER LINE.
    data: l_annl_lmt like zmm_annual_limit-limit.
    data: wa_agr like ist_agr.
    data: begin of ist_lv occurs 0,
          frgc  type t16fs-frgc1,
          end of ist_lv.

    data: begin of ist_t16fk_fld occurs 0,
            fidx like  sy-index ,
          end of ist_t16fk_fld.

    field-symbols: <val> type any.
    field-symbols: <fs> type t16fk.
    field-symbols: <fs1> type t16fs.

    data: wa_t16fk type t16fk.
    data: begin of ist_frgst occurs 0,
            sign(1),
            option(2),
            low  like abdbg-tabline,
            high like abdbg-tabline,
    end   of ist_frgst.

    data: begin of ist_frggr occurs 0,
            sign(1),
            option(2),
            low  like abdbg-tabline,
            high like abdbg-tabline,
    end   of ist_frggr.
    data: ist_rcode like ist_lv occurs 0.
    data: ist_pr_rel_val   type table of zmm_pr_rel_value .
    data: wa_pr_rel_val    type  zmm_pr_rel_value .
*----------------------------------------------------------------------*
    refresh : ist_frgst,ist_frggr .
    clear l_cf.
    loop at ist_eban01 into wa_eban01.
      ist_frgst-sign = 'I'.
      ist_frgst-option = 'EQ'.
      ist_frgst-low = wa_eban01-frgst.
      append ist_frgst.
      ist_frggr-sign = 'I'.
      ist_frggr-option = 'EQ'.
      ist_frggr-low = wa_eban01-frggr.
      append ist_frggr.
    endloop.

    if not ( ist_frgst is initial or ist_frggr is initial ).

      select * from t16fk into table ist_t16fk
            where frgsx in ist_frgst and
                  frggr in ist_frggr and
                  frgkx = 'B'.

      loop at ist_t16fk assigning  <fs>.
        do 8 times.
          l_index = sy-index.
          concatenate '<FS>-FRGA' l_index into l_fname.
          assign  (l_fname) to <val>.
          if  <val>  = 'X'.
            l_f = sy-index.
          endif.
        enddo.
        ist_t16fk_fld-fidx = l_f.
        append ist_t16fk_fld .
      endloop.

      sort ist_t16fk_fld by fidx.
    delete adjacent duplicates from ist_t16fk_fld comparing all fields .
      select * from t16fs into table ist_t16fs
             where frgsx in ist_frgst and
                 frggr in ist_frggr  .

      if sy-subrc = 0.
        loop at ist_t16fs assigning  <fs1>.
          do 8 times.
            clear l_index.
         read table ist_t16fk_fld into l_index with key fidx = sy-index.
            if sy-subrc = 0.
              l_f  = sy-index.
              concatenate '<FS1>-FRGC' l_f into l_fname.
              assign  (l_fname) to <val>.
              if not <val> is initial  .
                ist_lv-frgc = <val> .
                append ist_lv .
              endif.
            endif.
          enddo.
        endloop.
      endif.
    endif.
* If Release code determined is L1,1A,1B,1C,1D,1E,1F Then Make Cpfno
* field mandtory in PR.
    clear: l_di,l_cnt.
    describe table ist_lv lines l_cnt .
    loop at ist_lv.
      if ist_lv-frgc = 'L1' or
         ist_lv-frgc = '1A' or
         ist_lv-frgc = '1B' or
         ist_lv-frgc = '1C' or
         ist_lv-frgc = '1D' or
         ist_lv-frgc = '1E' or
         ist_lv-frgc = '1F' .
        l_cf = 'X'.
      elseif ist_lv-frgc = 'DI'.
        l_di = 'X'.
      endif.
    endloop.

* If Release code is not fall in above derived rel code; then skip
*validation.

    if l_cf = 'X'.

      read table ist_eban01 into wa_eban01 with key loekz = space.

      if l_cnt = 2.
        if wa_eban01-zzcpfno is initial and
          l_cf = 'X'.  "AND l_di = 'X' .  01/08/05
          message e212(zmm).
        endif.
      elseif l_cnt = 1 and  l_cf = 'X'.
        if wa_eban01-zzcpfno is initial .
          message e212(zmm).
        endif.
      endif.


* Get Roles from AGR_USERS.
      perform get_pos_role tables  ist_agr.
      clear l_chk_role.
* Check whether derived  Roles belongs to DI/DF/MD/BO/EC ..
      loop at ist_agr into wa_agr.
        if wa_agr+21(2) = 'DI' or
           wa_agr+21(2) = 'DF' or
           wa_agr+21(2) = 'MD' or
           wa_agr+21(2) = 'BO' or
           wa_agr+21(2) = 'EC' or
           wa_agr+21(2) = 'BV' .
          l_chk_role = 'X'.
          exit.
        else.
          l_chk_role = space.
        endif.

      endloop.

*    IF  l_chk_role NE 'X' OR l_cf = 'X'. "29/07/05

      if  ( l_chk_role ne 'X' and l_cnt = 2  ) or
          ( l_cf = 'X'  and l_cnt = 1 ).


*    read table ist_eban01 into wa_eban01 index 1. "26/07/05
*      READ TABLE ist_eban01 INTO wa_eban01 WITH KEY loekz = space.
*
**    select single * from  zmm_bdp_level
**       where bdpcode = wa_eban01-zzbdp.
*
*      IF wa_eban01-zzcpfno IS INITIAL AND l_cf = 'X'.
*        MESSAGE e212(zmm).
*      ENDIF.


*    if sy-subrc =  0 and l_cf = 'X'.

*    read table ist_agr into wa_agr index 1.

        if not ist_agr[] is initial.
          select   * from zmm_annual_limit into table
              ist_annual_limit for all entries in
              ist_agr  where posrole  =  ist_agr-agr_name and
                             bdpcode  = wa_eban01-zzbdp.
        endif.
        if  ist_annual_limit[] is  initial and l_cf = 'X'.
          message e214(zmm).
        endif.
        clear l_found.

* Get delivery date of First Undeleted Item
        loop at ist_eban01 into wa_eban01.
          if wa_eban01-loekz ne 'X'.
            l_lfdat   =  wa_eban01-lfdat.
            exit.
          endif.
        endloop.
* end

        call function 'FI_PERIOD_DETERMINE'
             exporting
                  i_budat     = l_lfdat
                  i_periv     = 'V3'
             importing
                  e_gjahr     = l_lfyear
             exceptions
                  fiscal_year = 1.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.

* In Annual Limit table there will be alway one matching record
* ie select statement included in side loop    .
        data: l_auth .
        clear l_auth .
*        LOOP AT ist_lv.

        loop at ist_annual_limit into wa_annual_limit  .
          read table ist_lv with key frgc = wa_annual_limit-rel_code.
          g_posrole = wa_annual_limit-posrole .
          if sy-subrc = 0.
            l_found = 'X'.
            l_annl_lmt  =  wa_annual_limit-limit.

            select * from zmm_pr_rel_value into table ist_pr_rel_val
                   where posrole  = wa_annual_limit-posrole  and
*                 rel_code = wa_annual_limit-rel_code and
                     bdpcode  = wa_annual_limit-bdpcode    and
                     fyear    = l_lfyear  and
                     cflag ne  'X'.
*        if sy-subrc = 0.
*         l_annl_lmt  =  wa_annual_limit-limit.
*        endif.
            l_auth = 'X'.
*            ELSE.
*              MESSAGE e214(zmm).
*            ENDIF.
          endif.
        endloop.

*        ENDLOOP.
        if l_auth ne 'X'.
          message e214(zmm).
        endif.

*COMMENTED ON 29/07/05
** Get delivery date of First Undeleted Item
*    LOOP AT ist_eban01 INTO wa_eban01.
*      IF wa_eban01-loekz NE 'X'.
*        l_lfdat   =  wa_eban01-lfdat.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
** end
*
*    CALL FUNCTION 'FI_PERIOD_DETERMINE'
*         EXPORTING
*              i_budat     = l_lfdat
*              i_periv     = 'V3'
*         IMPORTING
*              e_gjahr     = l_lfyear
*         EXCEPTIONS
*              fiscal_year = 1.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.


        loop at ist_pr_rel_val into wa_pr_rel_val.
*
*        CALL FUNCTION 'FI_PERIOD_DETERMINE'
*             EXPORTING
*                  i_budat     = wa_pr_rel_val-dvdate
*                  i_periv     = 'V3'
*             IMPORTING
*                  e_gjahr     = l_year
*             EXCEPTIONS
*                  fiscal_year = 1.
*        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDIF.
*        IF l_lfyear = l_year .
          l_prval = l_prval +  wa_pr_rel_val-prvalue.
*       ENDIF.

        endloop.
* Get Total PR Value

        loop at ist_eban01 into wa_eban01 where loekz ne 'X'.
          l_pr_tot =  l_pr_tot + wa_eban01-prtot .
        endloop.
        clear l_tot_val.
        l_tot_val = l_prval +  l_pr_tot.

        if l_found = 'X'.
          if  l_tot_val > l_annl_lmt.
            message e211(zmm).
          endif.
        endif.
      endif.
    endif.
  endform.                    " get_detail_T16
*&---------------------------------------------------------------------*
*&      Form  get_pos_role
*&---------------------------------------------------------------------*
*   Get Position Role and  level
*----------------------------------------------------------------------*
  form get_pos_role   tables it_agr  .
*    READ TABLE ist_eban01 INTO wa_eban01 INDEX 1.
    read table ist_eban01 into wa_eban01 with key loekz = space.

    select agr_name from agr_users into table it_agr
             where uname =  wa_eban01-zzcpfno  and
                  agr_name like '%D:MM_SRV_IND_APPROVE%'.

  endform.                    " get_pos_role
*&---------------------------------------------------------------------*
*&      Form  get_user_role
*&---------------------------------------------------------------------*
*       Get Position Role for Final Release.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form get_user_role.
    refresh: ist_agr,
             ist_annual_limit.
    clear :  ist_agr,
             ist_annual_limit.

    if not eban-banfn is initial and
    rm06b-frgab ne '01'.

      select single * from eban
        where banfn = eban-banfn.
      if sy-subrc = 0.
        select single * from zmm_annual_limit
            where bdpcode = eban-zzbdp.
        if  sy-subrc = 0.
*          select banfn bnfpo werks menge waers preis peinh  badat
*          frgst frggr zzcpfno zzesclevel frgst lfdat from
*           eban into corresponding fields of table ist_eban01
*               where banfn = eban-banfn.
*          if sy-subrc = 0.
          select agr_name from agr_users into table ist_agr
          where uname = sy-uname  and
                to_dat >= sy-datum and
                agr_name like '%D:MM_SRV_IND_APPROVE%'.
          if sy-subrc = 0.
            select * from zmm_annual_limit into table ist_annual_limit
                                 for all entries in ist_agr
                                 where posrole = ist_agr-agr_name and
                                      bdpcode  = eban-zzbdp .

          endif.
*         endif.
        endif.
      endif.
    endif.
    delete ist_annual_limit where rel_code ne rm06b-frgab.


  endform.                    " get_user_role
*&---------------------------------------------------------------------*
*&      Form  get_annual_limit
*&---------------------------------------------------------------------*
*       Calculate Annual Limit based on Position Role.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form get_annual_limit.

    clear g_posrole.
*---------local Variable Declaration-----------------------------------*
    data: l_prval    like zmm_pr_rel_value-prvalue,
          l_pr_tot   like zmm_pr_rel_value-prvalue,
          l_tot_val  like zmm_pr_rel_value-prvalue,
          l_tot_rel  like zmm_pr_rel_value-prvalue.

    data: wa_pr_rel_val     type zmm_pr_rel_value .
    data: ist_pr_rel_val   type table of zmm_pr_rel_value .
    data: l_year like bkpf-gjahr,
          l_lfyear like bkpf-gjahr,
          l_annl_lmt like zmm_annual_limit-limit,
          l_lfdat like eban-lfdat .

    clear:l_prval  ,
          l_pr_tot ,
          l_tot_val,
          l_tot_rel.
*----------------------------------------------------------------------*

* Get Fiscal Year from Delivery Date and update internal Table.
    loop at ist_eban01 into wa_eban01.
      call function 'FI_PERIOD_DETERMINE'
           exporting
                i_budat     = wa_eban01-lfdat
                i_periv     = 'V3'
           importing
                e_gjahr     = l_year
           exceptions
                fiscal_year = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

      wa_eban01-fyear = l_year.
      modify ist_eban01 from wa_eban01 index sy-tabix.
    endloop.
* End of updation.

* Get delivery date of First Undeleted Item
    loop at ist_eban01 into wa_eban01.
      if wa_eban01-loekz ne 'X'.
        l_lfdat   =  wa_eban01-lfdat.
        exit.
      endif.
    endloop.
* end

* Get Fiscal year based on First Undeleted items in EBAN
    call function 'FI_PERIOD_DETERMINE'
         exporting
              i_budat     = l_lfdat
              i_periv     = 'V3'
         importing
              e_gjahr     = l_lfyear
         exceptions
              fiscal_year = 1.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
* End

    clear : wa_annual_limit,  l_annl_lmt.
* Get Annual Limit from internal table  ist_annual_limit.
    read table ist_annual_limit into  wa_annual_limit index 1.

    l_annl_lmt = wa_annual_limit-limit .

* Get PR Released Values from Table  ZMM_PR_REL_VALUE.
    g_posrole = wa_annual_limit-posrole.

    select  *  from zmm_pr_rel_value into table ist_pr_rel_val
      where posrole  = wa_annual_limit-posrole  and
            rel_code = wa_annual_limit-rel_code and
            bdpcode  = wa_annual_limit-bdpcode  .


* Get rows fall in the same Fiscal year.
*Fiscal year for ZMM_PR_REL_VALUE will determined on the basis of Del.Dt
    loop at ist_pr_rel_val into wa_pr_rel_val.
      call function 'FI_PERIOD_DETERMINE'
           exporting
                i_budat     = wa_pr_rel_val-dvdate
                i_periv     = 'V3'
           importing
                e_gjahr     = l_year
           exceptions
                fiscal_year = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
      if l_lfyear = l_year .
        l_prval = l_prval +  wa_pr_rel_val-prvalue.
      endif.
    endloop.
* End.

* Calculate Total PR Value

    loop at ist_eban01   where loekz ne 'X'.
      l_pr_tot =  l_pr_tot + ist_eban01-prtot .
    endloop.
    clear l_tot_val.
    l_tot_val = l_prval +  l_pr_tot.

    if  g_rel_code_found = 'X'.

      if  l_tot_val > l_annl_lmt.
        message e211(zmm).
      endif.
    endif.
  endform.                    " get_annual_limit
*&---------------------------------------------------------------------*
*&      Form  get_rel_code
*&---------------------------------------------------------------------*
*       Get Release Code
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form get_rel_code.
    data: l_chk_role.
*    data: ist_annual_limit  type table of zmm_annual_limit .
*    data: wa_annual_limit like zmm_annual_limit.
    data: ist_t16fs  type table of t16fs.
    data: ist_t16fk  type table of t16fk.
    data: l_fname(15).
    data: l_index .
    data: l_f.
    data: l_prval like zmm_pr_rel_value-prvalue.
    data: l_pr_tot like zmm_pr_rel_value-prvalue.
    data: l_tot_val like zmm_pr_rel_value-prvalue.
    data: l_tot_rel  like zmm_pr_rel_value-prvalue.
    data: l_year like bkpf-gjahr,
          l_lfyear like bkpf-gjahr .
*    DATA: wa_rel_val LIKE  zmm_pr_rel_value.
*    DATA: ist_rel_val TYPE TABLE OF zmm_pr_rel_value WITH HEADER LINE.
    data: l_annl_lmt like zmm_annual_limit-limit.
    data: wa_agr like ist_agr.
    data: begin of ist_lv occurs 0,
          frgc  type t16fs-frgc1,
          end of ist_lv.

    data: l_found .
    clear l_found .
    data: begin of ist_t16fk_fld occurs 0,
            fidx like  sy-index ,
          end of ist_t16fk_fld.

    field-symbols: <val> type any.
    field-symbols: <fs> type t16fk.
    field-symbols: <fs1> type t16fs.

    data: wa_t16fk type t16fk.
    data: begin of ist_frgst occurs 0,
            sign(1),
            option(2),
            low  like abdbg-tabline,
            high like abdbg-tabline,
    end   of ist_frgst.

    data: begin of ist_frggr occurs 0,
            sign(1),
            option(2),
            low  like abdbg-tabline,
            high like abdbg-tabline,
    end   of ist_frggr.
    data: ist_rcode like ist_lv occurs 0.
    data: ist_pr_rel_val   type table of zmm_pr_rel_value .
    data: wa_pr_rel_val    type  zmm_pr_rel_value .
*----------------------------------------------------------------------*
    refresh : ist_frgst,ist_frggr .
    loop at ist_eban01 into wa_eban01.
      ist_frgst-sign = 'I'.
      ist_frgst-option = 'EQ'.
      ist_frgst-low = wa_eban01-frgst.
      append ist_frgst.
      ist_frggr-sign = 'I'.
      ist_frggr-option = 'EQ'.
      ist_frggr-low = wa_eban01-frggr.
      append ist_frggr.
    endloop.
    if not ( ist_frgst is initial or ist_frggr is initial ).

      select * from t16fk into table ist_t16fk
            where frgsx in ist_frgst and
                  frggr in ist_frggr and
                  frgkx = 'B'.

      loop at ist_t16fk assigning  <fs>.
        do 8 times.
          l_index = sy-index.
          concatenate '<FS>-FRGA' l_index into l_fname.
          assign  (l_fname) to <val>.
          if  <val>  = 'X'.
            l_f = sy-index.
          endif.
        enddo.
        ist_t16fk_fld-fidx = l_f.
        append ist_t16fk_fld .
      endloop.

      sort ist_t16fk_fld by fidx.
    delete adjacent duplicates from ist_t16fk_fld comparing all fields .
      select * from t16fs into table ist_t16fs
             where frgsx in ist_frgst and
                 frggr in ist_frggr  .

      if sy-subrc = 0.
        loop at ist_t16fs assigning  <fs1>.
          do 8 times.
            clear l_index.
         read table ist_t16fk_fld into l_index with key fidx = sy-index.
            if sy-subrc = 0.
              l_f  = sy-index.
              concatenate '<FS1>-FRGC' l_f into l_fname.
              assign  (l_fname) to <val>.
              if not <val> is initial  .
                ist_lv-frgc = <val> .
                append ist_lv .
              endif.
            endif.
          enddo.
        endloop.
      endif.
    endif.
* Get Roles from AGR_USERS.
*    perform get_pos_role tables  ist_agr.
    perform get_user_role.

    clear l_chk_role.
* Check whether derived  Roles belongs to DI/DF/MD/BO/EC ..
    loop at ist_agr into wa_agr.
      if wa_agr+21(2) = 'DI' or
         wa_agr+21(2) = 'DF' or
         wa_agr+21(2) = 'MD' or
         wa_agr+21(2) = 'BO' or
         wa_agr+21(2) = 'EC' or
         wa_agr+21(2) = 'BV' .
        l_chk_role = 'X'.
        exit.
      else.
        l_chk_role = space.
      endif.

    endloop.

    if  l_chk_role ne 'X'.

      clear  g_rel_code_found.

      loop at ist_annual_limit into wa_annual_limit.
        read table ist_lv with key frgc =  rm06b-frgab.
        g_posrole = wa_annual_limit-posrole .
        if sy-subrc = 0.
          g_rel_code_found = 'X'.
          l_annl_lmt  =  wa_annual_limit-limit.
          select * from zmm_pr_rel_value into table ist_pr_rel_val
                 where posrole  = wa_annual_limit-posrole  and
                   rel_code = wa_annual_limit-rel_code and
                   bdpcode  = wa_annual_limit-bdpcode  and
                   cflag    ne 'X'.
        else.
          l_found = space.
        endif.
      endloop.

* Get delivery date of First Undeleted Item
      loop at ist_eban01 into wa_eban01.
        if wa_eban01-loekz ne 'X'.
          l_lfdat   =  wa_eban01-lfdat.
          exit.
        endif.
      endloop.
* end

      call function 'FI_PERIOD_DETERMINE'
           exporting
                i_budat     = l_lfdat
                i_periv     = 'V3'
           importing
                e_gjahr     = l_lfyear
           exceptions
                fiscal_year = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.


      loop at ist_pr_rel_val into wa_pr_rel_val.

        call function 'FI_PERIOD_DETERMINE'
             exporting
                  i_budat     = wa_pr_rel_val-dvdate
                  i_periv     = 'V3'
             importing
                  e_gjahr     = l_year
             exceptions
                  fiscal_year = 1.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
        if l_lfyear = l_year .
          l_prval = l_prval +  wa_pr_rel_val-prvalue.
        endif.

      endloop.

      loop at ist_eban01 into wa_eban01 where loekz ne 'X'.
        l_pr_tot =  l_pr_tot + wa_eban01-prtot .
      endloop.
      clear l_tot_val.
      l_tot_val = l_prval +  l_pr_tot.


*    IF NOT ist_annual_limit[] IS INITIAL.
*      SELECT * FROM zmm_pr_rel_value INTO TABLE ist_rel_val
*         FOR ALL ENTRIES IN ist_annual_limit
*          WHERE bdpcode =  ist_annual_limit-bdpcode  AND
*                posrole =  ist_annual_limit-posrole.
*    ENDIF.
*
*    CLEAR l_tot_rel.
*    LOOP AT ist_rel_val.
*      l_tot_rel = l_tot_rel + ist_rel_val-prvalue.
*    ENDLOOP.
*

      if g_rel_code_found = 'X'.
        if  l_tot_val > l_annl_lmt.
          message e211(zmm).
        endif.
*      endif.

      endif.
    endif.
  endform.                    " get_rel_code
*&---------------------------------------------------------------------*
*&      Form  get_bdp_info_ANNUAL
*&---------------------------------------------------------------------*
*      bdp iNFO
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form get_bdp_info_annual.
    clear g_bdp_exist.
    if not eban-banfn is initial and
       rm06b-frgab ne '01'.

      select single * from eban
        where banfn = eban-banfn.
      if sy-subrc = 0.
        select single * from zmm_annual_limit
            where bdpcode = eban-zzbdp.
*        IF sy-subrc = 0.
        select banfn bnfpo werks menge waers preis peinh  badat
        frgst frggr zzcpfno zzesclevel frgst lfdat loekz  from
         eban into corresponding fields of table ist_eban01
             where banfn = eban-banfn.
*        ENDIF.
      endif.
    endif.

    read table ist_eban01 into wa_eban01 with key loekz = space.

    select single * from  zmm_bdp_level
       where bdpcode = wa_eban01-zzbdp.

    if sy-subrc = 0.
      g_bdp_exist = 'X'.
    else.
      g_bdp_exist = space.
    endif.



  endform.                    " get_bdp_info_ANNUAL
*&---------------------------------------------------------------------*
*&      Form  get_doc_cat
*&---------------------------------------------------------------------*
*      Get Document Category . If 'R' then do not validate Annual Limit
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form get_doc_cat.
*data: wa_eban02 like eban.
*
    clear g_bsakz.
    if not eban-banfn is initial.
      select single bsakz from eban into  g_bsakz
         where banfn = eban-banfn and
               loekz ne 'X'.
    endif.
*  if sy-subrc = 0.
*    select single bsakz  from t161 into g_bsakz
*         where bsakz = wa_eban02-bsakz.
*
*  endif.
* endif.

  endform.                    " get_doc_cat
*&---------------------------------------------------------------------*
*&      Form  check_bdp_bf_final_rel
*&---------------------------------------------------------------------*
*       Check BDP code
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form check_bdp_bf_final_rel.
    select single * from eban
          where banfn = eban-banfn.
    if sy-subrc = 0.
      select single * from zmm_annual_limit
          where bdpcode = eban-zzbdp.
*        IF sy-subrc = 0.
      select banfn bnfpo werks menge waers preis peinh  badat
      frgst frggr zzcpfno zzesclevel zzbdp frgst lfdat loekz  from
       eban into corresponding fields of table ist_eban01
           where banfn = eban-banfn.
*        ENDIF.
    endif.

    read table ist_eban01 into wa_eban01 with key loekz = space.


    select single * from  zmm_bdp_level
         where bdpcode = wa_eban01-zzbdp.

    if sy-subrc = 0.
      g_bdp_exist = 'X'.
    else.
      g_bdp_exist = space.
    endif.

  endform.                    " check_bdp_bf_final_rel
*&---------------------------------------------------------------------*
*&      Form  check_send_message
*&---------------------------------------------------------------------*
*  Check Document and Send Message.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  form check_send_message.
    data: ist_line type table of  popuptext  with header line .
    data: begin of ist_msg    occurs 0           ,
          title(55)                              ,
          rel_code  type zmm_bdp_limits-rel_code ,
          limit      type zmm_bdp_limits-limit   ,
          end of ist_msg.

    refresh:  ist_line,
              ist_msg.
    clear:  ist_line ,
              ist_msg.

    ist_msg-title = '          This is an escalated PR'.
    append ist_msg.
    clear ist_msg.
  ist_msg-title = 'Normal Annual Limit for the BDP clause are as below'.
    append ist_msg.
    clear   ist_msg-title.

    append ist_msg.
    data: wa_eban type eban.
    data: ist_limit type table of zmm_bdp_limits,
           wa_limit type zmm_bdp_limits.
    select single *  from eban into  wa_eban
            where banfn = eban-banfn and
                  loekz ne 'X'.
    if sy-subrc = 0.
      if wa_eban-zzesclevel ne space.
        select * from zmm_bdp_limits into table ist_limit
          where  bdpcode = wa_eban-zzbdp.
        loop at ist_limit into wa_limit .
          move-corresponding wa_limit to ist_msg.
          append   ist_msg.
          clear ist_msg.
        endloop.
      endif.
    endif.

    refresh ist_line.

 if wa_eban-zzesclevel ne space.

    loop at ist_msg.
      clear ist_line-text.
      if sy-tabix = 1 or sy-tabix = 2.
        move ist_msg to ist_line-text.
        append ist_line .

      elseif sy-tabix = 3.
         append ist_line .
      else.
        clear ist_line-text.
        concatenate '         ' ist_msg-rel_code '-->'
                                ist_msg-limit into
       ist_line-text.
        append ist_line .
      endif.
    endloop.


    call function 'DD_POPUP_WITH_INFOTEXT'
   exporting
     titel              = 'PR Message'
     start_column       = 5
     start_row          = 5
     end_column         = 60
    end_row             = 15
*    INFOFLAG           = ' '
*  IMPORTING
*    ANSWER             =
   tables
     lines              =  ist_line.
    .
 endif.


  endform.                    " check_send_message
*&---------------------------------------------------------------------*
*&      Form  CHECK_BDP_REL_CODE
*&---------------------------------------------------------------------*
*     Check BDP and Release code .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_bdp_rel_code.
*data: wa_eban like eban .
* select single *  from eban into  wa_eban
*            where banfn = eban-banfn and
*                  loekz ne 'X'.
*if sy-subrc = 0.
*  if wa_eba-zzesc
*endif.

endform.                    " CHECK_BDP_REL_CODE
*&---------------------------------------------------------------------*
*&      Form  check_release_ind
*&---------------------------------------------------------------------*
*      Check Release Indicator.
*----------------------------------------------------------------------*
*      <--P_L_FRGKX  text
*----------------------------------------------------------------------*
form check_release_ind changing p_frgkz.
*data: wa_eban type eban.
 select single frgkz from   eban into p_frgkz
 where banfn = eban-banfn.

endform.                    " check_release_ind
