REPORT z_corr_prctr2 .

TABLES: bseg,
        bkpf,
        bvor,
        bsid,
        bsik,
        bsis,
        bsad,
        bsak,
        bsas,
        t8a30,
        glpca.

DATA: ibseg LIKE bseg OCCURS 100 WITH HEADER LINE.
DATA: kbseg LIKE bseg OCCURS 100 WITH HEADER LINE.
DATA: bbseg LIKE bseg OCCURS 100 WITH HEADER LINE.
DATA: it_tkedrs LIKE tkedrs OCCURS 20 WITH HEADER LINE.
DATA: s_bvorg LIKE bvor-bvorg.
DATA: counter TYPE i VALUE IS INITIAL.
DATA: c_max TYPE i VALUE 1000.
DATA: db_change TYPE i.

*----------------------------------------------------------------------*
*   data definition
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA:   E_GROUP_OPENED.
*       message texts
TABLES: T100.

*Selection fields for GLPCA documents
SELECT-OPTIONS s_rbukrs FOR glpca-rbukrs.
SELECT-OPTIONS s_ryear  FOR glpca-ryear.
SELECT-OPTIONS s_refdoc FOR glpca-refdocnr.

PARAMETER: overwrt LIKE boole-boole DEFAULT space.
PARAMETER: real_run LIKE boole-boole DEFAULT space.

SELECT * FROM glpca
      WHERE rbukrs   IN s_rbukrs
      AND   ryear    IN s_ryear
      AND   rldnr    = '8A'
      AND   refdocnr IN s_refdoc.
*      AND   STFLG    = SPACE
*      AND   STOKZ    NE SPACE.

*FI line item
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*  SELECT SINGLE * FROM bkpf
*      WHERE belnr = glpca-refdocnr
*      AND   bukrs = glpca-aworg+00(04)
*      AND   gjahr = glpca-aworg+04(04).
  SELECT * FROM bkpf UP TO 1 ROWS
      WHERE belnr = glpca-refdocnr
      AND   bukrs = glpca-aworg+00(04)
      AND   gjahr = glpca-aworg+04(04) ORDER BY PRIMARY KEY.
  ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  IF bkpf-bvorg NE space.              "Cross company Posting
*    SELECT SINGLE * FROM bvor
*        WHERE bvorg = bkpf-bvorg
*          AND bukrs = glpca-rbukrs.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        SELECT * FROM bvor UP TO 1 ROWS
        WHERE bvorg = bkpf-bvorg
          AND bukrs = glpca-rbukrs ORDER BY PRIMARY KEY. ENDSELECT.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT * FROM bseg
      WHERE belnr = bvor-belnr
      AND   bukrs = bvor-bukrs
      AND   gjahr = bvor-gjahr.
      glpca-hsl = abs( glpca-hsl ).
      IF bseg-hkont = glpca-racct
      AND bseg-fkber = glpca-rfarea
      AND bseg-gsber = glpca-gsber
      AND bseg-shkzg = glpca-drcrk
      AND bseg-dmbtr = glpca-hsl.
        MOVE-CORRESPONDING bseg TO bbseg.
        APPEND bbseg.
      ENDIF.
    ENDSELECT.
    IF sy-subrc <> 0.
      WRITE: / 'No BVOR entry found'.
    ENDIF.
    DESCRIBE TABLE bbseg LINES sy-tfill.
    IF sy-tfill NE 1.
      WRITE: / 'BSEG entry from cross company doc', bvor-bvorg,
      'is not unique. Special analysis required!'.
    ELSE.
      LOOP AT bbseg.
        MOVE-CORRESPONDING bbseg TO bseg.
        PERFORM get_profit_center_crosscomp.
      ENDLOOP.
    ENDIF.
    REFRESH bbseg.
  ELSE.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT SINGLE * FROM  bseg
           WHERE  bukrs       = bkpf-bukrs
           AND    belnr       = bkpf-belnr
           AND    gjahr       = bkpf-gjahr
           AND    buzei       = glpca-refdocln.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    IF sy-subrc <> 0.
      WRITE: / 'No BSEG entry found'.
    ELSE.
      PERFORM get_profit_center.
    ENDIF.
  ENDIF.
ENDSELECT.
IF sy-subrc <> 0.
  WRITE: / 'No GLPCA entry found'.
  EXIT.
ENDIF.

*List or update
IF real_run = 'X'.
  PERFORM update_line_items.
  ULINE.
  WRITE: /'Corrected line items:', counter.
  ULINE.

  IF NOT kbseg[] IS INITIAL.

*    SUBMIT rgurec10 VIA SELECTION-SCREEN
*             WITH bukrs IN s_rbukrs
*             WITH gjahr IN s_ryear
*             WITH rbelnr IN s_refdoc
*             WITH test EQ ' '
*             WITH list EQ 'X'
*             WITH pruefen EQ ' '
*             WITH storno EQ 'X'
*             WITH mm_sd EQ 'X' AND RETURN.

    LOOP AT kbseg.

    refresh bdcdata.

    perform bdc_dynpro      using 'RGUREC10' '1000'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'MM_SD'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=ONLI'.
    perform bdc_field       using 'BUKRS-LOW'
                                  kbseg-bukrs.  "'MUM'.
    perform bdc_field       using 'GJAHR-LOW'
                                  kbseg-gjahr.  "'2004'.
    perform bdc_field       using 'RBELNR-LOW'
                                  kbseg-BELNR.  "'1003000001'.
    perform bdc_field       using 'TEST'
                                  ''.
    perform bdc_field       using 'LIST'
                                  'X'.
    perform bdc_field       using 'PRUEFEN'
                                  ''.
    perform bdc_field       using 'STORNO'
                                  'X'.
    perform bdc_field       using 'MM_SD'
                                  'X'.
    perform bdc_transaction using '1KE8'.



    ENDLOOP.

  ENDIF.

ELSE.
  PERFORM print_line_items.
  ULINE.
  WRITE: /'Line items for correction:', counter.
  ULINE.
ENDIF.

*   *
*	       FORM Get_profit_center	*
*   *
*	       ........	*
*   *
FORM get_profit_center.

*Get profit center (prctr) from PCA document corrected with 1KE8
SELECT SINGLE * FROM glpca
WHERE rbukrs = bseg-bukrs
AND   ryear  = bseg-gjahr
AND   refdocnr = bseg-belnr
AND   refdocln = bseg-buzei
AND   aworg    = glpca-aworg
AND   stflg    = space
AND   stokz    = space
AND   rprctr   NE space.
  IF sy-subrc <> 0.
    WRITE: / 'FI line item', bseg-bukrs, bseg-belnr, bseg-buzei,
': No valid entry found in GLPCA'.
  ELSE.
    PERFORM check_and_move_prctr.
  ENDIF.
ENDFORM.

*   *
*	       FORM Get_profit_center_crosscomp	*
*   *
*	       ........	*
*   *

FORM get_profit_center_crosscomp.
*Get profit center (prctr) from PCA document corrected with 1KE8
SELECT SINGLE * FROM glpca
      WHERE rbukrs = bseg-bukrs
       AND   ryear  = bseg-gjahr
            AND   refdocnr = glpca-refdocnr
            AND   refdocln = bseg-buzei
            AND   racct    = bseg-hkont
            AND   aworg    = glpca-aworg
            AND   stflg    = space
            AND   stokz    = space
            AND   rprctr   NE space.
IF sy-subrc <> 0.
  WRITE: / 'FI line item', bseg-bukrs, bseg-belnr,
            bseg-buzei, ': No valid entry found in GLPCA'.
ELSE.
  PERFORM check_and_move_prctr.
ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM correct_index                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM correct_index.

IF bseg-augbl = '  '.
  CASE bseg-koart.
    WHEN 'D'.
      SELECT SINGLE * FROM bsid
                            WHERE bukrs = bseg-bukrs
                            AND   kunnr = bseg-kunnr
                            AND   umsks = bseg-umsks
                            AND   umskz = bseg-umskz
                            AND   augdt = bseg-augdt
                            AND   augbl = bseg-augbl
                            AND   zuonr = bseg-zuonr
                            AND   gjahr = bseg-gjahr
                            AND   belnr = bseg-belnr
                            AND   buzei = bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING bseg TO bsid.
*        UPDATE bsid.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSID entry for BELNR ', bseg-belnr, 'not found!'.
      ENDIF.
      IF bseg-xhres = 'X'.
        PERFORM sonderhauptbuch_bsis_index.
      ENDIF.
    WHEN 'K'.
      SELECT SINGLE * FROM bsik
                            WHERE bukrs = bseg-bukrs
                            AND   lifnr = bseg-lifnr
                            AND   umsks = bseg-umsks
                            AND   umskz = bseg-umskz
                            AND   augdt = bseg-augdt
                            AND   augbl = bseg-augbl
                            AND   zuonr = bseg-zuonr
                            AND   gjahr = bseg-gjahr
                            AND   belnr = bseg-belnr
                            AND   buzei = bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING bseg TO bsik.
*        UPDATE bsik.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSIK entry for BELNR ', bseg-belnr, 'not found!'.
      ENDIF.
      IF bseg-xhres = 'X'.
        PERFORM sonderhauptbuch_bsis_index.
      ENDIF.
    WHEN 'S'.
      SELECT SINGLE * FROM bsis
                            WHERE bukrs = bseg-bukrs
                            AND   hkont = bseg-hkont
                            AND   augdt = bseg-augdt
                            AND   augbl = bseg-augbl
                            AND   zuonr = bseg-zuonr
                            AND   gjahr = bseg-gjahr
                            AND   belnr = bseg-belnr
                            AND   buzei = bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING bseg TO bsis.
*        UPDATE bsis.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSIS entry for BELNR ', bseg-belnr, 'not found!'.
      ENDIF.
  ENDCASE.
ELSE.
  CASE bseg-koart.
    WHEN 'D'.
      SELECT SINGLE * FROM bsad
                            WHERE bukrs = bseg-bukrs
                            AND   kunnr = bseg-kunnr
                            AND   umsks = bseg-umsks
                            AND   umskz = bseg-umskz
                            AND   augdt = bseg-augdt
                            AND   augbl = bseg-augbl
                            AND   zuonr = bseg-zuonr
                            AND   gjahr = bseg-gjahr
                            AND   belnr = bseg-belnr
                            AND   buzei = bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING bseg TO bsad.
*        UPDATE bsad.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSAD entry for BELNR ', bseg-belnr, 'not found!'.
      ENDIF.
      IF bseg-xhres = 'X'.
        PERFORM sonderhauptbuch_bsas_index.
      ENDIF.
    WHEN 'K'.
      SELECT SINGLE * FROM bsak
                            WHERE bukrs = bseg-bukrs
                            AND   lifnr = bseg-lifnr
                            AND   umsks = bseg-umsks
                            AND   umskz = bseg-umskz
                            AND   augdt = bseg-augdt
                            AND   augbl = bseg-augbl
                            AND   zuonr = bseg-zuonr
                            AND   gjahr = bseg-gjahr
                            AND   belnr = bseg-belnr
                            AND   buzei = bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING bseg TO bsak.
*        UPDATE bsak.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSAK entry for BELNR ', bseg-belnr, 'not found!'.
      ENDIF.
      IF bseg-xhres = 'X'.
        PERFORM sonderhauptbuch_bsas_index.
      ENDIF.
    WHEN 'S'.
      SELECT SINGLE * FROM bsas
                            WHERE bukrs = bseg-bukrs
                            AND   hkont = bseg-hkont
                            AND   augdt = bseg-augdt
                            AND   augbl = bseg-augbl
                            AND   zuonr = bseg-zuonr
                            AND   gjahr = bseg-gjahr
                            AND   belnr = bseg-belnr
                            AND   buzei = bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING bseg TO bsas.
*        UPDATE bsas.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSAS entry for BELNR ', bseg-belnr, 'not found!'.
      ENDIF.
  ENDCASE.
ENDIF.
ENDFORM.

* FORM SONDERHAUPTBUCH_BSIS_INDEX
FORM sonderhauptbuch_bsis_index.
  SELECT SINGLE * FROM bsis
                        WHERE bukrs = bseg-bukrs
                        AND   hkont = bseg-hkont
                        AND   augdt = bseg-augdt
                        AND   augbl = bseg-augbl
                        AND   zuonr = bseg-hzuon
                        AND   gjahr = bseg-gjahr
                        AND   belnr = bseg-belnr
                        AND   buzei = bseg-buzei.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING bseg TO bsis.
    bsis-zuonr = bseg-hzuon.
*    UPDATE bsis.
    IF sy-dbcnt <> 1.
      MESSAGE a500(fe) WITH 'Fehler'.
    ENDIF.
  ELSE.
    WRITE: / 'BSIS entry for BELNR ', bseg-belnr, 'not found!'.
  ENDIF.
ENDFORM.

* FORM SONDERHAUPTBUCH_BSAS_INDEX
FORM sonderhauptbuch_bsas_index.
  SELECT SINGLE * FROM bsas
                        WHERE bukrs = bseg-bukrs
                        AND   hkont = bseg-hkont
                        AND   augdt = bseg-augdt
                        AND   augbl = bseg-augbl
                        AND   zuonr = bseg-hzuon
                        AND   gjahr = bseg-gjahr
                        AND   belnr = bseg-belnr
                        AND   buzei = bseg-buzei.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING bseg TO bsas.
    bsas-zuonr = bseg-hzuon.
*    UPDATE bsas.
    IF sy-dbcnt <> 1.
      MESSAGE a500(fe) WITH 'Fehler'.
    ENDIF.
  ELSE.
    WRITE: / 'BSAS entry for BELNR ', bseg-belnr, 'not found!'.
  ENDIF.
ENDFORM.

* form update_line_items.
* update and print of line items.
FORM update_line_items.
  CHECK real_run = 'X'.
  WRITE: / 'Corrected entries:'.
  ULINE.
  WRITE: / 'Table', 15 'BUKRS', 22 'BELNR', 35 'BUZEI'.
  ULINE.
  LOOP AT ibseg.
    counter = counter + 1.
    CLEAR bseg.
    MOVE-CORRESPONDING ibseg TO bseg.
    UPDATE bseg.
    IF sy-dbcnt <> 1.
*      MESSAGE a500(fe) WITH 'Fehler'.
    ELSE.
      WRITE: / 'BSEG', 15 bseg-bukrs, 22 bseg-belnr, 35 bseg-buzei,
               40 bseg-prctr, 52 bseg-hkont.

      MOVE-CORRESPONDING ibseg TO kbseg.
      APPEND kbseg.
    ENDIF.
    IF bseg-xkres = 'X'.
      PERFORM correct_index.
    ENDIF.

    ADD 1 TO db_change.
    IF db_change >= c_max.
      CALL FUNCTION 'DB_COMMIT'.
      db_change = 0.
    ENDIF.

  ENDLOOP.
ENDFORM.

* form print_line_items.
FORM print_line_items.
  ULINE. "#EC CI_NOORDER
  WRITE: / 'Entries for correction:'. "#EC CI_NOORDER
  ULINE. "#EC CI_NOORDER
  WRITE: / 'Table', 15 'BUKRS', 22 'BELNR', 35 'BUZEI', 42 'PRCTR'. "#EC CI_NOORDER
  ULINE. "#EC CI_NOORDER
  LOOP AT ibseg.
    counter = counter + 1.
    WRITE: / 'BSEG', 15 ibseg-bukrs, 22 ibseg-belnr, 35 ibseg-buzei, "#EC CI_NOORDER
      40 ibseg-prctr.
  ENDLOOP.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM check_and_move_prctr                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_and_move_prctr.

glpca-hsl = abs( glpca-hsl ).
  IF bseg-dmbtr NE glpca-hsl.
    WRITE: / 'FI line item', bseg-bukrs, bseg-belnr, bseg-buzei,
   ': Entry found in GLPCA does not fit!'.
  ELSE.
    PERFORM move_prctr.
  ENDIF.
ENDFORM.                               " CHECK_AND_MOVE_PRCTR

*---------------------------------------------------------------------*
*       FORM move_prctr                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM move_prctr.

  MOVE-CORRESPONDING bseg TO ibseg.
* IBSEG-PRCTR = GLPCA-RPRCTR.
  PERFORM fill_from_t8a30.
  APPEND ibseg.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM fill_from_t8a30                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM fill_from_t8a30.

DATA: l_prctr  LIKE ibseg-prctr,
      dbfields TYPE TABLE OF dbfield WITH HEADER LINE,
      l_condi  TYPE string,
      l_subrc  TYPE sy-subrc,
      l_tabname TYPE dd02l-tabname.

*only from from table T8A30!!!!!
*  SELECT SINGLE * FROM t8a30
*    WHERE kokrs     = bseg-kokrs
*    AND   konto_von <= bseg-hkont
*    AND   konto_bis >= bseg-hkont.
  SELECT * FROM t8a30 UP TO 1 ROWS
    WHERE kokrs     = bseg-kokrs
    AND   konto_von <= bseg-hkont
    AND   konto_bis >= bseg-hkont ORDER BY PRIMARY KEY. ENDSELECT.

  IF sy-subrc <> 0.

    WRITE: / 'document', bseg-belnr,
': No T8A30 entry found FOR ACCOUNT', bseg-hkont.

  ELSE.

    IF t8a30-prctr = 'ONGC_DUMMY'.

      CLEAR l_prctr.

      SELECT SINGLE prctr INTO l_prctr FROM zpc_coba
        WHERE bukrs = bseg-bukrs AND
              gsber = bseg-gsber.

      IF sy-subrc = 0.
        ibseg-prctr = l_prctr.
      ENDIF.

    ENDIF.

  ENDIF.

*      REFRESH it_tkedrs.
*
*      SELECT * FROM tkedrs
*          INTO TABLE it_tkedrs
*          WHERE applclass = 'PCA' AND
*                kedrenv = t8a30-kokrs.
*
*      IF NOT it_tkedrs[] IS INITIAL.
*
*        LOOP AT it_tkedrs.
*
*          l_tabname = it_tkedrs-param_1.
*
*          CALL FUNCTION 'DB_GET_TABLE_FIELDS'
*            EXPORTING
**             FIELD_INFO       = 'A'
*              tabname          = l_tabname
*            IMPORTING
*              subrc            = l_subrc
*            TABLES
*              dbfields         = dbfields.
*
*          IF l_subrc = 0.
*
*            READ TABLE dbfields WITH KEY name = 'SOUR3_FROM'.
*
*            CLEAR l_prctr.
*
*            IF sy-subrc = 0.
*
*              SELECT SINGLE target1 INTO l_prctr
*                    FROM (it_tkedrs-param_1)
*                    WHERE sour1_from <= bseg-hkont AND
*                          sour1_to   >= bseg-hkont AND
*                          sour2_from = bseg-bukrs AND
*                          sour3_from = bseg-gsber.
*
*            ELSE.
*
*              SELECT SINGLE target1 INTO l_prctr
*                    FROM (it_tkedrs-param_1)
*                    WHERE sour1_from <= bseg-hkont AND
*                          sour1_to   >= bseg-hkont AND
*                          sour2_from = bseg-bukrs.
*
*            ENDIF.
*
*            IF sy-subrc = 0.
*
*              ibseg-prctr = l_prctr.
*              exit.
*
*            ENDIF.
*
*          ENDIF.
*
*        ENDLOOP.
*
*      ENDIF. " Commented By Kalpesh

*      ENDIF.
*
*    ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  bdc_transaction
*&---------------------------------------------------------------------*
form bdc_transaction using tcode.
  data: l_mstring(480).
  data: l_subrc like sy-subrc.
  data: l_mode value 'N'.
  data: l_upd value 'S'.
  call transaction tcode using bdcdata
                   update l_upd
                   mode   l_mode
                   messages into messtab.

endform.                    " bdc_transaction
