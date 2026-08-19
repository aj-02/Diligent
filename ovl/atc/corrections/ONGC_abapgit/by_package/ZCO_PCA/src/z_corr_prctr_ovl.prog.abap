REPORT z_corr_prctr .
TABLES: bseg,
*        bkpf,
*        bvor,
        bsid,
        bsik,
        bsis,
        bsad,
        bsak,
        bsas,
        t8a30,
        glpca.

PARAMETER: p_bukrs LIKE glpca-rbukrs OBLIGATORY,
           p_year  LIKE glpca-ryear OBLIGATORY,
           p_period LIKE glpca-poper OBLIGATORY.

SELECT-OPTIONS s_refdoc FOR glpca-refdocnr OBLIGATORY.

PARAMETER: real_run LIKE boole-boole DEFAULT 'X'.
RANGES: r_awkey FOR bkpf-awkey,
        r_hkont FOR glpca-racct,
        r_belnr FOR bseg-belnr.

DATA: it_bseg  LIKE bseg OCCURS 100 WITH HEADER LINE,
      it_glpca LIKE glpca OCCURS 100 WITH HEADER LINE,
      it_final LIKE glpca OCCURS 100 WITH HEADER LINE,
      it_bkpf  LIKE bkpf OCCURS 100 WITH HEADER LINE,
      it_bkpf1  LIKE bkpf OCCURS 100 WITH HEADER LINE,
      it_bkpf2  LIKE bkpf OCCURS 100 WITH HEADER LINE,
      it_bkpf3  LIKE bkpf OCCURS 100 WITH HEADER LINE,
      it_zpc_coba LIKE zpc_coba OCCURS 100 WITH HEADER LINE.
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF it_doc OCCURS 0,
      docnr LIKE glpca-docnr,
      refdocnr LIKE glpca-refdocnr,
     refryear LIKE glpca-refryear,
     refdocln LIKE glpca-refdocln ,
     awtyp   LIKE glpca-awtyp,
     refactiv LIKE glpca-refactiv,
     docct  LIKE glpca-docct,
     aworg LIKE glpca-aworg,
      END OF it_doc.



*DATA: l_prctr  LIKE bseg-prctr.
*      dbfields TYPE TABLE OF dbfield WITH HEADER LINE,
*      l_condi  TYPE string.
*      l_subrc  TYPE sy-subrc.
*      l_tabname TYPE dd02l-tabname.
DATA: wa_bseg LIKE bseg.
DATA: wa_glpca1 LIKE glpca.
DATA: wa_glpca2 LIKE glpca.
DATA: db_change TYPE i.
DATA: c_max TYPE i VALUE 1000.
DATA:l_tsl(19).
DATA: last_day LIKE sy-datum.
DATA: l_day1(10).
DATA: msg(256).
DATA: l_docnr LIKE glpca-docnr.
DATA: g_sirid TYPE glpca-gl_sirid.
DATA: g_monat TYPE monat.


g_monat = p_period+1(2).
SELECT * FROM glpca INTO TABLE it_glpca
   WHERE rbukrs  = p_bukrs
     AND ryear  = p_year
     AND poper = p_period
     AND refdocnr IN s_refdoc
     AND rprctr = 'OVL_DUMMY'.

LOOP AT it_glpca.
  CLEAR r_awkey.
  r_awkey-sign = 'I'.
  r_awkey-option = 'EQ'.
  CONCATENATE it_glpca-refdocnr '%' INTO r_awkey-low .
  APPEND r_awkey.

  CLEAR r_hkont.
  r_hkont-sign = 'I'.
  r_hkont-option = 'EQ'.
  r_hkont-low = it_glpca-racct.
  APPEND r_hkont.
ENDLOOP.

SORT r_awkey BY low.
DELETE ADJACENT DUPLICATES FROM r_awkey COMPARING  low.

LOOP AT r_awkey.
  SELECT * FROM bkpf APPENDING TABLE it_bkpf1
     WHERE bukrs  = p_bukrs
       AND gjahr  = p_year
       AND monat = g_monat "p_period
       AND awtyp IN ('VBRK','HRPAY','BKPF','MKPF' , 'AMBU' )
       AND awkey LIKE r_awkey-low."IN r_awkey.
  IF sy-subrc <> 0.
    SELECT * FROM bkpf APPENDING TABLE it_bkpf2
       WHERE bukrs  = p_bukrs
         AND gjahr  = p_year
         AND monat = g_monat "p_period
         AND   awtyp = 'RMRP'
         AND awkey LIKE r_awkey-low."IN r_awkey.
    IF sy-subrc <> 0.
      SELECT * FROM bkpf APPENDING TABLE it_bkpf3
         WHERE bukrs  = p_bukrs
           AND gjahr  = p_year
           AND monat = g_monat " p_period
           AND   awtyp = 'AUAK'
           AND awkey LIKE r_awkey-low."IN r_awkey.
    ENDIF.
  ENDIF.
ENDLOOP.

APPEND LINES OF it_bkpf1[] TO it_bkpf[].
APPEND LINES OF it_bkpf2[] TO it_bkpf[].
APPEND LINES OF it_bkpf3[] TO it_bkpf[].

LOOP AT it_bkpf.
  CLEAR r_belnr.
  r_belnr-sign = 'I'.
  r_belnr-option = 'EQ'.
  r_belnr-low = it_bkpf-belnr.
  APPEND r_belnr.
ENDLOOP.

SELECT * FROM zpc_coba INTO TABLE it_zpc_coba
     WHERE bukrs = p_bukrs.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
SELECT * FROM bseg INTO TABLE it_bseg
   WHERE bukrs  = p_bukrs
    AND belnr IN r_belnr
     AND gjahr  = p_year
     AND hkont  IN r_hkont.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*Start Changes by SAB_RAMESH on 09.10.2006
*     AND ( koart = 'S' OR koart = 'A' )
*     AND (  prctr = 'ONGC_DUMMY' OR prctr = '' ).


DELETE it_bseg WHERE ( koart <> 'S' OR koart <> 'A' ).
DELETE it_bseg WHERE ( prctr <> 'OVL_DUMMY' OR prctr <> '' ).
*End  Changes by SAB_RAMESH on 09.10.2006

IF real_run = 'X'.
  LOOP AT it_bseg INTO wa_bseg.

*    SELECT SINGLE * FROM t8a30
*      WHERE kokrs     = wa_bseg-kokrs
*      AND   konto_von <= wa_bseg-hkont
*      AND   konto_bis >= wa_bseg-hkont.
    SELECT * FROM t8a30 UP TO 1 ROWS
      WHERE kokrs     = wa_bseg-kokrs
      AND   konto_von <= wa_bseg-hkont
      AND   konto_bis >= wa_bseg-hkont ORDER BY PRIMARY KEY. ENDSELECT.
    IF sy-subrc <> 0.

      WRITE: / 'document', bseg-belnr,
  ': No T8A30 entry found FOR ACCOUNT', bseg-hkont.

    ELSE.

      IF t8a30-prctr = 'OVL_DUMMY'.

*      CLEAR l_prctr.

*      SELECT SINGLE prctr INTO l_prctr FROM zpc_coba
*        WHERE bukrs = wa_bseg-bukrs AND
*              gsber = wa_bseg-gsber.
        CLEAR it_zpc_coba.
        READ TABLE it_zpc_coba WITH KEY bukrs = wa_bseg-bukrs
                                        gsber = wa_bseg-gsber.
        IF sy-subrc = 0.
*        wa_bseg-prctr = l_prctr.
          wa_bseg-prctr = it_zpc_coba-prctr.
          UPDATE bseg FROM wa_bseg.
          COMMIT WORK.

          IF wa_bseg-xkres = 'X'.
            PERFORM correct_index.
          ENDIF.

        ENDIF.

      ENDIF.


      ADD 1 TO db_change.
      IF db_change >= c_max.
        CALL FUNCTION 'DB_COMMIT'.
        db_change = 0.
      ENDIF.

    ENDIF.

  ENDLOOP.

  LOOP AT it_glpca.
    CLEAR : it_zpc_coba,wa_glpca1,wa_glpca2.

    wa_glpca1 = wa_glpca2 = it_glpca.

    wa_glpca1-hsl = wa_glpca1-hsl * -1.
    APPEND wa_glpca1 TO it_final.

    READ TABLE it_zpc_coba WITH KEY bukrs = wa_glpca2-rbukrs
                                    gsber = wa_glpca2-gsber.
    IF sy-subrc = 0.
      wa_glpca2-rprctr = it_zpc_coba-prctr.
      APPEND wa_glpca2 TO it_final.
    ELSE.
    WRITE:/ 'No Profit Center for' , wa_glpca2-rbukrs, wa_glpca2-gsber , "#EC CI_NOORDER
                'In Table ZPC_COBA'.  "#EC CI_NOORDER
      APPEND wa_glpca2 TO it_final.
    ENDIF.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  ENDLOOP.  "#EC CI_FLDEXT_OK[2610650]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  LOOP AT it_bseg INTO wa_bseg.
    WRITE: / wa_bseg-bukrs, wa_bseg-belnr, wa_bseg-buzei,  "#EC CI_NOORDER
             wa_bseg-prctr, wa_bseg-dmbtr CURRENCY ''. "#EC CI_FLDEXT_OK[2610650]
  ENDLOOP.

  CALL FUNCTION 'BAPI_COAREA_GETPERIODLIMITS'
    EXPORTING
      controllingareaid         = 'ONGC'
      fiscal_period             = g_monat
      fiscal_year               = p_year
   IMPORTING
*   FIRST_DAY_OF_PERIOD       =
     last_day_of_period        = last_day
*   LAST_NORMAL_PERIOD        =
*   RETURN                    =
            .

  WRITE last_day TO l_day1 DD/MM/YYYY.

  LOOP AT it_final.
    REFRESH messtab.
    CLEAR l_tsl.
    l_tsl = it_final-hsl.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              input  = l_tsl
         IMPORTING
              output = l_tsl.
    CONDENSE l_tsl NO-GAPS.

    PERFORM bdc_dynpro      USING 'SAPMGBUK' '0202'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'GLU1-RTCUR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'GLU1-BUKRS'
                                  it_final-rbukrs.
    PERFORM bdc_field       USING 'GLU1-DOCTY'
                                  'MA'.
    PERFORM bdc_field       USING 'GLU1-RTCUR'
                                  'INR'.
    PERFORM bdc_field       USING 'RGBUK-DATE'
                                  l_day1.

    PERFORM bdc_dynpro      USING 'SAPMGBUK' '0110'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RGBUK-O_V02'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=DOWN'.
    PERFORM bdc_field       USING 'GLU1-TSL'
                                  l_tsl.
    PERFORM bdc_field       USING 'RGBUK-O_V01'
                                  it_final-rprctr.
    PERFORM bdc_field       USING 'RGBUK-O_V02'
                                  it_final-racct.
    PERFORM bdc_field       USING 'RGBUK-O_V04'
                                  '00'.
    PERFORM bdc_field       USING 'RGBUK-O_V07'
                                  '00'.

    PERFORM bdc_dynpro      USING 'SAPMGBUK' '0110'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'GLU1-SGTXT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'GLU1-TSL'
                                  l_tsl.
    PERFORM bdc_field       USING 'RGBUK-O_V01'
                                  '00'.
    PERFORM bdc_field       USING 'RGBUK-O_V04'
                                  '00'.
    PERFORM bdc_field       USING 'RGBUK-O_V08'
                                  '00.00.0000'.
    PERFORM bdc_field       USING 'GLU1-SGTXT'
                                  'Entries to tally GL to PCA'.

    PERFORM bdc_dynpro      USING 'SAPMGBUK' '0110'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'GLU1-TSL'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=BOOK'.
    PERFORM bdc_field       USING 'GLU1-TSL'
                                  l_tsl.
    PERFORM bdc_field       USING 'RGBUK-O_V01'
                                  '00'.
    PERFORM bdc_field       USING 'RGBUK-O_V04'
                                  '00'.
    PERFORM bdc_field       USING 'RGBUK-O_V08'
                                  '00.00.0000'.
    PERFORM bdc_field       USING 'GLU1-SGTXT'
                                  'Entries to tally GL to PCA'.
    PERFORM bdc_transaction USING '1KEL'.
    REFRESH bdcdata.
    IF NOT messtab[] IS INITIAL.
      LOOP AT messtab." WHERE msgtyp = 'E'.

        CALL FUNCTION 'FORMAT_MESSAGE'
             EXPORTING
                  id        = messtab-msgid
                  lang      = 'EN'
                  no        = messtab-msgnr
                  v1        = messtab-msgv1
                  v2        = messtab-msgv2
                  v3        = messtab-msgv3
                  v4        = messtab-msgv4
             IMPORTING
                  msg       = msg
             EXCEPTIONS
                  not_found = 1
                  OTHERS    = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
        IF messtab-msgtyp = 'E'.
          WRITE:/ msg.
        ENDIF.
        IF msg+0(38) = 'Document posted under document number '.
          l_docnr = msg+38(10).
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
               EXPORTING
                    input  = l_docnr
               IMPORTING
                    output = l_docnr.

          it_doc-docnr = l_docnr.
          it_doc-refdocnr = it_final-refdocnr.
          it_doc-refryear = it_final-refryear.
          it_doc-refdocln = it_final-refdocln.
          it_doc-awtyp   = it_final-awtyp.
          it_doc-refactiv = it_final-refactiv.
          it_doc-docct   = it_final-docct.
          it_doc-aworg   = it_final-aworg.
          APPEND it_doc.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  LOOP AT it_doc.
    CLEAR:g_sirid.

*    SELECT SINGLE gl_sirid INTO g_sirid FROM glpca
*     WHERE docnr = it_doc-docnr
*       AND rbukrs = p_bukrs
*       AND ryear  = p_year.
    SELECT gl_sirid INTO g_sirid FROM glpca UP TO 1 ROWS
     WHERE docnr = it_doc-docnr
       AND rbukrs = p_bukrs
       AND ryear  = p_year ORDER BY PRIMARY KEY. ENDSELECT.
    IF sy-subrc = 0.
      UPDATE glpca SET refdocnr = it_doc-refdocnr
                       refryear = it_doc-refryear
                       refdocln = it_doc-refdocln
                       awtyp    = it_doc-awtyp
                       refactiv = it_doc-refactiv
                       docct    = it_doc-docct
                       aworg    = it_doc-aworg
       WHERE gl_sirid = g_sirid.
      COMMIT WORK.
    ENDIF.
  ENDLOOP.
ENDIF.
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
                            WHERE bukrs = wa_bseg-bukrs
                            AND   kunnr = wa_bseg-kunnr
                            AND   umsks = wa_bseg-umsks
                            AND   umskz = wa_bseg-umskz
                            AND   augdt = wa_bseg-augdt
                            AND   augbl = wa_bseg-augbl
                            AND   zuonr = wa_bseg-zuonr
                            AND   gjahr = wa_bseg-gjahr
                            AND   belnr = wa_bseg-belnr
                            AND   buzei = wa_bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING wa_bseg TO bsid.
*        UPDATE bsid.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSID entry for BELNR ', bseg-belnr, 'not found!'.
      ENDIF.
      IF wa_bseg-xhres = 'X'.
        PERFORM sonderhauptbuch_bsis_index.
      ENDIF.
    WHEN 'K'.
      SELECT SINGLE * FROM bsik
                            WHERE bukrs = wa_bseg-bukrs
                            AND   lifnr = wa_bseg-lifnr
                            AND   umsks = wa_bseg-umsks
                            AND   umskz = wa_bseg-umskz
                            AND   augdt = wa_bseg-augdt
                            AND   augbl = wa_bseg-augbl
                            AND   zuonr = wa_bseg-zuonr
                            AND   gjahr = wa_bseg-gjahr
                            AND   belnr = wa_bseg-belnr
                            AND   buzei = wa_bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING wa_bseg TO bsik.
*        UPDATE bsik.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSIK entry for BELNR ', wa_bseg-belnr, 'not found!'.
      ENDIF.
      IF wa_bseg-xhres = 'X'.
        PERFORM sonderhauptbuch_bsis_index.
      ENDIF.
    WHEN 'S'.
      SELECT SINGLE * FROM bsis
                            WHERE bukrs = wa_bseg-bukrs
                            AND   hkont = wa_bseg-hkont
                            AND   augdt = wa_bseg-augdt
                            AND   augbl = wa_bseg-augbl
                            AND   zuonr = wa_bseg-zuonr
                            AND   gjahr = wa_bseg-gjahr
                            AND   belnr = wa_bseg-belnr
                            AND   buzei = wa_bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING wa_bseg TO bsis.
*        UPDATE bsis.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSIS entry for BELNR ', wa_bseg-belnr, 'not found!'.
      ENDIF.
  ENDCASE.
ELSE.
  CASE wa_bseg-koart.
    WHEN 'D'.
      SELECT SINGLE * FROM bsad
                            WHERE bukrs = wa_bseg-bukrs
                            AND   kunnr = wa_bseg-kunnr
                            AND   umsks = wa_bseg-umsks
                            AND   umskz = wa_bseg-umskz
                            AND   augdt = wa_bseg-augdt
                            AND   augbl = wa_bseg-augbl
                            AND   zuonr = wa_bseg-zuonr
                            AND   gjahr = wa_bseg-gjahr
                            AND   belnr = wa_bseg-belnr
                            AND   buzei = wa_bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING wa_bseg TO bsad.
*        UPDATE bsad.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSAD entry for BELNR ', wa_bseg-belnr, 'not found!'.
      ENDIF.
      IF wa_bseg-xhres = 'X'.
        PERFORM sonderhauptbuch_bsas_index.
      ENDIF.
    WHEN 'K'.
      SELECT SINGLE * FROM bsak
                            WHERE bukrs = wa_bseg-bukrs
                            AND   lifnr = wa_bseg-lifnr
                            AND   umsks = wa_bseg-umsks
                            AND   umskz = wa_bseg-umskz
                            AND   augdt = wa_bseg-augdt
                            AND   augbl = wa_bseg-augbl
                            AND   zuonr = wa_bseg-zuonr
                            AND   gjahr = wa_bseg-gjahr
                            AND   belnr = wa_bseg-belnr
                            AND   buzei = wa_bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING wa_bseg TO bsak.
*        UPDATE bsak.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSAK entry for BELNR ', wa_bseg-belnr, 'not found!'.
      ENDIF.
      IF wa_bseg-xhres = 'X'.
        PERFORM sonderhauptbuch_bsas_index.
      ENDIF.
    WHEN 'S'.
      SELECT SINGLE * FROM bsas
                            WHERE bukrs = wa_bseg-bukrs
                            AND   hkont = wa_bseg-hkont
                            AND   augdt = wa_bseg-augdt
                            AND   augbl = wa_bseg-augbl
                            AND   zuonr = wa_bseg-zuonr
                            AND   gjahr = wa_bseg-gjahr
                            AND   belnr = wa_bseg-belnr
                            AND   buzei = wa_bseg-buzei.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING wa_bseg TO bsas.
*        UPDATE bsas.
        IF sy-dbcnt <> 1.
          MESSAGE a500(fe) WITH 'Fehler'.
        ENDIF.
      ELSE.
        WRITE: / 'BSAS entry for BELNR ', wa_bseg-belnr, 'not found!'.
      ENDIF.
  ENDCASE.
ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM sonderhauptbuch_bsis_index                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM sonderhauptbuch_bsis_index.
  SELECT SINGLE * FROM bsis
                        WHERE bukrs = wa_bseg-bukrs
                        AND   hkont = wa_bseg-hkont
                        AND   augdt = wa_bseg-augdt
                        AND   augbl = wa_bseg-augbl
                        AND   zuonr = wa_bseg-hzuon
                        AND   gjahr = wa_bseg-gjahr
                        AND   belnr = wa_bseg-belnr
                        AND   buzei = wa_bseg-buzei.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING wa_bseg TO bsis.
    bsis-zuonr = wa_bseg-hzuon.
*    UPDATE bsis.
    IF sy-dbcnt <> 1.
      MESSAGE a500(fe) WITH 'Fehler'.
    ENDIF.
  ELSE.
    WRITE: / 'BSIS entry for BELNR ', wa_bseg-belnr, 'not found!'.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM sonderhauptbuch_bsas_index                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM sonderhauptbuch_bsas_index.
  SELECT SINGLE * FROM bsas
                        WHERE bukrs = wa_bseg-bukrs
                        AND   hkont = wa_bseg-hkont
                        AND   augdt = wa_bseg-augdt
                        AND   augbl = wa_bseg-augbl
                        AND   zuonr = wa_bseg-hzuon
                        AND   gjahr = wa_bseg-gjahr
                        AND   belnr = wa_bseg-belnr
                        AND   buzei = wa_bseg-buzei.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING wa_bseg TO bsas.
    bsas-zuonr = wa_bseg-hzuon.
*    UPDATE bsas.
    IF sy-dbcnt <> 1.
      MESSAGE a500(fe) WITH 'Fehler'.
    ENDIF.
  ELSE.
    WRITE: / 'BSAS entry for BELNR ', wa_bseg-belnr, 'not found!'.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM bdc_dynpro                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PROGRAM                                                       *
*  -->  DYNPRO                                                        *
*---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  bdc_transaction
*&---------------------------------------------------------------------*
FORM bdc_transaction USING tcode.
*  DATA: l_mstring(480).
*  DATA: l_subrc LIKE sy-subrc.
*  DATA: l_mode VALUE 'N'.
*  DATA: l_upd VALUE 'S'.
  DATA:wa_ctu_params TYPE ctu_params.
  wa_ctu_params-dismode = 'N'.
  wa_ctu_params-updmode = 'S'.
  wa_ctu_params-cattmode = ''.
  wa_ctu_params-defsize = 'X'.
  wa_ctu_params-racommit = 'X'.
  wa_ctu_params-nobinpt = ''.
  wa_ctu_params-nobiend = ''.
  CALL TRANSACTION tcode USING bdcdata
*                   UPDATE l_upd
*                   MODE   l_mode
                   OPTIONS FROM wa_ctu_params
                   MESSAGES INTO messtab.
*  CALL FUNCTION 'BDC_INSERT'
*       EXPORTING
*            tcode            = tcode
*       TABLES
*            dynprotab        = bdcdata
*       EXCEPTIONS
*            internal_error   = 1
*            not_open         = 2
*            queue_error      = 3
*            tcode_invalid    = 4
*            printing_invalid = 5
*            posting_invalid  = 6
*            OTHERS           = 7.

ENDFORM.                    " bdc_transaction
