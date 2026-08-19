*--- MAIN PROGRAM: MZMM_NONMOVO01 ---*
*** include MZMM_NONMOVO01
*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tct100_init OUTPUT.
  IF g_tct100_copied IS INITIAL.
*&spwizard: copy ddic-table 'ZMM_NMBLKCDDT'
*&spwizard: into internal table 'g_TCT100_itab

** get non-rejected rows from table for all modes except new request creation by user.
    IF g_mode <> 'CRE'.
      SELECT * FROM zmm_nmblkcddt
         INTO CORRESPONDING FIELDS
         OF TABLE g_tct100_itab
      where reqno = zmm_nmblkcdhd_st-reqno
        and ( status = 'ACCEPTED' or status = '' or status = 'REPLY' or status = 'QUERY' )  " ROW STATUS
        .
    ENDIF.
    g_tct100_copied = 'X'.
    REFRESH CONTROL 'TCT100' FROM SCREEN '0100'.
  ENDIF.


  sort g_tct100_itab ascending by matcode descending srno.
  delete adjacent duplicates from g_tct100_itab comparing matcode.
  sort g_tct100_itab ascending by srno.
ENDMODULE.

*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tct100_SRNO_STOCK_CONSMP OUTPUT.
** SR NO., Stock and Consumption figures
*  BREAK cab_alok.

  DATA : l_srno TYPE i,
         l_labst LIKE mard-labst,
         l_spmon like s034-spmon,
         l_mm(2) type n,
         l_yy(4) type n.
**1. Sr. No.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tct100_wa-matcode IS INITIAL.
      CLEAR: l_srno.
      IF g_tct100_wa-srno = 0.
        PERFORM get_nextsrno.
        MOVE l_srno TO g_tct100_wa-srno.
        MODIFY g_tct100_itab FROM g_tct100_wa
        INDEX tct100-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.


**2. Plant Stock
    IF NOT g_tct100_wa-matcode IS INITIAL.
      SELECT SUM( labst ) FROM mard INTO g_tct100_wa-plant_stk
        WHERE werks = zmm_nmblkcdhd_st-werks
          AND   matnr = g_tct100_wa-matcode.
      MODIFY g_tct100_itab FROM g_tct100_wa
      INDEX tct100-current_line TRANSPORTING plant_stk.
    ENDIF.
**3. ONGC Stock
    IF NOT g_tct100_wa-matcode IS INITIAL.
      SELECT SUM( labst ) FROM mard INTO g_tct100_wa-ongc_stk
      WHERE matnr = g_tct100_wa-matcode.
      MODIFY g_tct100_itab FROM g_tct100_wa
      INDEX tct100-current_line TRANSPORTING ongc_stk.
    ENDIF.
**4. Plant Consumption
    Clear: l_mm,l_yy.
    l_mm = sy-datum+4(2).
    if l_mm < '04'.
      l_yy = sy-datum+0(4) - 1.
      concatenate l_yy '04' into l_spmon.
    else.
      concatenate sy-datum+0(4) '04'  into l_spmon.
    endif.
    IF NOT g_tct100_wa-matcode IS INITIAL.
      SELECT SUM( cmgvbr ) FROM s034 INTO g_tct100_wa-cmgvbr
        WHERE werks = zmm_nmblkcdhd_st-werks
          AND   matnr = g_tct100_wa-matcode
          AND   spmon GE l_spmon.
      MODIFY g_tct100_itab FROM g_tct100_wa
      INDEX tct100-current_line TRANSPORTING cmgvbr.
    ENDIF.

**5. ONGC Consumption *************
    IF NOT g_tct100_wa-matcode IS INITIAL.
      SELECT SUM( cmgvbr ) FROM s034 INTO g_tct100_wa-ongc_cons
        WHERE matnr = g_tct100_wa-matcode
        and   spmon GE l_spmon.
      MODIFY g_tct100_itab FROM g_tct100_wa
      INDEX tct100-current_line TRANSPORTING ongc_cons.
    ENDIF.
  ENDIF.               "CRE or CHA

** Consumption figures: to be calculated dynamically
*get current financial year start and end dates
  data: G_FISCAL_YEAR(4),
        G_FISCAL_YEAR_NUMC  LIKE  T009B-BDATJ.
  DATA: G_first_day_fy TYPE sy-datum,
        G_last_day_fy TYPE sy-datum,
        G_DATE TYPE sy-datum.

  if ZMM_NMBLKCDHD_ST-NM_STATUS = ''. " document is being created
    G_DATE = sy-datum.
  else.                               " Existing document
    G_DATE = ZMM_NMBLKCDHD_ST-DOC_DATE.
  endif.

  CALL FUNCTION 'ZGM_GET_FISCAL_YEAR'
    EXPORTING
      I_DATE = G_DATE
      I_FYV  = 'V3'
    IMPORTING
      E_FY   = G_FISCAL_YEAR.

  move G_FISCAL_YEAR to G_FISCAL_YEAR_NUMC.

  CALL FUNCTION 'FIRST_AND_LAST_DAY_IN_YEAR_GET'
    EXPORTING
      i_gjahr        = G_FISCAL_YEAR_NUMC
      i_periv        = 'V3'
    IMPORTING
      e_first_day    = G_first_day_fy
      e_last_day     = G_last_day_fy
    EXCEPTIONS
      INPUT_FALSE    = 1
      T009_NOTFOUND  = 2
      T009B_NOTFOUND = 3
      OTHERS         = 4.


**6. Total Current financial year consumption at ONGC : CY_CONS_ONGC

  IF  g_tct100_wa-matcode IS NOT INITIAL.
    SELECT SUM( MGVBR )
      FROM s033
      INTO g_tct100_wa-CY_CONS_ONGC
      WHERE matnr = g_tct100_wa-matcode
        and SPTAG BETWEEN G_first_day_fy AND  G_last_day_fy.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING CY_CONS_ONGC.
  ENDIF.



*New Logic 19.05.2014 revised
*  IF  g_tct100_wa-matcode IS NOT INITIAL.
*    SELECT SUM( MENGE )
*      FROM MSEG
*      INTO g_tct100_wa-CY_CONS_ONGC
*      WHERE matnr = g_tct100_wa-matcode
*        and BWART in ('201' , '221' , '241' , '261')
*        and GJAHR = G_FISCAL_YEAR_NUMC.
*
*    MODIFY g_tct100_itab FROM g_tct100_wa
*    INDEX tct100-current_line TRANSPORTING CY_CONS_ONGC.
*  ENDIF.

**7. total Current financial year consumption at plant : CY_CONS_PLANT

  IF  g_tct100_wa-matcode IS NOT INITIAL.
    SELECT SUM( MGVBR )
      FROM s033
        INTO g_tct100_wa-CY_CONS_PLANT
          WHERE SPTAG BETWEEN G_first_day_fy AND  G_last_day_fy
            and werks = ZMM_NMBLKCDHD_ST-WERKS
            and matnr = g_tct100_wa-matcode
                .
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING CY_CONS_PLANT.
  ENDIF.

*New Logic 19.05.2014 revised
*  IF  g_tct100_wa-matcode IS NOT INITIAL.
*    SELECT SUM( MENGE )
*      FROM MSEG
*      INTO g_tct100_wa-CY_CONS_PLANT
*      WHERE matnr = g_tct100_wa-matcode
*        and werks = ZMM_NMBLKCDHD_ST-WERKS
*        and BWART in ('201' , '221' , '241' , '261')
*        and GJAHR = G_FISCAL_YEAR_NUMC.
*
*    MODIFY g_tct100_itab FROM g_tct100_wa
*    INDEX tct100-current_line TRANSPORTING CY_CONS_PLANT.
*  ENDIF.

**8. Last cons. date in CY across ONGC : CY_CONS_DATE_ONGC 19.05.2014
  data: L_MAX_MBLNR_ONGC TYPE  MSEG-MBLNR.

  IF  g_tct100_wa-matcode IS NOT INITIAL.
    SELECT MAX( MBLNR )
      FROM MSEG
      INTO L_MAX_MBLNR_ONGC
      WHERE matnr = g_tct100_wa-matcode
        and BWART in ('201' , '221' , '241' , '261')
        and GJAHR = G_FISCAL_YEAR_NUMC.

    if L_MAX_MBLNR_ONGC is NOT INITIAL.
      SELECT BUDAT
 FROM MKPF INTO G_TCT100_WA-CY_CONS_DATE_ONGC UP TO 1 ROWS WHERE MBLNR = L_MAX_MBLNR_ONGC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.
    IF g_tct100_wa-CY_CONS_ONGC is INITIAL.
      CLEAR g_tct100_wa-CY_CONS_DATE_ONGC.
    ENDIF.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING CY_CONS_DATE_ONGC.
  ENDIF.

**9. Last cons. date in CY in Plant : CY_CONS_DATE_PLANT 19.05.2014
  data: L_MAX_MBLNR_PLANT TYPE  MSEG-MBLNR.

  IF  g_tct100_wa-matcode IS NOT INITIAL.
    SELECT MAX( MBLNR )
      FROM MSEG
      INTO L_MAX_MBLNR_PLANT
      WHERE matnr = g_tct100_wa-matcode
        and werks = ZMM_NMBLKCDHD_ST-WERKS
        and BWART in ('201' , '221' , '241' , '261')
        and GJAHR = G_FISCAL_YEAR_NUMC.

    if L_MAX_MBLNR_PLANT is NOT INITIAL.
      SELECT BUDAT
 FROM MKPF INTO G_TCT100_WA-CY_CONS_DATE_PLANT UP TO 1 ROWS WHERE MBLNR = L_MAX_MBLNR_PLANT
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.
    IF g_tct100_wa-CY_CONS_PLANT is  INITIAL.
      CLEAR g_tct100_wa-CY_CONS_DATE_PLANT.
    ENDIF.

    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING CY_CONS_DATE_PLANT.
  ENDIF.

*======================================================================
**10. Last consumption (in Previous FY) across ONGC  :  LAST_CONS_ONGC
**11. last consumption date (in Previous FY) across ONGC  :  LAST_CONS_DATE_ONGC

** Commented 19.05.2014
**  IF  g_tct100_wa-matcode IS NOT INITIAL.
***   first find last consumption date (in Previous FY) at ONGC
**
**    SELECT max( LETZTVER )
**      FROM s032
**        INTO g_tct100_wa-LAST_CONS_DATE_ONGC
**          WHERE matnr = g_tct100_wa-matcode
**                and LETZTVER < G_first_day_fy.
**
***   now find Last consumption (in Previous FY) at ONGC
**
**    if g_tct100_wa-LAST_CONS_DATE_ONGC is NOT INITIAL.
**      SELECT single MGVBR
**        FROM s033
**          INTO g_tct100_wa-LAST_CONS_ONGC
**            WHERE SPTAG = g_tct100_wa-LAST_CONS_DATE_ONGC
**              and matnr = g_tct100_wa-matcode.
**    endif.
**
**    MODIFY g_tct100_itab FROM g_tct100_wa
**    INDEX tct100-current_line TRANSPORTING CY_CONS_PLANT.  ####
**  ENDIF.

** Commented 03.06.2014
***new logic: ONGC
***G_first_day_fy  20140401
**
**  data: G_first_Mon_fy TYPE S031-SPMON.
**  Data: G_MAX_SPMON type S031-SPMON.
**  data: G_MAX_SPMON_MONTH type FCMNR,
**        G_MAX_SPMON_YEAR type GJAHR.
**  Data: G_SPMON_BEGIN type DATUM.                           "20130601
**  Data: G_SPMON_END type DATUM.                             "20130601
**  data: G_MAX_SPTAG TYPE  DATUM.
**  data: G_SUM_MGVBR TYPE S033-MGVBR.
**
**  clear: G_first_Mon_fy, G_MAX_SPMON.
**  IF  g_tct100_wa-matcode IS NOT INITIAL.
**    G_first_Mon_fy = G_first_day_fy+0(6).
**
***S031
**    SELECT max( SPMON )
**      FROM S031
**        INTO G_MAX_SPMON                                    "201206
**          WHERE SPMON < G_first_Mon_fy
**            and matnr = g_tct100_wa-matcode
**            and MGVBR > 0.
**
**    CLEAR: G_MAX_SPMON_MONTH, G_MAX_SPMON_YEAR.
***I_MONTH  06
***I_YEAR    2013
**    G_MAX_SPMON_MONTH = G_MAX_SPMON+4(2).
**    G_MAX_SPMON_YEAR  = G_MAX_SPMON+0(4).
**
**    CLEAR: G_SPMON_BEGIN, G_SPMON_END.
**
**    CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
**      EXPORTING
**        I_MONTH     = G_MAX_SPMON_MONTH
**        I_YEAR      = G_MAX_SPMON_YEAR
***       I_DATE      =
**      IMPORTING
**        E_FIRST_DAY = G_SPMON_BEGIN
**        E_LAST_DAY  = G_SPMON_END
**      EXCEPTIONS
**        WRONG_DATE  = 1
**        OTHERS      = 2.
**    IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**    ENDIF.
**
***S033
**    clear: G_MAX_SPTAG.
**    SELECT max( SPTAG )
**      FROM S033
**        INTO G_MAX_SPTAG             "
**          WHERE matnr = g_tct100_wa-matcode
**            and SPTAG BETWEEN G_SPMON_BEGIN AND G_SPMON_END
**            and MGVBR > 0.
**
*** Last date of consumption(Prev. yrs): LAST_CONS_DATE_ONGC
**    g_tct100_wa-LAST_CONS_DATE_ONGC =  G_MAX_SPTAG.
**
*** LAST_CONS_ONGC
***Last consumption = sum(MGVBR) for Last date of consumption.
**    if g_tct100_wa-LAST_CONS_DATE_ONGC is NOT INITIAL.
**      clear: G_SUM_MGVBR.
**      SELECT SUM( MGVBR )
**        FROM S033
**          INTO G_SUM_MGVBR
**            WHERE matnr = g_tct100_wa-matcode
**              and SPTAG = g_tct100_wa-LAST_CONS_DATE_ONGC
**              and MGVBR > 0.
**      g_tct100_wa-LAST_CONS_ONGC = G_SUM_MGVBR  .
**    endif.
**
**    MODIFY g_tct100_itab FROM g_tct100_wa
**      INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_ONGC LAST_CONS_ONGC .
**  ENDIF.

** 03.06.2014
*------------------------------
***  data: L_MAX_MBLNR_ONGC_PY TYPE  MSEG-MBLNR.
***
***  IF  g_tct100_wa-matcode IS NOT INITIAL.
***    SELECT MAX( MBLNR )
***      FROM MSEG
***      INTO L_MAX_MBLNR_ONGC_PY
***      WHERE matnr = g_tct100_wa-matcode
***        and BWART  in ('201' , '221' , '241' , '261')
***        and GJAHR <> G_FISCAL_YEAR_NUMC.
***
***    if L_MAX_MBLNR_ONGC_PY is NOT INITIAL.
***      SELECT SINGLE MENGE              "Last consumption (in Previous FY) across ONGC
***        FROM MSEG
***          INTO g_tct100_wa-LAST_CONS_ONGC
***            WHERE MBLNR = L_MAX_MBLNR_ONGC_PY.
***
***      select single BUDAT              "last consumption date (in Previous FY) across ONGC
***        from MKPF
***          INTO g_tct100_wa-LAST_CONS_DATE_ONGC
***            WHERE MBLNR = L_MAX_MBLNR_ONGC_PY.
***    endif.
***
***    IF g_tct100_wa-LAST_CONS_ONGC is INITIAL.
***      CLEAR g_tct100_wa-LAST_CONS_DATE_ONGC.
***    ENDIF.
***    MODIFY g_tct100_itab FROM g_tct100_wa
***    INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_ONGC LAST_CONS_ONGC .
***  ENDIF.
*------------------------------
** 06.06.2014
    DATA: L_MATNR_I TYPE WB2_V_MKPF_MSEG2-MATNR_I,
           L_MAX_BUDAT TYPE WB2_V_MKPF_MSEG2-BUDAT,
           L_MENGE_I TYPE WB2_V_MKPF_MSEG2-MENGE_I,
           L_MBLNR TYPE WB2_V_MKPF_MSEG2-MBLNR.
  IF  g_tct100_wa-matcode IS NOT INITIAL.

    select MAX( BUDAT )
      from WB2_V_MKPF_MSEG2
        into (L_MAX_BUDAT)
          where BWART_I  in ('201' , '221' , '241' , '261')
            and MATNR_I = g_tct100_wa-matcode
            and GJAHR_I <> G_FISCAL_YEAR_NUMC.

     g_tct100_wa-LAST_CONS_DATE_ONGC = L_MAX_BUDAT.

    if L_MAX_BUDAT is NOT INITIAL.
      SELECT MENGE_I
 FROM WB2_V_MKPF_MSEG2 INTO G_TCT100_WA-LAST_CONS_ONGC UP TO 1 ROWS WHERE BWART_I IN ( '201' , '221' , '241' , '261' ) AND MATNR_I = G_TCT100_WA-MATCODE AND GJAHR_I <> G_FISCAL_YEAR_NUMC AND BUDAT = L_MAX_BUDAT
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.

    IF g_tct100_wa-LAST_CONS_ONGC is INITIAL.
      CLEAR g_tct100_wa-LAST_CONS_DATE_ONGC.
    ENDIF.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_ONGC LAST_CONS_ONGC .


  ENDIF.
*======================================================================
**12. Last consumption at plant level (in Previous FY) : LAST_CONS_PLANT
**13. Last consumption date at Plant (in Previous FY) : LAST_CONS_DATE_PLANT

**  IF  g_tct100_wa-matcode IS NOT INITIAL.
***   first find last consumption date (in Previous FY) at Plant
**    SELECT max( LETZTVER )
**      FROM s032
**        INTO g_tct100_wa-LAST_CONS_DATE_PLANT
**          WHERE werks = ZMM_NMBLKCDHD_ST-WERKS
**                and matnr = g_tct100_wa-matcode
**                and LETZTVER < G_first_day_fy.
**
***   now find Last consumption (in Previous FY) at Plant
**    if g_tct100_wa-LAST_CONS_DATE_ONGC is NOT INITIAL.
**      SELECT single MGVBR
**        FROM s033
**          INTO g_tct100_wa-LAST_CONS_PLANT
**            WHERE SPTAG = g_tct100_wa-LAST_CONS_DATE_ONGC
**              and werks = ZMM_NMBLKCDHD_ST-WERKS
**              and matnr = g_tct100_wa-matcode.
**    endif.
**
**    MODIFY g_tct100_itab FROM g_tct100_wa
**    INDEX tct100-current_line TRANSPORTING CY_CONS_PLANT.
**  ENDIF.

** Commented 03.06.2014
**new Logic : Plant
**  clear: G_first_Mon_fy, G_MAX_SPMON.
**  IF  g_tct100_wa-matcode IS NOT INITIAL.
**    G_first_Mon_fy = G_first_day_fy+0(6).
**
***S031
**    SELECT max( SPMON )
**      FROM S031
**        INTO G_MAX_SPMON                                    "201206
**          WHERE SPMON < G_first_Mon_fy
**            and werks = ZMM_NMBLKCDHD_ST-WERKS
**            and  matnr = g_tct100_wa-matcode
**            and MGVBR > 0.
**
**    CLEAR: G_MAX_SPMON_MONTH, G_MAX_SPMON_YEAR.
***I_MONTH  06
***I_YEAR    2013
**    G_MAX_SPMON_MONTH = G_MAX_SPMON+4(2).
**    G_MAX_SPMON_YEAR  = G_MAX_SPMON+0(4).
**
**    CLEAR: G_SPMON_BEGIN, G_SPMON_END.
**
**    CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
**      EXPORTING
**        I_MONTH     = G_MAX_SPMON_MONTH
**        I_YEAR      = G_MAX_SPMON_YEAR
***       I_DATE      =
**      IMPORTING
**        E_FIRST_DAY = G_SPMON_BEGIN
**        E_LAST_DAY  = G_SPMON_END
**      EXCEPTIONS
**        WRONG_DATE  = 1
**        OTHERS      = 2.
**    IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**    ENDIF.
**
***S033
**    clear: G_MAX_SPTAG.
**    SELECT max( SPTAG )
**      FROM S033
**        INTO G_MAX_SPTAG             "
**          WHERE matnr = g_tct100_wa-matcode
**                and werks = ZMM_NMBLKCDHD_ST-WERKS
**                and SPTAG BETWEEN G_SPMON_BEGIN AND G_SPMON_END
**                and MGVBR > 0.
**
*** Last date of consumption(Prev. yrs): LAST_CONS_DATE_PLANT
**    g_tct100_wa-LAST_CONS_DATE_PLANT =  G_MAX_SPTAG.
**
*** LAST_CONS_PLANT
***Last consumption = sum(MGVBR) for Last date of consumption.
**    if g_tct100_wa-LAST_CONS_DATE_PLANT is NOT INITIAL.
**      clear: G_SUM_MGVBR.
**      SELECT SUM( MGVBR )
**        FROM S033
**          INTO G_SUM_MGVBR
**            WHERE matnr = g_tct100_wa-matcode
**                and werks = ZMM_NMBLKCDHD_ST-WERKS
**                and SPTAG = g_tct100_wa-LAST_CONS_DATE_PLANT
**                and MGVBR > 0.
**      g_tct100_wa-LAST_CONS_PLANT = G_SUM_MGVBR  .
**    endif.
**
**    MODIFY g_tct100_itab FROM g_tct100_wa
**      INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_PLANT LAST_CONS_PLANT .
**  ENDIF.

** 03.06.2014
***  data: L_MAX_MBLNR_PLANT_PY TYPE  MSEG-MBLNR.
***
***  IF  g_tct100_wa-matcode IS NOT INITIAL.
***    SELECT MAX( MBLNR )
***      FROM MSEG
***      INTO L_MAX_MBLNR_PLANT_PY
***      WHERE matnr = g_tct100_wa-matcode
***        AND WERKS = ZMM_NMBLKCDHD_ST-WERKS
***        and BWART in ('201' , '221' , '241' , '261')
***        and GJAHR <> G_FISCAL_YEAR_NUMC.
***
***    if L_MAX_MBLNR_PLANT_PY is NOT INITIAL.
***      SELECT SINGLE MENGE              "Last consumption (in Previous FY) at PLANT
***        FROM MSEG
***          INTO g_tct100_wa-LAST_CONS_PLANT
***            WHERE MBLNR = L_MAX_MBLNR_PLANT_PY.
***
***      select single BUDAT              "last consumption date (in Previous FY) at Plant
***        from MKPF
***          INTO g_tct100_wa-LAST_CONS_DATE_PLANT
***            WHERE MBLNR = L_MAX_MBLNR_PLANT_PY.
***    endif.
***
***    IF g_tct100_wa-LAST_CONS_PLANT is INITIAL.
***      CLEAR g_tct100_wa-LAST_CONS_DATE_PLANT.
***    ENDIF.
***    MODIFY g_tct100_itab FROM g_tct100_wa
***    INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_PLANT LAST_CONS_PLANT .
***  ENDIF.
*--------
** 06.06.2014
  IF  g_tct100_wa-matcode IS NOT INITIAL.

CLEAR L_MAX_BUDAT.

select MAX( BUDAT )
      from WB2_V_MKPF_MSEG2
        into (L_MAX_BUDAT)
          where BWART_I  in ('201' , '221' , '241' , '261')
            and MATNR_I = g_tct100_wa-matcode
            and WERKS_I = ZMM_NMBLKCDHD_ST-WERKS
            and GJAHR_I <> G_FISCAL_YEAR_NUMC.

     g_tct100_wa-LAST_CONS_DATE_PLANT = L_MAX_BUDAT.

    if L_MAX_BUDAT is NOT INITIAL.
      SELECT MENGE_I
 FROM WB2_V_MKPF_MSEG2 INTO G_TCT100_WA-LAST_CONS_PLANT UP TO 1 ROWS WHERE BWART_I IN ( '201' , '221' , '241' , '261' ) AND MATNR_I = G_TCT100_WA-MATCODE AND WERKS_I = ZMM_NMBLKCDHD_ST-WERKS AND GJAHR_I <> G_FISCAL_YEAR_NUMC AND BUDAT = L_MAX_BUDAT
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.

    IF g_tct100_wa-LAST_CONS_PLANT is INITIAL.
      CLEAR g_tct100_wa-LAST_CONS_DATE_PLANT.
    ENDIF.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_PLANT LAST_CONS_PLANT .
  ENDIF.

*****

  MOVE-CORRESPONDING g_tct100_wa TO zmm_nmblkcddt.
ENDMODULE.   "// tct100_SRNO_STOCK_CONSMP

*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct100_get_lines OUTPUT.
  g_tct100_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA : l_mode(3) TYPE c,
         l_reqno(10) TYPE c.


  PERFORM fill_sttab.

  SET PF-STATUS 'OPTNS' EXCLUDING it_tab1.
  CASE g_mode.
    WHEN 'CRE'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Create Request'.
    WHEN 'CHA'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Change/Release Request'.
    WHEN 'DIS'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Display Request'.
    WHEN 'DEL'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Delete Request'.
****    WHEN 'REL'.
****      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Submit Request'.
    WHEN OTHERS.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.
  ENDCASE.

  if sy-tcode = 'ZMMNMWF2'.
    SET PF-STATUS 'S_L3L4'.
    SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.

  elseif sy-tcode = 'ZMMNMWFL2'.
    SET PF-STATUS 'S_L2'.
    SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.

  elseif sy-tcode = 'ZMMNMWF3'.
    SET PF-STATUS 'S_L1L2'.
    SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.

  elseif sy-tcode = 'ZMMNMWF4'.
    SET PF-STATUS 'S_DIR'.
    SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.

  endif.


ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize OUTPUT.
  PERFORM get_correspondense.
ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE splitter_ctrl_vorbereiten1 OUTPUT.
  IF gv_splitter1 IS INITIAL.
    CREATE OBJECT gv_custom_container
      EXPORTING
        container_name = 'C_DIS'.

    CREATE OBJECT gv_splitter1
      EXPORTING
        parent        = gv_custom_container
        orientation   = 1
        sash_position = 1.
  ENDIF.

  IF ( g_mode = 'CRE' ) OR
    ( g_mode = 'CHA' ) OR
     ( sy-tcode = 'ZMMNMWF2' ) OR
     ( sy-tcode = 'ZMMNMWFL2' ) OR
     ( sy-tcode = 'ZMMNMWF3' ) OR
     ( sy-tcode = 'ZMMNMWF4' ).

    IF gv_splitter2 IS INITIAL.

      CREATE OBJECT gv_custom_container
        EXPORTING
          container_name = 'C_WRT'.


      CREATE OBJECT gv_splitter2
        EXPORTING
          parent        = gv_custom_container
          orientation   = 1
          sash_position = 1.

    ENDIF.
  ENDIF.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_vorbereiten1 OUTPUT.
  IF gv_text_editor1 IS INITIAL.
    CREATE OBJECT gv_text_editor1
      EXPORTING
        parent                     = gv_splitter1->bottom_right_container
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
        wordwrap_to_linebreak_mode = cl_gui_textedit=>false
      EXCEPTIONS
        error_cntl_create          = 1
        error_cntl_init            = 2
        error_cntl_link            = 3
        error_dp_create            = 4
        gui_type_not_supported     = 5.
  ENDIF.
  IF ( g_mode = 'CRE' ) OR
    ( g_mode = 'CHA' ) OR
     ( sy-tcode = 'ZMMNMWF2' ) OR
     ( sy-tcode = 'ZMMNMWFL2' ) OR
     ( sy-tcode = 'ZMMNMWF3' ) OR
     ( sy-tcode = 'ZMMNMWF4' ).

    IF gv_text_editor2 IS INITIAL.
      CREATE OBJECT gv_text_editor2
        EXPORTING
          parent                     = gv_splitter2->bottom_right_container
          wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
          wordwrap_to_linebreak_mode = cl_gui_textedit=>false
        EXCEPTIONS
          error_cntl_create          = 1
          error_cntl_init            = 2
          error_cntl_link            = 3
          error_dp_create            = 4
          gui_type_not_supported     = 5.
    ENDIF.
  ENDIF.

  PERFORM text_control_eingabebereit1.
  PERFORM text_control_set_text_table1.
ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  SET PF-STATUS 'STAT105'.
ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr_attr_header  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr_attr_header OUTPUT.

  LOOP AT SCREEN.
    if screen-name = 'G_REL_FLAG' .
      SCREEN-INVISIBLE = 1.  " 1:invisi , make Rel flag invisible for all, later make it visible for 'CHA' mode
      MODIFY SCREEN.
    endif.
  ENDLOOP.



  IF sy-tcode = 'ZMMNMREQ'.

***    TCT100-INVISIBLE = 0.   "make table control visible
***        LOOP AT SCREEN.     "make other sceen elements visible.
***          SCREEN-INVISIBLE = 0.
***          MODIFY SCREEN.
***        ENDLOOP.

    CASE g_mode.
      WHEN ''.

        LOOP AT SCREEN.
          screen-input = 0.       " make display only
          MODIFY SCREEN.
        ENDLOOP.

****    TCT100-INVISIBLE = 1.   "make table control invisible
****        LOOP AT SCREEN.     "make other sceen elements invisible.
****          SCREEN-INVISIBLE = 1.
****          MODIFY SCREEN.
****        ENDLOOP.


      WHEN 'CRE'.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO'  OR
             screen-name = 'ZMM_NMBLKCDHD_ST-STATUS' OR
             screen-name = 'G_REL_FLAG' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-TEL' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-APPFLAG'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.

      WHEN 'CHA'.
        IF zmm_nmblkcdhd_st-reqno IS INITIAL.
          LOOP AT SCREEN.
            IF screen-name <> 'ZMM_NMBLKCDHD_ST-REQNO'.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.
          ENDLOOP.
        ELSE.
          LOOP AT SCREEN.
            IF SCREEN-GROUP1 = 'CHA' OR     " Change
              screen-group1 = 'MAR' OR      "
              screen-group1 = 'MOD' OR
              screen-group1 = 'PAG' OR
               screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
               screen-name = 'G_REL_FLAG' OR
               screen-name = 'PB_CORS' OR
               screen-name = 'ZMM_NMBLKCDHD_ST-WERKS' OR
               screen-name = 'ZMM_NMBLKCDHD_ST-ADDR1' .
*              OR
*               screen-name = 'ZMM_NMBLKCDHD_ST-TEL'.
              screen-input = 1.      " make editable
              screen-INVISIBLE = 0.  "make G_REL_FLAG visible
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

* Row Status : If this is a reverted req, then disable 'INSERT' and 'DELETE'
            IF ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is NOT INITIAL.
              if screen-name = 'TCT100_INSERT' or screen-name = 'TCT100_DELETE'.
                screen-input = 0.       " make display only
                MODIFY SCREEN.
              endif.
            ENDIF.
          ENDLOOP.
        ENDIF.

      WHEN OTHERS.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
             screen-name = 'PB_CORS' OR
             screen-group1 = 'PAG' OR
             screen-group1 = 'MAR'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
    ENDCASE.

  ELSEIF sy-tcode = 'ZMMNMWF2'.     " for incharge - L3/L4

    LOOP AT SCREEN.
      IF  screen-group1 = 'PAG' OR
            screen-name = 'PB_CORS' OR
             screen-group2 = 'INC' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWFL2'.    " for L2 auth
    LOOP AT SCREEN.
      IF  screen-group1 = 'PAG' OR
            screen-name = 'PB_CORS' OR
             screen-group3 = 'L2' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWF3'.    " for L1 auth
    LOOP AT SCREEN.
      IF  screen-group1 = 'PAG' OR
            screen-name = 'PB_CORS' OR
             screen-group4 = 'L1' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWF4'.   " for Dir

    LOOP AT SCREEN.
      IF  screen-group1 = 'PAG' OR
            screen-name = 'PB_CORS'.
*           OR screen-group4 = 'DIR' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.



  ENDIF.
ENDMODULE.                 " scr_attr_header  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module STATUS_0103 output.
*  SET PF-STATUS 'STAT_REL'.
*  SET TITLEBAR 'xxx'.

endmodule.                 " STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  write_certificate  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module write_certificate output.
  SUPPRESS DIALOG.
  SET TITLEBAR '103'.
  SET PF-STATUS 'STAT_REL'.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*
  NEW-PAGE NO-TITLE.
  WRITE : / '              Confirmation to start Workflow                  '
                                                  COLOR 4.
  WRITE : / '--------------------------------------------------------------'.
  WRITE : / 'Please ensure that information provided in this  request is    '.
  WRITE : / 'correct and complete. Starting the workflow  will trigger a    '.
  WRITE : / 'flow of workitem through the Inboxes of the users maintained                                   '.
  WRITE : / 'in the approval chain of this request. '.
  WRITE : / '                                        '.

endmodule.                 " write_certificate  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT100_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TCT100_change_field_attr output.

**
** Row Status: Hide Decision Column for Creator when this is a fresh request(ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is INITIAL)
*  otherwise if it is a reverted request: Decision column is visible and make already accepted rows display only .
  IF sy-tcode = 'ZMMNMREQ' and ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is INITIAL.
    DATA col LIKE LINE OF TCT100-COLS .
    READ TABLE TCT100-COLS  INTO col index 3. " Decision is 3rd column of table control TCT100.
    col-INVISIBLE = 1.
    MODIFY  TCT100-COLS FROM col INDEX 3.
  ENDIF.

**Make MATCODE Intensified
  LOOP AT SCREEN.
    if screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
      screen-INTENSIFIED = '1'.
      MODIFY SCREEN.
    endif.
  ENDLOOP.

  IF sy-tcode = 'ZMMNMREQ'.

    CASE g_mode.

      WHEN 'CRE' OR 'CHA'.
        LOOP AT SCREEN.
          IF   screen-group1 = 'CHA' or SCREEN-NAME	=	'G_TCT100_WA-FLAG'.
            screen-input = 1.   " make editable
          ELSE.
            screen-input = 0.   "make display only
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

      WHEN  'DIS' OR 'DEL' or ''.
        LOOP AT SCREEN.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDLOOP.

    ENDCASE.

  ELSEIF sy-tcode = 'ZMMNMWF2'.     " for incharge - L3/L4

    LOOP AT SCREEN.
      IF   screen-group2 = 'INC' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWFL2'.    " for L2 auth
    LOOP AT SCREEN.
      IF   screen-group3 = 'L2' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWF3'.    " for L1 auth
    LOOP AT SCREEN.
      IF   screen-group4 = 'L1' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWF4'.   " for Dir

    LOOP AT SCREEN.
      IF   screen-name = 'ZMM_NMBLKCDDT-DECISION' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

**ROW STATUS: If HEADER-STATUS_AT_REVERSAL is not initial then make rows, already having status 'ACCEPTED',
*  display only.
  IF ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is NOT INITIAL.

    LOOP AT SCREEN.
      if g_TCT100_wa-STATUS = 'ACCEPTED'.
        screen-input = 0.       " make whole row display only.
        MODIFY SCREEN.
      endif.
    ENDLOOP.

  ENDIF.

endmodule.                 " TCT100_change_field_attr  OUTPUT

*****************&---------------------------------------------------------------------*
*****************&      Module  display_message  OUTPUT
*****************&---------------------------------------------------------------------*
*****************       text
*****************----------------------------------------------------------------------*
****************module display_message output.
****************  Data:l_100msg type t_tct100.
****************  IF G_ERRCD_M IS INITIAL.
****************    Read table g_tct100_itab into l_100msg with key errcd = 'M'.
****************    if sy-subrc = 0.
****************      G_ERRCD_M = 'X'.
****************      message i122(zmm_oth).
****************    endif.
****************
****************  ENDIF.
***************** clear g_errstat.
****************
****************endmodule.                 " display_message  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_USER_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_USER_DATA OUTPUT.

  IF sy-tcode = 'ZMMNMREQ' .      "for creator

*Set Company code          " , Location, Name
    CLEAR G_USER_BUKRS.
    SELECT BUKRS
 FROM PA0001 INTO G_USER_BUKRS UP TO 1 ROWS WHERE PERNR = G_USER_PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if G_USER_PERNR = 77783 and sy-sysid(2) = 'RD'.
      G_USER_BUKRS = 'MUM'.
    endif.

    if G_USER_BUKRS is initial.
      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Company code of' sy-uname text-012 .
    endif.

*Set Phone No.
    data: G_USER_PHONE LIKE ZMM_NMBLKCDHD_ST-TEL.

    SELECT * FROM  PA9205 APPENDING
      CORRESPONDING FIELDS OF TABLE IT_9205
      WHERE Pernr = G_USER_PERNR AND  " SY-UNAME
            Subty = '01' AND
            Endda = '99991231' .
    clear G_USER_PHONE.

    IF SY-SUBRC = 0.
      SORT  IT_9205 By Begda DESCENDING  .
      READ TABLE It_9205 INTO Wa_9205 INDEX 1  .
      CONCATENATE '91' Wa_9205-ZPHONE+1(10) INTO G_USER_PHONE .
    ENDIF.

*Set creator ID, COMP CODE, PHONE
    IF g_mode = 'CRE' .
      MOVE sy-uname TO zmm_nmblkcdhd_st-ID_CREATOR.
      ZMM_NMBLKCDHD_ST-BUKRS = G_USER_BUKRS.
      ZMM_NMBLKCDHD_ST-TEL = G_USER_PHONE.
    ELSEIF g_mode = 'CHA' .
      ZMM_NMBLKCDHD_ST-BUKRS = G_USER_BUKRS.
    ENDIF.

* Extract PLANT, PURCH GRP from roles
*    IF  sy-uname+0(3) <> 'CMM'.

    IF g_mode = 'CRE' OR g_mode = 'CHA'.
      perform EXTRACT_PLANTS.
      PERFORM EXTRACT_PURCH_GRP.
    ENDIF.

*    ENDIF.

*=====================================================
  ELSE.
    "Get user data for L3L4/L2/L1/DIR
  ENDIF.

ENDMODULE.                 " GET_USER_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_REQ_NO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_REQ_DATA OUTPUT.

** get header data for Level L3, l2, L1, Dir

  DATA: G_REQ_NO type ZMM_NMBLKCDHD_ST-REQNO.
  data: FLAG_WF(1).

  IMPORT FLAG_WF FROM MEMORY ID 'ID_NMWF'. " imported from WF

  IF sy-tcode = 'ZMMNMWF2' or sy-tcode = 'ZMMNMWF3' or sy-tcode = 'ZMMNMWF4'
      or ( sy-tcode = 'ZMMNMREQ' and FLAG_WF = 'X' )
      or sy-tcode = 'ZMMNMWFL2'.     " added later for L2 level
* get Req. no.
    data: DOCUMENTNUMBER TYPE ZMM_NMBLKCDHD-REQNO.
    IMPORT DOCUMENTNUMBER FROM MEMORY ID 'ID_NMREQ'.
    G_REQ_NO = DOCUMENTNUMBER.
    clear DOCUMENTNUMBER.

*****************
**if G_REQ_NO is initial, Program has been started using tcodes (not from Workflow), so Req No is missing.
**POPUP to get Req No.
    data : ist_req like sval occurs 0 with header line.
    refresh IST_REQ.

    MOVE : 'ZMM_NMBLKCDHD'     TO   IST_REQ-TABNAME,
           'REQNO'         TO    IST_REQ-FIELDNAME.
    append IST_REQ.

    if G_REQ_NO is initial.
      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
*         NO_VALUE_CHECK        = ' '
          POPUP_TITLE           = 'Input Req  no.'
          START_COLUMN          = '5'
          START_ROW             = '5'
*       IMPORTING
*         RETURNCODE            =
        TABLES
          FIELDS                = IST_REQ
*       EXCEPTIONS
*         ERROR_IN_FIELDS       = 1
*         OTHERS                = 2
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.
      G_REQ_NO = IST_REQ-VALUE.

    endif.
*****************

*Get header data of the Req no.
*==============================
    if G_REQ_NO is NOT INITIAL and G_HD_COPIED is INITIAL.

      ZMM_NMBLKCDHD_ST-REQNO = G_REQ_NO.
      select SINGLE * from ZMM_NMBLKCDHD
        into CORRESPONDING FIELDS OF ZMM_NMBLKCDHD_ST
          WHERE REQNO = ZMM_NMBLKCDHD_ST-REQNO.

      if sy-subrc <> 0.
        MESSAGE e202(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Invalid request no.
      endif.

      G_HD_COPIED  = 'X'.
      PERFORM get_correspondense.

    endif.

  ELSEIF  sy-tcode = 'ZMMNMREQ' and FLAG_WF <> 'X' .  "transaction not triggered from WF

*Get header data of the Req no. for modes other than 'create'
*==============================
    IF zmm_nmblkcdhd_st-reqno IS NOT INITIAL.
      IF g_mode <> 'CRE' and g_hd_copied is initial.  "g_mode = 'CHA', 'DIS', 'DEL'

        SELECT SINGLE * FROM zmm_nmblkcdhd
        INTO CORRESPONDING FIELDS OF zmm_nmblkcdhd_st
            WHERE reqno = zmm_nmblkcdhd_st-reqno.
        if sy-subrc <> 0.
          MESSAGE e202(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Invalid request no.
        endif.

* commented on 17.04.2014
*        if zmm_nmblkcdhd_st-doc_date < '20131101'.
*          MESSAGE e227(zmm_oth) WITH '20131101'. "Pls select a request created after &.
*        endif.

        if zmm_nmblkcdhd_st-ID_CREATOR is INITIAL and zmm_nmblkcdhd_st-REQCPF is NOT INITIAL.
*  if l_hd_reqno-ID_CREATOR is INITIAL and l_hd_reqno-REQCPF is NOT INITIAL.
          MESSAGE e237(zmm_oth). "Pls input a request no. created thro' tcode ZMMNMREQ only.
        endif.

        G_HD_COPIED  = 'X'.
        PERFORM get_correspondense.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " GET_REQ_NO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_USER_PERNR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_USER_PERNR OUTPUT.

* get pernr
* if User is core team member
  DATA: WA_ZMM_CORETEAM type ZMM_CORETEAM.

  if sy-uname+0(3) = 'CAB' or sy-uname+0(3) = 'CMM'.
    select single pernr from ZMM_CORETEAM
      into G_USER_PERNR
        where uname = sy-uname.

    if sy-subrc <> 0.
      message id 'ZMSG' type 'E' number '000' with 'USER ID' sy-uname text-001 .
    endif.
  else.
* get pernr from communication data
    SELECT PERNR
 FROM PA0105 INTO G_USER_PERNR UP TO 1 ROWS WHERE USRID = SY-UNAME AND SUBTY = '0001' AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc <> 0.
      message id 'ZMSG' type 'E' number '000' with 'USER ID' sy-uname text-002 .
    endif.
  endif.
ENDMODULE.                 " GET_USER_PERNR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_PBO OUTPUT.

  if sy-tcode = 'ZMMNMREQ'. " User is requisitioner
    if  G_MODE = 'CHA' AND G_REL_FLAG = 'X' .  " requisitioner ir trying to release
      if zmm_nmblkcdhd_st-reqno <> 0000000000.
        perform VALIDATE_REQNO.
      endif.
    endif.

  elseif sy-tcode = 'ZMMNMWF2'.  "User is Incharge (L3/L4)
    if ZMM_NMBLKCDHD_ST-NM_STATUS <> 'IL3L4'.
      MESSAGE e204(zmm_oth) WITH ' L3/L4 level' sy-uname. "Request is not at & ( user & ).
    endif.

    if sy-uname <> ZMM_NMBLKCDHD_ST-ID_INCHARGE.
      MESSAGE e203(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Request is not assigned to the logged-in user.
    endif.

  elseif sy-tcode = 'ZMMNMWFL2'. " User is L2
    if ZMM_NMBLKCDHD_ST-NM_STATUS <>  'IL2'. .
      MESSAGE e204(zmm_oth) WITH 'L2 level' sy-uname. "Request is not at & ( user & ).
    endif.

    if sy-uname <> ZMM_NMBLKCDHD_ST-ID_L2.
      MESSAGE e203(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Request is not assigned to the logged-in user.
    endif.

  elseif sy-tcode = 'ZMMNMWF3'. " User is L1
    if ZMM_NMBLKCDHD_ST-NM_STATUS <>  'IL1'.               " 'IL1L2'. .
      MESSAGE e204(zmm_oth) WITH ' L1 level' sy-uname. "Request is not at & ( user & ).
    endif.

    if sy-uname <> ZMM_NMBLKCDHD_ST-ID_L1.
      MESSAGE e203(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Request is not assigned to the logged-in user.
    endif.

  elseif sy-tcode = 'ZMMNMWF4'. " User is a Dir
    if ZMM_NMBLKCDHD_ST-NM_STATUS <>  'IDIR'. .
      MESSAGE e204(zmm_oth) WITH ' the Director level' sy-uname. "Request is not at & ( user & ).
    endif.

    if sy-uname <> ZMM_NMBLKCDHD_ST-ID_DIRECTOR.
      MESSAGE e203(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Request is not assigned to the logged-in user.
    endif.

  endif.
ENDMODULE.                 " VALIDATE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ROLE_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ROLE_AUTH OUTPUT.
  perform ROLE_AUTH.

ENDMODULE.                 " ROLE_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME_CREATOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_NAME_CREATOR OUTPUT.
  PERFORM SHOW_NAME_CREATOR.

  PERFORM SHOW_NAME_INCHARGE.  "for display mode- LOV of concatenated names of L3/l2/l1/dir
ENDMODULE.                 " SHOW_NAME_CREATOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ROW_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ROW_CONTROL OUTPUT.
** Row Status: clear STATUS_AT_REVERSAL when the request is back at the level at
*   which reversal was initiated. This will enable editing of already accepted Rows.
  if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ZMM_NMBLKCDHD_ST-NM_STATUS.
    ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''.
  endif.

ENDMODULE.                 " ROW_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PRUNE_DETAIL_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRUNE_DETAIL_DATA OUTPUT.

** If some ZMM_NMBLKCDDT-DECISION which has flowed from previous level is not
* allowed in this level, clear it (only decision, not status).

  data: g_TCT100_wa1     type t_TCT100,
        l_tabix1 type sy-tabix.

  loop at g_tct100_itab into g_TCT100_wa1.
    l_tabix1 = sy-tabix.

    IF sy-tcode = 'ZMMNMREQ'. " decision col will appear only in case of reverted req,
      if g_TCT100_wa1-decision = 'ACCEPT'    " in reverted req, Accept will be grey.
        or g_TCT100_wa1-decision = 'REJECT'
         or g_TCT100_wa1-decision = 'REPLY'.
        " allowed
      else.
        clear g_TCT100_wa1-decision.
      endif.

    ELSEIF  sy-tcode = 'ZMMNMWF2'
          or sy-tcode = 'ZMMNMWF3'
             or sy-tcode = 'ZMMNMWFL2'.

      if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''. " fresh request
        if g_TCT100_wa1-decision = 'ACCEPT'
           or g_TCT100_wa1-decision = 'REJECT'
             or g_TCT100_wa1-decision = 'QUERY'.
          " allowed
        else.
          clear g_TCT100_wa1-decision.
        endif.

      else.     "reverted requests, all statuses allowed in PBO

      endif.

    ELSEIF sy-tcode = 'ZMMNMWF4'.

      if g_TCT100_wa1-decision = 'ACCEPT'
       or g_TCT100_wa1-decision = 'REJECT'
         or g_TCT100_wa1-decision = 'QUERY'.
        " allowed
      else.
        clear g_TCT100_wa1-decision.
      endif.

    ENDIF.
    MODIFY g_tct100_itab FROM g_TCT100_wa1 INDEX l_tabix1.
    clear g_TCT100_wa1.
  endloop.

ENDMODULE.                 " PRUNE_DETAIL_DATA  OUTPUT
