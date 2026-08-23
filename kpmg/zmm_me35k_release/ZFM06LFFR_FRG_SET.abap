*&---------------------------------------------------------------------*
*&  Include           ZFM06LFFR_FRG_SET      (package ZMM_PO)
*&  Main program      SAPMZFM06L
*&---------------------------------------------------------------------*
*  Restores on S/4 the custom FRG_SET that is live in ECC.
*
*  Background: on S/4 the include ZFM06LFFR was rebuilt from the modular
*  SAP standard and now reads "INCLUDE FM06LFFR_FRG_SET" - SAP's own,
*  unmodified routine. The CR 30011813 header and the ist_ola_pr_hdr
*  declarations survived at the top of ZFM06LFFR, but every custom block
*  inside FRG_SET was lost. This include puts them back.
*
*  Custom blocks carried over from ECC:
*    [1] 02.03.2005 Harish        - block release if a linked PR is
*                                   still released (A192 ZMM).
*                                   Skipped for SY-TCODE = ZMMME28.
*    [2] 05.02.2013 Lipsy  CR 30008101 - block release if OLA target
*                                   value exceeds total PR value
*                                   (A239 ZMM_OTH). ZMMME35K only.
*    [3] 29.09.2014 CAB_SPYADAV CR 30011813 - currency / exchange rate
*                                   rework + GET_ALL_OLAS_PRS.
*
*  Deliberate differences from the ECC source - read before activating:
*    (a) ME_REL_SET is called WITH the EXCEPTIONS block and the
*        E102/E103/E104 handling from the S/4 standard. ECC has the
*        EXCEPTIONS commented out, which on an unhandled classic
*        exception gives a short dump instead of a message. Keeping the
*        standard handling is strictly safer and changes no successful
*        path.
*    (b) FORM ITERATION is not carried over. Its only call site is
*        commented out in ECC ("commented old subroutine iteration",
*        CR 30011813) - it was replaced by GET_ALL_OLAS_PRS.
*    (c) Large commented-out blocks from ECC are dropped. No executable
*        statement has been changed.
*
*  Prerequisites on S/4 - check before activating:
*    - message class ZMM      message 192
*    - message class ZMM_OTH  message 239
*    - ist_ola_pr_hdr / wa_ola_pr_hdr declared in ZFM06LFFR (already
*      present - that is where they come from)
*&---------------------------------------------------------------------*

*eject
*----------------------------------------------------------------------*
*  Freigabe setzen                                                     *
*----------------------------------------------------------------------*
FORM frg_set.

*--- [1] 02.03.2005 Harish : work areas for the PR release check -------*
  DATA : BEGIN OF l_ekpo OCCURS 0,
           ebeln LIKE ekpo-ebeln,
           ebelp LIKE ekpo-ebelp,
           banfn LIKE ekpo-banfn,
           loekz LIKE ekpo-loekz,
         END OF l_ekpo.

  DATA : l_frgkz LIKE eban-frgkz,
         l_banfn LIKE eban-banfn.

  PERFORM check_kopfzeile.
  CHECK exitflag EQ space.
  READ TABLE fekko WITH KEY hidk-ebeln BINARY SEARCH.
  fekkoind = sy-tabix.
  CHECK sy-subrc EQ 0.
  PERFORM frg_check_update.

  CALL FUNCTION 'ME_REL_SET'
    EXPORTING
      i_title                = ' '
      i_dialog               = ' '
      i_frgrl                = fekko-frgrl
      i_frgco                = xfrgco
      i_frgkz                = fekko-frgke
      i_frggr                = fekko-frggr
      i_frgst                = fekko-frgsx
      i_frgzu                = fekko-frgzu
      i_frgot                = '2'
    IMPORTING
      e_frgkz                = fekko-frgke
      e_frgzu                = fekko-frgzu
      e_frgrl                = fekko-frgrl
    EXCEPTIONS
      prerequisite_fail      = 01                           "1039231
      release_already_posted = 02
      responsibility_fail    = 03
      OTHERS                 = 04.

  CASE sy-subrc.                                            "see note (a)
    WHEN 01.
      MESSAGE e102(me).
    WHEN 02.
      MESSAGE e103(me).                                     "#EC *
    WHEN 03.
      MESSAGE e104(me).
  ENDCASE.                                                  "1039231

  fekko-updkz = 'U'.
  MODIFY fekko INDEX fekkoind.
  PERFORM frg_zeile_update USING 'X'.
  CLEAR: hidk, hidp.

*======================================================================*
* [1] 02.03.2005 Harish  - is a linked PR still released?              *
*     29.05.2006 SAB_VGOPAL - not for ZMMME28                          *
*======================================================================*
  IF sy-tcode NE 'ZMMME28'.

    SELECT ebeln ebelp banfn loekz FROM ekpo INTO TABLE l_ekpo
                                   WHERE ebeln = ekko-ebeln.

    DELETE l_ekpo WHERE banfn = space OR loekz NE space.

    IF NOT l_ekpo[] IS INITIAL.
      LOOP AT l_ekpo.
        SELECT SINGLE frgkz banfn INTO (l_frgkz, l_banfn) FROM eban
                                  WHERE banfn = l_ekpo-banfn AND
                                        ebeln = l_ekpo-ebeln AND
                                        ebelp = l_ekpo-ebelp AND
                                        loekz = space.
        IF sy-subrc = 0 AND l_frgkz EQ 'X'.
          MESSAGE a192(zmm) WITH l_banfn.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.

*======================================================================*
* [2] 05.02.2013 Lipsy  CR 30008101                                    *
*     OLA target value must not exceed the total PR value              *
* [3] 29.09.2014 CAB_SPYADAV CR 30011813 - currency handling           *
*======================================================================*
  IF sy-tcode = 'ZMMME35K'.

    DATA: l_banfn1         TYPE ekpo-banfn,
          count            TYPE i,
          v_ekpo_ola_ebeln TYPE ebeln.

    TYPES: BEGIN OF ty_eban_pr,
             bnfpo TYPE eban-bnfpo,
             menge TYPE eban-menge,
             preis TYPE ktwrt,
             banfn TYPE eban-banfn,
             waers TYPE eban-waers,
             badat TYPE eban-badat,
           END OF ty_eban_pr.

    TYPES: BEGIN OF ty_ekpo_ola,
             ebeln TYPE ekpo-ebeln,
             loekz TYPE ekpo-loekz,
             banfn TYPE ekpo-banfn,
             bnfpo TYPE ekpo-bnfpo,
           END OF ty_ekpo_ola.

    TYPES: BEGIN OF ty_ekko_ola,
             ebeln TYPE ekko-ebeln,
             ktwrt TYPE ekko-ktwrt,
             wkurs TYPE ekko-wkurs,
             waers TYPE ekko-waers,
             bedat TYPE ekko-bedat,
             bsart TYPE ekko-bsart,
           END OF ty_ekko_ola.

    DATA: itab_eban_pr  TYPE TABLE OF ty_eban_pr,
          itab_ekpo_ola TYPE TABLE OF ty_ekpo_ola,
          itab_ekpo_ola1 TYPE TABLE OF ty_ekpo_ola,
          itab_ekko_ola TYPE TABLE OF ty_ekko_ola,
          wa_eban_pr    LIKE LINE OF itab_eban_pr,
          wa_ekpo_ola   LIKE LINE OF itab_ekpo_ola,
          wa_ekko_ola   LIKE LINE OF itab_ekko_ola.

    DATA: v_eban_price  TYPE ktwrt,
          v_eban_price1 TYPE ktwrt,
          v_ekko_price  TYPE ktwrt.

    DATA : BEGIN OF wa_ola_eban,
             ebeln     TYPE ekpo-ebeln,
             loekz     TYPE ekpo-loekz,
             banfn     TYPE ekpo-banfn,
             bnfpo     TYPE ekpo-bnfpo,
             waers_ola TYPE ekko-waers,
             waers_pr  TYPE eban-waers,
             badat     TYPE eban-badat,
           END OF wa_ola_eban.

    DATA : ist_ola      LIKE TABLE OF wa_ola_eban,
           ist_eban     LIKE TABLE OF wa_ola_eban,
           ist_ola_eban LIKE TABLE OF wa_ola_eban.

    DATA : ist_eban_t TYPE TABLE OF ty_eban_pr,
           wa_eban_t  TYPE ty_eban_pr.

    DATA : l_waers_ola TYPE ekko-waers,
           l_waers_pr  TYPE ekko-waers,
           l_no_ola    TYPE sy-tabix,
           l_no_pr     TYPE sy-tabix,
           l_index     TYPE sy-tabix.

    DATA : l_badat     TYPE eban-badat,
           l_waers_val(1).

    CLEAR: l_banfn1.
    REFRESH: itab_eban_pr.

    IF ekko-bsart = 'MQCM' OR ekko-bsart = 'MQCN'.
*     these document types are exempt from the value check
    ELSE.

*---- get all PRs and related OLAs for this OLA (CR 30011813) ---------*
      REFRESH : itab_ekpo_ola1.
      CLEAR   : wa_ekpo_ola.

      PERFORM get_all_olas_prs USING ekko-ebeln.

      LOOP AT ist_ola_pr_hdr INTO wa_ola_pr_hdr.
        MOVE-CORRESPONDING wa_ola_pr_hdr TO wa_ekpo_ola.
        APPEND wa_ekpo_ola TO itab_ekpo_ola1.
      ENDLOOP.

*---- build the OLA and PR tables -------------------------------------*
      LOOP AT itab_ekpo_ola1 INTO wa_ekpo_ola.

        CLEAR wa_ola_eban.
        MOVE wa_ekpo_ola-ebeln TO wa_ola_eban-ebeln.
        APPEND wa_ola_eban TO ist_ola.

        CLEAR wa_ola_eban.
        IF wa_ekpo_ola-banfn = '9999999999'.
        ELSE.
          REFRESH : ist_eban_t.
          SELECT bnfpo menge preis banfn waers FROM eban
                 INTO CORRESPONDING FIELDS OF TABLE ist_eban_t
                 WHERE banfn = wa_ekpo_ola-banfn AND
                       loekz = ''.
        ENDIF.

        IF NOT ist_eban_t[] IS INITIAL.

          SORT ist_eban_t BY bnfpo.
          CLEAR l_badat.

          LOOP AT ist_eban_t INTO wa_eban_t.

*           first release date of the PR
            IF l_badat IS INITIAL.
              PERFORM get_1st_pr_rel_dt USING    wa_eban_t-banfn
                                        CHANGING wa_eban_t-badat.
              MOVE wa_eban_t-badat TO l_badat.
            ENDIF.

            MOVE l_badat TO wa_eban_t-badat.
            APPEND wa_eban_t TO itab_eban_pr.

            MOVE wa_eban_t-banfn TO wa_ola_eban-banfn.
            MOVE wa_eban_t-bnfpo TO wa_ola_eban-bnfpo.
            MOVE wa_eban_t-waers TO wa_ola_eban-waers_pr.
            MOVE wa_eban_t-badat TO wa_ola_eban-badat.

            APPEND wa_ola_eban TO ist_eban.

          ENDLOOP.

        ENDIF.

      ENDLOOP.

      SORT ist_ola BY ebeln.
      DELETE ADJACENT DUPLICATES FROM ist_ola COMPARING ebeln.

      SORT ist_eban BY banfn bnfpo.
      DELETE ADJACENT DUPLICATES FROM ist_eban COMPARING banfn bnfpo.
      DELETE ist_eban WHERE banfn IS INITIAL.

      SORT itab_eban_pr BY banfn bnfpo.
      DELETE ADJACENT DUPLICATES FROM itab_eban_pr COMPARING banfn bnfpo.
      DELETE itab_eban_pr WHERE banfn IS INITIAL.

*---- currency of each OLA -------------------------------------------*
      LOOP AT ist_ola INTO wa_ola_eban.
        l_index = sy-tabix.
        SELECT SINGLE waers FROM ekko INTO wa_ola_eban-waers_ola
               WHERE ebeln = wa_ola_eban-ebeln AND
                     loekz = ''.
        IF sy-subrc EQ 0.
          MODIFY ist_ola FROM wa_ola_eban INDEX l_index
                              TRANSPORTING waers_ola.
        ENDIF.
      ENDLOOP.

*---- one single currency on both sides? -----------------------------*
      ist_ola_eban[] = ist_ola[].
      SORT ist_ola_eban BY waers_ola.
      DELETE ADJACENT DUPLICATES FROM ist_ola_eban COMPARING waers_ola.
      DESCRIBE TABLE ist_ola_eban LINES l_no_ola.
      IF l_no_ola = 1.
        READ TABLE ist_ola_eban INTO wa_ola_eban INDEX 1.
        MOVE wa_ola_eban-waers_ola TO l_waers_ola.
      ENDIF.

      ist_ola_eban[] = ist_eban[].
      SORT ist_ola_eban BY waers_pr.
      DELETE ADJACENT DUPLICATES FROM ist_ola_eban COMPARING waers_pr.
      DESCRIBE TABLE ist_ola_eban LINES l_no_pr.
      IF l_no_pr = 1.
        READ TABLE ist_ola_eban INTO wa_ola_eban INDEX 1.
        MOVE wa_ola_eban-waers_pr TO l_waers_pr.
      ENDIF.

*     same single currency on both sides -> no conversion at all
      IF NOT l_waers_ola IS INITIAL  AND
         NOT l_waers_pr  IS INITIAL AND
         ( l_waers_ola = l_waers_pr ).
        l_waers_val = 'X'.
      ENDIF.

*---- total PR value --------------------------------------------------*
      CLEAR : v_eban_price, wa_eban_pr.

      LOOP AT itab_eban_pr INTO wa_eban_pr.

        IF l_waers_val = 'X'.
          v_eban_price = v_eban_price +
                       ( wa_eban_pr-preis * wa_eban_pr-menge ) / 1000.
        ELSE.
          IF wa_eban_pr-waers = 'INR'.
            v_eban_price = v_eban_price +
                         ( wa_eban_pr-preis * wa_eban_pr-menge ) / 1000.
          ELSE.
            CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
              EXPORTING
                client           = sy-mandt
                date             = wa_eban_pr-badat
                foreign_amount   = wa_eban_pr-preis
                foreign_currency = wa_eban_pr-waers
                local_currency   = 'INR'
                type_of_rate     = 'M'
                read_tcurr       = 'X'
              IMPORTING
                local_amount     = wa_eban_pr-preis
              EXCEPTIONS
                no_rate_found    = 1
                overflow         = 2
                no_factors_found = 3
                no_spread_found  = 4
                derived_2_times  = 5
                OTHERS           = 6.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            v_eban_price = v_eban_price +
                         ( wa_eban_pr-preis * wa_eban_pr-menge ) / 1000.
          ENDIF.
          CLEAR: wa_eban_pr.
        ENDIF.

      ENDLOOP.

*---- total OLA value -------------------------------------------------*
      IF itab_ekpo_ola1 IS NOT INITIAL.
        REFRESH: itab_ekpo_ola.
        SELECT ebeln loekz banfn bnfpo FROM ekpo
               INTO CORRESPONDING FIELDS OF TABLE itab_ekpo_ola
               FOR ALL ENTRIES IN itab_ekpo_ola1
               WHERE banfn = itab_ekpo_ola1-banfn
                 AND loekz = ''.
      ENDIF.

      IF itab_ekpo_ola IS NOT INITIAL.
        REFRESH: itab_ekko_ola.
        SELECT ebeln ktwrt wkurs waers bedat bsart FROM ekko
               INTO CORRESPONDING FIELDS OF TABLE itab_ekko_ola
               FOR ALL ENTRIES IN itab_ekpo_ola
               WHERE ebeln = itab_ekpo_ola-ebeln AND loekz = ''.
      ENDIF.

      SORT itab_ekpo_ola BY ebeln.
      DELETE ADJACENT DUPLICATES FROM itab_ekpo_ola COMPARING ebeln.

      CLEAR: v_ekko_price, wa_ekko_ola.
      READ TABLE itab_eban_pr INTO wa_eban_pr INDEX 1.

      LOOP AT itab_ekko_ola INTO wa_ekko_ola.

        IF l_waers_val = 'X'.
          v_ekko_price = wa_ekko_ola-ktwrt + v_ekko_price.
        ELSE.
          IF wa_ekko_ola-waers = 'INR'.
            v_ekko_price = wa_ekko_ola-ktwrt + v_ekko_price.
          ELSE.
            v_ekko_price = ( wa_ekko_ola-ktwrt * wa_ekko_ola-wkurs )
                           / 100000 + v_ekko_price.
          ENDIF.
        ENDIF.

      ENDLOOP.

      CLEAR: v_eban_price1.
      v_eban_price1 = v_eban_price.

      IF v_ekko_price > v_eban_price1.
        IF wa_ekko_ola-bedat GT '20140924'.
          MESSAGE a239(zmm_oth) WITH v_ekko_price v_eban_price1.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.                    "frg_set

*&---------------------------------------------------------------------*
*&      Form  GET_1ST_PR_REL_DT
*&---------------------------------------------------------------------*
* To get first PR release date
*----------------------------------------------------------------------*
FORM get_1st_pr_rel_dt  USING    p_banfn
                        CHANGING p_badat.

  DATA : BEGIN OF wa_cdpos,
           objectid   TYPE cdpos-objectid,
           objectclas TYPE cdpos-objectclas,
           tabname    TYPE cdpos-tabname,
           fname      TYPE cdpos-fname,
           value_old  TYPE cdpos-value_old,
           changenr   TYPE cdpos-changenr,
         END OF wa_cdpos.

  DATA : ist_cdpos LIKE TABLE OF wa_cdpos.

  DATA : BEGIN OF wa_cdhdr,
           objectid   TYPE cdpos-objectid,
           objectclas TYPE cdpos-objectclas,
           changenr   TYPE cdpos-changenr,
           udate      TYPE cdhdr-udate,
           utime      TYPE cdhdr-utime,
         END OF wa_cdhdr.

  DATA : ist_cdhdr LIKE TABLE OF wa_cdhdr.

  SELECT * FROM cdpos
         INTO CORRESPONDING FIELDS OF TABLE ist_cdpos
         WHERE objectclas EQ 'BANF'  AND
               objectid   EQ p_banfn AND
               tabname    EQ 'EBAN'  AND
               fname      EQ 'FRGZU' AND
               value_old  =  ' '.

  IF NOT ist_cdpos[] IS INITIAL.

    SELECT * FROM cdhdr
           INTO CORRESPONDING FIELDS OF TABLE ist_cdhdr
           FOR ALL ENTRIES IN ist_cdpos
           WHERE changenr   EQ ist_cdpos-changenr AND
                 objectclas EQ 'BANF'             AND
                 objectid   EQ p_banfn.

    SORT ist_cdhdr BY udate utime ASCENDING.

    READ TABLE ist_cdhdr INTO wa_cdhdr INDEX 1.

    IF sy-subrc EQ 0.
      p_badat = wa_cdhdr-udate.
    ENDIF.

  ENDIF.

ENDFORM.                    " GET_1ST_PR_REL_DT

*&---------------------------------------------------------------------*
*&      Form  GET_ALL_OLAS_PRS
*&---------------------------------------------------------------------*
* To get all PRs & related OLAs for the OLA No.
*----------------------------------------------------------------------*
FORM get_all_olas_prs USING p_ebeln.

  DATA : l_chk(1) VALUE 'X'.

  REFRESH : ist_ola_pr_hdr.
  CLEAR   : wa_ola_pr_hdr.

  WHILE l_chk = 'X'.

    IF ist_ola_pr_hdr[] IS INITIAL.
      PERFORM get_ola_pr_dtl USING    p_ebeln
                             CHANGING l_chk.
    ELSE.
      PERFORM get_old_pr_dtl_r CHANGING l_chk.
    ENDIF.

  ENDWHILE.

  SORT ist_ola_pr_hdr BY ebeln banfn.
  DELETE ADJACENT DUPLICATES FROM ist_ola_pr_hdr COMPARING ebeln banfn.

ENDFORM.                    " GET_ALL_OLAS_PRS

*&---------------------------------------------------------------------*
*&      Form  GET_OLA_PR_DTL
*&---------------------------------------------------------------------*
* To get all PRs related to the OLA No.
*----------------------------------------------------------------------*
FORM get_ola_pr_dtl USING    p_ebeln
                    CHANGING p_chk.

  SELECT ebeln ebelp banfn bnfpo FROM ekpo
         INTO CORRESPONDING FIELDS OF TABLE ist_ola_pr_hdr
         WHERE ebeln = p_ebeln AND
               loekz = ''.

  IF ist_ola_pr_hdr[] IS INITIAL.
    CLEAR p_chk.
  ELSE.
    LOOP AT ist_ola_pr_hdr INTO wa_ola_pr_hdr.
      IF wa_ola_pr_hdr-banfn IS INITIAL.
        wa_ola_pr_hdr-banfn = '9999999999'.
        MODIFY ist_ola_pr_hdr FROM wa_ola_pr_hdr
                              INDEX sy-tabix TRANSPORTING banfn.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_OLA_PR_DTL

*&---------------------------------------------------------------------*
*&      Form  GET_OLD_PR_DTL_R
*&---------------------------------------------------------------------*
* To get all PRs & related OLA Nos
*----------------------------------------------------------------------*
FORM get_old_pr_dtl_r  CHANGING p_chk.

  DATA : ist_ola_pr_tmp LIKE TABLE OF wa_ola_pr_rec,
         wa_ola_pr_tmp  LIKE wa_ola_pr_rec.

  DATA : ist_ola_pr_t LIKE TABLE OF wa_ola_pr_rec,
         wa_ola_pr_t  LIKE wa_ola_pr_rec.

  IF NOT ist_ola_pr_hdr[] IS INITIAL.

*---- OLAs reached through the PRs ------------------------------------*
    SELECT ebeln ebelp banfn bnfpo FROM ekpo
           INTO CORRESPONDING FIELDS OF TABLE ist_ola_pr_tmp
           FOR ALL ENTRIES IN ist_ola_pr_hdr
           WHERE banfn = ist_ola_pr_hdr-banfn AND
                 loekz = ''.

    IF NOT ist_ola_pr_tmp[] IS INITIAL.

      LOOP AT ist_ola_pr_hdr INTO wa_ola_pr_hdr.
        DELETE ist_ola_pr_tmp WHERE ebeln = wa_ola_pr_hdr-ebeln.
      ENDLOOP.

      IF NOT ist_ola_pr_tmp[] IS INITIAL.

        LOOP AT ist_ola_pr_tmp INTO wa_ola_pr_tmp.
          MOVE-CORRESPONDING wa_ola_pr_tmp TO wa_ola_pr_hdr.
          IF wa_ola_pr_hdr-ebeln IS INITIAL.
            wa_ola_pr_hdr-ebeln = '9999999999'.
          ENDIF.
          APPEND wa_ola_pr_hdr TO ist_ola_pr_hdr.
        ENDLOOP.

*---- PRs reached through those OLAs ----------------------------------*
        SELECT ebeln ebelp banfn bnfpo FROM ekpo
               INTO CORRESPONDING FIELDS OF TABLE ist_ola_pr_t
               FOR ALL ENTRIES IN ist_ola_pr_tmp
               WHERE ebeln = ist_ola_pr_tmp-ebeln AND
                     loekz = ''.

        IF NOT ist_ola_pr_t[] IS INITIAL.

          LOOP AT ist_ola_pr_hdr INTO wa_ola_pr_hdr.
            DELETE ist_ola_pr_t WHERE banfn = wa_ola_pr_hdr-banfn.
          ENDLOOP.

          IF NOT ist_ola_pr_t[] IS INITIAL.
            LOOP AT ist_ola_pr_t INTO wa_ola_pr_t.
              MOVE-CORRESPONDING wa_ola_pr_t TO wa_ola_pr_hdr.
              IF wa_ola_pr_hdr-banfn IS INITIAL.
                wa_ola_pr_hdr-banfn = '9999999999'.
              ENDIF.
              APPEND wa_ola_pr_hdr TO ist_ola_pr_hdr.
            ENDLOOP.
          ELSE.
            CLEAR p_chk.
          ENDIF.

        ELSE.
          CLEAR p_chk.
        ENDIF.

      ELSE.
        CLEAR p_chk.
      ENDIF.

    ELSE.
      CLEAR p_chk.
    ENDIF.

  ENDIF.

ENDFORM.                    " GET_OLD_PR_DTL_R
