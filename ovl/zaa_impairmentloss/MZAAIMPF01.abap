*----------------------------------------------------------------------*
***INCLUDE MZMM_STOF01 .
*----------------------------------------------------------------------*
*Change History
***********************************************************************
*  Date        Transport   USERID      Description                    *
* 08/09/2008   RD1K960036  SAB_SRIDHAR Obsolete FM "POPUP_TO_CONFIRM_ *
*                                      STEP replaced "POPUP_TO_CONFIRM*
***********************************************************************

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0211   text
*      -->P_0212   text
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
ENDFORM.                    " bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  bdc_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0336   text
*----------------------------------------------------------------------*
FORM BDC_TRANSACTION USING TCODE.
  REFRESH MESSTAB.
  CALL FUNCTION 'BDC_INSERT'
       EXPORTING
            TCODE     = TCODE
       TABLES
            DYNPROTAB = BDCDATA.
  REFRESH BDCDATA.
ENDFORM.                    " bdc_transaction
*&---------------------------------------------------------------------*
*&      Form  open_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OPEN_GROUP.
  DATA:UNAME LIKE APQI-USERID,
       KEEP,
       HOLDDATE LIKE SY-DATUM.
  CASE G_OKCODE.
    WHEN 'IMPAIR' OR 'DEPCOM'.
      CONCATENATE P_BUKRS P_GJAHR P_MONAT 'BAA' INTO GROUP.
    WHEN 'WBACK'.
      CONCATENATE P_BUKRS P_GJAHR P_MONAT 'BZU' INTO GROUP.
    WHEN 'UNPDEP'.
      CONCATENATE P_BUKRS P_GJAHR P_MONAT 'PPA' INTO GROUP.
    WHEN 'PWBACK'.
      CONCATENATE P_BUKRS P_GJAHR P_MONAT 'PPU' INTO GROUP.
*      CONCATENATE P_BUKRS P_GJAHR P_MONAT 'FPU' INTO GROUP1.
    WHEN 'WBACKGROSS'.
      CONCATENATE P_BUKRS P_GJAHR P_MONAT 'BZU' INTO GROUP.
  ENDCASE.

  UNAME = SY-UNAME.
  KEEP = 'X'.
  HOLDDATE = SY-DATUM.
  CALL FUNCTION 'BDC_OPEN_GROUP'
       EXPORTING
            CLIENT   = SY-MANDT
            GROUP    = GROUP
            USER     = UNAME
            KEEP     = KEEP
            HOLDDATE = HOLDDATE.
*    CALL FUNCTION 'BDC_OPEN_GROUP'
*         EXPORTING
*              CLIENT   = SY-MANDT
*              GROUP    = GROUP1
*              USER     = UNAME
*              KEEP     = KEEP
*              HOLDDATE = HOLDDATE.
*    CALL FUNCTION 'BDC_OPEN_GROUP'
*         EXPORTING
*              CLIENT   = SY-MANDT
*              GROUP    = GROUP1
*              USER     = UNAME
*              KEEP     = KEEP
*              HOLDDATE = HOLDDATE.

ENDFORM.                    " open_group
*&---------------------------------------------------------------------*
*&      Form  close_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLOSE_GROUP.
  IF G_OKCODE <> 'PWBACK' and G_OKCODE <> 'WBACKGROSS'.
* Begin of change on 17-Jun-2013
    CALL FUNCTION 'BDC_CLOSE_GROUP'
     EXCEPTIONS
       NOT_OPEN          = 1
       QUEUE_ERROR       = 2
       OTHERS            = 3
              .
* End of change on 17-Jun-2013
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    IF SY-SUBRC = 0.
      MESSAGE I053(ZAA) WITH GROUP.
      CALL TRANSACTION 'SESSION_MANAGER'.
    ENDIF.
  ELSE.
    CALL FUNCTION 'BDC_CLOSE_GROUP'.
  ENDIF.

ENDFORM.                    " close_group

*&---------------------------------------------------------------------*
*&      Form  close_group1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLOSE_GROUP1.
* Begin of change on 17-Jun-2013
  CALL FUNCTION 'BDC_CLOSE_GROUP'
   EXCEPTIONS
     NOT_OPEN          = 1
     QUEUE_ERROR       = 2
     OTHERS            = 3
            .
* End of change on 17-Jun-2013
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


  IF SY-SUBRC = 0.
    if G_OKCODE = 'WBACKGROSS'.
      MESSAGE I053(ZAA) WITH GROUP.
      MESSAGE I053(ZAA) WITH GROUP1.
    else .
      MESSAGE I053(ZAA) WITH GROUP.
    endif.
    CALL TRANSACTION 'SESSION_MANAGER'.
  ENDIF.
ENDFORM.                    " close_group

*&---------------------------------------------------------------------*
*&      Form  popup_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TEXT  text
*----------------------------------------------------------------------*
FORM POPUP_MESSAGE USING G_TEXT.
*Begin of <RD1K960036>

*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            DEFAULTOPTION = 'Y'
*            TEXTLINE1     = G_TEXT
*            TITEL         = 'Geo well data maintenance'
*       IMPORTING
*            ANSWER        = G_ANSWER.

CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Geo well data maintenance'(T01)
   TEXT_QUESTION               = G_TEXT
   TEXT_BUTTON_1               = 'Yes'(T03)
   TEXT_BUTTON_2               = 'No'(T04)
 IMPORTING
   ANSWER                      = G_ANSWER
EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2.

IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
*End of <RD1K960036>

ENDFORM.                    " popup_message
*&---------------------------------------------------------------------*
*&      Form  OPEN_GROUP1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OPEN_GROUP1.
  DATA:UNAME LIKE APQI-USERID,
       KEEP,
       HOLDDATE LIKE SY-DATUM.
  UNAME = SY-UNAME.
  KEEP = 'X'.
  HOLDDATE = SY-DATUM.
  CONCATENATE P_BUKRS P_GJAHR P_MONAT 'BAA' INTO GROUP1.
  CALL FUNCTION 'BDC_OPEN_GROUP'
       EXPORTING
            CLIENT   = SY-MANDT
            GROUP    = GROUP1
            USER     = UNAME
            KEEP     = KEEP
            HOLDDATE = HOLDDATE.

ENDFORM.                    " OPEN_GROUP1

*BOC By SAP_ABAP on 27/08/26
*&---------------------------------------------------------------------*
*&  S/4 conversion - posting layer replacing the ABAA / ABZU batch input
*&---------------------------------------------------------------------*
*  ABAA and ABZU are no longer posting transactions on S/4. Both are
*  assigned in SE93 to the dispatcher report RADISPATCH_AB01, which
*  forwards to the new transactions with LEAVE TO TRANSACTION. That is
*  illegal inside batch input, so every session this program built died
*  at step 1 with message 00 352. Re-recording cannot help - the
*  dispatcher forwards every time.
*
*  Posting therefore moves to the FI-AA posting BAPIs, function group
*  AMFA, which is the route SAP supports for new Asset Accounting:
*
*    ABAA (unplanned depreciation) -> BAPI_ASSET_VALUE_ADJUST_CHECK
*                                     BAPI_ASSET_VALUE_ADJUST_POST
*    ABZU (write-up)               -> BAPI_ASSET_WRITEUP_CHECK
*                                     BAPI_ASSET_WRITEUP_POST
*
*  Each _CHECK twin validates without posting, so MZAAIMPI01 can show the
*  user what would post - and any per-asset error - before anything is
*  written. That replaces the review step the SM35 session provided.
*
*  Neither posting FORM commits. The caller commits, so WBACKGROSS -
*  which posts a write-up and an unplanned depreciation for the same
*  asset - can keep both legs together.
*&---------------------------------------------------------------------*

* ASSUMPTION: impairment posts under accounting principle 0004, advised by
* functional on 27/08/26. Verified on OCQ the same day: with
* ACC_PRINCIPLE = '0004' and DEPR_AREA left initial, the BAPI derives the
* depreciation areas itself - the check returned warning AU 176 only, the
* identical result transaction ABAAL gives in dialog for the same asset.
* Setting DEPR_AREA instead restricts the posting to that one area, which
* is narrower than the old screen behaviour. Do not set DEPR_AREA here.
* Written confirmation from functional is still outstanding; if the
* accounting principle changes, this constant is the only place to edit.
CONSTANTS: G_C_ACCPRINCIPLE TYPE BAPIFAPO_GEN_INFO-ACC_PRINCIPLE
                            VALUE '0004'.

* Company code currency, read once on first use.
DATA: G_WAERS TYPE T001-WAERS.

*&---------------------------------------------------------------------*
*&      Form  ZAA_GET_WAERS
*&---------------------------------------------------------------------*
*       Company code currency for the BAPI amount fields. The BDC never
*       passed one - the ABAA screen defaulted it - so it has to be read
*       explicitly now. Buffered in G_WAERS; one SELECT per session.
*----------------------------------------------------------------------*
FORM ZAA_GET_WAERS CHANGING PV_SUBRC.

  CLEAR PV_SUBRC.

  IF G_WAERS IS INITIAL.
    SELECT SINGLE waers FROM t001
           WHERE bukrs = @P_BUKRS
           INTO @G_WAERS.
    IF SY-SUBRC <> 0.
      PV_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.                    " ZAA_GET_WAERS

*&---------------------------------------------------------------------*
*&      Form  ZAA_COLLECT_RETURN
*&---------------------------------------------------------------------*
*       Folds the BAPI RETURN structure and RETURN_ALL table into one
*       message table and reports whether it carries an error.
*       PV_SUBRC = 4 if any message is type E or A.
*----------------------------------------------------------------------*
FORM ZAA_COLLECT_RETURN TABLES   PT_RETURN STRUCTURE BAPIRET2
                                 PT_RETALL STRUCTURE BAPIRET2
                        USING    PS_RETURN LIKE BAPIRET2
                        CHANGING PV_SUBRC.

  CLEAR PV_SUBRC.

  IF NOT PS_RETURN IS INITIAL.
    PT_RETURN = PS_RETURN.
    APPEND PT_RETURN.
  ENDIF.

  LOOP AT PT_RETALL.
    PT_RETURN = PT_RETALL.
    APPEND PT_RETURN.
  ENDLOOP.

  LOOP AT PT_RETURN WHERE TYPE = 'E' OR TYPE = 'A'.
    PV_SUBRC = 4.
    EXIT.
  ENDLOOP.

ENDFORM.                    " ZAA_COLLECT_RETURN

*&---------------------------------------------------------------------*
*&      Form  ZAA_VALUE_ADJUST
*&---------------------------------------------------------------------*
*       Replaces the ABAA batch input.
*       PV_CHECK = 'X' validates only and posts nothing.
*       PV_CHECK initial posts. No COMMIT - see ZAA_BAPI_COMMIT.
*       PV_SUBRC = 4 if PT_RETURN carries any E or A message.
*
*       Field mapping from the BDC this replaces:
*         ANBZ-BUKRS -> COMP_CODE     ANBZ-BWASL -> ASSETTRTYP
*         ANBZ-ANLN1 -> ASSETMAINO    ANBZ-BZDAT -> TRANS_DATE
*         ANBZ-ANLN2 -> ASSETSUBNO    ANBZ-DMBTR -> AMOUNT
*         ANEK-BLDAT -> DOC_DATE      ANEK-SGTXT -> ITEM_TEXT
*         ANEK-BUDAT -> PSTNG_DATE    ANBZ-PERID -> FIS_PERIOD
*----------------------------------------------------------------------*
FORM ZAA_VALUE_ADJUST TABLES   PT_RETURN STRUCTURE BAPIRET2
                      USING    PV_ANLN1
                               PV_ANLN2
                               PV_TTYPE
                               PV_AMOUNT
                               PV_BZDAT
                               PV_TEXT
                               PV_CHECK
                      CHANGING PV_SUBRC.

  DATA: LS_GENERAL LIKE BAPIFAPO_GEN_INFO,
        LS_VALADJ  LIKE BAPIFAPO_VALUE_ADJUSTMENT,
        LS_FURTHER LIKE BAPIFAPO_ADD_INFO,
        LS_RETURN  LIKE BAPIRET2,
        LT_RETALL  LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
        L_BZDAT    LIKE ANEK-BZDAT,
        L_SUBRC    LIKE SY-SUBRC.

  REFRESH: PT_RETURN, LT_RETALL.
  CLEAR:   PV_SUBRC, LS_RETURN.

  PERFORM ZAA_GET_WAERS CHANGING L_SUBRC.
  IF L_SUBRC <> 0.
    PT_RETURN-TYPE    = 'E'.
    PT_RETURN-MESSAGE = 'Currency not found for company code'.
    APPEND PT_RETURN.
    PV_SUBRC = 4.
    EXIT.
  ENDIF.

* IST_DISPLAY-BZDAT is CHAR(10) in external format - the report converted
* it with CONVERT_DATE_TO_EXTERNAL so it could be typed into the BDC
* screen. The BAPI needs an internal date, so convert it back.
  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
       EXPORTING
            DATE_EXTERNAL            = PV_BZDAT
       IMPORTING
            DATE_INTERNAL            = L_BZDAT
       EXCEPTIONS
            DATE_EXTERNAL_IS_INVALID = 1
            OTHERS                   = 2.
  IF SY-SUBRC <> 0.
    PT_RETURN-TYPE    = 'E'.
    PT_RETURN-MESSAGE = 'Asset value date is not a valid date'.
    APPEND PT_RETURN.
    PV_SUBRC = 4.
    EXIT.
  ENDIF.

  LS_GENERAL-COMP_CODE     = P_BUKRS.
  LS_GENERAL-ASSETMAINO    = PV_ANLN1.
  LS_GENERAL-ASSETSUBNO    = PV_ANLN2.
  LS_GENERAL-DOC_DATE      = SY-DATUM.
  LS_GENERAL-PSTNG_DATE    = P_BUDAT.
  LS_GENERAL-FIS_PERIOD    = P_MONAT.
  LS_GENERAL-ASSETTRTYP    = PV_TTYPE.
  LS_GENERAL-TRANS_DATE    = L_BZDAT.
  LS_GENERAL-ACC_PRINCIPLE = G_C_ACCPRINCIPLE.
* DEPR_AREA deliberately left initial - see G_C_ACCPRINCIPLE above.

  LS_VALADJ-AMOUNT    = PV_AMOUNT.
  LS_VALADJ-CURRENCY  = G_WAERS.
  LS_VALADJ-VALUEDATE = L_BZDAT.

  LS_FURTHER-ITEM_TEXT = PV_TEXT.

  IF PV_CHECK = 'X'.
    CALL FUNCTION 'BAPI_ASSET_VALUE_ADJUST_CHECK'
         EXPORTING
              GENERALPOSTINGDATA = LS_GENERAL
              VALUEADJUSTDATA    = LS_VALADJ
              FURTHERPOSTINGDATA = LS_FURTHER
         IMPORTING
              RETURN             = LS_RETURN
         TABLES
              RETURN_ALL         = LT_RETALL.
  ELSE.
    CALL FUNCTION 'BAPI_ASSET_VALUE_ADJUST_POST'
         EXPORTING
              GENERALPOSTINGDATA = LS_GENERAL
              VALUEADJUSTDATA    = LS_VALADJ
              FURTHERPOSTINGDATA = LS_FURTHER
         IMPORTING
              RETURN             = LS_RETURN
         TABLES
              RETURN_ALL         = LT_RETALL.
  ENDIF.

  PERFORM ZAA_COLLECT_RETURN TABLES   PT_RETURN
                                      LT_RETALL
                             USING    LS_RETURN
                             CHANGING PV_SUBRC.

ENDFORM.                    " ZAA_VALUE_ADJUST

*&---------------------------------------------------------------------*
*&      Form  ZAA_WRITEUP
*&---------------------------------------------------------------------*
*       Replaces the ABZU batch input.
*       PV_CHECK = 'X' validates only and posts nothing.
*       PV_CHECK initial posts. No COMMIT - see ZAA_BAPI_COMMIT.
*
*       The write-up legs never used a single amount field. The BDC split
*       it by transaction type:
*         IF TTYPE = 'X70'. ANBZ-SAFAV = amount.   " special depreciation
*         ELSE.             ANBZ-NAFAV = amount.   " ordinary depreciation
*       WRITEUPDATA carries the same split, so the branch is preserved:
*         ANBZ-SAFAV -> SPE_DEP_CU
*         ANBZ-NAFAV -> ORD_DEP_CU
*
*       PV_DEPKIND says which bucket the amount belongs in:
*         'S' - special depreciation  -> SPE_DEP_CU
*         'O' - ordinary depreciation -> ORD_DEP_CU
*         initial - decide from the transaction type, as the BDC did
*       It is not enough to test the transaction type everywhere. Two of
*       the three ABZU sites used the IF TTYPE = 'X70' rule, but the
*       PWBACK site (screen 0600) wrote ANBZ-SAFAV unconditionally, with
*       transaction types X21 / X32. Deriving from the type alone would
*       silently move that amount into ordinary depreciation.
*
*       PV_BLART takes what the BDC put in RA01B-BLART. Only two of the
*       three ABZU call sites set it ('AA'); the third left it to default,
*       so it is a parameter and not a constant.
*----------------------------------------------------------------------*
FORM ZAA_WRITEUP TABLES   PT_RETURN STRUCTURE BAPIRET2
                 USING    PV_ANLN1
                          PV_ANLN2
                          PV_TTYPE
                          PV_AMOUNT
                          PV_BZDAT
                          PV_TEXT
                          PV_BLART
                          PV_DEPKIND
                          PV_CHECK
                 CHANGING PV_SUBRC.

  DATA: LS_GENERAL LIKE BAPIFAPO_GEN_INFO,
        LS_WRITEUP LIKE BAPIFAPO_WRITEUP,
        LS_FURTHER LIKE BAPIFAPO_ADD_INFO,
        LS_RETURN  LIKE BAPIRET2,
        LT_RETALL  LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
        L_BZDAT    LIKE ANEK-BZDAT,
        L_SUBRC    LIKE SY-SUBRC.

  REFRESH: PT_RETURN, LT_RETALL.
  CLEAR:   PV_SUBRC, LS_RETURN.

  PERFORM ZAA_GET_WAERS CHANGING L_SUBRC.
  IF L_SUBRC <> 0.
    PT_RETURN-TYPE    = 'E'.
    PT_RETURN-MESSAGE = 'Currency not found for company code'.
    APPEND PT_RETURN.
    PV_SUBRC = 4.
    EXIT.
  ENDIF.

  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
       EXPORTING
            DATE_EXTERNAL            = PV_BZDAT
       IMPORTING
            DATE_INTERNAL            = L_BZDAT
       EXCEPTIONS
            DATE_EXTERNAL_IS_INVALID = 1
            OTHERS                   = 2.
  IF SY-SUBRC <> 0.
    PT_RETURN-TYPE    = 'E'.
    PT_RETURN-MESSAGE = 'Asset value date is not a valid date'.
    APPEND PT_RETURN.
    PV_SUBRC = 4.
    EXIT.
  ENDIF.

  LS_GENERAL-COMP_CODE     = P_BUKRS.
  LS_GENERAL-ASSETMAINO    = PV_ANLN1.
  LS_GENERAL-ASSETSUBNO    = PV_ANLN2.
  LS_GENERAL-DOC_DATE      = SY-DATUM.
  LS_GENERAL-PSTNG_DATE    = P_BUDAT.
  LS_GENERAL-FIS_PERIOD    = P_MONAT.
  LS_GENERAL-ASSETTRTYP    = PV_TTYPE.
  LS_GENERAL-TRANS_DATE    = L_BZDAT.
  LS_GENERAL-DOC_TYPE      = PV_BLART.
  LS_GENERAL-ACC_PRINCIPLE = G_C_ACCPRINCIPLE.
* DEPR_AREA deliberately left initial - see G_C_ACCPRINCIPLE above.

  CASE PV_DEPKIND.
    WHEN 'S'.
      LS_WRITEUP-SPE_DEP_CU = PV_AMOUNT.
    WHEN 'O'.
      LS_WRITEUP-ORD_DEP_CU = PV_AMOUNT.
    WHEN OTHERS.
*     Initial - the rule the two sites that had one used.
      IF PV_TTYPE = 'X70'.
        LS_WRITEUP-SPE_DEP_CU = PV_AMOUNT.
      ELSE.
        LS_WRITEUP-ORD_DEP_CU = PV_AMOUNT.
      ENDIF.
  ENDCASE.
  LS_WRITEUP-CURRENCY  = G_WAERS.
  LS_WRITEUP-VALUEDATE = L_BZDAT.

  LS_FURTHER-ITEM_TEXT = PV_TEXT.

* WRITEUPAREAVALUES is left empty on purpose. It overrides the amounts
* per depreciation area, and the accounting principle already scopes the
* areas - the same derivation transaction ABZU performed on its own.
  IF PV_CHECK = 'X'.
    CALL FUNCTION 'BAPI_ASSET_WRITEUP_CHECK'
         EXPORTING
              GENERALPOSTINGDATA = LS_GENERAL
              WRITEUPDATA        = LS_WRITEUP
              FURTHERPOSTINGDATA = LS_FURTHER
         IMPORTING
              RETURN             = LS_RETURN
         TABLES
              RETURN_ALL         = LT_RETALL.
  ELSE.
    CALL FUNCTION 'BAPI_ASSET_WRITEUP_POST'
         EXPORTING
              GENERALPOSTINGDATA = LS_GENERAL
              WRITEUPDATA        = LS_WRITEUP
              FURTHERPOSTINGDATA = LS_FURTHER
         IMPORTING
              RETURN             = LS_RETURN
         TABLES
              RETURN_ALL         = LT_RETALL.
  ENDIF.

  PERFORM ZAA_COLLECT_RETURN TABLES   PT_RETURN
                                      LT_RETALL
                             USING    LS_RETURN
                             CHANGING PV_SUBRC.

ENDFORM.                    " ZAA_WRITEUP

*&---------------------------------------------------------------------*
*&      Form  ZAA_BAPI_COMMIT
*&---------------------------------------------------------------------*
*       WAIT = 'X' so the asset values are on the database before the
*       next row is checked - the impairment of one asset can depend on
*       what the previous posting left behind.
*----------------------------------------------------------------------*
FORM ZAA_BAPI_COMMIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
       EXPORTING
            WAIT = 'X'.

ENDFORM.                    " ZAA_BAPI_COMMIT

*&---------------------------------------------------------------------*
*&      Form  ZAA_BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*       Used where one user action posts more than one document for the
*       same asset - WBACKGROSS posts a write-up and an unplanned
*       depreciation - so a failure on the second leg does not leave the
*       first one standing on its own.
*----------------------------------------------------------------------*
FORM ZAA_BAPI_ROLLBACK.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

ENDFORM.                    " ZAA_BAPI_ROLLBACK
*EOC By SAP_ABAP on 27/08/26
