*----------------------------------------------------------------------*
***INCLUDE MZPZ9920_MED_INPATIENT_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_LIST_BOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0007   text
*----------------------------------------------------------------------*
Form get_list .
**    CALL FUNCTION 'HR_PSBUFFER_INITIALIZE'.
endform.
FORM GET_LIST_BOX  USING   p_id.

  DATA: itab TYPE TABLE OF pa9919 WITH HEADER LINE.
  DATA: fname LIKE pa0021-favor, lname LIKE pa0021-fanam.
  Clear :g_city .
  Clear :g_persa, g_value, g_list.
  refresh g_list.


  SELECT WERKS INTO G_PERSA
 FROM PA0001 UP TO 1 ROWS WHERE PERNR = P9920-PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  if sy-subrc = 0.
    Select single CITYC
           into g_city
           from T500P
           where PERSA = g_persa .
  endif.
  g_id = p_id.
  refresh g_list[].
  data: lv_cu_date like SY-DATUM,
          lv_sx_date like sy-datum.

  lv_cu_date = sy-datum.

* begin RD1K978193 CAB_ALOK CR 30006378
* Remove 6-month's validity condition
*  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
*    EXPORTING
*      currdate   = lv_cu_date
*      backmonths = 6
*    IMPORTING
*      NEWDATE    = lv_sx_date.
* End RD1K978193 CAB_ALOK CR 30006378

  SELECT * FROM pa9919 INTO TABLE itab WHERE pernr = p9920-pernr "g_pernr
* begin RD1K978193 CAB_ALOK CR 30006378
* get all cards which were valid at any point of time.(i.e. remove condition on dates)
*  AND  begda <= sy-datum AND endda >= lv_sx_date
* Employee and his dependents can be in different cities, remove condition on location
*  and  ZLOC_CR = g_city .
   .
* end RD1K978193 CAB_ALOK   CR 30006378

  if sy-subrc = 0.
    move itab[] to lv_endda_ch[] .      " used for card number validation
  endif.
  Sort lv_endda_ch by zcrdno endda descending .
  Clear lv_endda_ch .
  if g_facility = '07'.
  else.
    IF itab[] IS INITIAL.
      MESSAGE e111(zhr) WITH p9920-pernr.
    ENDIF.
  endif.
  Sort itab by zcrdno endda descending .
  Clear itab .
  Delete ADJACENT DUPLICATES FROM  itab comparing zcrdno .
  LOOP AT itab.
    g_value-key = itab-zcrdno.

*** get relation
    SELECT SINGLE stext FROM t591s INTO g_value-text WHERE sprsl =
    'E' AND infty =  '0021' AND subty = itab-subty.
    IF itab-subty <> '16'.
*  Get relation-name
      SELECT FAVOR FANAM FROM PA0021 INTO ( FNAME , LNAME ) UP TO 1 ROWS
 WHERE PERNR = P9920-PERNR AND SUBTY = ITAB-SUBTY AND OBJPS = ITAB-OBJPS
 ORDER BY PRIMARY KEY .
 ENDSELECT.
* end RD1K978193 CAB_ALOK CR 30006378

      CONCATENATE g_value-text '-' fname lname INTO g_value-text
      SEPARATED BY space.
    elseif itab-subty = '16'.
      SELECT ENAME
 FROM PA0001 INTO (FNAME ) UP TO 1 ROWS WHERE PERNR = P9920-PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      CONCATENATE g_value-text '-' fname INTO g_value-text
      SEPARATED BY space.

    ENDIF.
    APPEND g_value TO g_list.
    CLEAR g_value.
  ENDLOOP.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_id
      values = g_list.

ENDFORM.                    " GET_LIST_BOX
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_0101
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_0101 .
* begin RD1K978193 CAB_ALOK CR 30006378
**** Check dates:
*  if p9920-subty = '03'.
***  dates empty
*    if p9920-zdate_from is initial
*      or p9920-zdate_to is initial
*        or P9920-ZBILL_DATE is initial.
*      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*          WITH text-021.   " date is empty.
***   error: start date  is greater than end date
*    elseif p9920-zdate_from > p9920-zdate_to.
*      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*          WITH text-008.
*** dates > current date
*    elseif  p9920-zdate_from > sy-datum
*      or p9920-zdate_to > sy-datum
*        or P9920-ZBILL_DATE > sy-datum .
*      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*         WITH text-022.
*    elseif P9920-ZBILL_DATE < p9920-zdate_to  .
*      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*         WITH text-023.
*    endif.
*
*  elseif p9920-subty = '04'
*           or p9920-subty = '05'
*             or p9920-subty = '06'.
***  dates empty
*    if p9920-zdate_from is initial
*       or P9920-ZBILL_DATE is initial.
*      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*          WITH text-021.   " date is empty.
*** dates > current date
*    elseif  p9920-zdate_from > sy-datum
*        or P9920-ZBILL_DATE > sy-datum .
*      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*         WITH text-022.
*    elseif P9920-ZBILL_DATE < p9920-zdate_from  .
*      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*         WITH text-024.
*    endif.
*
*  endif.

**Check vendor
** empty?
*  if p9920-zhospid is initial.
*    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*           WITH text-025.   "
*  endif.
** Validate: (vendor code entered & company code of Dealing officer) pair should
**    exist in ZHR_MED_VENDORS
*  clear WA_ZHR_MED_VENDORS.
*  select single * from ZHR_MED_VENDORS into WA_ZHR_MED_VENDORS
**  where BUKRS = G_BUKRS " Now P9920-GRPVL
*      where BUKRS = P9920-GRPVL
*      and LIFNR = P9920-ZHOSPID.
*  if sy-subrc <> 0 .
*    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH text-030.
*  endif.

** Check illness, bill no.
*  if p9920-ZILLNESS is initial.
*    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*           WITH text-026.   "
*  endif.
*  if p9920-ZBILL_NO is initial.
*    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*           WITH text-027.   "
*  endif.
*
**Check claim amt.
*  IF P9920-ZAMOUNT is initial.
*    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*           WITH text-028.   "
*  ENDIF.

** Check: if recovery > 0 then Remarks mandatory.
*  IF P9920-ZADV_TKN > 0 and P9920-ZREMARKS is initial.
*    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
*           WITH text-029.   "
*  ENDIF.

**  Validate Card No.
*  perform validate_card_no.
* end RD1K978193 CAB_ALOK CR 30006378

* validations of p9920
  DATA: VALIDATION_MSG type ZCHAR_MAX,                      "255 char
        ERROR_FLAG type CHAR1.

  clear: ERROR_FLAG , VALIDATION_MSG.
  CALL FUNCTION 'ZHR_MED_PYMT9920_VALIDATE_FILL'
    IMPORTING
      VALIDATION_MSG = VALIDATION_MSG
      ERROR_FLAG     = ERROR_FLAG
    CHANGING
      P9920          = P9920.

  if ERROR_FLAG = '1'.  " validation failed

    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
           WITH VALIDATION_MSG.


  endif.


****  if ZHR_MED_VENDORS-TAXABLE is INITIAL.
****    g_claim_not_save = 'X'.
****    message s000(zmsg)
****    with 'Claim can not be saved - Hospital category for taxation '
****         'not maintained - if there please press enter'.
****  endif.

ENDFORM.                    " VALIDATE_0101
*&---------------------------------------------------------------------*
*&      Form  LOCK_AND_UPDATE_USER_0101
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LOCK_AND_UPDATE_USER_0101 .

  CALL FUNCTION 'BAPI_EMPLOYEET_ENQUEUE'
    EXPORTING
      number        = p9920-pernr
      validitybegin = sy-datum
    IMPORTING
      return        = l_return.
  IF l_return-type NE space.
    PERFORM read_enqueue_table_0101.
  ELSE.


* Updating data in infotype 9920
    PERFORM update_info_0101.

  ENDIF.



ENDFORM.                    " LOCK_AND_UPDATE_USER_0101
*&---------------------------------------------------------------------*
*&      Form  READ_ENQUEUE_TABLE_0101
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ENQUEUE_TABLE_0101 .
  DATA: number LIKE sy-tabix,
          arg    LIKE seqg3-garg,
          enq    LIKE seqg3 OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gclient               = sy-mandt
      gname                 = 'PREL'
      garg                  = arg
      guname                = space
    IMPORTING
      number                = number
    TABLES
      enq                   = enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc EQ 0.
    IF number > 0.
      IF sy-ucomm = 'EXIT' or sy-ucomm = 'BACK' .
        PERFORM unlock_user_0101.
        EXIT.
      ENDIF.
      CLEAR enq.
      READ TABLE enq WITH KEY gtarg+3(8) = p9920-pernr.
* Is the record locked by the ESS user or administrator?
      IF enq-guname <> sy-uname.
        MESSAGE s238(pwww) WITH p9920-pernr enq-guname.
      ELSE.
        MESSAGE s238(pwww) WITH p9920-pernr sy-uname.
      ENDIF.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.
ENDFORM.                    " READ_ENQUEUE_TABLE_0101
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_USER_0101
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNLOCK_USER_0101 .
  CALL FUNCTION 'BAPI_EMPLOYEET_DEQUEUE'
    EXPORTING
      number        = p9920-pernr
      validitybegin = sy-datum
    IMPORTING
      return        = l_return.

  IF NOT l_return IS INITIAL.
    IF l_return-type NE 'S'.
      l_return-type = 'S'.
    ENDIF.
    MESSAGE ID l_return-id TYPE l_return-type NUMBER l_return-number
         WITH l_return-message_v1 l_return-message_v2
              l_return-message_v3 l_return-message_v4.
    EXIT.
  ENDIF.
ENDFORM.                    " UNLOCK_USER_0101
*&---------------------------------------------------------------------*
*&      Form  UPDATE_INFO_0101
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_INFO_0101 .
  DATA : ist_email LIKE zhr_mailid OCCURS 0.
  DATA : ist_ret LIKE bapireturn1 OCCURS 0.
  DATA : l_person TYPE ad_smtpadr.
  DATA : l_date(10) TYPE c.
  DATA : l_subjc TYPE witext,
         l_text1 TYPE ad_smtpadr,
         l_text2 TYPE ad_smtpadr,
         l_text3 TYPE ad_smtpadr,
         l_text4 TYPE ad_smtpadr,
         l_text5 TYPE ad_smtpadr,
         l_text6 TYPE ad_smtpadr.



* p9920-subty already calculated with G_FACILITY
  p9920-infty = '9920'.





  CALL FUNCTION 'HR_INFOTYPE_OPERATION'
    EXPORTING
      infty            = '9920'
      number           = p9920-pernr
      subtype          = p9920-subty
*     OBJECTID         =
      lockindicator    = 'X'
      validityend      = '99991231' "sy-datum
      validitybegin    = p9920-BEGDA       "sy-datum
*     RECORDNUMBER     =
      record           = p9920
      operation        = 'INS'  "INS/MOD
      tclas            = 'A'
*     dialog_mode      = '0'
      nocommit         = 'X'
*     VIEW_IDENTIFIER  =
*     SECONDARY_RECORD =
    IMPORTING
      return           = l_return
      key              = bapipakey_tab.

  IF NOT l_return IS INITIAL.
    ROLLBACK WORK.

    IF l_return-type NE 'S'.
      l_return-type = 'S'.
    ENDIF.
    MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
      WITH l_return-message.

    EXIT.
  ELSE.
    COMMIT WORK.
    g_greyoff = 'X'.  " Record has been saved


*****Send Mail.
****
****        CONCATENATE wa_claims-reimt
****                  ename
****                  '('
****                  g_pernr
****                  ')'
****             INTO l_subjc
****        SEPARATED BY space.
****
****      CONCATENATE wa_claims-reimt
****                  g_pernr
****                  '-'
****                  ename
****                  'has been created.'
****              INTO l_text1
****         SEPARATED BY space.
****
****      l_text2 = 'Please execute the mail to unlock the same'.
****
****
****CALL FUNCTION 'ZHR_SEND_MAIL_TO_ADMIN'
****             EXPORTING
****                  pernr            = '99999999'
****                  persadmin        = space
****                  time             = ' '
****                  payradmin        = space
****                  internet_address = space
****                  sap_inbox        = 'X'
****                  mail_subject     = l_subjc
****                  content1         = l_text1
****                  content2         = l_text2
*****                  content3         = l_text3
*****                  content4         = l_text4
****                  email            = space
****                  sap_uname        = mail_id
****                  to               = 'X'
****                  cc               = ' '
****                  bcc              = ' '
****                  infty            = '9920'
****                  per              = g_pernr
****                  EXECMAIL         = 'X'
****             TABLES
****                  return           = ist_ret
*****               mailid           = lt_mailid
****             EXCEPTIONS
****                  admin_not_found  = 1
****                  usrid_not_found  = 2
****                  usrid_not_assign = 3
****                  mailid_not_found = 4
****                  send_api         = 5
****                  OTHERS           = 6.
****
****    IF sy-subrc <> 0.
****    ENDIF.
****
****
*****End send mail

    MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
      WITH 'Claim created with submission number ' P9920-cnter .
*          CLEAR p9920.
****      CLEAR flg_first_9000.
  ENDIF.
****  ENDIF.
ENDFORM.                    " UPDATE_INFO_0101

*&---------------------------------------------------------------------*
*&      Form  GET_COUNTER_0101
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COUNTER_0101 .
  CLEAR p9920-cnter.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZHR_MED'
    IMPORTING
      number                  = p9920-cnter
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  IF sy-subrc NE 0.
    CLEAR save_ok.
    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
          WITH 'Can not process, Error in counter generation'.
  ENDIF.
ENDFORM.                    " GET_COUNTER_0101
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALCULATE_VALUES .

  p9920-subty = G_FACILITY.

*   get next free claim number.
  PERFORM get_counter_0101.
*  p9920-cnter = '9999999999'.

  p9920-zstatus = 'NEW'.



ENDFORM.                    " CALCULATE_VALUES
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_CARD_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_CARD_NO .
* Validate CARD NO.
  data: lv_cu_date like SY-DATUM,
          lv_sx_date like sy-datum.
  refresh lv_endda_ch.
  clear lv_endda_ch.
  lv_cu_date = sy-datum.
  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = lv_cu_date
      backmonths = 6
    IMPORTING
      NEWDATE    = lv_sx_date.

  SELECT * FROM pa9919
    INTO TABLE lv_endda_ch
    WHERE pernr = p9920-pernr
        AND  begda <= sy-datum
        AND endda >= lv_sx_date.

  Sort lv_endda_ch by zcrdno endda descending .
  Clear lv_endda_ch .
  if g_facility = '07'.
  else.
    IF lv_endda_ch[] IS INITIAL.
      MESSAGE e111(zhr) WITH p9920-pernr.
    ENDIF.
  endif.

  Sort lv_endda_ch by zcrdno endda descending .
  Clear lv_endda_ch .
  Delete ADJACENT DUPLICATES FROM lv_endda_ch comparing zcrdno .

  read table lv_endda_ch  with key  zcrdno = p9920-zcrdno .
  if sy-subrc = 0.
    if P9920-ZDATE_FROM GT lv_endda_ch-endda.

      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
         WITH 'Treatment start Date cannot be greater'
               'than Medical Card End Date'.
    endif.
  endif.

  if lv_endda_ch-endda LT sy-datum.
    MESSAGE ID 'ZMSG' TYPE 'W' NUMBER '000'
       WITH 'Medical Card Expiered' lv_endda_ch-endda.

  endif.
ENDFORM.                    " VALIDATE_CARD_NO
*&---------------------------------------------------------------------*
*&      Form  RESET_LIST_BOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0030   text
*----------------------------------------------------------------------*
FORM RESET_LIST_BOX  USING  P_ID .
  DATA: x_list TYPE vrm_values,
        X_value  LIKE LINE OF x_list.
  G_ID = P_ID.

  Refresh X_LIST.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_id
      values = x_list.

*CALL FUNCTION 'VRM_REFRESH_VALUES' .

*CALL FUNCTION 'VRM_DELETE_VALUES'
*  EXPORTING
*    ID                         = G_ID
**   ID_CONTAINS_PROGNAME       =
* EXCEPTIONS
*   ID_NOT_FOUND               = 1
*   OTHERS                     = 2   .
*IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
ENDFORM.                    " RESET_LIST_BOX

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_0401
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_0401 .

  DATA: submit_pernr TYPE pernr_d.
  DATA: submit_name TYPE emnam.
  DATA: submit_orgeh TYPE orgeh.
  DATA: submit_plans TYPE plans.
  DATA: submit_persa TYPE persa.
  DATA: submit_bukrs TYPE bukrs.
*data: IST_9920_SUBMIT type table of PA9920.



*  PERFORM GETDATA_USER
*       changing submit_pernr submit_name submit_orgeh
*          submit_plans submit_persa submit_bukrs.

  PERFORM GETDATA_IST_9920_SUBMIT tables IST_9920_SUBMIT using G_USER_BUKRS. "submit_bukrs .


ENDFORM.                    " GET_DATA_0401
*&---------------------------------------------------------------------*
*&      Form  GETDATA_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETDATA_USER changing submit_pernr submit_name submit_orgeh
        submit_plans submit_persa submit_bukrs..
** find comapny code of current user.

  CALL FUNCTION 'HR_GETEMPLOYEEDATA_FROMUSER'
    EXPORTING
      username                  = sy-uname
      validbegin                = sy-datum
*     check_auth                =  space
    IMPORTING
      employeenumber            = submit_pernr
      name                      = submit_name
      orgunit                   = submit_orgeh
      position                  = submit_plans
      personnelarea             = submit_persa
      COMPANYCODE               = submit_bukrs
    EXCEPTIONS
      user_not_found            = 1
      countrygrouping_not_found = 2
      infty_not_found           = 3
      OTHERS                    = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*###############################################
*** remove after modifying PA30- 0105 (communication) for CHR_SAHA and enable the above MSG
*  if sy-uname = 'CHR_SAHA'.
*    SUBMIT_PERNR =   '00052970'.
*    SUBMIT_BUKRS =   'DLI'.
*  endif.
*###############################################

ENDFORM.                    " GETDATA_USER

*&---------------------------------------------------------------------*
*&      Form  GETDATA_IST_9920_SUBMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

* Begin RD1K981765 CR: 30007609 CAB_ALOK
*FORM  GETDATA_IST_9920_SUBMIT  tables IST_9920_SUBMIT using submit_bukrs.
FORM GETDATA_IST_9920_SUBMIT  tables IST_9920_SUBMIT STRUCTURE IST_9920_SUBMIT using submit_bukrs.
* End RD1K981765 CR: 30007609 CAB_ALOK
  DATA: wa_9920_SUBMIT1 TYPE ty_submit,
              l_tabix  TYPE sy-tabix.

  data: R_UNAME TYPE RANGE OF PA9920-UNAME WITH HEADER LINE,
        R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
        R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE .


*** data:  DATE_LOW type sy-datum,
***        DATE_HIGH type sy-datum.


*get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
* and company code of record = comapny code of current user.
* and Status of record = 'NEW'
*Struct.     ZPMED_SUBMIT
*    BEGDA_LOW          20100831
*    BEGDA_HIGH         20100929
*    UNAME_LOW          ABC
*    UNAME_HIGH         X
*    ZHOSPID_LOW        111
*    ZHOSPID_HIGH       222

*** convert dates
**            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
**              EXPORTING
**                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_LOW
**             IMPORTING
**                DDMMYYYY       = DATE_LOW.
**
**            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
**              EXPORTING
**                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_HIGH
**             IMPORTING
**                DDMMYYYY       = DATE_HIGH.

*Put data in range so that 'IN' keyword can be used in SELECT stmt.
  clear: R_UNAME, R_BEGDA, R_ZHOSPID.
  refresh: R_UNAME, R_BEGDA, R_ZHOSPID.

  R_UNAME-SIGN = 'I'.
  R_UNAME-LOW = ZPMED_SUBMIT-UNAME_LOW.
  R_UNAME-HIGH = ZPMED_SUBMIT-UNAME_HIGH.
  if R_UNAME-LOW is NOT INITIAL and  R_UNAME-HIGH is NOT INITIAL.
    R_UNAME-OPTION = 'BT'.
  else.
    R_UNAME-OPTION = 'EQ'.
  endif.
  append R_UNAME.
  if R_UNAME-LOW is INITIAL and  R_UNAME-HIGH is INITIAL.
    clear: R_UNAME.
    refresh:  R_UNAME.
  endif.

  R_BEGDA-SIGN = 'I'.
  R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
  R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
  if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
    R_BEGDA-OPTION = 'BT'.
  else.
    R_BEGDA-OPTION = 'EQ'.
  endif.
  append R_BEGDA.
  if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
    clear: R_BEGDA.
    refresh:  R_BEGDA.
  endif.




  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.

  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_HIGH.

  R_ZHOSPID-SIGN = 'I'.
  R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
  R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
  if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
    R_ZHOSPID-OPTION = 'BT'.
  else.
    R_ZHOSPID-OPTION = 'EQ'.
  endif.
  append R_ZHOSPID.
  if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
    clear: R_ZHOSPID.
    refresh:  R_ZHOSPID.
  endif.


*if ZPMED_SUBMIT-UNAME_HIGH is INITIAL.
*  ZPMED_SUBMIT-UNAME_HIGH = ZPMED_SUBMIT-UNAME_LOW.
*endif.
*if ZPMED_SUBMIT-BEGDA_HIGH is INITIAL.
*  ZPMED_SUBMIT-BEGDA_HIGH = ZPMED_SUBMIT-BEGDA_LOW.
*endif.
*if ZPMED_SUBMIT-ZHOSPID_HIGH is INITIAL.
*  ZPMED_SUBMIT-ZHOSPID_HIGH = ZPMED_SUBMIT-ZHOSPID_LOW.
*endif.

*select * from PA9920
*  into corresponding fields of table IST_9920_SUBMIT
*    where uname between ZPMED_SUBMIT-UNAME_LOW  AND ZPMED_SUBMIT-UNAME_HIGH
*      and BEGDA BETWEEN ZPMED_SUBMIT-BEGDA_LOW AND ZPMED_SUBMIT-BEGDA_HIGH " as YYYYMMDD
*      and ZHOSPID BETWEEN ZPMED_SUBMIT-ZHOSPID_LOW AND ZPMED_SUBMIT-ZHOSPID_HIGH  " as 0000800001
*      and GRPVL = submit_bukrs
*      and ZSTATUS = 'NEW'.

  select * from PA9920
    into corresponding fields of table IST_9920_SUBMIT
      where uname IN R_UNAME
        and BEGDA IN R_BEGDA " as YYYYMMDD
        and ZHOSPID IN R_ZHOSPID  " as 0000800001
        and GRPVL = submit_bukrs
        and ZSTATUS = 'NEW'
        and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or
              SUBTY = '07' ) .

* Begin RD1K981765 CR: 30007609 CAB_ALOK
  Sort IST_9920_SUBMIT by CNTER ASCENDING.
* End RD1K981765 CR: 30007609 CAB_ALOK

** Fill INFTY, serial no.

  loop at IST_9920_SUBMIT into wa_9920_SUBMIT1.
    l_tabix = sy-tabix.
    wa_9920_SUBMIT1-INFTY = '9920'.
    wa_9920_SUBMIT1-serial_no = l_tabix.
    MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT1 INDEX l_tabix.
  endloop.










ENDFORM.                    " GETDATA_IST_9920_SUBMIT

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC_SUBMIT                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC_SUBMIT USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
*     WHEN 'INSR'.                      "insert row
*       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME.
*       CLEAR P_OK.
*
*     WHEN 'DELE'.                      "delete row
*       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME
*                                         P_MARK_NAME.
*       CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

    WHEN 'SBMT'.                      "demark all filled lines

*       PERFORM                USING P_TC_NAME
*                                           P_TABLE_NAME
*                                           P_MARK_NAME .

      PERFORM SUBMIT_0405. " Global IST_9920_SUBMIT


      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC_SUBMIT

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_LINES_NAME       LIKE FELD-NAME.
  DATA L_SELLINE          LIKE SY-STEPL.
  DATA L_LASTLINE         TYPE I.
  DATA L_LINE             TYPE I.
  DATA L_TABLE_NAME       LIKE FELD-NAME.
  FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <LINES>              TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
  ASSIGN (L_LINES_NAME) TO <LINES>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE L_SELLINE.
  IF SY-SUBRC <> 0.                   " append line to table
    L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line                                               *
    IF L_SELLINE > <LINES>.
      <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
    ELSE.
      <TC>-TOP_LINE = 1.
    ENDIF.
  ELSE.                               " insert line into table
    L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
    L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
  <TC>-LINES = <TC>-LINES + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE L_LINE.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME
                       P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    IF <MARK_FIELD> = 'X'.
      DELETE <TABLE> INDEX SYST-TABIX.
      IF SY-SUBRC = 0.
        <TC>-LINES = <TC>-LINES - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                      P_OK.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TC_NEW_TOP_LINE     TYPE I.
  DATA L_TC_NAME             LIKE FELD-NAME.
  DATA L_TC_LINES_NAME       LIKE FELD-NAME.
  DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <LINES>      TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
  ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*&SPWIZARD: is no line filled?                                         *
  IF <TC>-LINES = 0.
*&SPWIZARD: yes, ...                                                   *
    L_TC_NEW_TOP_LINE = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        ENTRY_ACT             = <TC>-TOP_LINE
        ENTRY_FROM            = 1
        ENTRY_TO              = <TC>-LINES
        LAST_PAGE_FULL        = 'X'
        LOOPS                 = <LINES>
        OK_CODE               = P_OK
        OVERLAPPING           = 'X'
      IMPORTING
        ENTRY_NEW             = L_TC_NEW_TOP_LINE
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO           = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS                = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD L_TC_FIELD_NAME
             AREA  L_TC_NAME.

  IF SYST-SUBRC = 0.
    IF L_TC_NAME = P_TC_NAME.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                               P_TABLE_NAME
                               P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                 P_TABLE_NAME
                                 P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  SUBMIT_0405
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TABLE_NAME  text
*----------------------------------------------------------------------*
FORM SUBMIT_0405.
  " Operation on IST_9920_SUBMIT

  DATA: WA_9920_SUBMIT_SEL TYPE TY_SUBMIT,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.

  LOOP AT IST_9920_SUBMIT INTO WA_9920_SUBMIT_SEL WHERE SEL = 'X' AND ZSTATUS = 'NEW'.
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_SUBMIT_SEL to WA_9920_MSG.
    WA_9920_MSG-SPRPS = 'X' .  "to be retained
    WA_9920_MSG-ZSTATUS = 'SUBMITTED' .

*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
*    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
*End RD1K976756  CAB_ALOK
      EXPORTING
        OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
        LOCK_INDICATOR = 'X'
      CHANGING
        WA_9920_MSG    = WA_9920_MSG.
    if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
      WA_9920_MSG-ZSTATUS = 'NEW' .
    endif.
    MOVE-CORRESPONDING WA_9920_MSG to  WA_9920_SUBMIT_SEL.

*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
    " No component exists with the name "SPRPR". .
    " above stmts not working

    MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix.

    CLEAR: WA_9920_SUBMIT_SEL ,
           WA_9920_MSG.

  ENDLOOP.





ENDFORM.                    " SUBMIT_0405
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_0501
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_0501 .

  DATA: submit_pernr TYPE pernr_d.
  DATA: submit_name TYPE emnam.
  DATA: submit_orgeh TYPE orgeh.
  DATA: submit_plans TYPE plans.
  DATA: submit_persa TYPE persa.
  DATA: submit_bukrs TYPE bukrs.


*  PERFORM GETDATA_USER
*       changing submit_pernr submit_name submit_orgeh
*          submit_plans submit_persa submit_bukrs.

  PERFORM GETDATA_IST_9920_UNLOCK tables IST_9920_UNLOCK using G_USER_BUKRS. "submit_bukrs .

ENDFORM.                    " GET_DATA_0501
*&---------------------------------------------------------------------*
*&      Form  GETDATA_IST_9920_UNLOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_9920_UNLOCK  text
*      -->P_SUBMIT_BUKRS  text
*----------------------------------------------------------------------*

* Begin RD1K981765 CR: 30007609 CAB_ALOK
*FORM  GETDATA_IST_9920_UNLOCK   tables IST_9920_UNLOCK using submit_bukrs.
FORM GETDATA_IST_9920_UNLOCK tables IST_9920_UNLOCK STRUCTURE IST_9920_UNLOCK using submit_bukrs.
* End RD1K981765 CR: 30007609 CAB_ALOK
  DATA: wa_9920_SUBMIT1 TYPE ty_submit,
              l_tabix  TYPE sy-tabix.

  data: R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
*   R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE, Now only one vendor in the lot
        R_PERNR TYPE RANGE OF PA9920-PERNR WITH HEADER LINE,
        R_SUBTY TYPE RANGE OF PA9920-SUBTY WITH HEADER LINE .


*** data:  DATE_LOW type sy-datum,
***        DATE_HIGH type sy-datum.


*get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
* and company code of record = comapny code of current user.
* and Status of record = 'NEW'
*Struct.     ZPMED_SUBMIT
*    BEGDA_LOW          20100831
*    BEGDA_HIGH         20100929
*    UNAME_LOW          ABC
*    UNAME_HIGH         X
*    ZHOSPID_LOW        111
*    ZHOSPID_HIGH       222

*** convert dates
**            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
**              EXPORTING
**                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_LOW
**             IMPORTING
**                DDMMYYYY       = DATE_LOW.
**
**            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
**              EXPORTING
**                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_HIGH
**             IMPORTING
**                DDMMYYYY       = DATE_HIGH.

*Put data in range so that 'IN' keyword can be used in SELECT stmt.
  clear:  R_BEGDA,  R_PERNR, R_SUBTY.   "R_ZHOSPID,
  refresh:  R_BEGDA,  R_PERNR, R_SUBTY. "R_ZHOSPID,

  R_BEGDA-SIGN = 'I'.
  R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
  R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
  if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
    R_BEGDA-OPTION = 'BT'.
  else.
    R_BEGDA-OPTION = 'EQ'.
  endif.
  append R_BEGDA.
  if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
    clear: R_BEGDA.
    refresh:  R_BEGDA.
  endif.


  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.

*   CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
*      CHANGING
*         VENDOR        = ZPMED_SUBMIT-ZHOSPID_HIGH.
*
*R_ZHOSPID-SIGN = 'I'.
*R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
*R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
*if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
*  R_ZHOSPID-OPTION = 'BT'.
*else.
*  R_ZHOSPID-OPTION = 'EQ'.
*endif.
*append R_ZHOSPID.
*if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
*  clear: R_ZHOSPID.
*  refresh:  R_ZHOSPID.
*endif.


  R_PERNR-SIGN = 'I'.
  R_PERNR-LOW = ZPMED_SUBMIT-PERNR_LOW.
  R_PERNR-HIGH = ZPMED_SUBMIT-PERNR_HIGH.
  if R_PERNR-LOW is NOT INITIAL and  R_PERNR-HIGH is NOT INITIAL.
    R_PERNR-OPTION = 'BT'.
  else.
    R_PERNR-OPTION = 'EQ'.
  endif.
  append R_PERNR.
  if R_PERNR-LOW is INITIAL and  R_PERNR-HIGH is INITIAL.
    clear: R_PERNR.
    refresh:  R_PERNR.
  endif.

  R_SUBTY-SIGN = 'I'.
  R_SUBTY-LOW = ZPMED_SUBMIT-SUBTY_LOW.
  R_SUBTY-HIGH = ZPMED_SUBMIT-SUBTY_HIGH.
  if R_SUBTY-LOW is NOT INITIAL and  R_SUBTY-HIGH is NOT INITIAL.
    R_SUBTY-OPTION = 'BT'.
  else.
    R_SUBTY-OPTION = 'EQ'.
  endif.
  append R_SUBTY.
  if R_SUBTY-LOW is INITIAL and  R_SUBTY-HIGH is INITIAL.
    clear: R_SUBTY.
    refresh:  R_SUBTY.
  endif.

*if ZPMED_SUBMIT-UNAME_HIGH is INITIAL.
*  ZPMED_SUBMIT-UNAME_HIGH = ZPMED_SUBMIT-UNAME_LOW.
*endif.
*if ZPMED_SUBMIT-BEGDA_HIGH is INITIAL.
*  ZPMED_SUBMIT-BEGDA_HIGH = ZPMED_SUBMIT-BEGDA_LOW.
*endif.
*if ZPMED_SUBMIT-ZHOSPID_HIGH is INITIAL.
*  ZPMED_SUBMIT-ZHOSPID_HIGH = ZPMED_SUBMIT-ZHOSPID_LOW.
*endif.

  select * from PA9920
    into corresponding fields of table IST_9920_UNLOCK
      where BEGDA IN R_BEGDA " as YYYYMMDD
        "and ZHOSPID IN R_ZHOSPID  " as 0000800001, Single vendor Lot
        and ZHOSPID = ZPMED_SUBMIT-ZHOSPID_LOW
        and PERNR IN R_PERNR
        and SUBTY IN R_SUBTY
        and GRPVL = submit_bukrs
        and ZSTATUS = 'SUBMITTED'
        and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' )
        order by PERNR .

* Begin RD1K981765 CR: 30007609 CAB_ALOK
  Sort IST_9920_UNLOCK by CNTER ASCENDING.
* End RD1K981765 CR: 30007609 CAB_ALOK

** Fill INFTY, serial no., MO_AMOUNT
*  sort IST_9920_UNLOCK by pernr ASCENDING.
  loop at IST_9920_UNLOCK into wa_9920_SUBMIT1.
    l_tabix = sy-tabix.
    wa_9920_SUBMIT1-INFTY = '9920'.
    wa_9920_SUBMIT1-serial_no = l_tabix.
    if wa_9920_SUBMIT1-ztax = 'X'.
      wa_9920_SUBMIT1-taxable = 'Y'.
    elseif wa_9920_SUBMIT1-znontax = 'X'.
      wa_9920_SUBMIT1-taxable = 'N'.
    else.
      wa_9920_SUBMIT1-taxable = 'B'.
    endif.
    if WA_9920_SUBMIT1-ZAMTMOTOTAL is initial.
      WA_9920_SUBMIT1-ZAMTMOTOTAL = wa_9920_SUBMIT1-ZAMOUNT.
      "otherwise display ZAMTMOTOTAL value saved after editing by MO.
    endif.
    MODIFY IST_9920_UNLOCK FROM  WA_9920_SUBMIT1 INDEX l_tabix.
  endloop.

*begin RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
  clear G_VENDOR_NAME.
  select single NAME1 from ZHR_MED_VENDORS   " BUKRS, LIFNR
    into  G_VENDOR_NAME
      where BUKRS = P9920-GRPVL
        and LIFNR = ZPMED_SUBMIT-ZHOSPID_LOW.
*end RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
ENDFORM.                    " GETDATA_IST_9920_UNLOCK

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC_UNLOCK                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC_UNLOCK USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*   Clear: SAVE_OK_CODE_0505.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
*     WHEN 'INSR'.                      "insert row
*       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME.
*       CLEAR P_OK.
*
*     WHEN 'DELE'.                      "delete row
*       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME
*                                         P_MARK_NAME.
*       CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.
    WHEN 'UNLOCK'.                      "UNLOCK selected lines

      PERFORM UNLOCK_0505. " on Global IST_9920_UNLOCK

      CLEAR P_OK.

    WHEN 'REJMO'.                      "Reject(by MO) selected lines

      PERFORM REJMO_0505. " on Global IST_9920_UNLOCK

      CLEAR P_OK.

    WHEN 'EDITMO'.                      "EDIT(by MO) selected lines

*       PERFORM EDITMO_0505. " on Global IST_9920_UNLOCK
      G_FLAG_EDITMO = 'X'.
      CLEAR: G_FLAG_SAVEMO.

*       SAVE_OK_CODE_0505 = OK_CODE_0505.
      CLEAR P_OK.

    WHEN 'SAVEMO'.                      "SAVE(by MO) selected lines
      G_FLAG_SAVEMO = 'X'.
      CLEAR: G_FLAG_EDITMO.

*       SAVE_OK_CODE_0505 = OK_CODE_0505.
      PERFORM SAVEMO_0505. " on Global IST_9920_UNLOCK
      CLEAR P_OK.

* begin RD1K978193 CAB_ALOK CR 30006378
    WHEN 'SRCH'.                      "Reject(by MO) selected lines
      PERFORM SEARCH. " on Global IST_9920_UNLOCK
      CLEAR P_OK.
* end RD1K978193 CAB_ALOK CR 30006378

  ENDCASE.

ENDFORM.                              " USER_OK_TC_UNLOCK
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_0505
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNLOCK_0505 .
  " Operation on IST_9920_UNLOCK
  DATA: WA_9920_UNLOCK_SEL TYPE TY_SUBMIT,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.
  DATA: L_ZLOT_NO TYPE p9920-ZLOT_NO,
        l_check type c.

  clear L_CHECK .
  LOOP AT IST_9920_UNLOCK INTO WA_9920_UNLOCK_SEL WHERE SEL = 'X' AND ZSTATUS = 'SUBMITTED'.

    if WA_9920_UNLOCK_SEL-taxable = 'Y' or WA_9920_UNLOCK_SEL-taxable = 'N'.
    else.
      L_CHECK = 'F'. "Fail
      WA_9920_UNLOCK_SEL-message = 'Specify Amount is Taxable or not'.
      MODIFY IST_9920_UNLOCK   FROM  WA_9920_UNLOCK_SEL INDEX sy-tabix.

      message s000(zmsg) with 'Specify Amount is Taxable or not'.
    endif.

    CLEAR: WA_9920_UNLOCK_SEL .
  ENDLOOP.

  if l_check = 'F'.
  else.
    clear: L_ZLOT_NO.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '02'
        object                  = 'ZHR_MED'
      IMPORTING
        number                  = L_ZLOT_NO
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc NE 0.
      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
            WITH 'Can not process, Error in counter generation'.
    ENDIF.


    LOOP AT IST_9920_UNLOCK INTO WA_9920_UNLOCK_SEL WHERE SEL = 'X' AND ZSTATUS = 'SUBMITTED'.
      l_tabix =   sy-tabix .
      MOVE-CORRESPONDING WA_9920_UNLOCK_SEL to WA_9920_MSG.
      WA_9920_MSG-SPRPS = '' .  "to be changed from X to ''
      WA_9920_MSG-ZLOT_NO = L_ZLOT_NO .  "
      WA_9920_MSG-ZSTATUS = 'UNLOCKED' .

*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
*    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
      CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
*End RD1K976756  CAB_ALOK
        EXPORTING
          OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
          LOCK_INDICATOR = 'X'
        CHANGING
          WA_9920_MSG    = WA_9920_MSG.
      if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
        WA_9920_MSG-SPRPS = 'X' .
        WA_9920_MSG-ZLOT_NO = ''.
        WA_9920_MSG-ZSTATUS = 'SUBMITTED' .
      endif.
      MOVE-CORRESPONDING WA_9920_MSG to WA_9920_UNLOCK_SEL.

*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
      " No component exists with the name "SPRPR". .
      " above stmts not working

      MODIFY IST_9920_UNLOCK  FROM  WA_9920_UNLOCK_SEL INDEX l_tabix.

      CLEAR: WA_9920_UNLOCK_SEL ,
             WA_9920_MSG.

    ENDLOOP.
  endif.
ENDFORM.                    " UNLOCK_0505
*&---------------------------------------------------------------------*
*&      Form  REJMO_0505
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REJMO_0505 .
  " Operation on IST_9920_UNLOCK
  DATA: WA_9920_UNLOCK_SEL TYPE TY_SUBMIT,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.

  LOOP AT IST_9920_UNLOCK INTO WA_9920_UNLOCK_SEL WHERE SEL = 'X' AND ZSTATUS = 'SUBMITTED'.
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_UNLOCK_SEL to WA_9920_MSG.
    WA_9920_MSG-SPRPS = 'X' .  "to be retained
    WA_9920_MSG-ZSTATUS = 'REJMO' .

*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
*    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
*End RD1K976756  CAB_ALOK
      EXPORTING
        OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
        LOCK_INDICATOR = 'X'
      CHANGING
        WA_9920_MSG    = WA_9920_MSG.
    if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
      WA_9920_MSG-SPRPS = 'X' .
      WA_9920_MSG-ZSTATUS = 'SUBMITTED' .
    endif.
    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_UNLOCK_SEL.

*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
    " No component exists with the name "SPRPR". .
    " above stmts not working

    MODIFY IST_9920_UNLOCK  FROM  WA_9920_UNLOCK_SEL INDEX l_tabix.

    CLEAR: WA_9920_UNLOCK_SEL ,
           WA_9920_MSG.

  ENDLOOP.
ENDFORM.                    " REJMO_0505
*&---------------------------------------------------------------------*
*&      Form  SAVEMO_0505
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVEMO_0505 .

  " Operation on IST_9920_UNLOCK
  DATA: WA_9920_UNLOCK_SEL TYPE TY_SUBMIT,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.


  LOOP AT IST_9920_UNLOCK INTO WA_9920_UNLOCK_SEL WHERE SEL = 'X' AND ZSTATUS = 'SUBMITTED'.
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_UNLOCK_SEL to WA_9920_MSG.

    if WA_9920_UNLOCK_SEL-taxable = 'Y'.
      WA_9920_MSG-ztax = 'X'.
      clear WA_9920_MSG-znontax.
    elseif WA_9920_UNLOCK_SEL-taxable = 'N'.
      WA_9920_MSG-znontax = 'X'.
      clear WA_9920_MSG-ztax.
    elseif WA_9920_UNLOCK_SEL-taxable = 'B'.
      clear: WA_9920_MSG-znontax , WA_9920_MSG-ztax.
    endif.


    WA_9920_MSG-SPRPS = 'X' .  "to be retained
    WA_9920_MSG-ZSTATUS = 'SUBMITTED' .  "to be retained
    " only WA_9920_MSG-ZAMTMOTOTAL & WA_9920_MSG-ZREMARKSMO will be updated in PA9920

*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
*    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
*End RD1K976756  CAB_ALOK
      EXPORTING
        OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
        LOCK_INDICATOR = 'X'
      CHANGING
        WA_9920_MSG    = WA_9920_MSG.
*if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
*   WA_9920_MSG-SPRPS = 'X' .
*   WA_9920_MSG-ZSTATUS = 'SUBMITTED' .
*endif.

    if WA_9920_MSG-ERROR_FLAG <> '1'. "if update Operation successful, then modify the Message
      WA_9920_MSG-MESSAGE = 'Saved '.  " otherwise this message contains 'Status: submitted'
    endif.


    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_UNLOCK_SEL.

*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
    " No component exists with the name "SPRPR". .
    " above stmts not working

    MODIFY IST_9920_UNLOCK  FROM  WA_9920_UNLOCK_SEL INDEX l_tabix.
    CLEAR: WA_9920_UNLOCK_SEL ,
           WA_9920_MSG.

  ENDLOOP.






ENDFORM.                    " SAVEMO_0505
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_0301
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_0301 .
  DATA: submit_pernr TYPE pernr_d.
  DATA: submit_name TYPE emnam.
  DATA: submit_orgeh TYPE orgeh.
  DATA: submit_plans TYPE plans.
  DATA: submit_persa TYPE persa.
  DATA: submit_bukrs TYPE bukrs.
*data: IST_9920_SUBMIT type table of PA9920.

*  PERFORM GETDATA_USER
*       changing submit_pernr submit_name submit_orgeh
*          submit_plans submit_persa submit_bukrs.

  PERFORM GETDATA_IST_9920_EDIT tables IST_9920_EDIT using G_USER_BUKRS. "submit_bukrs .


ENDFORM.                    " GET_DATA_0301
*&---------------------------------------------------------------------*
*&      Form  GETDATA_IST_9920_EDIT_REJECTED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_9920_SUBMIT  text
*      -->P_SUBMIT_BUKRS  text
*----------------------------------------------------------------------*


* Begin RD1K981765 CR: 30007609 CAB_ALOK
*FORM GETDATA_IST_9920_EDIT  tables IST_9920_EDIT   using submit_bukrs.
FORM GETDATA_IST_9920_EDIT  tables IST_9920_EDIT STRUCTURE IST_9920_EDIT using submit_bukrs.
* End RD1K981765 CR: 30007609 CAB_ALOK
  DATA: wa_9920_SUBMIT1 TYPE ty_submit,
              l_tabix  TYPE sy-tabix.

  data: R_UNAME TYPE RANGE OF PA9920-UNAME WITH HEADER LINE,
        R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
        R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE .


*** data:  DATE_LOW type sy-datum,
***        DATE_HIGH type sy-datum.


*get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
* and company code of record = comapny code of current user.
* and Status of record = 'NEW'
*Struct.     ZPMED_SUBMIT
*    BEGDA_LOW          20100831
*    BEGDA_HIGH         20100929
*    UNAME_LOW          ABC
*    UNAME_HIGH         X
*    ZHOSPID_LOW        111
*    ZHOSPID_HIGH       222

*** convert dates
**            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
**              EXPORTING
**                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_LOW
**             IMPORTING
**                DDMMYYYY       = DATE_LOW.
**
**            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
**              EXPORTING
**                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_HIGH
**             IMPORTING
**                DDMMYYYY       = DATE_HIGH.

*Put data in range so that 'IN' keyword can be used in SELECT stmt.
  clear: R_UNAME, R_BEGDA, R_ZHOSPID.
  refresh: R_UNAME, R_BEGDA, R_ZHOSPID.

  R_UNAME-SIGN = 'I'.
  R_UNAME-LOW = ZPMED_SUBMIT-UNAME_LOW.
  R_UNAME-HIGH = ZPMED_SUBMIT-UNAME_HIGH.
  if R_UNAME-LOW is NOT INITIAL and  R_UNAME-HIGH is NOT INITIAL.
    R_UNAME-OPTION = 'BT'.
  else.
    R_UNAME-OPTION = 'EQ'.
  endif.
  append R_UNAME.
  if R_UNAME-LOW is INITIAL and  R_UNAME-HIGH is INITIAL.
    clear: R_UNAME.
    refresh:  R_UNAME.
  endif.

  R_BEGDA-SIGN = 'I'.
  R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
  R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
  if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
    R_BEGDA-OPTION = 'BT'.
  else.
    R_BEGDA-OPTION = 'EQ'.
  endif.
  append R_BEGDA.
  if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
    clear: R_BEGDA.
    refresh:  R_BEGDA.
  endif.


  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.

  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_HIGH.

  R_ZHOSPID-SIGN = 'I'.
  R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
  R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
  if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
    R_ZHOSPID-OPTION = 'BT'.
  else.
    R_ZHOSPID-OPTION = 'EQ'.
  endif.
  append R_ZHOSPID.
  if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
    clear: R_ZHOSPID.
    refresh:  R_ZHOSPID.
  endif.


*if ZPMED_SUBMIT-UNAME_HIGH is INITIAL.
*  ZPMED_SUBMIT-UNAME_HIGH = ZPMED_SUBMIT-UNAME_LOW.
*endif.
*if ZPMED_SUBMIT-BEGDA_HIGH is INITIAL.
*  ZPMED_SUBMIT-BEGDA_HIGH = ZPMED_SUBMIT-BEGDA_LOW.
*endif.
*if ZPMED_SUBMIT-ZHOSPID_HIGH is INITIAL.
*  ZPMED_SUBMIT-ZHOSPID_HIGH = ZPMED_SUBMIT-ZHOSPID_LOW.
*endif.

*select * from PA9920
*  into corresponding fields of table IST_9920_SUBMIT
*    where uname between ZPMED_SUBMIT-UNAME_LOW  AND ZPMED_SUBMIT-UNAME_HIGH
*      and BEGDA BETWEEN ZPMED_SUBMIT-BEGDA_LOW AND ZPMED_SUBMIT-BEGDA_HIGH " as YYYYMMDD
*      and ZHOSPID BETWEEN ZPMED_SUBMIT-ZHOSPID_LOW AND ZPMED_SUBMIT-ZHOSPID_HIGH  " as 0000800001
*      and GRPVL = submit_bukrs
*      and ZSTATUS = 'NEW'.

  select * from PA9920
    into corresponding fields of table IST_9920_EDIT
      where uname IN R_UNAME
        and BEGDA IN R_BEGDA " as YYYYMMDD
        and ZHOSPID IN R_ZHOSPID  " as 0000800001
        and GRPVL = submit_bukrs  " company code of the current user
        and ( ZSTATUS = 'REJMO' or ZSTATUS = 'REJFI' )
        and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' )
        order by pernr .

* Begin RD1K981765 CR: 30007609 CAB_ALOK
  Sort IST_9920_EDIT by CNTER ASCENDING.
* End RD1K981765 CR: 30007609 CAB_ALOK


** Fill INFTY, serial no.

  loop at IST_9920_EDIT into wa_9920_SUBMIT1.
    l_tabix = sy-tabix.
    wa_9920_SUBMIT1-INFTY = '9920'.
    wa_9920_SUBMIT1-ZLOT_No = ''.
    wa_9920_SUBMIT1-serial_no = l_tabix.
    MODIFY IST_9920_EDIT  FROM  WA_9920_SUBMIT1 INDEX l_tabix.
  endloop.


ENDFORM.                    " GETDATA_IST_9920_EDIT_REJECTED

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC_EDIT                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC_EDIT USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
*     WHEN 'INSR'.                      "insert row
*       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME.
*       CLEAR P_OK.
*
*     WHEN 'DELE'.                      "delete row
*       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME
*                                         P_MARK_NAME.
*       CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

    WHEN 'EDITDO'.                      "EDIT(by DO) selected lines

      G_FLAG_EDITDO = 'X'.
      CLEAR: G_FLAG_SAVEDO.

      CLEAR P_OK.

    WHEN 'SAVEDO'.                      "SAVE(by DO) selected lines
      G_FLAG_SAVEDO = 'X'.
      CLEAR: G_FLAG_EDITDO.
      PERFORM SAVEDO_0305. " on Global IST_9920_EDIT
      CLEAR P_OK.

* begin RD1K978193 CAB_ALOK CR 30006378
    WHEN 'SRCH'.                      "Reject(by MO) selected lines
      PERFORM SEARCH. " on Global IST_9920_EDIT
      CLEAR P_OK.
* end RD1K978193 CAB_ALOK CR 30006378

  ENDCASE.

ENDFORM.                              " USER_OK_TC_EDIT
*&---------------------------------------------------------------------*
*&      Form  SAVEDO_0305
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVEDO_0305 .

  " Operation on IST_9920_UNLOCK
  DATA: WA_9920_EDIT_SEL TYPE TY_SUBMIT,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.

  DATA: VALIDATION_MSG type ZCHAR_MAX,                      "255 char
        ERROR_FLAG type CHAR1,
        l_tabix_val  TYPE sy-tabix.

  data: SAVE_ZSTATUS type ZHR_MEDPYMT_9920_MSG-ZSTATUS ,
        SAVE_SPRPS type ZHR_MEDPYMT_9920_MSG-SPRPS.
*begin RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
  data: SAVE_ZAMTMOTOTA type ZHR_MEDPYMT_9920_MSG-ZAMTMOTOTAL.
*end RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
  LOOP AT IST_9920_EDIT INTO WA_9920_EDIT_SEL WHERE SEL = 'X' AND ( ZSTATUS = 'REJMO' or ZSTATUS = 'REJFI' ).
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_EDIT_SEL to WA_9920_MSG.
    SAVE_ZSTATUS = WA_9920_MSG-ZSTATUS .
    SAVE_SPRPS   = WA_9920_MSG-SPRPS.
    WA_9920_MSG-SPRPS = 'X' .  " new status will be 'NEW', so SPRPS = 'X'
    WA_9920_MSG-ZSTATUS = 'NEW' .  " to be changed from 'REJ*' to 'NEW'
*begin RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
    SAVE_ZAMTMOTOTA = WA_9920_MSG-ZAMTMOTOTAL.
    WA_9920_MSG-ZAMTMOTOTAL = WA_9920_MSG-ZAMOUNT.
*end RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
* Modified fields of WA_9920_MSG  will be updated in PA9920
* VALIDATE the record before updation
    clear: P9920, ERROR_FLAG , VALIDATION_MSG.
    MOVE-CORRESPONDING WA_9920_MSG to P9920.
    CALL FUNCTION 'ZHR_MED_PYMT9920_VALIDATE_FILL'
      IMPORTING
        VALIDATION_MSG = VALIDATION_MSG
        ERROR_FLAG     = ERROR_FLAG
      CHANGING
        P9920          = P9920.

    if ERROR_FLAG = '1'.  " validation failed

      WA_9920_MSG-ERROR_FLAG = ERROR_FLAG.
      WA_9920_MSG-MESSAGE = VALIDATION_MSG.
      "if validation failed, then reset the status & sprps
      WA_9920_MSG-SPRPS   = SAVE_SPRPS .
      WA_9920_MSG-ZSTATUS = SAVE_ZSTATUS .
*begin RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
      WA_9920_MSG-ZAMTMOTOTAL = SAVE_ZAMTMOTOTA .
*end RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
    else.  " Validation OK, now update PA9920

      WA_9920_MSG-ZHOSPID = P9920-ZHOSPID.
      WA_9920_MSG-ZBILL_NO = P9920-ZBILL_NO.

*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
*    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
      CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
*End RD1K976756  CAB_ALOK
          EXPORTING
            OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
            LOCK_INDICATOR = 'X'
          CHANGING
            WA_9920_MSG    = WA_9920_MSG.

      if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status & sprps
        WA_9920_MSG-SPRPS   = SAVE_SPRPS .
        WA_9920_MSG-ZSTATUS = SAVE_ZSTATUS .
*begin RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
        WA_9920_MSG-ZAMTMOTOTAL = SAVE_ZAMTMOTOTA .
*end RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
      endif.

    endif.  " /ERROR_FLAG = '1'.

    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_EDIT_SEL.

*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
    " No component exists with the name "SPRPR". .
    " above stmts not working

    MODIFY IST_9920_EDIT  FROM  WA_9920_EDIT_SEL INDEX l_tabix.
    CLEAR: WA_9920_EDIT_SEL ,
           WA_9920_MSG,
           P9920.

  ENDLOOP.



ENDFORM.                    " SAVEDO_0305
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_0601
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_0601 .
  DATA: submit_pernr TYPE pernr_d.
  DATA: submit_name TYPE emnam.
  DATA: submit_orgeh TYPE orgeh.
  DATA: submit_plans TYPE plans.
  DATA: submit_persa TYPE persa.
  DATA: submit_bukrs TYPE bukrs.

*  PERFORM GETDATA_USER
*       changing submit_pernr submit_name submit_orgeh
*          submit_plans submit_persa submit_bukrs.

  PERFORM GETDATA_IST_9920_PAY tables IST_9920_PAY using G_USER_BUKRS. "submit_bukrs .



ENDFORM.                    " GET_DATA_0601
*&---------------------------------------------------------------------*
*&      Form  GETDATA_IST_9920_PAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_9920_PAY  text
*      -->P_SUBMIT_BUKRS  text
*----------------------------------------------------------------------*

* Begin RD1K981765 CR: 30007609 CAB_ALOK
*FORM  GETDATA_IST_9920_PAY  tables IST_9920_PAY using submit_bukrs.
FORM GETDATA_IST_9920_PAY  tables IST_9920_PAY STRUCTURE IST_9920_PAY using submit_bukrs.
* End RD1K981765 CR: 30007609 CAB_ALOK
  DATA: wa_9920_PAY1 TYPE ty_pay,
               l_tabix  TYPE sy-tabix.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = ZPMED_SUBMIT-ZLOT_NO_LOW
    IMPORTING
      OUTPUT = ZPMED_SUBMIT-ZLOT_NO_LOW.

  select * from PA9920
    into corresponding fields of table IST_9920_PAY
      where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
        and GRPVL = submit_bukrs
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
*        and ZSTATUS = 'UNLOCKED'
        and ( ZSTATUS = 'UNLOCKED' or ZSTATUS = 'REVERSED' )
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
        and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07') .

* Begin RD1K981765 CR: 30007609 CAB_ALOK
  Sort IST_9920_PAY by CNTER ASCENDING.
* End RD1K981765 CR: 30007609 CAB_ALOK

** Fill INFTY, serial no., MO_AMOUNT
  loop at IST_9920_PAY into wa_9920_PAY1.
    l_tabix = sy-tabix.
    wa_9920_PAY1-INFTY = '9920'.
    wa_9920_PAY1-serial_no = l_tabix.

*Begin of <RD1K994929> cab_pareek  17.10.2014
* instead of taxable status stored at bill creation it is now
* checking for status in vendor table
*    if wa_9920_PAY1-ztax = 'X'.
*      wa_9920_PAY1-taxable = 'Y'.
*    elseif wa_9920_PAY1-znontax = 'X'.
*      wa_9920_PAY1-taxable = 'N'.
*    else.
*      wa_9920_PAY1-taxable = 'B'.
*    endif.
    data l_vendors type ZHR_MED_VENDORS.
    select single * from ZHR_MED_VENDORS into l_vendors where
                                      lifnr = wa_9920_PAY1-zhospid and
                                      taxable = 'N'.
    if sy-subrc = 0.
      wa_9920_PAY1-taxable = 'N'.
    else.
      wa_9920_PAY1-taxable = 'Y'.
    endif.

*End of <RD1K994929> cab_pareek  17.10.2014

    WA_9920_PAY1-ZAMTPCSTOTAL = WA_9920_PAY1-ZAMTMOTOTAL.
    MODIFY IST_9920_PAY FROM  WA_9920_PAY1 INDEX l_tabix.
  endloop.

ENDFORM.                    " GETDATA_IST_9920_PAY

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC_PAY                                              *
*&---------------------------------------------------------------------*
FORM USER_OK_TC_PAY USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

  data: TEST_FLAG(1) ,
        L_GLAC type char10 ,
        L_FISCAL_YEAR(4) TYPE C ,
        l_bukrs type bukrs.


*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
*     WHEN 'INSR'.                      "insert row
*       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME.
*       CLEAR P_OK.
*
*     WHEN 'DELE'.                      "delete row
*       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME
*                                         P_MARK_NAME.
*       CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.
    WHEN 'TEST'.
      TEST_FLAG = 'T'.
      PERFORM PAY_0605 using TEST_FLAG.
      CLEAR P_OK.
*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
    WHEN 'CHECK'.
      PERFORM LEVEL_1_CHECK_0605.
      CLEAR P_OK.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP

    WHEN 'PAY'.                      " applicable on selected lines

      " chnages frm here by Swetha

*  Loop at ist_9920_pay into wa_9920_pay .
*            if WA_9920_PAY-SUBTY = '05'.
*              L_GLAC = '0000200301'.
*            elseif ( WA_9920_PAY-SUBTY = '03' or WA_9920_PAY-SUBTY = '06' ).
*              L_GLAC = '0000200308'.
*            elseif WA_9920_PAY-SUBTY = '04'.
*              L_GLAC = '0000200309'.
*            endif.
*
*             CLEAR: l_persk, l_persg, L_GLAC .
*        SELECT SINGLE persk persg           " bukrs
*              FROM pa0001
*              INTO (l_persk, l_persg)       " , L_BUKRS
*                WHERE pernr = WA_9920_PAY-PERNR
*                 AND begda =< sy-datum
*                 AND endda >= sy-datum.
*
*        if sy-subrc = 0.
*          if   l_persg = '2'
*            or l_persg = 'B' .    " Retd. Employee
*
*            if WA_9920_PAY-SUBTY = '05'.
*              L_GLAC = '0000200301'.
*            elseif ( WA_9920_PAY-SUBTY = '03' or WA_9920_PAY-SUBTY = '06' ).
*              L_GLAC = '0000200308'.
*            elseif WA_9920_PAY-SUBTY = '04'.
*              L_GLAC = '0000200309'.
*            endif.
*
*          elseif l_persg = '1' " Activ. Employee (Officer + Staff)
*              or l_persg = '7'
*              or l_persg = '8'
*              or l_persg = '9'
*              or l_persg = 'A'
*              or l_persg = 'G'
*              or l_persg = 'S'.
*            " now determine whether Officer or Staff
*            if   l_persk = 'C'    " => officer
*              or l_persk = 'D'
*              or l_persk = 'E0'
*              or l_persk = 'E1'
*              or l_persk = 'E2'
*              or l_persk = 'E3'
*              or l_persk = 'E4'
*              or l_persk = 'E5'
*              or l_persk = 'E6'
*              or l_persk = 'E7'
*              or l_persk = 'E8'
*              or l_persk = 'E9'
*              or l_persk = 'GT'.
*
*              if WA_9920_PAY-SUBTY = '05'.
*                L_GLAC = '0000200301'.
*              elseif ( WA_9920_PAY-SUBTY = '03' or WA_9920_PAY-SUBTY = '06' ).
*                L_GLAC = '0000200307'.
*              elseif WA_9920_PAY-SUBTY = '04'.
*                L_GLAC = '0000200302'.
*              endif.    "//officer
*
*            elseif l_persk = 'A1'    " => Staff
*                or l_persk = 'A2'
*                or l_persk = 'A3'
*                or l_persk = 'A4'
*                or l_persk = 'S1'
*                or l_persk = 'S2'
*                or l_persk = 'S3'
*                or l_persk = 'S4'
*                or l_persk = 'TC'
*                or l_persk = 'W1'
*                or l_persk = 'W2'
*                or l_persk = 'W3'
*                or l_persk = 'W4'
*                or l_persk = 'W5'
*                or l_persk = 'W6'
*                or l_persk = 'W7'.
*
*              if WA_9920_PAY-SUBTY = '05'.
*                L_GLAC = '0000200301'.
*              elseif ( WA_9920_PAY-SUBTY = '03' or WA_9920_PAY-SUBTY = '06' ).
*                L_GLAC = '0000200318'.
*              elseif WA_9920_PAY-SUBTY = '04'.
*                L_GLAC = '0000200317'.
*              endif.
*            endif. "//staff
*          elseif l_persg = 'C'.
*
*            if l_persk = 'C1'    " => Contingent worker
*                 or l_persk = 'C2'
*                 or l_persk = 'C3'.
*              L_GLAC = '0000200350'.
*            endif.
*
*          endif.
*        endif. "sy-subrc  " // GL Account logic.
*
*
*
*       CALL FUNCTION 'GM_GET_FISCAL_YEAR'
*        EXPORTING
*          I_DATE    = G_BUDAT
*          i_fyv     = 'V3'
*        IMPORTING
*          E_FY      = L_FISCAL_YEAR .
*
*
*    SELECT SINGLE BUKRS FROM PA0001 INTO L_BUKRS WHERE pernr = sy-uname
*        and begda <= sy-datum and endda >= sy-datum .
*
*    Refresh ist_zhrhospsanction.
*    Select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction
*       where BUKRS = L_BUKRS and GLHEAD = L_GLAC
*           and GJAHR = L_FISCAL_YEAR.
*     Clear t_amt.
*      Loop at ist_zhrhospsanction into wa_zhrhospsanction.
*        t_amt = t_amt + wa_zhrhospsanction-amt.
*      Endloop.
*
*
*    select single * from zhrhospsanc_utl into  wa_zhrhospsanc_utl
*         where BUKRS = L_BUKRS and GLHEAD = L_GLAC
*           and GJAHR = L_FISCAL_YEAR.
*      If sy-subrc = 0.
*        wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + WA_9920_PAY-ZAMTPCSTOTAL.
*        t_amt1 = t_amt *   8 / 10 .
*        If wa_zhrhospsanc_utl-utilamt > t_amt .
*          Message e023(ZHR) .
*
*        ElseIf wa_zhrhospsanc_utl-utilamt >=  t_amt1.
*          Message i025(ZHR) .
*        Endif.
*        wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
*        wa_zhrhospsanc_utl-amt = t_amt.
*        Modify zhrhospsanc_utl from wa_zhrhospsanc_utl .
*        Commit Work.
*      Else.
*        If t_amt <> 0  and t_amt is not initial.
*          If WA_9920_PAY-ZAMTPCSTOTAL > t_amt.
*            Message e023(ZHR) .
*          Else.
*          wa_zhrhospsanc_utl-BUKRS = L_BUKRS .
*          wa_zhrhospsanc_utl-GLHEAD = L_GLAC .
*          wa_zhrhospsanc_utl-GJAHR = L_FISCAL_YEAR.
*          wa_zhrhospsanc_utl-amt = t_amt.
*          wa_zhrhospsanc_utl-utilamt = WA_9920_PAY-ZAMTPCSTOTAL.
*          wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
*          Insert into zhrhospsanc_utl values wa_zhrhospsanc_utl.
*          Commit Work.
*          Endif.
*        Else.
*          Message e027(ZHR) .
*        Endif.
*      Endif.

*Endloop.

*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
      data: FLAG_LEVEL_2_CHECK(1).
      FLAG_LEVEL_2_CHECK = 'T'.
      PERFORM LEVEL_2_CHECK_0605 CHANGING FLAG_LEVEL_2_CHECK.
      if FLAG_LEVEL_2_CHECK = 'T'.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
        TEST_FLAG = 'P'.
        PERFORM PAY_0605 using TEST_FLAG. " on Global IST_9920_PAY
*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
      endif. "//if FLAG_LEVEL_2_CHECK = 'X'.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP

      CLEAR P_OK.

    WHEN 'REJFI'.                      "Reject(by Finance) selected lines

      PERFORM REJFI_0605. " on Global IST_9920_PAY

      CLEAR P_OK.

    WHEN 'EDITFI'.                      "EDIT(by Finance) selected lines

      G_FLAG_EDITFI = 'X'.
      CLEAR: G_FLAG_SAVEFI.
      CLEAR P_OK.

    WHEN 'SAVEFI'.                      "SAVE(by Finance) selected lines
      G_FLAG_SAVEFI = 'X'.
      CLEAR: G_FLAG_EDITFI.

      PERFORM SAVEFI_0605. " on Global IST_9920_PAY
      CLEAR P_OK.
  ENDCASE.


ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  REJFI_0605
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REJFI_0605 .
  " Operation on IST_9920_PAY
  DATA: WA_9920_PAY_SEL TYPE TY_PAY,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
  DATA: SAVE_CHECKED_BY_PERNR type PERNR,
        SAVE_CHECKED_BY_LEVEL type PERSK.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
  LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_9920_MSG.

    WA_9920_MSG-ZSTATUS = 'REJFI' .
    WA_9920_MSG-SPRPS = 'X' .  "to be set to 'X' as the record is being rejected
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
* clear CHECKED_BY_PERNR and CHECKED_BY_LEVEL in the Rejected record
    SAVE_CHECKED_BY_PERNR = WA_9920_MSG-CHECKED_BY_PERNR. "temp save
    SAVE_CHECKED_BY_LEVEL = WA_9920_MSG-CHECKED_BY_LEVEL. "temp save
    Clear: WA_9920_MSG-CHECKED_BY_PERNR,
           WA_9920_MSG-CHECKED_BY_LEVEL.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
*    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
*End RD1K976756  CAB_ALOK
      EXPORTING
        OPERATION_TYPE = 'MOD' "OPERATION of HR_INFOTYPE_OPERATION
        LOCK_INDICATOR = ' '   "current value of lockindicator
      CHANGING
        WA_9920_MSG    = WA_9920_MSG.
    if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation fails, then set the status back to original
      WA_9920_MSG-SPRPS = ' ' .
      WA_9920_MSG-ZSTATUS = 'UNLOCKED' .
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
* Set CHECKED_BY_PERNR and CHECKED_BY_LEVEL back to original.
      WA_9920_MSG-CHECKED_BY_PERNR = SAVE_CHECKED_BY_PERNR.
      WA_9920_MSG-CHECKED_BY_LEVEL = SAVE_CHECKED_BY_LEVEL.
    endif.
    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL.

*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
    " No component exists with the name "SPRPR". .
    " above stmts not working

    MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.

    CLEAR: WA_9920_PAY_SEL ,
           WA_9920_MSG.

  ENDLOOP.


ENDFORM.                    " REJFI_0605
*&---------------------------------------------------------------------*
*&      Form  SAVEFI_0605
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVEFI_0605 .
  " Operation on IST_9920_PAY
  DATA: WA_9920_PAY_SEL TYPE TY_PAY,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.

  LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_9920_MSG.
    if WA_9920_PAY_SEL-taxable = 'Y'.
      WA_9920_MSG-ztax = 'X'.
      clear WA_9920_MSG-znontax.
    elseif WA_9920_PAY_SEL-taxable = 'N'.
      WA_9920_MSG-znontax = 'X'.
      clear WA_9920_MSG-ztax.
    elseif WA_9920_PAY_SEL-taxable = 'B'.
      clear: WA_9920_MSG-znontax , WA_9920_MSG-ztax.
    endif.
*   WA_9920_MSG-SPRPS = ' ' .  "to be retained
*   WA_9920_MSG-ZSTATUS = 'UNLOCKED' .  "to be retained

    " only WA_9920_MSG-ZREMARKSPCS will be updated in PA9920
*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
*    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
*End RD1K976756  CAB_ALOK
      EXPORTING
        OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
        LOCK_INDICATOR = ' '   "current value of lockindicator
      CHANGING
        WA_9920_MSG    = WA_9920_MSG.
    if WA_9920_MSG-ERROR_FLAG <> '1'. "if update Operation successful, then modify the Message
      WA_9920_MSG-MESSAGE = 'Saved '.  " otherwise this message contains 'Status: UNLOCKED'
    endif.

    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL.

    MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
    CLEAR: WA_9920_PAY_SEL ,
           WA_9920_MSG.

  ENDLOOP.


ENDFORM.                    " SAVEFI_0605
*&---------------------------------------------------------------------*
*&      Form  PAY_0605
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PAY_0605 USING TEST_FLAG .


** F-02, on the basis of:
** IST_9920_PAY
** WA_F_02_HEADER TYPE TY_F_02_HEADER.
** WA_F_02_CREDIT TYPE TY_F_02_CREDIT.
** IST_F_02_DEBIT TYPE table of  TY_F_02_DEBIT,
** WA_F_02_DEBIT TYPE  TY_F_02_DEBIT,
** WA_F_02_DEBIT_NEXT TYPE  TY_F_02_DEBIT.

  data:  WA_F_02_HEADER TYPE TY_F_02_HEADER.
  data:  WA_F_02_CREDIT TYPE TY_F_02_CREDIT.
  data:  IST_F_02_DEBIT TYPE table of  TY_F_02_DEBIT,
         WA_F_02_DEBIT TYPE  TY_F_02_DEBIT,
         WA_F_02_DEBIT_NEXT TYPE  TY_F_02_DEBIT.

  data:  WA_9920_PAY_TMP TYPE TY_PAY,
         WA_9920_PAY TYPE TY_PAY,
         WA_9920_PAY_SEL TYPE TY_PAY,
         l_tabix  TYPE sy-tabix.
  data : SUM_ZAMTPCSTOTAL type WRBTR.
  data : WA_PA0027 type PA0027.

  data: l_persk TYPE persk. "Employee Group : active, retd etc
  data: l_persg TYPE persg. " E1, E2, Etc

  data: L_GLAC type NEWKO.  "GL A/c
  data: L_BUKRS type bukrs. " comp. code. of emp.

  FIELD-SYMBOLS : <FS_KPR> type any,               " percentage
                  <FS_COMPNY_PERNR> type any,
                  <FS_WBS_ELE> type any,
                  <FS_COST_CTR> type any.
  data: count type i.
  data: count_c(2).
  data: l_bvorg(10).
  data: str_kpr type string,
        str_comp type string,
        str_wbs_ele type string,
        str_cost_ctr type string.

  Data :  L_FISCAL_YEAR(4) TYPE C.


* Data : ist_mesg type table of TY_ESP1_MESSAGE with header line.
  Data : ist_mesg type ESP1_MESSAGE_TAB_TYPE with header line.
  data cnt type i.
  data : bdc_subrc like sy-subrc. " capture status of BDC success
  data : IST_PA9920 type  table of  PA9920,
         WA_PA9920 type PA9920.
  data : IST_ZHRMED_EMP_RECOV type table of ZHRMED_EMP_RECOV,
         WA_ZHRMED_EMP_RECOV type ZHRMED_EMP_RECOV.

* begin of RD1K977852 CAB_ALOK  CR 30006309: Zero balance problem
  DATA IST_F_02_DEBIT_TEMP TYPE table of  TY_F_02_DEBIT.
* end of RD1K977852 CAB_ALOK  CR 30006309

* *begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
*  when MODE is PAY or TEST
*  Take lock on all the pernrs.
*  if any one already locked, get information about who has taken the lock,
*       release all locks, return to screen & display error msg.
*  elseif all pernrs locked
*    run BDC in given mode.
*       .
*       .
*      if mode = production and BDC successful.
*          update 9920.
*              .
*              .
*      endif
*     unlock all pernrs
*   endif
  data: WA_9920_PAY_SEL1 TYPE TY_PAY,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        ERROR_PERNR_LOCK type char1.

* Remove previous MESSAGEs & ERROR_FLAGs before each run of table control
  clear l_tabix.
  CLEAR: WA_9920_PAY_SEL1 .
  LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE ZSTATUS = 'UNLOCKED'.
    l_tabix =   sy-tabix .
    clear: WA_9920_PAY_SEL1-MESSAGE, WA_9920_PAY_SEL1-ERROR_FLAG.
    MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
    CLEAR: WA_9920_PAY_SEL1 .
  endloop.

*Lock all Pernrs of IST_9920_PAY.
  clear l_tabix.
  CLEAR: WA_9920_PAY_SEL1, WA_9920_MSG.
  LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_9920_MSG.

    CALL FUNCTION 'ZHR_MED_PERNR_LOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
      CHANGING
        WA_9920_MSG = WA_9920_MSG.

    if WA_9920_MSG-ERROR_FLAG = '1'.   " at least one pernr lock failed
      ERROR_PERNR_LOCK = '1'.
    endif.

    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL1.

    MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
    CLEAR: WA_9920_PAY_SEL1 , WA_9920_MSG.
  ENDLOOP.

  IF ERROR_PERNR_LOCK = '1'.

    MESSAGE i113(zhr). "At least one pernr is locked. See message column.
    clear ERROR_PERNR_LOCK.
    " at least one pernr lock failed so release other locked pernr of the IST_9920_PAY before exiting
    clear l_tabix.
    CLEAR: WA_9920_PAY_SEL1, WA_9920_MSG.
    LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED' AND ERROR_FLAG = ''.
      l_tabix =   sy-tabix .
      MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_9920_MSG.

      CALL FUNCTION 'ZHR_MED_PERNR_UNLOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
        CHANGING
          WA_9920_MSG = WA_9920_MSG.

      MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL1.

      MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
      CLEAR: WA_9920_PAY_SEL1 , WA_9920_MSG.
    ENDLOOP.

  ELSE.  " All pernrs locked, now process BDC (TEST or PAY)
* end RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794

*Clear: WA_F_02_HEADER, WA_F_02_CREDIT, WA_F_02_DEBIT, WA_F_02_DEBIT_NEXT.
*Refresh: IST_F_02_DEBIT.

** get data from IST_9920_PAY for Header & Credit line item
    read table IST_9920_PAY into WA_9920_PAY_TMP
                    with key SEL = 'X' ZSTATUS = 'UNLOCKED'.
    if sy-subrc = 0.    "Atleast one unlocked row selected.
** Build WA_F_02_HEADER
*----------------------
      WA_F_02_HEADER-BLDAT = sy-datum.
      WA_F_02_HEADER-BLART = 'KM'.
      WA_F_02_HEADER-BUKRS = WA_9920_PAY_TMP-GRPVL.    " GRPVL: company code for credit.
      WA_F_02_HEADER-BUDAT = G_BUDAT.
      WA_F_02_HEADER-WAERS = 'INR'.
      WA_F_02_HEADER-XBLNR = 'MEDICAL Payment' . " 'ref head'.
      WA_F_02_HEADER-BKTXT = WA_9920_PAY_TMP-ZLOT_NO. "'hospital head text'. displaying facility NOT POSSIBLE, All the records belong to different SUBTYPE(facility)


** Build WA_F_02_CREDIT line item
*--------------------------------
      WA_F_02_CREDIT-VENDOR = WA_9920_PAY_TMP-ZHOSPID.      "NEWKO , ZHOSPID

* calculate CREDIT AMT = SUM of ZAMTPCSTOTAL from IST_9920_PAY
      SUM_ZAMTPCSTOTAL = 0.
      loop at IST_9920_PAY into WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'..
        SUM_ZAMTPCSTOTAL = SUM_ZAMTPCSTOTAL + WA_9920_PAY_SEL-ZAMTPCSTOTAL.
      endloop.
      WA_F_02_CREDIT-WRBTR = SUM_ZAMTPCSTOTAL .   " amt., sum_ZAMTPCSTOTAL

      WA_F_02_CREDIT-SECCO = G_SECCO.    " section code
      WA_F_02_CREDIT-ZFBDT  = sy-datum.  " base line date
      WA_F_02_CREDIT-KIDNO = G_KIDNO.    " paymt ref

*  WA_F_02_CREDIT-SGTXT = 'line item text vendor'
      concatenate 'Payment against LOT No.' WA_9920_PAY_TMP-ZLOT_NO into WA_F_02_CREDIT-SGTXT .

      WA_F_02_CREDIT-WT_WITHCD = G_WT_WITHCD. "Withholding tax code
      WA_F_02_CREDIT-WT_BASE = G_WT_BASE.     "Withholding tax base amount

** Build WA_F_02_DEBITEBIT line items, split IST_9920_PAY if need be
*=====================================================================
      clear: WA_9920_PAY_SEL, WA_F_02_DEBIT.

* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
      Data: FLAG_MODI_UTIL. " F: False- utilization checks fail, T: True-Utilization checks OK ,
      FLAG_MODI_UTIL = 'T'.
      refresh: ist_zhrhospsanc_utl.

* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

      loop at IST_9920_PAY into WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'..
        l_tabix =   sy-tabix .

        MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_F_02_DEBIT.
** WA_F_02_DEBIT
****************
* (PA0027(
*MESSAGE
*ERROR_FLAG
*GLAC
*COMPNY_PERNR
*SPLIT_AMT                                      0.00
*VALUT                                      00000000
*SGTXT
*WBS_ELE
*COST_CTR


** Determine GL Account on the basis of Emp grp & facility, AS PER FOLLOWING TABLE,
********************************************
*    SUBTY  05        03 or 06           04
*          ( Medicine Hospital / Diag   Doctor )
* Staff     200301    200318            200317
* Officer   200301    200307            200302
* Retd      200301    200308            200309

** PA0001-PERSG  " employee group
*1  Active employee   ACTIVE
*2  Retiree/pensioner   RETD
*7  Deputation-In   ACTIVE
*8  Deputation-out  ACTIVE
*9  Term based    ACTIVE
*A  Adhoc Appointment   ACTIVE
*B  Separated/deceased    RETD
*G  Graduate Trainee    ACTIVE
*S  Subsidiary    ACTIVE
*T  Tenure Based

** PA0001-PERSK   " Employee level
* OFFICER                 * STAFF
*C  ONGC CHAIRMAN           A1  ONGC ASST A-I
*D  ONGC DIRECTOR           A2  ONGC ASST A-II
*E0 ONGC EXEC E0            A3  ONGC ASST A-III
*E1 ONGC EXEC E1            A4  ONGC ASST A-IV
*E2 ONGC EXEC E2            S1  ONGC STAFF S-I
*E3 ONGC EXEC E3            S2  ONGC STAFF S-II
*E4 ONGC EXEC E4            S3  ONGC STAFF S-III
*E5 ONGC EXEC E5            S4  ONGC STAFF S-IV
*E6 ONGC EXEC E6            TC  ONGC TOP OF CLSS III
*E7 ONGC EXEC E7            W1  ONGC WORKMEN W-I
*E8 ONGC EXEC E8            W2  ONGC WORKMEN W-II
*E9 ONGC EXEC E9            W3  ONGC WORKMEN W-III
*GT Graduate Trainee        W4  ONGC WORKMEN W-IV
*                           W5  ONGC WORKMEN W-V
*                           W6  ONGC WORKMEN W-VI
*                           W7  ONGC WORKMEN W-VII

        CLEAR: l_persk, l_persg, L_GLAC .
        SELECT PERSK PERSG
 FROM PA0001 INTO ( L_PERSK , L_PERSG ) UP TO 1 ROWS WHERE PERNR = WA_9920_PAY_SEL-PERNR AND BEGDA =< SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if sy-subrc = 0.
          if   l_persg = '2'
            or l_persg = 'B' .    " Retd. Employee

            if WA_9920_PAY_SEL-SUBTY = '05'.
              L_GLAC = '200301'.
            elseif ( WA_9920_PAY_SEL-SUBTY = '03' or WA_9920_PAY_SEL-SUBTY = '06' ).
              L_GLAC = '200308'.
            elseif WA_9920_PAY_SEL-SUBTY = '04'.
              L_GLAC = '200309'.
            endif.

          elseif l_persg = '1' " Activ. Employee (Officer + Staff)
              or l_persg = '7'
              or l_persg = '8'
              or l_persg = '9'
              or l_persg = 'A'
              or l_persg = 'G'
              or l_persg = 'S'.
            " now determine whether Officer or Staff
            if   l_persk = 'C'    " => officer
              or l_persk = 'D'
              or l_persk = 'E0'
              or l_persk = 'E1'
              or l_persk = 'E2'
              or l_persk = 'E3'
              or l_persk = 'E4'
              or l_persk = 'E5'
              or l_persk = 'E6'
              or l_persk = 'E7'
              or l_persk = 'E8'
              or l_persk = 'E9'
              or l_persk = 'GT'.

              if WA_9920_PAY_SEL-SUBTY = '05'.
                L_GLAC = '200301'.
              elseif ( WA_9920_PAY_SEL-SUBTY = '03' or WA_9920_PAY_SEL-SUBTY = '06' ).
                L_GLAC = '200307'.
              elseif WA_9920_PAY_SEL-SUBTY = '04'.
                L_GLAC = '200302'.
              endif.    "//officer

            elseif l_persk = 'A1'    " => Staff
                or l_persk = 'A2'
                or l_persk = 'A3'
                or l_persk = 'A4'
                or l_persk = 'S1'
                or l_persk = 'S2'
                or l_persk = 'S3'
                or l_persk = 'S4'
                or l_persk = 'TC'
                or l_persk = 'W1'
                or l_persk = 'W2'
                or l_persk = 'W3'
                or l_persk = 'W4'
                or l_persk = 'W5'
                or l_persk = 'W6'
                or l_persk = 'W7'.

              if WA_9920_PAY_SEL-SUBTY = '05'.
                L_GLAC = '200301'.
              elseif ( WA_9920_PAY_SEL-SUBTY = '03' or WA_9920_PAY_SEL-SUBTY = '06' ).
                L_GLAC = '200318'.
              elseif WA_9920_PAY_SEL-SUBTY = '04'.
                L_GLAC = '200317'.
              endif.
            endif. "//staff

* Begin RD1K997486 CAB_ALOK Medical Vendor pymt for Contingent workers -CR 30012858
            elseif l_persg = 'C'.  "Contingent worker
*              if l_persk = 'C1'    "
*                   or l_persk = 'C2'
*                   or l_persk = 'C3'.
                L_GLAC = '200350'.
*              endif.
* End RD1K997486 CAB_ALOK Medical Vendor pymt for Contingent workers -CR 30012858

          endif.
        endif. "sy-subrc  " // GL Account logic.

* GL A/C
        WA_F_02_DEBIT-GLAC = L_GLAC.
* Company code
*    WA_F_02_DEBIT-COMPNY_PERNR =  L_BUKRS. " now determined from PA0027
* value date
        WA_F_02_DEBIT-VALUT = sy-datum  .
* Txt
        WA_F_02_DEBIT-SGTXT = 'line item text vendor' .

*** Determine Split_Amount= ZAMTPCSTOTAL x  KPR**/100, COMPNY_PERNR, COST_CTR &  WBS_ELE
***************************************************************************
        select single * from PA0027 into WA_PA0027
           where PERNR = WA_9920_PAY_SEL-PERNR
               and SUBTY = '01'
               and BEGDA =< WA_9920_PAY_SEL-ZDATE_FROM
               AND ENDDA => WA_9920_PAY_SEL-ZDATE_FROM.

**WA_PA0027
***********
*  PERNR                                      00023733
*SUBTY                                      01
*SPRPS
*ENDDA                                      99991231
*BEGDA                                      20100101
*SEQNR                                      000
*AEDTM                                      20101115
*UNAME                                      CHR_SAHA
*
*KSTAR                                      01
*KBU01                                      MUM
*KGB01                                      FB
*KST01
*KPR01                                      20.00
*KBU02                                      MUM
*KGB02                                      FB
*KST02
*KPR02                                      80.00
*... till KPR25

*PSP01        NUMC 8                        00000560, apply CONVERSION_EXIT_ABPSP_OUTPUT
*PSP02                                      00000561
*PSP03                                      00000564
*PSP04                                      00000000
*PSP05                                      00000000
*... till PSP25

*** calculate Split amount , Comp code: KBU01..KBU25 ,  WBS ele: PSP01..PSP25 or Cost ctr: KST01..KST25,
* as per percentage  WA_PA0027-KPR01 to WA_PA0027-KPR25

        count = 1.
        do 25 times.
          clear count_c.
          move count to count_c.
          SHIFT count_c RIGHT DELETING TRAILING SPACE.
          OVERLAY count_c WITH '00'.

          concatenate'WA_PA0027-KPR' count_c into str_kpr.      " cost %age
          concatenate'WA_PA0027-KBU' count_c into str_comp.     " Comp.
          concatenate 'WA_PA0027-PSP' count_c into str_wbs_ele. " wbs ele
          concatenate 'WA_PA0027-KST' count_c into str_cost_ctr. " cost ctr

          ASSIGN (str_kpr) to <FS_KPR> .
          ASSIGN (str_comp) to <FS_COMPNY_PERNR> .
          ASSIGN (str_wbs_ele) to <FS_WBS_ELE> .
          ASSIGN (str_cost_ctr) to <FS_COST_CTR> .

          if <FS_KPR> is not INITIAL.

            clear: WA_F_02_DEBIT-COMPNY_PERNR, WA_F_02_DEBIT-SPLIT_AMT, WA_F_02_DEBIT-WBS_ELE, WA_F_02_DEBIT-COST_CTR.
*COMPNY_PERNR; Company of the pernr in that period
            WA_F_02_DEBIT-COMPNY_PERNR = <FS_COMPNY_PERNR>.
* Split Amt
            WA_F_02_DEBIT-SPLIT_AMT = WA_F_02_DEBIT-ZAMTPCSTOTAL * <FS_KPR> / 100.
** WA_PA0027 will have either WBS elements or cost centers.
*   WBS ELE:  WA_PA0027-PSP01(00000560) converted to WA_F_02_DEBIT-WBS_ELE(WO.00S.MUMSW.0022D)
            if <FS_WBS_ELE> is not INITIAL.
              CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
                EXPORTING
                  INPUT  = <FS_WBS_ELE>
                IMPORTING
                  OUTPUT = WA_F_02_DEBIT-WBS_ELE.
*COST CTR:  WA_PA0027-KST01
            elseif <FS_COST_CTR> is not INITIAL.
*Begin RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
*              WA_F_02_DEBIT-COST_CTR = <FS_COST_CTR> .

              data: WA_CSKS type CSKS.
*      Check: Cost Ctr is valid as on date.
              clear WA_CSKS.
              SELECT *
 FROM CSKS INTO WA_CSKS UP TO 1 ROWS WHERE KOSTL = <FS_COST_CTR> AND DATAB =< SY-DATUM AND DATBI >= SY-DATUM AND BKZKP = ''
 ORDER BY PRIMARY KEY .
 ENDSELECT.     " X = Cost ctr Blocked
              if WA_CSKS-KOSTL is not INITIAL.  " Cost Ctr is valid as on date
                WA_F_02_DEBIT-COST_CTR = WA_CSKS-KOSTL .
              else.     " Cost Ctr is invalid as on date, Get dominant cost ctr

                data: L_GSBER(2),
                      L_BUK(3),
                     WA_TKA3G type TKA3G.
                clear: L_BUK, L_GSBER.
*         compute business area
                L_BUK   = <FS_COST_CTR>+0(3).
                L_GSBER = <FS_COST_CTR>+3(2).

                clear WA_TKA3G.
                select single *
                  from TKA3G
                    into WA_TKA3G
                      where BUKRS = L_BUK
                        and GSBER = L_GSBER.
                if WA_TKA3G-KOSTL is not INITIAL.  " dominant cost ctr found.
                  WA_F_02_DEBIT-COST_CTR = WA_TKA3G-KOSTL.
                endif.
              endif.

*End RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840

            endif.
* begin of RD1K977852 CAB_ALOK  CR 30006309: Zero balance problem
*   append WA_F_02_DEBIT to IST_F_02_DEBIT.
            append WA_F_02_DEBIT to IST_F_02_DEBIT_TEMP.
* end of RD1K977852 CAB_ALOK  CR 30006309
          endif . " <FS_KPR>
          count = count + 1.

          UNASSIGN <FS_KPR> .
          UNASSIGN <FS_COMPNY_PERNR>.
          UNASSIGN <FS_WBS_ELE> .
          UNASSIGN <FS_COST_CTR> .

        enddo.     "//  25 times (split debit line items)
* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*        clear: WA_9920_PAY_SEL, WA_F_02_DEBIT.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930


* begin of RD1K977852 CAB_ALOK  CR 30006309: Zero balance problem
*  In few cases, Claim amount and Sum of split amounts have a difference of few paisa,
*  hence Zero balance error during F-02 posting. adjusting this additional
*   amount in the last debit line item.
        PERFORM zero_balance tables IST_F_02_DEBIT_TEMP.
        append LINES OF IST_F_02_DEBIT_TEMP to IST_F_02_DEBIT.
        refresh IST_F_02_DEBIT_TEMP.

* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*      endloop. " // end of Debit line-items creation .
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
* end of RD1K977852 CAB_ALOK  CR 30006309

* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
****** check limits

*BREAK CAB_ALOK.

*g_user_bukrs
*wa_9920_msg-gjahr
*wa_9920_pay_sel-grpvl
*wa_f_02_debit-glac


        types:  begin of ty_limits,
                  GRPVL type  PA9920-GRPVL,
                  GLAC type  HKONT,
                  gjahr type  PA9920-gjahr,
                end of ty_limits.

        data: WA_9920_limits type ty_limits.
        data: WA_F_02_DEBIT_TMP type TY_F_02_DEBIT.
        data: OPER_TYPE(3).
        clear WA_9920_limits.
        data: diff type zhrhospsanc_utl-utilamt,
              l_taxable type c.

        read TABLE IST_F_02_DEBIT INTO WA_F_02_DEBIT_TMP INDEX 1.
*WA_F_02_DEBIT_TMP-GRPVL comapny code of Logged-in user
*WA_F_02_DEBIT_TMP-GLAC  GL A/c of pernr
*Calculate WA_9920_limits-GJAHR

        WA_9920_limits-GRPVL = WA_F_02_DEBIT_TMP-GRPVL.

*        CALL FUNCTION 'FKK_FM_GET_FISCAL_YEAR'
*          EXPORTING
*            i_bukrs = WA_9920_limits-GRPVL
*            i_budat = wa_f_02_header-budat
*          IMPORTING
*            e_gjahr = WA_9920_limits-gjahr.   " Fiscal yr
        CALL FUNCTION 'GET_CURRENT_YEAR'                    "RD1K988011
                     EXPORTING
                       BUKRS         = WA_9920_limits-GRPVL
                       DATE          = wa_f_02_header-budat
                     IMPORTING
*               CURRM        =
                       CURRY         = WA_9920_limits-gjahr.
*               PREVM        =
*               PREVY        =
        .                                                   "RD1K988011



*New logic given:
*Earlier logic given was that amount sanctioned against each GL will be
*checked against payment belonging to that GL only. Now,
*1. Sanctioned amount in 200301 will be checked against payment in GL
*head 200301 of ZHRHOSP and ZHRNEHOSP only.
*2. Sanctioned amount in 200302 will be checked against payment in GL
*heads 200302, 200307,200308,200309,200317,200318 and 200316(ZHRNEHOSP).

        WA_9920_limits-GLAC = WA_F_02_DEBIT-GLAC.

        data: major_head type HKONT.
* Begin RD1K992265 CAB_ALOK CR 30010881
        if G_BUDAT < '20140401' .
* End RD1K992265 CAB_ALOK CR 30010881
          case  WA_F_02_DEBIT-GLAC.

            when '200301'.
              major_head = '200301'.

*begin RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
*          when '200302' or '200307' or '200308' or '200309' or
*                 '200317' or '200318'.
*            major_head = '200302'.

* Begin RD1K992265 CAB_ALOK CR 30010881
*          when '200302' or '200307' or '200317' or '200318'.
*            if G_BUDAT >= '20140401'.
*              major_head = '200302'.
*            endif.
*
*          when  '200308' or '200309' .
*            if G_BUDAT >= '20140401'.
*              major_head = '200309'.
*            endif.

            when '200302' or '200307' or '200308' or '200309' or
                   '200317' or '200318'.
              major_head = '200302'.

* End RD1K992265 CAB_ALOK CR 30010881

*end RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
          endcase.

*=======================
* Begin RD1K992265 CAB_ALOK CR 30010881
        else. " G_BUDAT >= '20140401'

          case  WA_F_02_DEBIT-GLAC.

            when '200301'.
              major_head = '200301'.

            when '200302' or '200307' or '200317' or '200318'.
              major_head = '200302'.

            when  '200308' or '200309' .
              major_head = '200309'.

*Begin RD1K997486  CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
            when  '200350' .
              major_head = '200350'.
*End RD1K997486   CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858



          endcase.

* End RD1K992265 CAB_ALOK CR 30010881
        endif.


* for handling GL A/c prefix issue. (add 0000 to GL A/c)
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
*           INPUT  = WA_9920_limits-GLAC
            INPUT  = major_head
          IMPORTING
*           OUTPUT = WA_9920_limits-GLAC   .
            OUTPUT = major_head.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = WA_9920_limits-GLAC
          IMPORTING
            OUTPUT = WA_9920_limits-GLAC.

* exemption to company was inserted later, was causing warning at every line item.
* so now first consolidating for (bukrs, GL A/c, Fiscal year)
* then checking.

*Begin RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
** Commented
***    select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction
***       where bukrs = WA_9920_limits-GRPVL
****           and glhead = WA_9920_limits-GLAC
***           and glhead = major_head
***           and gjahr = WA_9920_limits-gjahr.
***
***
***
**** calculate  total sanc. amt for ( user_bukrs, pernr's GL A/c, Fiscal year )
***     clear t_amt.
***     clear wa_zhrhospsanction.
***     loop at ist_zhrhospsanction into wa_zhrhospsanction.
***       t_amt = t_amt + wa_zhrhospsanction-amt.
***     endloop.
***
****This check should be applicable for Fiscal year equal to or greater
****than 2013.
***if WA_9920_limits-gjahr => '2013'.
**** This check should be excluded for the company codes in table
****ZFIHOSPBUKRSEXEM.
***
***
***  clear WA_ZFIHOSPBUKRSEXEM.
***    select single bukrs          "exempted company code
***      from ZFIHOSPBUKRSEXEM
***      into WA_ZFIHOSPBUKRSEXEM-BUKRS
***      where bukrs = WA_9920_limits-GRPVL.
****  if WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
*****instead of skipping all the checks and updation for
**** exempted company codes, give msg and update utilization
**** with -ve values (if any).
***
***    if t_amt = 0
***       AnD WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.. " sanc. amt not maintained
***          FLAG_MODI_UTIL = 'F'.
***          message e027(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
***       else.   " sanc. amt maintained, Calc util amt
***
***      clear wa_zhrhospsanc_utl.
***       select single * from zhrhospsanc_utl
***         into  wa_zhrhospsanc_utl
***           where bukrs = WA_9920_limits-GRPVL
****           and glhead = WA_9920_limits-GLAC
***           and glhead = major_head
***           and gjahr = WA_9920_limits-gjahr.
***
***
***
*** calc., irrespective of whether the util record is found or not
***
***
***wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + wa_9920_pay_sel-zamtpcstotal.
***
****Utilisation amount exceeds the sanctioned limit.
***      if wa_zhrhospsanc_utl-utilamt > t_amt.
***        if WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
***          FLAG_MODI_UTIL = 'F'.
****          message e023(zhr) with WA_9920_limits-GRPVL WA_9920_limits-GLAC WA_9920_limits-gjahr. .
***          clear diff.
***          diff = wa_zhrhospsanc_utl-utilamt - t_amt.
***          message e023(zhr) with diff WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
***        else. "exempted comp code
***          message w066(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
***        endif.
***      endif.
***
****Utilasation amount reached 80% of sanctioned limit
***      clear t_amt80.
***      t_amt80 = t_amt *   8 / 10 .
***      if wa_zhrhospsanc_utl-utilamt >=  t_amt80
***        AnD WA_ZFIHOSPBUKRSEXEM-BUKRS = ''..
***          message i029(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
***      endif.
***
****update/insert Utilizn record, only after BDC success
***    wa_zhrhospsanc_utl-BUKRS = WA_9920_limits-GRPVL.
****    wa_zhrhospsanc_utl-GLHEAD = WA_9920_limits-GLAC.
***    wa_zhrhospsanc_utl-GLHEAD = major_head.
***    wa_zhrhospsanc_utl-GJAHR =  WA_9920_limits-gjahr.
****    wa_zhrhospsanc_utl-AMT = t_amt.
***    wa_zhrhospsanc_utl-BALAMT = t_amt - wa_zhrhospsanc_utl-utilamt.
***
***    collect wa_zhrhospsanc_utl into ist_zhrhospsanc_utl.
***
***    endif. "// t_amt =< 0 . " sanc. amt not maintained
***
****  endif. "// WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
***
***endif.  "// WA_9920_limits-gjahr => '2013'.
*###End comment


        CLEAR wa_zhrhospsanc_utl.
        wa_zhrhospsanc_utl-utilamt = wa_9920_pay_sel-zamtpcstotal.
        wa_zhrhospsanc_utl-BUKRS = WA_9920_limits-GRPVL.
        wa_zhrhospsanc_utl-GLHEAD = major_head.
        wa_zhrhospsanc_utl-GJAHR =  WA_9920_limits-gjahr.

* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
        wa_zhrhospsanc_utl-SECCO = G_SECCO.
* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991

        collect wa_zhrhospsanc_utl into ist_zhrhospsanc_utl.

* End RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
        clear: WA_9920_PAY_SEL, WA_F_02_DEBIT.
      endloop. " // end of Debit line-items creation .
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930


* Begin RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
      loop at ist_zhrhospsanc_utl into wa_zhrhospsanc_utl.
*This check should be applicable for Fiscal year equal to or greater
*than 2013.
        IF wa_zhrhospsanc_utl-gjahr => '2013'.
* util checks should be excluded for the company codes in table
*ZFIHOSPBUKRSEXEM but util table should be updated for these BUKRS
*even if the balance becomes -ve
          clear WA_ZFIHOSPBUKRSEXEM.
          select single bukrs          "exempted company code
           from ZFIHOSPBUKRSEXEM
            into WA_ZFIHOSPBUKRSEXEM-BUKRS
               where bukrs = wa_zhrhospsanc_utl-BUKRS
** Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
*                and secco = wa_zhrhospsanc_utl-SECCO
** End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
                     .



* calculate  total sanc amt for (bukrs, GL A/c, Fiscal year) from DB
          refresh ist_zhrhospsanction.
          select * from zhrhospsanction
           into corresponding fields of table ist_zhrhospsanction
            where bukrs = wa_zhrhospsanc_utl-BUKRS
* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
                and secco = wa_zhrhospsanc_utl-SECCO
* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
             and glhead = wa_zhrhospsanc_utl-GLHEAD
             and gjahr = wa_zhrhospsanc_utl-GJAHR.
          clear t_amt. "sanc amt
          clear wa_zhrhospsanction.
          loop at ist_zhrhospsanction into wa_zhrhospsanction.
            t_amt = t_amt + wa_zhrhospsanction-amt.
            clear wa_zhrhospsanction.
          endloop.

* Get current util amt for (bukrs, GL A/c, Fiscal year ) from DB
          data: wa_zhrhospsanc_utl_curr type zhrhospsanc_utl.
          clear  wa_zhrhospsanc_utl_curr.
          select single * from zhrhospsanc_utl
           into  wa_zhrhospsanc_utl_curr
            where bukrs = wa_zhrhospsanc_utl-BUKRS
* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
             and secco = wa_zhrhospsanc_utl-SECCO
* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
             and glhead = wa_zhrhospsanc_utl-GLHEAD
             and gjahr = wa_zhrhospsanc_utl-GJAHR.

* calculate new util amt = util amt on screen + util amt in db table for (bukrs, GL A/c, Fiscal year )
          wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + wa_zhrhospsanc_utl_curr-utilamt.

**CHECKs
*1. Utilisation amount > the sanctioned limit.
          if wa_zhrhospsanc_utl-utilamt > t_amt.
            if WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
              FLAG_MODI_UTIL = 'F'.
              clear diff.
              diff = wa_zhrhospsanc_utl-utilamt - t_amt.
* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
*                message e023(zhr) with diff wa_zhrhospsanc_utl-BUKRS wa_zhrhospsanc_utl-GLHEAD wa_zhrhospsanc_utl-GJAHR .
data: L_BUK_SECCO(9).
CONCATENATE  wa_zhrhospsanc_utl-BUKRS '/' wa_zhrhospsanc_utl-SECCO INTO L_BUK_SECCO SEPARATED BY SPACE.
               message e062(zhr) with diff L_BUK_SECCO wa_zhrhospsanc_utl-GLHEAD wa_zhrhospsanc_utl-GJAHR .

* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
            else. "exempted comp code
* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
*              message w066(zhr) with wa_zhrhospsanc_utl-BUKRS wa_zhrhospsanc_utl-GLHEAD wa_zhrhospsanc_utl-GJAHR .
              message w066(zhr) with wa_zhrhospsanc_utl-BUKRS wa_zhrhospsanc_utl-GLHEAD wa_zhrhospsanc_utl-GJAHR wa_zhrhospsanc_utl-SECCO.
* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991

            endif.
          endif.

*2. Utilasation amount reached 80% of sanctioned limit
          clear t_amt80.
          t_amt80 = t_amt * 8 / 10 .
          if wa_zhrhospsanc_utl-utilamt >=  t_amt80
            AnD WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.

* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
*            message i029(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
            message i029(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr G_SECCO. .

* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
          endif.

* calculate new balance for (bukrs, GL A/c, Fiscal year )
          wa_zhrhospsanc_utl-BALAMT = t_amt - wa_zhrhospsanc_utl-utilamt.

* modify ist with new util & bal
          MODIFY ist_zhrhospsanc_utl FROM wa_zhrhospsanc_utl TRANSPORTING utilamt BALAMT.
        ENDIF.
      endloop.
*End RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233

      refresh messtab.

* perform BDC only when util limit is available
      if  FLAG_MODI_UTIL = 'T'.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

* F-02 Posting
        PERFORM BDC_F_02 tables  IST_F_02_DEBIT
           using TEST_FLAG WA_F_02_HEADER WA_F_02_CREDIT CHANGING bdc_subrc . " using Flag_test
      endif.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930




* if BDC is successful in Posting Mode then
* 1. change status of selected records to 'PAID' in IST_9920_PAY and PA9920
* 2. post recovery data, if any, to ZHRMED_EMP_RECOV

* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*    if bdc_subrc = 0 and TEST_FLAG = 'P'.

      if bdc_subrc = 0 and TEST_FLAG = 'P'
                            and FLAG_MODI_UTIL = 'T'.

* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930


* 1.
*============
**  LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
**    l_tabix =   sy-tabix .
**
**    " Modify screen display
**    WA_9920_PAY_SEL-ZSTATUS = 'PAID' .
**    WA_9920_PAY_SEL-MESSAGE = 'Paid' .
**    WA_9920_PAY_SEL-AEDTM = sy-datum.
**    WA_9920_PAY_SEL-UNAME = sy-uname.
**
**    MODIFY  IST_9920_PAY INDEX l_tabix FROM  WA_9920_PAY_SEL .
**    " Modify table PA9920
**    MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_PA9920.
**    WA_PA9920-MANDT = sy-mandt.
**    append WA_PA9920 to IST_PA9920  .
*============*

* Begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
*        data: WA_9920_PAY_SEL1 TYPE TY_PAY,
*              WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG.
        clear: WA_9920_PAY_SEL1, WA_9920_MSG.
* End RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794

*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP-paymt reversal
*Get FI Doc. no. (messtab-MSGV1) & comp. code (messtab-MSGV2) from Messtab
        READ TABLE messtab WITH KEY TCODE ='FB01'
                                  DYNAME = 'SAPMF05A'
                                  DYNUMB = '0701'
                                  MSGTYP = 'S'
                                  MSGSPRA = 'E'
                                  MSGID   = 'F5'
                                  MSGNR = '312'
                                    INTO wa_messtab.
        if sy-subrc <> 0.
          READ TABLE messtab WITH KEY TCODE ='FB01'
                                    DYNAME = 'SAPMF05A'
                                    DYNUMB = '0700'
                                    MSGTYP = 'S'
                                    MSGSPRA = 'E'
                                    MSGID   = 'F5'
                                    MSGNR = '312'
                                      INTO wa_messtab.
        endif.
*End RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP

        LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
          l_tabix =   sy-tabix .

****
          select COUNT(*)
            FROM  ZHRMED_EMP_RECOV
            into l_bvorg
            where CNTER = WA_9920_PAY_SEL1-CNTER.



          MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_9920_MSG.

*Begin of <RD1K994929> cab_pareek  17.10.2014
          if WA_9920_PAY_SEL1-taxable = 'N'.
            WA_9920_MSG-znontax = 'X'.
            clear WA_9920_MSG-ztax.
          else.
            clear WA_9920_MSG-znontax.
            WA_9920_MSG-ztax  = 'X'.
          endif.

*End of <RD1K994929> cab_pareek  17.10.2014
*    WA_9920_MSG-SPRPS = '' .  "to be retained as ''

*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP:dual check, paymt reversal
          data: SAVE_ZSTATUS TYPE PA9920-ZSTATUS.
*          WA_9920_MSG-ZSTATUS = 'PAID' .
          SAVE_ZSTATUS = WA_9920_MSG-ZSTATUS. "Value: 'UNLOCKED' or 'REVERSED'
          WA_9920_MSG-ZSTATUS = 'PAID' .

          WA_9920_MSG-PAID_BY_PERNR = G_USER_PERNR .
          WA_9920_MSG-PAID_BY_LEVEL = G_USER_PERSK .

          WA_9920_MSG-BELNR = wa_messtab-MSGV1.  " FI Doc. no.
          WA_9920_MSG-BUKRS = wa_messtab-MSGV2.  "comp. code


          DATA: L_BUDAT1 type BUDAT,
                L_BUKRS1 type BUKRS.
          MOVE WA_F_02_HEADER-BUDAT TO L_BUDAT1.
          MOVE wa_messtab-MSGV2 TO L_BUKRS1.
*          CALL FUNCTION 'FKK_FM_GET_FISCAL_YEAR'
*            EXPORTING
*              I_BUKRS = L_BUKRS1
*              I_BUDAT = L_BUDAT1
*            IMPORTING
*              E_GJAHR = WA_9920_MSG-GJAHR.   " Fiscal yr
          CALL FUNCTION 'GET_CURRENT_YEAR'                  "RD1K988011
              EXPORTING
                BUKRS         = l_bukrs1
                DATE          = l_budat1
              IMPORTING
*               CURRM        =
                CURRY         = wa_9920_msg-gjahr.
*               PREVM        =
*               PREVY        =
          .                                                 "RD1K988011

*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
*begin of CR 30006427 CAB_ALOK

*  clear WA_9920_MSG-SPRPS
*          WA_9920_MSG-ZSTATUS = 'UNLOCKED'.   "  'REVERSED'.
*          WA_9920_MSG-STBLG = L_STBLG.
*
*          SAVE_PAID_BY_PERNR = WA_9920_MSG-PAID_BY_PERNR.
*          SAVE_PAID_BY_LEVEL = WA_9920_MSG-PAID_BY_LEVEL.
*          SAVE_BELNR  =  WA_9920_MSG-BELNR.

**          SAVE_BUKRS  =  WA_9920_MSG-BUKRS.
*          SAVE_GJAHR  =  WA_9920_MSG-GJAHR.

*          SAVE_CHECKED_BY_PERNR  =  WA_9920_MSG-CHECKED_BY_PERNR.
*          SAVE_CHECKED_BY_LEVEL  =  WA_9920_MSG-CHECKED_BY_LEVEL.
          CONCATENATE  WA_9920_MSG-ZREMARKS ':' l_bvorg into WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE.
*
*  WA_9920_MSG-ZSTATUS = 'REVERSED'.
*
*end of CR 30006427  CAB_ALOK

* Begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
****Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
****    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
**          CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
***End RD1K976756  CAB_ALOK
**             EXPORTING
**              OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
**              LOCK_INDICATOR = ' '
**            CHANGING
**              WA_9920_MSG    = WA_9920_MSG.

* functionality of ZHR_MED_PYMT_UPDATE9920_MSG now trifurcated into separate
* FMs (LOCK, UPDATE, UNLOCK) for Payment process
          CALL FUNCTION 'ZHR_MED_PYMT_INFO_OPER_9920' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
            EXPORTING
              OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
              LOCK_INDICATOR = ' '
            CHANGING
              WA_9920_MSG    = WA_9920_MSG.
* End RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794

          if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status & other data to original.

*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP:dual check, Paymt reversal
*            WA_9920_MSG-ZSTATUS = 'UNLOCKED' .
            WA_9920_MSG-ZSTATUS = SAVE_ZSTATUS. "Value: 'UNLOCKED' or 'REVERSED'
            clear: WA_9920_MSG-PAID_BY_PERNR,
                   WA_9920_MSG-PAID_BY_LEVEL.

            clear: WA_9920_MSG-BELNR,
                   WA_9920_MSG-BUKRS,
                   WA_9920_MSG-GJAHR.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP

* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
          else. " Infotype oper successful, update utilizn tables
            if WA_9920_limits-gjahr => '2013'.
              modify zhrhospsanc_utl from TABLE ist_zhrhospsanc_utl.
              commit work.
              refresh  ist_zhrhospsanc_utl.
            endif.  "// WA_9920_limits-gjahr => '2013'.
** following block commented by Alok
****
*****    CR 30008930  chages by cab_swetha , specs by cfi_mallik
****        Else.
****       " Else statement added .. if payment is successful  tables zhrhospsanction
****      "       & zhrhospsanc_utl will get updated .
****        CLEAR: l_persk, l_persg, L_GLAC .
****        SELECT SINGLE persk persg           " bukrs
****              FROM pa0001
****              INTO (l_persk, l_persg)       " , L_BUKRS
****                WHERE pernr = WA_9920_PAY_SEL1-PERNR
****                 AND begda =< sy-datum
****                 AND endda >= sy-datum.
****
****        if sy-subrc = 0.
****          if   l_persg = '2'
****            or l_persg = 'B' .    " Retd. Employee
****
****            if WA_9920_PAY_SEL1-SUBTY = '05'.
****              L_GLAC = '0000200301'.
****            elseif ( WA_9920_PAY_SEL1-SUBTY = '03' or WA_9920_PAY_SEL1-SUBTY = '06' ).
****              L_GLAC = '0000200308'.
****            elseif WA_9920_PAY_SEL1-SUBTY = '04'.
****              L_GLAC = '0000200309'.
****            endif.
****
****          elseif l_persg = '1' " Activ. Employee (Officer + Staff)
****              or l_persg = '7'
****              or l_persg = '8'
****              or l_persg = '9'
****              or l_persg = 'A'
****              or l_persg = 'G'
****              or l_persg = 'S'.
****            " now determine whether Officer or Staff
****            if   l_persk = 'C'    " => officer
****              or l_persk = 'D'
****              or l_persk = 'E0'
****              or l_persk = 'E1'
****              or l_persk = 'E2'
****              or l_persk = 'E3'
****              or l_persk = 'E4'
****              or l_persk = 'E5'
****              or l_persk = 'E6'
****              or l_persk = 'E7'
****              or l_persk = 'E8'
****              or l_persk = 'E9'
****              or l_persk = 'GT'.
****
****              if WA_9920_PAY_SEL1-SUBTY = '05'.
****                L_GLAC = '0000200301'.
****              elseif ( WA_9920_PAY_SEL1-SUBTY = '03' or WA_9920_PAY_SEL1-SUBTY = '06' ).
****                L_GLAC = '0000200307'.
****              elseif WA_9920_PAY_SEL1-SUBTY = '04'.
****                L_GLAC = '0000200302'.
****              endif.    "//officer
****
****            elseif l_persk = 'A1'    " => Staff
****                or l_persk = 'A2'
****                or l_persk = 'A3'
****                or l_persk = 'A4'
****                or l_persk = 'S1'
****                or l_persk = 'S2'
****                or l_persk = 'S3'
****                or l_persk = 'S4'
****                or l_persk = 'TC'
****                or l_persk = 'W1'
****                or l_persk = 'W2'
****                or l_persk = 'W3'
****                or l_persk = 'W4'
****                or l_persk = 'W5'
****                or l_persk = 'W6'
****                or l_persk = 'W7'.
****
****              if WA_9920_PAY_SEL1-SUBTY = '05'.
****                L_GLAC = '0000200301'.
****              elseif ( WA_9920_PAY_SEL1-SUBTY = '03' or WA_9920_PAY_SEL1-SUBTY = '06' ).
****                L_GLAC = '0000200318'.
****              elseif WA_9920_PAY_SEL1-SUBTY = '04'.
****                L_GLAC = '0000200317'.
****              endif.
****            endif. "//staff
****          elseif l_persg = 'C'.
****
****            if l_persk = 'C1'    " => Contingent worker
****                 or l_persk = 'C2'
****                 or l_persk = 'C3'.
****              L_GLAC = '0000200350'.
****            endif.
****
****          endif.
****        endif. "sy-subrc  " // GL Account logic.
****
****
****
*****       CALL FUNCTION 'GM_GET_FISCAL_YEAR'
*****        EXPORTING
*****          I_DATE    = WA_9920_MSG-GJAHR "G_BUDAT
*****          i_fyv     = 'V3'
*****        IMPORTING
*****          E_FY      = L_FISCAL_YEAR .
****   L_FISCAL_YEAR = WA_9920_MSG-GJAHR .
****
****    SELECT SINGLE BUKRS FROM PA0001 INTO L_BUKRS WHERE pernr = sy-uname
****        and begda <= sy-datum and endda >= sy-datum .
****
****    Refresh ist_zhrhospsanction.
****    Select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction
****       where BUKRS = L_BUKRS and GLHEAD = L_GLAC
****           and GJAHR = L_FISCAL_YEAR.
****     Clear t_amt.
****      Loop at ist_zhrhospsanction into wa_zhrhospsanction.
****        t_amt = t_amt + wa_zhrhospsanction-amt.
****      Endloop.
****
****
****    select single * from zhrhospsanc_utl into  wa_zhrhospsanc_utl
****         where BUKRS = L_BUKRS and GLHEAD = L_GLAC
****           and GJAHR = L_FISCAL_YEAR.
****      If sy-subrc = 0.
****        wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + WA_9920_PAY_SEL1-ZAMTPCSTOTAL.
****        t_amt1 = t_amt *   8 / 10 .
****        If wa_zhrhospsanc_utl-utilamt > t_amt .
****          Message e023(ZHR) .
****
****        ElseIf wa_zhrhospsanc_utl-utilamt >=  t_amt1.
****          Message i025(ZHR) .
****        Endif.
****        wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
****        wa_zhrhospsanc_utl-amt = t_amt.
****        Modify zhrhospsanc_utl from wa_zhrhospsanc_utl .
****        Commit Work.
****      Else.
****        If t_amt <> 0  and t_amt is not initial.
****          If WA_9920_PAY_SEL1-ZAMTPCSTOTAL > t_amt.
****            Message e023(ZHR) .
****          Else.
****          wa_zhrhospsanc_utl-BUKRS = L_BUKRS .
****          wa_zhrhospsanc_utl-GLHEAD = L_GLAC .
****          wa_zhrhospsanc_utl-GJAHR = L_FISCAL_YEAR.
****          wa_zhrhospsanc_utl-amt = t_amt.
****          wa_zhrhospsanc_utl-utilamt = WA_9920_PAY_SEL1-ZAMTPCSTOTAL.
****          wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
****          Insert into zhrhospsanc_utl values wa_zhrhospsanc_utl.
****          Commit Work.
****          Endif.
****        Else.
****          Message e027(ZHR) .
****        Endif.
****      Endif.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

          endif.

          MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL1.

*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
          " No component exists with the name "SPRPR". .
          " above stmts not working

          MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
          MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_PA9920.
          l_taxable = WA_9920_PAY_SEL1-taxable.
          CLEAR: WA_9920_PAY_SEL1 , WA_9920_MSG.
*============*

* 2.
* ZHRMED_EMP_RECOV
*MANDT  MANDT CLNT  3
*PERNR  PERSNO  NUMC  8
*ZCRDNO CHAR10  CHAR  10
*CNTER  CHAR10  CHAR  10
*SUBTY  SUBTY CHAR  4
*RECOVERY_TYPE  CHAR50 CHAR  50
*
*RECOVERY_AMT CHAR10  CHAR  10
*VENDOR_NAME  CHAR20  CHAR  20
*UPDATE_STATUS  CHAR1 CHAR  1
*REMARKS  CHAR50  CHAR  50
*CREATED_ON DATUM DATS  8
*UPDATED_ON AEDTM DATS  8
*CREATED_BY UNAME CHAR  12
*UPDATED_BY AENAM CHAR  12

          " Modify table ZHRMED_EMP_RECOV
          WA_PA9920-MANDT = sy-mandt.
          if WA_PA9920-ZADV_TKN > 0.  " recovery amt exists

            MOVE-CORRESPONDING WA_PA9920 to WA_ZHRMED_EMP_RECOV .

            WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = WA_PA9920-ZADV_TKN .
            WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
            WA_ZHRMED_EMP_RECOV-UPDATE_STATUS = 'N' .


***begin of CR 30006427 CAB_ALOK
***            L_RECOVERY_AMT = -1 * WA_PA9920-ZADV_TKN .
            if count is INITIAL.
* WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = -1 * WA_PA9920-ZADV_TKN .
***end of CR 30006427  CAB_ALOK
              WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE = 'RECOV'.
*begin of CR 30006427 CAB_ALOK
            endif.
*            WA_ZHRMED_EMP_RECOV-REMARKS = 'REV'.

*            WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_9920_REV_SEL1-ZHOSPID .
            concatenate 'Lot:' WA_PA9920-ZLOT_NO INTO WA_ZHRMED_EMP_RECOV-REMARKS. "'REVERSAL'. "
            WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
*end of CR 30006427  CAB_ALOK

            WA_ZHRMED_EMP_RECOV-CREATED_ON = sy-datum .
            WA_ZHRMED_EMP_RECOV-CREATED_BY = sy-uname  .

            append WA_ZHRMED_EMP_RECOV to IST_ZHRMED_EMP_RECOV.
          endif. "//WA_PA9920-ZADV_TKN

* Append taxable amount.
          WA_PA9920-MANDT = sy-mandt.
          if l_taxable = 'Y'.  " if claim is taxable

            MOVE-CORRESPONDING WA_PA9920 to WA_ZHRMED_EMP_RECOV .

            WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = WA_PA9920-ZAMTPCSTOTAL .
            WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
            WA_ZHRMED_EMP_RECOV-UPDATE_STATUS = 'N' .
            WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE = 'TAXA'.
            concatenate 'Lot:' WA_PA9920-ZLOT_NO INTO WA_ZHRMED_EMP_RECOV-REMARKS. "'REVERSAL'. "
            WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
            WA_ZHRMED_EMP_RECOV-CREATED_ON = sy-datum .
            WA_ZHRMED_EMP_RECOV-CREATED_BY = sy-uname  .

            append WA_ZHRMED_EMP_RECOV to IST_ZHRMED_EMP_RECOV.
*Begin of <RD1K994929>  CAB_PAREEK 17.10.2014
          else.
            MOVE-CORRESPONDING WA_PA9920 to WA_ZHRMED_EMP_RECOV .

            WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = WA_PA9920-ZAMTPCSTOTAL .
            WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
            WA_ZHRMED_EMP_RECOV-UPDATE_STATUS = 'N' .
            WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE = 'NTAXA'.
            concatenate 'Lot:' WA_PA9920-ZLOT_NO INTO WA_ZHRMED_EMP_RECOV-REMARKS. "'REVERSAL'. "
            WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
            WA_ZHRMED_EMP_RECOV-CREATED_ON = sy-datum .
            WA_ZHRMED_EMP_RECOV-CREATED_BY = sy-uname  .

            append WA_ZHRMED_EMP_RECOV to IST_ZHRMED_EMP_RECOV.
          endif. "//WA_PA9920-ZADV_TKN
*End of <RD1K994929>  CAB_PAREEK 17.10.2014
          CLEAR: WA_9920_PAY_SEL, WA_PA9920, WA_ZHRMED_EMP_RECOV , l_taxable.
        ENDLOOP.

*================
**  if IST_PA9920 is NOT INITIAL.
**    MODIFY PA9920  from table IST_PA9920.
**  endif.
*=================*
        if IST_ZHRMED_EMP_RECOV is NOT INITIAL.
          insert ZHRMED_EMP_RECOV from table IST_ZHRMED_EMP_RECOV.
        endif.

      endif. "//BDC is successful in Posting Mode

* Begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
      " Release all the locked PERNRs of the IST_9920_PAY after BDC (in any mode)
      clear l_tabix.
      clear: WA_9920_PAY_SEL1, WA_9920_MSG.
      LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE SEL = 'X'.
        l_tabix =   sy-tabix .
        MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_9920_MSG.

        CALL FUNCTION 'ZHR_MED_PERNR_UNLOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
          CHANGING
            WA_9920_MSG = WA_9920_MSG.

        MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL1.

        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
        CLEAR: WA_9920_PAY_SEL1 , WA_9920_MSG.
      ENDLOOP.
* End RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794

*show Popup message
      refresh ist_mesg.
      cnt = 0.
      loop at messtab into wa_messtab.
        cnt = cnt + 1.
        move wa_messtab-MSGTYP   to ist_mesg-msgty.
        move wa_messtab-MSGID     to ist_mesg-msgid.
        move wa_messtab-MSGNR to ist_mesg-msgno.
        move wa_messtab-MSGV1 to ist_mesg-msgv1.
        move wa_messtab-MSGV2 to ist_mesg-msgv2.
        move wa_messtab-MSGV3 to ist_mesg-msgv3.
        move wa_messtab-MSGV4 to ist_mesg-msgv4.
        move cnt to ist_mesg-LINENO.
        append ist_mesg.
        clear wa_messtab.

      endloop.

      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          I_MESSAGE_TAB = ist_mesg.

* in test mode if no error is found, C14Z_MESSAGES doesn't give any msg.
* hence give explicit msg
      if BDC_SUBRC = 0 and  TEST_FLAG = 'T'  and IST_MESG[] is initial.
        MESSAGE ID 'ZMSG' TYPE 'I' NUMBER '000'
           WITH 'Test run successful.' .
      endif.

    endif.  " //sy-subrc: Atleast one row having status 'unlocked' selected.

* begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
  ENDIF. " All pernrs locked
* end RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794

ENDFORM.                                                    " PAY_0605
*&---------------------------------------------------------------------*
*&      Form  BDC_F_02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_F_02_DEBIT  text
*      -->P_WA_F_02_HEADER  text
*      -->P_WA_F_02_CREDIT  text
*----------------------------------------------------------------------*
FORM BDC_F_02  TABLES   IST_F_02_DEBIT LIKE STRU_F_02_DEBIT
               USING  TEST_FLAG
                      WA_F_02_HEADER STRUCTURE STRU_F_02_HEADER
                      WA_F_02_CREDIT STRUCTURE STRU_F_02_CREDIT
               CHANGING bdc_subrc.

  data: l_mode(1).
  data :   WA_F_02_DEBIT TYPE  TY_F_02_DEBIT,
           WA_F_02_DEBIT_NEXT TYPE  TY_F_02_DEBIT.

  data: l_index  TYPE sy-tabix,
        l_lines TYPE sy-tabix,
        l_index_next TYPE sy-tabix.

  data: tmp_date type DATS.
  data: tmp_date_str(8).
  data: tmp_amt type string.
* begin RD1K977728 CAB_ALOK CR 30006277
  data: tmp_c(1).
  tmp_c = ''.
* end RD1K977728 CAB_ALOK CR 30006277
  REFRESH : bdcdata , messtab .

***
  perform bdc_dynpro      using 'SAPMF05A' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  clear: tmp_date.
  CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
    EXPORTING
      YYYYMMDD = WA_F_02_HEADER-BLDAT
    IMPORTING
      DDMMYYYY = tmp_date.

  """"""""
  "added by lipsy on 22.09.2015 for simultaneous updation in ims RD1K998594
  clear:  tmp_date_update.
  tmp_date_update = WA_F_02_HEADER-BLDAT.
  "end of addition by lipsy on 22.9.2015 for simultaneous updation in ims RD1K998594
  """""""""

  perform bdc_field       using 'BKPF-BLDAT'
                                 tmp_date  . "WA_F_02_HEADER-BLDAT " '20101126'.
  perform bdc_field       using 'BKPF-BLART'
                                 WA_F_02_HEADER-BLART. " 'KM'.
  perform bdc_field       using 'BKPF-BUKRS'
                                WA_F_02_HEADER-BUKRS . "'DLI'.

  clear tmp_date.
  CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
    EXPORTING
      YYYYMMDD = WA_F_02_HEADER-BUDAT
    IMPORTING
      DDMMYYYY = tmp_date.

  perform bdc_field       using 'BKPF-BUDAT'
                                 tmp_date  . "WA_F_02_HEADER-BUDAT  .  "'20101126'
****perform bdc_field       using 'BKPF-MONAT'
****                              '7'.
  perform bdc_field       using 'BKPF-WAERS'
                                WA_F_02_HEADER-WAERS. "'INR'.
  perform bdc_field       using 'BKPF-XBLNR'
                                WA_F_02_HEADER-XBLNR  . "'ref head'.
  perform bdc_field       using 'BKPF-BKTXT'
                                WA_F_02_HEADER-BKTXT. "'hospital head text'.
****perform bdc_field       using 'FS006-DOCID'
****                              ''.

  perform bdc_field       using 'RF05A-NEWBS'
                                '31'.
  perform bdc_field       using 'RF05A-NEWKO'
                                WA_F_02_CREDIT-VENDOR .     "'800045'.

*BEGIN RD1K976756  CAB_ALOK
*    PERFORM bdc_dynpro      USING 'SAPMF05A' '0330'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'BSEG-XREF1'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'BSEG-XREF1'
*                                  '.' .
*END RD1K976756  CAB_ALOK

***

  perform bdc_dynpro      using 'SAPMF05A' '0302'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RF05A-NEWBK'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=QS'.

  clear tmp_amt.
  Move WA_F_02_CREDIT-WRBTR to tmp_amt.
  perform bdc_field       using 'BSEG-WRBTR'
                               tmp_amt.
****perform bdc_field       using 'BSEG-MWSKZ'
****                              '**'.
  perform bdc_field       using 'BSEG-SECCO'
                                WA_F_02_CREDIT-SECCO. "'dli'.
****perform bdc_field       using 'BSEG-ZTERM'
****                              '0001'.

  clear tmp_date.
  CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
    EXPORTING
      YYYYMMDD = WA_F_02_CREDIT-ZFBDT
    IMPORTING
      DDMMYYYY = tmp_date.
  perform bdc_field       using 'BSEG-ZFBDT'
                                tmp_date . "
****perform bdc_field       using 'BSEG-ZLSPR'
****                              'X'.
  perform bdc_field       using 'BSEG-KIDNO'
                                WA_F_02_CREDIT-KIDNO. "
  perform bdc_field       using 'BSEG-SGTXT'
                                WA_F_02_CREDIT-SGTXT. "'


  READ TABLE IST_F_02_DEBIT into WA_F_02_DEBIT index 1.

  perform bdc_field       using 'RF05A-NEWBS'
                                '40'.
  perform bdc_field       using 'RF05A-NEWKO'
                                WA_F_02_DEBIT-GLAC.         "
  perform bdc_field       using 'RF05A-NEWBK'
                                WA_F_02_DEBIT-COMPNY_PERNR . "

  data: WA_WITHT type ty_witht.
  data: l_tabix type sy-tabix.
  data: c_tabix(2).
  data: s_tabix(4).
  data: S_WT_BASE(22),
        S_WT_WITHCD(23).

  clear: WA_PAY.
  REFRESH : ist_9920_pay_tmp, IST_WITHT.

  ist_9920_pay_tmp[] =  ist_9920_pay[].
  read table ist_9920_pay_tmp into wa_pay index 1.

  select WITHT from LFBW
    into CORRESPONDING FIELDS OF TABLE IST_WITHT
      where LIFNR = WA_PAY-ZHOSPID
           and BUKRS = G_USER_BUKRS
* begin RD1K979096 CAB_ALOK ZHRHOSP - CR 30006712
           and WT_SUBJCT = 'X'.
* end RD1K979096 CAB_ALOK ZHRHOSP - CR 30006712

  if IST_WITHT[] is not initial.

    SORT IST_WITHT BY WITHT ASCENDING.
    DELETE ADJACENT DUPLICATES FROM IST_WITHT COMPARING WITHT.
    delete IST_WITHT where WITHT CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    read table IST_WITHT into WA_WITHT with key WITHT = G_WITHT.
    l_tabix = sy-tabix.

    move l_tabix to c_tabix.
    SHIFT c_tabix RIGHT DELETING TRAILING SPACE.
    OVERLAY c_tabix WITH '00'.
    concatenate '(' c_tabix ')' into s_tabix.
    CONCATENATE 'WITH_DIALG-WT_BASE' '(' c_tabix ')' into S_WT_BASE.
    concatenate 'WITH_ITEM-WT_WITHCD' '(' c_tabix ')' into S_WT_WITHCD.

    perform bdc_dynpro      using 'SAPLFWTD' '0100'.
    perform bdc_field       using 'BDC_CURSOR'
                                   S_WT_BASE.  "
    perform bdc_field       using 'BDC_OKCODE'
                                  '=GO'.
    if WA_F_02_CREDIT-WT_WITHCD is NOT INITIAL.

      perform bdc_field       using  S_WT_WITHCD
                                     WA_F_02_CREDIT-WT_WITHCD.
      if WA_F_02_CREDIT-WT_BASE is NOT INITIAL.
        clear tmp_amt.
        Move WA_F_02_CREDIT-WT_BASE to tmp_amt.
        perform bdc_field       using S_WT_BASE
                                    tmp_amt.
      endif.
    endif.

  ENDIF. "/ IST_WITHT[] is not initial.


  Describe TABLE IST_F_02_DEBIT LINES l_lines.  "** Dr.**
  clear WA_F_02_DEBIT.
  loop at IST_F_02_DEBIT into WA_F_02_DEBIT.
    l_index = sy-tabix.
    perform bdc_dynpro      using 'SAPMF05A' '0300'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'BSEG-WRBTR'.  "
    if l_index < l_lines.
      perform bdc_field       using 'BDC_OKCODE'
                                     '/00'.       " '=BS'      "'/00'.
    else .
      perform bdc_field       using 'BDC_OKCODE'
                                   '=BS'.       " '=BS'      "'/00'.
    endif.

    clear tmp_amt.
    Move WA_F_02_DEBIT-SPLIT_AMT to tmp_amt.
    perform bdc_field       using 'BSEG-WRBTR'
                                   tmp_amt. "WA_F_02_DEBIT-SPLIT_AMT. "'5000'.
    clear tmp_date.
    CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
      EXPORTING
        YYYYMMDD = WA_F_02_DEBIT-VALUT
      IMPORTING
        DDMMYYYY = tmp_date.

    perform bdc_field       using 'BSEG-VALUT'
                                   tmp_date  . "WA_F_02_DEBIT-VALUT. "'29.10.2010'.
    perform bdc_field       using 'BSEG-ZUONR'
                                  WA_F_02_DEBIT-PERNR.      "'23733'.
    perform bdc_field       using 'BSEG-SGTXT'
                                  WA_F_02_DEBIT-SGTXT. "'line item text vendor'.

    if l_index < l_lines.
      l_index_next = l_index + 1.
      read table IST_F_02_DEBIT into WA_F_02_DEBIT_NEXT index l_index_next.
      perform bdc_field       using 'RF05A-NEWBS'
                                    '40'.
      perform bdc_field       using 'RF05A-NEWKO'
                                    WA_F_02_DEBIT_NEXT-GLAC. "'200307'.
      perform bdc_field       using 'RF05A-NEWBK'
                                    WA_F_02_DEBIT_NEXT-COMPNY_PERNR . "'DLI'.

    endif.

* begin RD1K977728 CAB_ALOK  CR 30006277
    if WA_F_02_HEADER-BUKRS <> WA_F_02_DEBIT-COMPNY_PERNR.
      tmp_c  = 'X'.
    endif.
* end RD1K977728 CAB_ALOK  CR 30006277

****perform bdc_field       using 'DKACB-FMORE'      "######## NOT NEEDED
****                              'X'.

    perform bdc_dynpro      using 'SAPLKACB' '0002'.

    if  WA_F_02_DEBIT-WBS_ELE is not INITIAL.
      perform bdc_field       using 'BDC_CURSOR'
                                    'COBL-PS_POSID'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTE'.
      perform bdc_field       using 'COBL-PS_POSID'
                                    WA_F_02_DEBIT-WBS_ELE.
*perform bdc_field       using 'COBL-FIPEX'
*                              '200302'.
*perform bdc_field       using 'COBL-FIPOS'
*                              '200302'.
    elseif WA_F_02_DEBIT-COST_CTR is not INITIAL.

      perform bdc_field       using 'BDC_CURSOR'
                                    'COBL-KOSTL'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTE'.
      perform bdc_field       using 'COBL-KOSTL'
                                    WA_F_02_DEBIT-COST_CTR . "'DLICSGEEXE'.
*perform bdc_field       using 'COBL-FIPEX'
*                              'WELFARE'.
*perform bdc_field       using 'COBL-FIPOS'
*                              'WELFARE'.

    endif.

  endloop.

* begin RD1K977728 CAB_ALOK - CR 30006277

  if tmp_c  = 'X'.

    perform bdc_dynpro      using 'SAPMF05A' '0701'.
  else .
    perform bdc_dynpro      using 'SAPMF05A' '0700'.
  endif.
  perform bdc_field       using 'BDC_CURSOR'
                                'RF05A-NEWBS'.

* end RD1K977728 CAB_ALOK  - CR 30006277
***
  if TEST_FLAG = 'P'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=BU'.
  elseif TEST_FLAG = 'T'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '/EEND'.
    perform bdc_dynpro      using 'SAPLSPO1' '0200'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=YES'.
  endif.

*perform bdc_transaction using 'F-02'.
*perform close_group.
*Begin RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
*  l_mode = 'N'.
  data: WA_ZFI_MED_FOREGRND TYPE ZFI_MED_FOREGRND.
  SELECT single *
    from ZFI_MED_FOREGRND
      INTO WA_ZFI_MED_FOREGRND
      WHERE UNAME = SY-UNAME.
  if sy-subrc = 0.
    l_mode = 'A'.
  else.
    l_mode = 'N'.
  endif.
*end RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
  call transaction 'F-02' using bdcdata mode l_mode messages into messtab.  " 'N', 'E' , 'A', 'P'
  bdc_subrc = sy-subrc.

data:        wa_messtab1 type bdcmsgcoll .
    READ TABLE messtab WITH KEY  MSGTYP = 'E' INTO wa_messtab1.
    if wa_messtab1-MSGTYP = 'E'.
        bdc_subrc = 4.
    endif.
  """""""""""""""""""""
    "added by lipsy on 22.09.2015 for simultaneous updation in ims RD1K998594

  refresh:itab_bkpf_update[],itab_bseg_update.
  clear:wa_bkpf_update,wa_bseg_update.
  wait up to 5 seconds.
  if WA_F_02_HEADER-BKTXT is not initial.

  select * from bkpf
  INTO CORRESPONDING FIELDS OF TABLE itab_bkpf_update
  WHERE bukrs = WA_F_02_HEADER-BUKRS
   and    blart = WA_F_02_HEADER-BLART
   and bktxt = WA_F_02_HEADER-BKTXT
   and bldat =   tmp_date_update ORDER BY PRIMARY KEY.



 if sy-subrc = 0.

READ TABLE  itab_bkpf_update INTO wa_bkpf_update INDEX 1.




if wa_bkpf_update-belnr is NOT INITIAL.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  select * from bseg
  INTO CORRESPONDING FIELDS OF TABLE itab_bseg_update
  WHERE bukrs = WA_F_02_HEADER-BUKRS
  and  belnr = wa_bkpf_update-belnr
  and  gjahr  = wa_bkpf_update-gjahr
  and bschl = '31' ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

    if sy-subrc = 0.


 LOOP at  itab_bseg_update INTO wa_bseg_update.

if    wa_bseg_update-kidno+0(1) = '1' or wa_bseg_update-kidno+0(1) = '4' or wa_bseg_update-kidno+0(1) = '6'

    or wa_bseg_update-kidno+0(1) = '8'.

 call function 'ZMM_IMS_UPDATE_HOSP'
      exporting
       V_BELNR = wa_bkpf_update-belnr
       V_BUDAT = wa_bkpf_update-budat
       V_DMBTR = wa_bseg_update-DMBTR
       V_WRBTR = wa_bseg_update-WRBTR
       V_WAERS =   wa_bkpf_update-WAERS
       V_trackno = wa_bseg_update-kidno.

 endif.

endloop.


endif.
endif.
endif.

endif.


  "end of addition by lipsy on 22.09.2015 for simultaneous updation in ims RD1K998594

  """"""""""""""""""""""""


ENDFORM.                                                    " BDC_F_02
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
form bdc_dynpro using program dynpro.
  clear bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  append bdcdata.
endform.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
form bdc_field using fnam fval.
  clear bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  append bdcdata.
endform.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_701
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_701 .
  DATA: submit_pernr TYPE pernr_d.
  DATA: submit_name TYPE emnam.
  DATA: submit_orgeh TYPE orgeh.
  DATA: submit_plans TYPE plans.
  DATA: submit_persa TYPE persa.
  DATA: submit_bukrs TYPE bukrs.


*  PERFORM GETDATA_USER
*       changing submit_pernr submit_name submit_orgeh
*          submit_plans submit_persa submit_bukrs.


  PERFORM GETDATA_IST_9920_STATUS tables IST_9920_STATUS using G_USER_BUKRS. "submit_bukrs .

ENDFORM.                    " GET_DATA_701
*&---------------------------------------------------------------------*
*&      Form  GETDATA_IST_9920_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_9920_STATUS  text
*      -->P_SUBMIT_BUKRS  text
*----------------------------------------------------------------------*

* Begin RD1K981765 CR: 30007609 CAB_ALOK
*FORM GETDATA_IST_9920_STATUS  TABLES IST_9920_STATUS USING SUBMIT_BUKRS.
FORM GETDATA_IST_9920_STATUS  tables IST_9920_STATUS STRUCTURE IST_9920_STATUS using submit_bukrs.
* End RD1K981765 CR: 30007609 CAB_ALOK

  DATA: wa_9920_SUBMIT1 TYPE ty_submit,
              l_tabix  TYPE sy-tabix.

  data: R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
        R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE,
        R_PERNR TYPE RANGE OF PA9920-PERNR WITH HEADER LINE,
        R_ZLOT_NO TYPE RANGE OF PA9920-ZLOT_NO WITH HEADER LINE,
        R_UNAME TYPE RANGE OF PA9920-UNAME WITH HEADER LINE,
        R_CNTER TYPE RANGE OF PA9920-CNTER WITH HEADER LINE .


*get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
* and company code of record = comapny code of current user.


*Put data in range so that 'IN' keyword can be used in SELECT stmt.
  clear:  R_BEGDA, R_ZHOSPID, R_PERNR, R_ZLOT_NO,  R_UNAME, R_CNTER.
  refresh:  R_BEGDA, R_ZHOSPID, R_PERNR, R_ZLOT_NO,  R_UNAME, R_CNTER.

*Create RANGES
  R_BEGDA-SIGN = 'I'.
  R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
  R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
  if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
    R_BEGDA-OPTION = 'BT'.
  else.
    R_BEGDA-OPTION = 'EQ'.
  endif.
  append R_BEGDA.
  if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
    clear: R_BEGDA.
    refresh:  R_BEGDA.
  endif.


  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.

  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_HIGH.

  R_ZHOSPID-SIGN = 'I'.
  R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
  R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
  if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
    R_ZHOSPID-OPTION = 'BT'.
  else.
    R_ZHOSPID-OPTION = 'EQ'.
  endif.
  append R_ZHOSPID.
  if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
    clear: R_ZHOSPID.
    refresh:  R_ZHOSPID.
  endif.


  R_PERNR-SIGN = 'I'.
  R_PERNR-LOW = ZPMED_SUBMIT-PERNR_LOW.
  R_PERNR-HIGH = ZPMED_SUBMIT-PERNR_HIGH.
  if R_PERNR-LOW is NOT INITIAL and  R_PERNR-HIGH is NOT INITIAL.
    R_PERNR-OPTION = 'BT'.
  else.
    R_PERNR-OPTION = 'EQ'.
  endif.
  append R_PERNR.
  if R_PERNR-LOW is INITIAL and  R_PERNR-HIGH is INITIAL.
    clear: R_PERNR.
    refresh:  R_PERNR.
  endif.

  R_ZLOT_NO-SIGN = 'I'.
  R_ZLOT_NO-LOW = ZPMED_SUBMIT-ZLOT_NO_LOW.
  R_ZLOT_NO-HIGH = ZPMED_SUBMIT-ZLOT_NO_HIGH.
  if R_ZLOT_NO-LOW is NOT INITIAL and  R_ZLOT_NO-HIGH is NOT INITIAL.
    R_ZLOT_NO-OPTION = 'BT'.
  else.
    R_ZLOT_NO-OPTION = 'EQ'.
  endif.
  append R_ZLOT_NO.
  if R_ZLOT_NO-LOW is INITIAL and  R_ZLOT_NO-HIGH is INITIAL.
    clear: R_ZLOT_NO.
    refresh:  R_ZLOT_NO.
  endif.

  R_UNAME-SIGN = 'I'.
  R_UNAME-LOW = ZPMED_SUBMIT-UNAME_LOW.
  R_UNAME-HIGH = ZPMED_SUBMIT-UNAME_HIGH.
  if R_UNAME-LOW is NOT INITIAL and  R_UNAME-HIGH is NOT INITIAL.
    R_UNAME-OPTION = 'BT'.
  else.
    R_UNAME-OPTION = 'EQ'.
  endif.
  append R_UNAME.
  if R_UNAME-LOW is INITIAL and  R_UNAME-HIGH is INITIAL.
    clear: R_UNAME.
    refresh:  R_UNAME.
  endif.

  R_CNTER-SIGN = 'I'.
  R_CNTER-LOW = ZPMED_SUBMIT-CNTER_LOW.
  R_CNTER-HIGH = ZPMED_SUBMIT-CNTER_HIGH.
  if R_CNTER-LOW is NOT INITIAL and  R_CNTER-HIGH is NOT INITIAL.
    R_CNTER-OPTION = 'BT'.
  else.
    R_CNTER-OPTION = 'EQ'.
  endif.
  append R_CNTER.
  if R_CNTER-LOW is INITIAL and  R_CNTER-HIGH is INITIAL.
    clear: R_CNTER.
    refresh:  R_CNTER.
  endif.

  select * from PA9920
    into corresponding fields of table IST_9920_STATUS
      where BEGDA IN R_BEGDA " as YYYYMMDD
        and ZHOSPID IN R_ZHOSPID " as 0000800001, S
        and PERNR IN R_PERNR
        and ZLOT_NO IN R_ZLOT_NO
        and UNAME IN R_UNAME
        and CNTER IN R_CNTER
        and GRPVL = submit_bukrs
        and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' ) .

* Begin RD1K981765 CR: 30007609 CAB_ALOK
  Sort IST_9920_STATUS by CNTER ASCENDING.
* End RD1K981765 CR: 30007609 CAB_ALOK

*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
  data: WA_9919 type PA9919,
        fname LIKE pa0021-favor,
        lname LIKE pa0021-fanam.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP

** Fill INFTY, serial no.
  loop at IST_9920_STATUS into wa_9920_SUBMIT1.
    l_tabix = sy-tabix.
    wa_9920_SUBMIT1-INFTY = '9920'.
    wa_9920_SUBMIT1-serial_no = l_tabix.
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
* Derive patient's name

    clear: WA_9919, fname, lname.
    SELECT * FROM PA9919
 INTO WA_9919 UP TO 1 ROWS WHERE PERNR = WA_9920_SUBMIT1-PERNR AND ZCRDNO = WA_9920_SUBMIT1-ZCRDNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if WA_9919-subty <> '16'.
      SELECT FAVOR FANAM
 FROM PA0021 INTO ( FNAME , LNAME ) UP TO 1 ROWS WHERE PERNR = WA_9919-PERNR AND SUBTY = WA_9919-SUBTY AND OBJPS = WA_9919-OBJPS AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    elseif WA_9919-subty = '16'.
      SELECT ENAME
 FROM PA0001 INTO FNAME UP TO 1 ROWS WHERE PERNR = WA_9919-PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.
    CONCATENATE fname lname INTO wa_9920_SUBMIT1-patient_name SEPARATED BY space.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
    MODIFY IST_9920_STATUS FROM  WA_9920_SUBMIT1 INDEX l_tabix.
  endloop.

*begin RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
  clear G_VENDOR_NAME.
  if ZPMED_SUBMIT-ZHOSPID_LOW is not INITIAL
     and ZPMED_SUBMIT-ZHOSPID_HIGH is INITIAL.
    select single NAME1 from ZHR_MED_VENDORS
      into  G_VENDOR_NAME
        where BUKRS = P9920-GRPVL
          and LIFNR = ZPMED_SUBMIT-ZHOSPID_LOW.
  endif.
*end RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
ENDFORM.                    " GETDATA_IST_9920_STATUS

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC_STATUS_REP USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
*     WHEN 'INSR'.                      "insert row
*       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME.
*       CLEAR P_OK.
*
*     WHEN 'DELE'.                      "delete row
*       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME
*                                         P_MARK_NAME.
*       CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
* Report download
    WHEN 'DNLD'.
      PERFORM DOWNLOAD_REPORT.
      CLEAR P_OK.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
  ENDCASE.

ENDFORM.                              " USER_OK_TC

*****&---------------------------------------------------------------------*
*****&      Form  FCODE_INSERT_ROW                                         *
*****&---------------------------------------------------------------------*
**** FORM fcode_insert_row
****               USING    P_TC_NAME           TYPE DYNFNAM
****                        P_TABLE_NAME             .
****
*****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
****   DATA L_LINES_NAME       LIKE FELD-NAME.
****   DATA L_SELLINE          LIKE SY-STEPL.
****   DATA L_LASTLINE         TYPE I.
****   DATA L_LINE             TYPE I.
****   DATA L_TABLE_NAME       LIKE FELD-NAME.
****   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
****   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
****   FIELD-SYMBOLS <LINES>              TYPE I.
*****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
****
****   ASSIGN (P_TC_NAME) TO <TC>.
****
*****&SPWIZARD: get the table, which belongs to the tc                     *
****   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
****   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
****
*****&SPWIZARD: get looplines of TableControl                              *
****   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
****   ASSIGN (L_LINES_NAME) TO <LINES>.
****
*****&SPWIZARD: get current line                                           *
****   GET CURSOR LINE L_SELLINE.
****   IF SY-SUBRC <> 0.                   " append line to table
****     L_SELLINE = <TC>-LINES + 1.
*****&SPWIZARD: set top line                                               *
****     IF L_SELLINE > <LINES>.
****       <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
****     ELSE.
****       <TC>-TOP_LINE = 1.
****     ENDIF.
****   ELSE.                               " insert line into table
****     L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
****     L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
****   ENDIF.
*****&SPWIZARD: set new cursor line                                        *
****   L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
****
*****&SPWIZARD: insert initial line                                        *
****   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
****   <TC>-LINES = <TC>-LINES + 1.
*****&SPWIZARD: set cursor                                                 *
****   SET CURSOR LINE L_LINE.
****
**** ENDFORM.                              " FCODE_INSERT_ROW
****
*****&---------------------------------------------------------------------*
*****&      Form  FCODE_DELETE_ROW                                         *
*****&---------------------------------------------------------------------*
**** FORM fcode_delete_row
****               USING    P_TC_NAME           TYPE DYNFNAM
****                        P_TABLE_NAME
****                        P_MARK_NAME   .
****
*****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
****   DATA L_TABLE_NAME       LIKE FELD-NAME.
****
****   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
****   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
****   FIELD-SYMBOLS <WA>.
****   FIELD-SYMBOLS <MARK_FIELD>.
*****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
****
****   ASSIGN (P_TC_NAME) TO <TC>.
****
*****&SPWIZARD: get the table, which belongs to the tc                     *
****   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
****   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
****
*****&SPWIZARD: delete marked lines                                        *
****   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.
****
****   LOOP AT <TABLE> ASSIGNING <WA>.
****
*****&SPWIZARD: access to the component 'FLAG' of the table header         *
****     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
****
****     IF <MARK_FIELD> = 'X'.
****       DELETE <TABLE> INDEX SYST-TABIX.
****       IF SY-SUBRC = 0.
****         <TC>-LINES = <TC>-LINES - 1.
****       ENDIF.
****     ENDIF.
****   ENDLOOP.
****
**** ENDFORM.                              " FCODE_DELETE_ROW
****
*****&---------------------------------------------------------------------*
*****&      Form  COMPUTE_SCROLLING_IN_TC
*****&---------------------------------------------------------------------*
*****       text
*****----------------------------------------------------------------------*
*****      -->P_TC_NAME  name of tablecontrol
*****      -->P_OK       ok code
*****----------------------------------------------------------------------*
**** FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
****                                       P_OK.
*****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
****   DATA L_TC_NEW_TOP_LINE     TYPE I.
****   DATA L_TC_NAME             LIKE FELD-NAME.
****   DATA L_TC_LINES_NAME       LIKE FELD-NAME.
****   DATA L_TC_FIELD_NAME       LIKE FELD-NAME.
****
****   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
****   FIELD-SYMBOLS <LINES>      TYPE I.
*****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
****
****   ASSIGN (P_TC_NAME) TO <TC>.
*****&SPWIZARD: get looplines of TableControl                              *
****   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
****   ASSIGN (L_TC_LINES_NAME) TO <LINES>.
****
****
*****&SPWIZARD: is no line filled?                                         *
****   IF <TC>-LINES = 0.
*****&SPWIZARD: yes, ...                                                   *
****     L_TC_NEW_TOP_LINE = 1.
****   ELSE.
*****&SPWIZARD: no, ...                                                    *
****     CALL FUNCTION 'SCROLLING_IN_TABLE'
****          EXPORTING
****               ENTRY_ACT             = <TC>-TOP_LINE
****               ENTRY_FROM            = 1
****               ENTRY_TO              = <TC>-LINES
****               LAST_PAGE_FULL        = 'X'
****               LOOPS                 = <LINES>
****               OK_CODE               = P_OK
****               OVERLAPPING           = 'X'
****          IMPORTING
****               ENTRY_NEW             = L_TC_NEW_TOP_LINE
****          EXCEPTIONS
*****              NO_ENTRY_OR_PAGE_ACT  = 01
*****              NO_ENTRY_TO           = 02
*****              NO_OK_CODE_OR_PAGE_GO = 03
****               OTHERS                = 0.
****   ENDIF.
****
*****&SPWIZARD: get actual tc and column                                   *
****   GET CURSOR FIELD L_TC_FIELD_NAME
****              AREA  L_TC_NAME.
****
****   IF SYST-SUBRC = 0.
****     IF L_TC_NAME = P_TC_NAME.
*****&SPWIZARD: et actual column                                           *
****       SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
****     ENDIF.
****   ENDIF.
****
*****&SPWIZARD: set the new top line                                       *
****   <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.
****
****
**** ENDFORM.                              " COMPUTE_SCROLLING_IN_TC
****
*****&---------------------------------------------------------------------*
*****&      Form  FCODE_TC_MARK_LINES
*****&---------------------------------------------------------------------*
*****       marks all TableControl lines
*****----------------------------------------------------------------------*
*****      -->P_TC_NAME  name of tablecontrol
*****----------------------------------------------------------------------*
****FORM FCODE_TC_MARK_LINES USING P_TC_NAME
****                               P_TABLE_NAME
****                               P_MARK_NAME.
*****&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
****  DATA L_TABLE_NAME       LIKE FELD-NAME.
****
****  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
****  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
****  FIELD-SYMBOLS <WA>.
****  FIELD-SYMBOLS <MARK_FIELD>.
*****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
****
****  ASSIGN (P_TC_NAME) TO <TC>.
****
*****&SPWIZARD: get the table, which belongs to the tc                     *
****   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
****   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
****
*****&SPWIZARD: mark all filled lines                                      *
****  LOOP AT <TABLE> ASSIGNING <WA>.
****
*****&SPWIZARD: access to the component 'FLAG' of the table header         *
****     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
****
****     <MARK_FIELD> = 'X'.
****  ENDLOOP.
****ENDFORM.                                          "fcode_tc_mark_lines
****
*****&---------------------------------------------------------------------*
*****&      Form  FCODE_TC_DEMARK_LINES
*****&---------------------------------------------------------------------*
*****       demarks all TableControl lines
*****----------------------------------------------------------------------*
*****      -->P_TC_NAME  name of tablecontrol
*****----------------------------------------------------------------------*
****FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
****                                 P_TABLE_NAME
****                                 P_MARK_NAME .
*****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
****  DATA L_TABLE_NAME       LIKE FELD-NAME.
****
****  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
****  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
****  FIELD-SYMBOLS <WA>.
****  FIELD-SYMBOLS <MARK_FIELD>.
*****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
****
****  ASSIGN (P_TC_NAME) TO <TC>.
****
*****&SPWIZARD: get the table, which belongs to the tc                     *
****   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
****   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
****
*****&SPWIZARD: demark all filled lines                                    *
****  LOOP AT <TABLE> ASSIGNING <WA>.
****
*****&SPWIZARD: access to the component 'FLAG' of the table header         *
****     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
****
****     <MARK_FIELD> = SPACE.
****  ENDLOOP.
****ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  GET_USER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_USER_DATA .
*get Data of the Logged-in user
*-------------------------------------------------------------------
*Get PERNR of the user_id.

  clear: G_USER_PERNR, G_USER_BUKRS, g_user_werks, g_user_name, g_user_desig .
**  CPF No. (PERNR )
* begin  RD1K977570 CAB_ALOK - CR 30006026
* For Core team members, get pernr data from Core team table
* as communication data is not available for their userid.
  select single PERNR
    from ZHRCORETEAM_MED
     into G_USER_PERNR
      where USERID = SY-UNAME.
  if sy-subrc = 0.
* set Core_team_ID flag,  pop-up for Company code, Location, Name
    G_CORE_TEAM_FLAG = 'X'.
    PERFORM POPUP_GET_VALUES..
  else.
* find pernr from communication data
* end  RD1K977570 CAB_ALOK - CR 30006026
    SELECT PERNR
 FROM PA0105 INTO G_USER_PERNR UP TO 1 ROWS WHERE USRID = SY-UNAME AND SUBTY = '0001' AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc <> 0.
      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'USER ID' sy-uname text-012 .
    endif.
* begin  RD1K977570 CAB_ALOK - CR 30006026
  endif.
* end  RD1K977570 CAB_ALOK - CR 30006026
** Company code, Location, Name
  select single BUKRS WERKS ENAME
    from PA0001
    into (G_USER_BUKRS, g_user_werks, g_user_name ) " company code, location, name
            where pernr = G_USER_PERNR
               AND begda <=   sy-datum
               AND endda >=  sy-datum.

*  select zhr_med_users table for some authorization for overridinh
  SELECT * FROM ZHR_MED_USERS UP TO 1 ROWS
 WHERE USERID = SY-UNAME AND
 BEGDA LE SY-DATUM AND ENDDA GE SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  if sy-subrc = 0.
    G_USER_BUKRS = ZHR_MED_USERS-bukrs.
  endif.

  if G_USER_BUKRS is initial.
    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Company code of' G_USER_PERNR text-012 .
  endif.
  if G_USER_WERKS is initial.
    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Location of' G_USER_PERNR text-012 .
  endif.
  if G_USER_NAME is initial.
    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Name of' G_USER_PERNR text-012 .
  endif.

***PA9930
**PERNR   = 77783
**  ENDDA
** BEGDA
*DESIGNO = 304
*R_P_CD = MRP80
*VERSION = 1

***  ZDESIGNATION_REV
**DESIG_CODE                        304
**R_P_CD                            MRP80
**VERSION                           1
*DESIG_TEXT            Senior Programming Officer

  data: L_DESIGNO type PA9930-DESIGNO,
          L_R_P_CD type PA9930-R_P_CD,
           L_VERSION type PA9930-VERSION.


** Designation:
  SELECT DESIGNO R_P_CD VERSION FROM PA9930
 INTO ( L_DESIGNO , L_R_P_CD , L_VERSION ) UP TO 1 ROWS WHERE PERNR = G_USER_PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  select single DESIG_TEXT  from ZDESIGNATION_REV
   into G_USER_DESIG
            where DESIG_CODE = L_DESIGNO
               AND R_P_CD =   L_R_P_CD
               AND VERSION =  L_VERSION.
*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
** Get Employee Subgroup (level E1,E2 etc.)
  SELECT SINGLE persk
        FROM pa0001
        INTO G_USER_PERSK
          WHERE pernr = G_USER_PERNR
           AND begda =< sy-datum
           AND endda >= sy-datum.
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP


*  CALL FUNCTION 'HR_GETEMPLOYEEDATA_FROMUSER'  "Very Slow
*     EXPORTING
*      username                        = sy-uname
*      validbegin                      =  sy-datum
**    check_auth                      =  space
*    IMPORTING
*      employeenumber                  = g_user_pernr
*      name                            = g_user_name
*      orgunit                         = g_user_orgeh
*      position                        = g_user_plans
*      personnelarea                   = g_user_persa
*      COMPANYCODE                     = g_user_bukrs
*
*    EXCEPTIONS
*      user_not_found                  = 1
*      countrygrouping_not_found       = 2
*      infty_not_found                 = 3
*      OTHERS                          = 4
*             .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

ENDFORM.                    " GET_USER_DATA

*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_801
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_801 .
  PERFORM GETDATA_IST_9920_DELETE tables IST_9920_DELETE using G_USER_BUKRS .

ENDFORM.                    " GET_DATA_801
*&---------------------------------------------------------------------*
*&      Form  GETDATA_IST_9920_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_9920_DELETE  text
*      -->P_G_USER_BUKRS  text
*----------------------------------------------------------------------*


* Begin RD1K981765 CR: 30007609 CAB_ALOK
*FORM GETDATA_IST_9920_DELETE  TABLES IST_9920_DELETE USING G_USER_BUKRS.
FORM GETDATA_IST_9920_DELETE  tables IST_9920_DELETE STRUCTURE IST_9920_DELETE using submit_bukrs.
* End RD1K981765 CR: 30007609 CAB_ALOK

  DATA: wa_9920_SUBMIT1 TYPE ty_submit,
              l_tabix  TYPE sy-tabix.

  data: R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
        R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE,
        R_PERNR TYPE RANGE OF PA9920-PERNR WITH HEADER LINE,
        R_ZLOT_NO TYPE RANGE OF PA9920-ZLOT_NO WITH HEADER LINE,
        R_UNAME TYPE RANGE OF PA9920-UNAME WITH HEADER LINE,
        R_CNTER TYPE RANGE OF PA9920-CNTER WITH HEADER LINE ,
        R_ZSTATUS TYPE RANGE OF PA9920-ZSTATUS WITH HEADER LINE .


*get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
* and company code of record = comapny code of current user
* and status = NEW/REJMO/REJFI.


*Put data in range so that 'IN' keyword can be used in SELECT stmt.
  clear:  R_BEGDA, R_ZHOSPID, R_PERNR, R_ZLOT_NO,  R_UNAME, R_CNTER, R_ZSTATUS.
  refresh:  R_BEGDA, R_ZHOSPID, R_PERNR, R_ZLOT_NO,  R_UNAME, R_CNTER, R_ZSTATUS.

*Create RANGES
  R_BEGDA-SIGN = 'I'.
  R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
  R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
  if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
    R_BEGDA-OPTION = 'BT'.
  else.
    R_BEGDA-OPTION = 'EQ'.
  endif.
  append R_BEGDA.
  if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
    clear: R_BEGDA.
    refresh:  R_BEGDA.
  endif.


  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.

  CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
    CHANGING
      VENDOR = ZPMED_SUBMIT-ZHOSPID_HIGH.

  R_ZHOSPID-SIGN = 'I'.
  R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
  R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
  if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
    R_ZHOSPID-OPTION = 'BT'.
  else.
    R_ZHOSPID-OPTION = 'EQ'.
  endif.
  append R_ZHOSPID.
  if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
    clear: R_ZHOSPID.
    refresh:  R_ZHOSPID.
  endif.


  R_PERNR-SIGN = 'I'.
  R_PERNR-LOW = ZPMED_SUBMIT-PERNR_LOW.
  R_PERNR-HIGH = ZPMED_SUBMIT-PERNR_HIGH.
  if R_PERNR-LOW is NOT INITIAL and  R_PERNR-HIGH is NOT INITIAL.
    R_PERNR-OPTION = 'BT'.
  else.
    R_PERNR-OPTION = 'EQ'.
  endif.
  append R_PERNR.
  if R_PERNR-LOW is INITIAL and  R_PERNR-HIGH is INITIAL.
    clear: R_PERNR.
    refresh:  R_PERNR.
  endif.

  R_ZLOT_NO-SIGN = 'I'.
  R_ZLOT_NO-LOW = ZPMED_SUBMIT-ZLOT_NO_LOW.
  R_ZLOT_NO-HIGH = ZPMED_SUBMIT-ZLOT_NO_HIGH.
  if R_ZLOT_NO-LOW is NOT INITIAL and  R_ZLOT_NO-HIGH is NOT INITIAL.
    R_ZLOT_NO-OPTION = 'BT'.
  else.
    R_ZLOT_NO-OPTION = 'EQ'.
  endif.
  append R_ZLOT_NO.
  if R_ZLOT_NO-LOW is INITIAL and  R_ZLOT_NO-HIGH is INITIAL.
    clear: R_ZLOT_NO.
    refresh:  R_ZLOT_NO.
  endif.

  R_UNAME-SIGN = 'I'.
  R_UNAME-LOW = ZPMED_SUBMIT-UNAME_LOW.
  R_UNAME-HIGH = ZPMED_SUBMIT-UNAME_HIGH.
  if R_UNAME-LOW is NOT INITIAL and  R_UNAME-HIGH is NOT INITIAL.
    R_UNAME-OPTION = 'BT'.
  else.
    R_UNAME-OPTION = 'EQ'.
  endif.
  append R_UNAME.
  if R_UNAME-LOW is INITIAL and  R_UNAME-HIGH is INITIAL.
    clear: R_UNAME.
    refresh:  R_UNAME.
  endif.

  R_CNTER-SIGN = 'I'.
  R_CNTER-LOW = ZPMED_SUBMIT-CNTER_LOW.
  R_CNTER-HIGH = ZPMED_SUBMIT-CNTER_HIGH.
  if R_CNTER-LOW is NOT INITIAL and  R_CNTER-HIGH is NOT INITIAL.
    R_CNTER-OPTION = 'BT'.
  else.
    R_CNTER-OPTION = 'EQ'.
  endif.
  append R_CNTER.
  if R_CNTER-LOW is INITIAL and  R_CNTER-HIGH is INITIAL.
    clear: R_CNTER.
    refresh:  R_CNTER.
  endif.

  R_ZSTATUS-SIGN = 'I'.
  R_ZSTATUS-LOW = ZPMED_SUBMIT-CNTER_LOW.
  R_ZSTATUS-HIGH = ZPMED_SUBMIT-CNTER_HIGH.
  if R_ZSTATUS-LOW is NOT INITIAL and  R_ZSTATUS-HIGH is NOT INITIAL.
    R_ZSTATUS-OPTION = 'BT'.
  else.
    R_ZSTATUS-OPTION = 'EQ'.
  endif.
  append R_ZSTATUS.
  if R_ZSTATUS-LOW is INITIAL and  R_ZSTATUS-HIGH is INITIAL.
    clear: R_ZSTATUS.
    refresh:  R_ZSTATUS.
  endif.


  select * from PA9920
    into corresponding fields of table IST_9920_DELETE
      where BEGDA IN R_BEGDA " as YYYYMMDD
        and ZHOSPID IN R_ZHOSPID " as 0000800001, S
        and PERNR IN R_PERNR
        and ZLOT_NO IN R_ZLOT_NO
        and UNAME IN R_UNAME
        and CNTER IN R_CNTER
        and ZSTATUS IN R_ZSTATUS
        and ( ZSTATUS = 'NEW' or ZSTATUS = 'REJMO' or ZSTATUS = 'REJFI' )
        and GRPVL = G_USER_BUKRS
        and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' ) .

* Begin RD1K981765 CR: 30007609 CAB_ALOK
  Sort IST_9920_DELETE by CNTER ASCENDING.
* End RD1K981765 CR: 30007609 CAB_ALOK

** Fill INFTY, serial no.
  loop at IST_9920_DELETE into wa_9920_SUBMIT1.
    l_tabix = sy-tabix.
    wa_9920_SUBMIT1-INFTY = '9920'.
    wa_9920_SUBMIT1-serial_no = l_tabix.
    MODIFY IST_9920_DELETE FROM  WA_9920_SUBMIT1 INDEX l_tabix.
  endloop.


ENDFORM.                    " GETDATA_IST_9920_DELETE

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC_DELETE                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC_DELETE USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
*     WHEN 'INSR'.                      "insert row
*       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME.
*       CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
*       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME
*                                         P_MARK_NAME.
      PERFORM DELETE_0805. " on Global IST_9920_DELETE
      CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC_DELETE
*&---------------------------------------------------------------------*
*&      Form  DELETE_0805
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_0805 .
  " Operation on IST_9920_PAY
  DATA: WA_9920_DELETE_SEL TYPE TY_SUBMIT,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.
  data: SAVE_ZSTATUS type ZHR_MEDPYMT_9920_MSG-ZSTATUS ,
        SAVE_SPRPS type ZHR_MEDPYMT_9920_MSG-SPRPS.

  LOOP AT IST_9920_DELETE INTO WA_9920_DELETE_SEL WHERE SEL = 'X' and ( ZSTATUS = 'NEW ' or ZSTATUS = 'REJFI'  or ZSTATUS = 'REJMO' ) .  " ONLY new/rejfi/rejmo in the IST
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_DELETE_SEL to WA_9920_MSG.

    SAVE_ZSTATUS = WA_9920_MSG-ZSTATUS .
    SAVE_SPRPS   = WA_9920_MSG-SPRPS.

    WA_9920_MSG-ZSTATUS = 'DELETED'. "to be set to 'DELETED'
*    WA_9920_MSG-SPRPS = 'X' .  "to be retained as 'X' as the record is being deleted
*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
*    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
*End RD1K976756  CAB_ALOK
      EXPORTING
        OPERATION_TYPE = 'MOD' "OPERATION of HR_INFOTYPE_OPERATION
        LOCK_INDICATOR = 'X'   "current value of lockindicator
      CHANGING
        WA_9920_MSG    = WA_9920_MSG.
    if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then set the status back to original
*      WA_9920_MSG-SPRPS = 'X' .
      WA_9920_MSG-ZSTATUS = SAVE_ZSTATUS .
    endif.
    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_DELETE_SEL.

*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
*MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
    " No component exists with the name "SPRPR". .
    " above stmts not working

    MODIFY IST_9920_DELETE  FROM  WA_9920_DELETE_SEL INDEX l_tabix.

    CLEAR: WA_9920_DELETE_SEL ,
           WA_9920_MSG.

  ENDLOOP.
ENDFORM.                    " DELETE_0805
*&---------------------------------------------------------------------*
*&      Form  PRINT_LETTER_0901
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_LETTER_0901 .

* ZMED_PRINT_LETTER

  DATA : IST_PRINT TYPE  ZMED_PRINT_LETTER_TT,  "table type
         WA_PRINT TYPE ZMED_PRINT_LETTER. " struct
  DATA: L_VENDOR_NAME type ZHR_MED_VENDORS-NAME1,
        l_tabix type sy-tabix.
  data: C_DATE type ztxt10 . "      C_DATE(10).
* begin RD1K978193 CAB_ALOK CR 30006378
  data L_TOTAL_PAYMT type ZTOTAL_AMT.
* end RD1K978193 CAB_ALOK CR 30006378
* LotNo.:                  ZPMED_SUBMIT-ZLOT_NO_LOW
* Date:                    sy-datum
* Location:                g_user_werks
* Name of Medical Officer: g_user_name
* ZDESIGNATION:            g_user_desig
* CPF No:                  G_USER_PERNR,
* Comp. Code:              G_USER_BUKRS


  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) INTO C_DATE .

  select * from PA9920
      into corresponding fields of table IST_PRINT
       where   ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
          and  ZSTATUS = 'UNLOCKED'
          and  GRPVL   = G_USER_BUKRS  " company code of the current user
          and ( SUBTY  = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' ) .
     " subty = '07' added by swetha <RD1K9A00TI> 7 june 2016


* Begin RD1K981765 CR: 30007609 CAB_ALOK
  Sort IST_PRINT by CNTER ASCENDING.
* End RD1K981765 CR: 30007609 CAB_ALOK


* Vendor name:
*All the rows of a LOT belong to a single vendor, so deriving it only once.
  read table IST_PRINT into WA_PRINT index 1.
  SELECT NAME1 FROM ZHR_MED_VENDORS
 INTO L_VENDOR_NAME UP TO 1 ROWS WHERE LIFNR = WA_PRINT-ZHOSPID AND BUKRS = G_USER_BUKRS
 ORDER BY PRIMARY KEY .
 ENDSELECT.



  Loop at IST_PRINT into WA_PRINT.
* begin RD1K978193 CAB_ALOK CR 30006378
    L_TOTAL_PAYMT = L_TOTAL_PAYMT + WA_PRINT-ZAMTMOTOTAL.
* end RD1K978193 CAB_ALOK CR 30006378
    l_tabix = sy-tabix.
    WA_PRINT-SRNO = l_tabix.
    WA_PRINT-NAME1 = L_VENDOR_NAME.
    CONCATENATE WA_PRINT-ZBILL_DATE+6(2) '.' WA_PRINT-ZBILL_DATE+4(2) '.' WA_PRINT-ZBILL_DATE+0(4) INTO WA_PRINT-CBILL_DATE .
    if WA_PRINT-SUBTY = '03'.
      WA_PRINT-FACILITY_NAME = 'Hospital'.
    elseif  WA_PRINT-SUBTY = '04'.
      WA_PRINT-FACILITY_NAME = 'Doctor'.
    elseif  WA_PRINT-SUBTY = '05'.
      WA_PRINT-FACILITY_NAME = 'Pharmacy'.
    elseif  WA_PRINT-SUBTY = '06'.
      WA_PRINT-FACILITY_NAME = 'Diagnostics'.
    endif.

    MODIFY IST_PRINT  FROM  WA_PRINT INDEX l_tabix.
  endloop. "// IST_PRINT


  DATA :   fp_outputparams    TYPE sfpoutputparams,
             w_doc_param       TYPE sfpdocparams,"Doc Parameters
             fm_name    TYPE rs38l_fnam.
  DATA : fp_formoutput TYPE fpformoutput.
  DATA : fp_docuparams TYPE sfpdocparams.


  TRY.
**To get the generated function module
      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'           "#EC ARGCHECKED
        EXPORTING
          i_name     = 'ZMED_PAYMENT_ORDER_PRINT'
        IMPORTING
          e_funcname = fm_name.
    CATCH cx_fp_api_repository.
    CATCH cx_fp_api_usage.
    CATCH cx_fp_api_internal.
  ENDTRY.


  fp_outputparams-nodialog = ''.
  fp_outputparams-preview  = ''.    " launch print preview
  fp_outputparams-getpdf = ''.
  fp_outputparams-connection = 'ADS'."gc_connection.
*Begin RD1K977852 CAB_ALOK  CR 30006309
  fp_outputparams-dest = 'HP01'.
*End RD1K977852 CAB_ALOK CR 30006309
  sy-cprog = 'X'.                                         "#EC WRITE_OK

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = fp_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  fp_docuparams-langu = 'E'.
  fp_docuparams-country = 'US'.
  fp_docuparams-fillable = 'X'.
  fp_docuparams-dynamic = 'X'.


  CALL FUNCTION fm_name
    EXPORTING
      /1bcdwb/docparams  = fp_docuparams
      IST_PRINT          = IST_PRINT
      SF_LOT_NO          = ZPMED_SUBMIT-ZLOT_NO_LOW
      SF_DATE            = C_DATE
      SF_USER_WERKS      = g_user_werks
      SF_USER_NAME       = g_user_name
      SF_USER_DESIG      = g_user_desig
      SF_TOTAL_PAYMT     = L_TOTAL_PAYMT
    IMPORTING
      /1bcdwb/formoutput = fp_formoutput
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  CALL FUNCTION 'FP_JOB_CLOSE'
* IMPORTING
*   E_RESULT             =
   EXCEPTIONS
     usage_error          = 1
     system_error         = 2
     internal_error       = 3
     OTHERS               = 4 .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*****************
****************************
*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
ENDFORM . " PRINT_LETTER_0901 .
*&---------------------------------------------------------------------*
*&      Form  CONAINER_INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LOAD_IMAGE .
  IF INIT IS INITIAL.
* create the custom container
    CREATE OBJECT CONTAINER
      EXPORTING
        CONTAINER_NAME = 'CONTAINER1'.
* create the picture control
    CREATE OBJECT PICTURE
      EXPORTING
        PARENT = CONTAINER.

* Request an URL from the data provider by exporting the pic_data.
    CLEAR URL.

    PERFORM LOAD_PIC_FROM_DB CHANGING URL.

* load picture
    CALL METHOD PICTURE->LOAD_PICTURE_FROM_URL
      EXPORTING
        URL = URL.

    INIT = 'X'.

    CALL METHOD CL_GUI_CFW=>FLUSH
      EXCEPTIONS
        CNTL_SYSTEM_ERROR = 1
        CNTL_ERROR        = 2.
    IF SY-SUBRC <> 0.
* error handling
    ENDIF.
  ENDIF.

ENDFORM.                    " CONAINER_INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  LOAD_PIC_FROM_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_URL  text
*----------------------------------------------------------------------*
FORM LOAD_PIC_FROM_DB CHANGING P_URL.
  DATA QUERY_TABLE LIKE W3QUERY OCCURS 1 WITH HEADER LINE.
  DATA HTML_TABLE LIKE W3HTML OCCURS 1.
  DATA RETURN_CODE LIKE  W3PARAM-RET_CODE.
  DATA CONTENT_TYPE LIKE  W3PARAM-CONT_TYPE.
  DATA CONTENT_LENGTH LIKE  W3PARAM-CONT_LEN.
  DATA PIC_DATA LIKE W3MIME OCCURS 0.
  DATA PIC_SIZE TYPE I.

  REFRESH QUERY_TABLE.
  QUERY_TABLE-NAME = '_OBJECT_ID'.
*   QUERY_TABLE-VALUE = 'YONGCLOGO1'.
  QUERY_TABLE-VALUE = 'YONGCLOGO2'.
*   QUERY_TABLE-VALUE = 'ZLION'.

  APPEND QUERY_TABLE.

  CALL FUNCTION 'WWW_GET_MIME_OBJECT'
    TABLES
      QUERY_STRING        = QUERY_TABLE
      HTML                = HTML_TABLE
      MIME                = PIC_DATA
    CHANGING
      RETURN_CODE         = RETURN_CODE
      CONTENT_TYPE        = CONTENT_TYPE
      CONTENT_LENGTH      = CONTENT_LENGTH
    EXCEPTIONS
      OBJECT_NOT_FOUND    = 1
      PARAMETER_NOT_FOUND = 2
      OTHERS              = 3.
  IF SY-SUBRC = 0.
    PIC_SIZE = CONTENT_LENGTH.
  ENDIF.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      TYPE     = 'image'
      SUBTYPE  = CNDP_SAP_TAB_UNKNOWN
      SIZE     = PIC_SIZE
      LIFETIME = CNDP_LIFETIME_TRANSACTION
    TABLES
      DATA     = PIC_DATA
    CHANGING
      URL      = URL
    EXCEPTIONS
      OTHERS   = 1.

ENDFORM.                    " LOAD_PIC_FROM_DB
*&---------------------------------------------------------------------*
*&      Form  LOCK_UPDATE_UNLOCK_USER_0101
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
FORM LOCK_UPDATE_UNLOCK_USER_0101 .

  DATA: WA_9920_UNLOCK_SEL TYPE TY_SUBMIT,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG.
  p9920-infty = '9920'.

  MOVE-CORRESPONDING P9920 to WA_9920_MSG.


  WA_9920_MSG-SPRPS = 'X' .  "New rec to be craeted with lock ind = 'X'
  WA_9920_MSG-ZSTATUS = 'NEW' .

*  Taxable / not Taxable Decision
  if ZHR_MED_VENDORS-taxable = 'Y'.
    WA_9920_MSG-ztax = 'X'.
    clear  WA_9920_MSG-ZNONTAX.
  elseif ZHR_MED_VENDORS-taxable = 'N'.
    WA_9920_MSG-ZNONTAX = 'X'.
    clear WA_9920_MSG-ztax.
  elseif ZHR_MED_VENDORS-taxable = 'B'.
    clear: WA_9920_MSG-ZNONTAX , WA_9920_MSG-ztax.
  endif.

  if WA_9920_MSG-subty = '07'.
    WA_9920_MSG-ZCRDNO = 'Self'.
  endif.

  CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
    EXPORTING
      OPERATION_TYPE = 'INS'       "OPERATION of HR_INFOTYPE_OPERATION
*     LOCK_INDICATOR = 'X'
    CHANGING
      WA_9920_MSG    = WA_9920_MSG.

  if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
    MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
      WITH WA_9920_MSG-MESSAGE.          .
  else.
    MOVE-CORRESPONDING WA_9920_MSG to p9920.
    g_greyoff = 'X'.  " Record has been saved
    MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
      WITH 'Claim created with submission number ' WA_9920_MSG-cnter .
  endif.

ENDFORM.                    " LOCK_UPDATE_UNLOCK_USER_0101
*End RD1K976756  CAB_ALOK
*&---------------------------------------------------------------------*
*&      Form  POPUP_GET_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin  RD1K977570 CAB_ALOK - CR 30006026
FORM POPUP_GET_VALUES .
*data : it_sval like sval occurs 0 with header line.
*
*  refresh it_sval.
*  clear it_sval.
*
*  move : 'ZOL_MFST'  to it_sval-tabname,
*         'MFST_NUM'    to it_sval-fieldname,
*         'X'           to it_sval-field_obl.
*
*  get parameter id 'ZMFN' field it_sval-value.
*  append it_sval.
*
*  call function 'POPUP_GET_VALUES'
*       exporting
*            popup_title     = text-103
*       tables
*            fields          = it_sval
*       exceptions
*            error_in_fields = 1
*            others          = 2.
*
*  if sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  endif.
*  g_mfst_num = it_sval-value.
*  set parameter id 'ZMFN' field g_mfst_num.
ENDFORM.                    " POPUP_GET_VALUES
*end  RD1K977570 CAB_ALOK - CR 30006026
*&---------------------------------------------------------------------*
*&      Form  ZERO_BALANCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_F_02_DEBIT_TEMP  text
*----------------------------------------------------------------------*
* begin of RD1K977852 CAB_ALOK  CR 30006309: Zero balance problem
FORM ZERO_BALANCE  TABLES   P_IST_F_02_DEBIT_TEMP like STRU_F_02_DEBIT.
  data: P_WA_F_02_DEBIT_TEMP type TY_F_02_DEBIT.
  data: SUM_SPLIT_AMT type TY_F_02_DEBIT-SPLIT_AMT.
  data: l_tabix type sy-tabix.
  loop at P_IST_F_02_DEBIT_TEMP into P_WA_F_02_DEBIT_TEMP.
    l_tabix = sy-tabix.
    SUM_SPLIT_AMT = SUM_SPLIT_AMT + P_WA_F_02_DEBIT_TEMP-SPLIT_AMT.
  endloop.

*  making adjustment in last debit line.
  if SUM_SPLIT_AMT <> P_WA_F_02_DEBIT_TEMP-ZAMTPCSTOTAL.
    P_WA_F_02_DEBIT_TEMP-SPLIT_AMT = P_WA_F_02_DEBIT_TEMP-SPLIT_AMT - SUM_SPLIT_AMT + P_WA_F_02_DEBIT_TEMP-ZAMTPCSTOTAL.
    MODIFY P_IST_F_02_DEBIT_TEMP  FROM  P_WA_F_02_DEBIT_TEMP INDEX l_tabix.
  endif.

ENDFORM.                    " ZERO_BALANCE
* end of RD1K977852 CAB_ALOK  CR 30006309
*&---------------------------------------------------------------------*
*&      Form  SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* begin RD1K978193 CAB_ALOK CR 30006378
FORM SEARCH .
  CLEAR ZPMED_SUBMIT-PERNR_LOW.
* call screen 0510  starting at  50  50
*                   ending at  100 100 .

  call screen 0510  starting at  10 10
                    ending at  50 25 .

ENDFORM.                    " SEARCH

*&---------------------------------------------------------------------*
*&      Form  TC_UNLOCK_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TC_UNLOCK_SEARCH .
  data: l_tabix type sy-tabix.

  IF g_srch_flag = 'X'.
    IF ZPMED_SUBMIT-PERNR_LOW is not initial.
*     sort IST_9920_UNLOCK by pernr ASCENDING.
      READ TABLE IST_9920_UNLOCK INTO WA_9920_UNLOCK
          WITH KEY  pernr = ZPMED_SUBMIT-PERNR_LOW.
      IF sy-subrc = 0.
        l_tabix = sy-tabix.
        TC_UNLOCK-top_line = l_tabix.
        SET CURSOR 1 1.
        CLEAR g_srch_flag.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " TC_UNLOCK_SEARCH
* end RD1K978193 CAB_ALOK CR 30006378
*&---------------------------------------------------------------------*
*&      Form  TC_EDIT_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TC_EDIT_SEARCH .
  data: l_tabix type sy-tabix.

  IF g_srch_flag = 'X'.
    IF ZPMED_SUBMIT-PERNR_LOW is not initial.
*     sort IST_9920_UNLOCK by pernr ASCENDING.
      READ TABLE IST_9920_EDIT INTO WA_9920_UNLOCK
          WITH KEY  pernr = ZPMED_SUBMIT-PERNR_LOW.
      IF sy-subrc = 0.
        l_tabix = sy-tabix.
        TC_EDIT-top_line = l_tabix.
        SET CURSOR 1 1.
        CLEAR g_srch_flag.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " TC_EDIT_SEARCH
*&---------------------------------------------------------------------*
*&      Form  CHECK_MEMORY_LOT_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
FORM CHECK_LOT_LOCK .

**data L_LOT_NO type ZLOT.
**
**GET PARAMETER ID 'ZSPA_LOT_NO' FIELD L_LOT_NO .
**
**IF sy-subrc <> 0 ." first run
**  MESSAGE 'Lot not in process' TYPE 'I'.
**    L_LOT_NO  = ZPMED_SUBMIT-ZLOT_NO_LOW.
**    SET PARAMETER ID 'ZSPA_LOT_NO' FIELD L_LOT_NO .
***  // continue process.
**  elseif sy-subrc = 0. "The SPA/GPA parameter exists for the current user in the SAP Memory and its value was transferred to the target field.
**    "lot may be in process in another session
**
**    if L_LOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
**      MESSAGE 'Lot already in process in other session' TYPE 'E'.
**    else.
**       MESSAGE 'Lot not in process' TYPE 'I'.
**       L_LOT_NO  = ZPMED_SUBMIT-ZLOT_NO_LOW.
**       SET PARAMETER ID 'ZSPA_LOT_NO' FIELD L_LOT_NO .
**    endif.
**
**ENDIF.

  data L_LOT_NO type ZLOT.
  DATA WA_ZHRMED_LOT_LOCK TYPE ZHRMED_LOT_LOCK.

* SELECT single *
*   from ZHRMED_LOT_LOCK
*     into WA_ZHRMED_LOT_LOCK
*       where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
*
*   if WA_ZHRMED_LOT_LOCK-ZLOT_NO is initial. " LOT is not locked, Lock it in ZHRMED_LOT_LOCK
*     WA_ZHRMED_LOT_LOCK-MANDT = sy-mandt.
*     WA_ZHRMED_LOT_LOCK-ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
*     insert ZHRMED_LOT_LOCK from  WA_ZHRMED_LOT_LOCK.
*
*     else. " LOT is locked for processing by other user or other session
*        MESSAGE 'Lot already in process in another session' TYPE 'E'.
*   endif.

*========================

  SELECT single *
    from ZHRMED_LOT_LOCK
      into WA_ZHRMED_LOT_LOCK
        where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.

  " if LOT NO. exists then Take a lock on table ZHRMED_LOT_LOCK
  if WA_ZHRMED_LOT_LOCK-ZLOT_NO is not initial.

* if LOT NO. doesn't exist, insert ZLOT_NO into table ZHRMED_LOT_LOCK
    " and Take the lock
  elseif WA_ZHRMED_LOT_LOCK-ZLOT_NO is initial. " LOT is not locked, Lock it in ZHRMED_LOT_LOCK
    WA_ZHRMED_LOT_LOCK-MANDT = sy-mandt.
    WA_ZHRMED_LOT_LOCK-ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
    insert ZHRMED_LOT_LOCK from  WA_ZHRMED_LOT_LOCK.

  endif.

  perform LOCK_LOT_NO using WA_ZHRMED_LOT_LOCK-ZLOT_NO.


*=========================




ENDFORM.                    " CHECK_MEMORY_LOT_NO
* end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
*&---------------------------------------------------------------------*
*&      Form  LOCK_LOT_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* Begin RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
FORM LOCK_LOT_NO USING P_ZLOT_NO.

*Call the ENQUEUE FM corresponding to the lock object EZHRMED_LOT_LOCK
  CALL FUNCTION 'ENQUEUE_EZHRMED_LOT_LOCK'
    EXPORTING
      MODE_ZHRMED_LOT_LOCK = 'E'         "write lock
      MANDT                = SY-MANDT
      ZLOT_NO              = P_ZLOT_NO
*     X_ZLOT_NO            = ' '
*     _SCOPE               = '2'
*     _WAIT                = ' '
*     _COLLECT             = ' '
    EXCEPTIONS
      FOREIGN_LOCK         = 1
      SYSTEM_FAILURE       = 2
      OTHERS               = 3.
  IF SY-SUBRC <> 0.  "Lock could not be obtained, Show message
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " LOCK_LOT_NO
* End RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_LOT_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZPMED_SUBMIT_ZLOT_NO_LOW  text
*----------------------------------------------------------------------*
* Begin RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
FORM UNLOCK_LOT_NO  USING P_ZLOT_NO.

  CALL FUNCTION 'DEQUEUE_EZHRMED_LOT_LOCK'
    EXPORTING
      MODE_ZHRMED_LOT_LOCK = 'E'
      MANDT                = SY-MANDT
      ZLOT_NO              = P_ZLOT_NO
*     X_ZLOT_NO            = ' '
*     _SCOPE               = '3'
*     _SYNCHRON            = ' '
*     _COLLECT             = ' '
    .



ENDFORM.                    " UNLOCK_LOT_NO
* end RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_TOTALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
FORM CALCULATE_TOTALS .
  clear wa_9920_PAY.
  clear: LOT_TOTAL_PCS_AMT ,
         SELECT_TOTAL_PCS_AMT,
         PENDING_TOTAL_PCS_AMT.

  loop at IST_9920_PAY into WA_9920_PAY WHERE zstatus = 'UNLOCKED'.
    PENDING_TOTAL_PCS_AMT = PENDING_TOTAL_PCS_AMT + WA_9920_PAY-ZAMTPCSTOTAL.
    if WA_9920_PAY-SEL = 'X'.  "row has been selected
      SELECT_TOTAL_PCS_AMT = SELECT_TOTAL_PCS_AMT + WA_9920_PAY-ZAMTPCSTOTAL.
    endif.
  endloop.
  clear wa_9920_PAY.

  select SUM( ZAMTMOTOTAL ) from PA9920
    into LOT_TOTAL_PCS_AMT
      where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
        and ( ZSTATUS = 'UNLOCKED' OR  zstatus = 'PAID' )
        and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' ) .

ENDFORM.                    " CALCULATE_TOTALS

*&---------------------------------------------------------------------*
*&      Form  LEVEL_1_CHECK_0605
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LEVEL_1_CHECK_0605 .
*  If 'CHECK1' is pressed:

  data: L_MAX_AMT type ZAMT15_2.
  L_MAX_AMT = 9999999999999 / 100 .  " = 99999999999.99

*begin RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt

*  if LOT_TOTAL_PCS_AMT => 1500001 and LOT_TOTAL_PCS_AMT =< L_MAX_AMT .
*    If G_USER_PERSK between 'E1' and 'E3'.
**   Update PA9920-check_by_pernr & PA9920-Check_by_level
*      perform UPDATE_CHECK1_INFO.
*    else.
*      message e114(zhr) with G_USER_PERNR G_USER_PERSK. "Level 1 check not permitted by
*    endif.
*  else.
*    message e115(zhr). " Level 1 check not required for this amount.
*  endif.

  if LOT_TOTAL_PCS_AMT > 1000000 and LOT_TOTAL_PCS_AMT =< L_MAX_AMT .
    If G_USER_PERSK between 'E1' and 'E9'.
*   Update PA9920-check_by_pernr & PA9920-Check_by_level
      perform UPDATE_CHECK1_INFO.
    else.
      message e114(zhr) with G_USER_PERNR G_USER_PERSK. "Level 1 check not permitted by
    endif.
  else.
    message e115(zhr). " Level 1 check not required for this amount.
  endif.


*End RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt




ENDFORM.                    " LEVEL_1_CHECK_0605

*&---------------------------------------------------------------------*
*&      Form  UPDATE_CHECK1_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_CHECK1_INFO .
* Operation on IST_9920_PAY: Update PA9920-checked_by_pernr & PA9920-Checked_by_level
  DATA: WA_9920_PAY_SEL TYPE TY_PAY,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.

  LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_9920_MSG.
    WA_9920_MSG-CHECKED_BY_PERNR = G_USER_PERNR .
    WA_9920_MSG-CHECKED_BY_LEVEL = G_USER_PERSK .

    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
      EXPORTING
        OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
        LOCK_INDICATOR = ' '   "current value of lockindicator
      CHANGING
        WA_9920_MSG    = WA_9920_MSG.
    if WA_9920_MSG-ERROR_FLAG <> '1'.  "if update Operation successful, then modify the Message
      WA_9920_MSG-MESSAGE = 'Checked '. " otherwise this message contains 'Status: UNLOCKED'
    elseif WA_9920_MSG-ERROR_FLAG = '1'.
      clear: WA_9920_MSG-CHECKED_BY_PERNR,
             WA_9920_MSG-CHECKED_BY_LEVEL.
    endif.

    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL.

    MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
    CLEAR: WA_9920_PAY_SEL ,
           WA_9920_MSG.

  ENDLOOP.

ENDFORM.                    " UPDATE_CHECK1_INFO

*&---------------------------------------------------------------------*
*&      Form  LEVEL_2_CHECK_0605
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FLAG_LEVEL_2_CHECK  text
*----------------------------------------------------------------------*
FORM LEVEL_2_CHECK_0605  CHANGING P_FLAG_LEVEL_2_CHECK.

  DATA: WA_9920_PAY_SEL TYPE TY_PAY,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        l_tabix  TYPE sy-tabix.
  data: L_MAX_AMT type ZAMT15_2.
  L_MAX_AMT = 9999999999999 / 100 .  " = 99999999999.99

*begin RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt

**  if ( LOT_TOTAL_PCS_AMT => 1 and LOT_TOTAL_PCS_AMT =< 10000 )
*** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
***                    and ( G_USER_PERSK between 'E0' and 'E4' )
**                    and ( G_USER_PERSK between 'E0' and 'E9' )
*** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
**      OR ( LOT_TOTAL_PCS_AMT => 10001 and LOT_TOTAL_PCS_AMT =< 500000 )
*** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
***                    and ( G_USER_PERSK between 'E1' and 'E4' )
**                    and ( G_USER_PERSK between 'E1' and 'E9' )
*** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
**
**      OR ( LOT_TOTAL_PCS_AMT => 500001 and LOT_TOTAL_PCS_AMT =< 1500000 )
*** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
***                    and ( G_USER_PERSK between 'E2' and 'E4' ).
**                    and ( G_USER_PERSK between 'E2' and 'E9' ).
*** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
**
**    "// Level 2 check for the row is OK.
**
**  elseif ( LOT_TOTAL_PCS_AMT => 1500001 and LOT_TOTAL_PCS_AMT =< 10000000 )
*** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
***                     and ( G_USER_PERSK between 'E2' and 'E4' ).
**                     and ( G_USER_PERSK between 'E2' and 'E9' ).
*** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
**
**    LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
**      l_tabix =   sy-tabix .
**      if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
**                 AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
**        if WA_9920_PAY_SEL-CHECKED_BY_PERNR <> G_USER_PERNR.
**          "// Level 2 check for the row is OK.
**        else.
**          P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
**          WA_9920_PAY_SEL-message = 'Claim can not be checked & paid by the same pernr'.
**          MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
**        endif.
**      else.
**        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
**        WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
**        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
**      endif.
**
**      if WA_9920_PAY_SEL-taxable = 'Y' or WA_9920_PAY_SEL-taxable = 'N'.
**      else.
**        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
**        WA_9920_PAY_SEL-message = 'Specify Amount is Taxable or not'.
**        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
**      endif.
**
**      CLEAR: WA_9920_PAY_SEL.
**    ENDLOOP.
**
**  elseif ( LOT_TOTAL_PCS_AMT => 10000001 and LOT_TOTAL_PCS_AMT =< L_MAX_AMT )
*** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
***              and ( G_USER_PERSK = 'E4' ).
**               and ( G_USER_PERSK between 'E4' and 'E9' ).
*** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
**
**    clear l_tabix.
**    LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
**      l_tabix = sy-tabix .
**      if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
**                 AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
**        "// Level 2 check for the row is OK.
**      else.
**        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
**        WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
**        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
**      endif.
**
**      CLEAR: WA_9920_PAY_SEL.
**    ENDLOOP.
**
**  else.
**    P_FLAG_LEVEL_2_CHECK = 'F'.
**    message e116(zhr) with G_USER_PERNR G_USER_PERSK. "Payment not permitted by
**  endif.

  if ( LOT_TOTAL_PCS_AMT >= 1 and LOT_TOTAL_PCS_AMT <= 50000 )
                    and ( G_USER_PERSK between 'E0' and 'E9' )

      OR ( LOT_TOTAL_PCS_AMT > 50000 and LOT_TOTAL_PCS_AMT <= 1000000 )
                   and ( G_USER_PERSK between 'E1' and 'E9' ).

    "// Level 2 check for the row is OK.

  elseif ( LOT_TOTAL_PCS_AMT > 1000000 and LOT_TOTAL_PCS_AMT <= 5000000 )
                     and ( G_USER_PERSK between 'E2' and 'E9' ).

    LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
      l_tabix =   sy-tabix .
      if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
                 AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
        if WA_9920_PAY_SEL-CHECKED_BY_PERNR <> G_USER_PERNR.
          "// Level 2 check for the row is OK.
        else.
          P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
          WA_9920_PAY_SEL-message = 'Claim can not be checked & paid by the same pernr'.
          MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
        endif.
      else.
        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
        WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
      endif.

      if WA_9920_PAY_SEL-taxable = 'Y' or WA_9920_PAY_SEL-taxable = 'N'.
      else.
        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
        WA_9920_PAY_SEL-message = 'Specify Amount is Taxable or not'.
        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
      endif.

      CLEAR: WA_9920_PAY_SEL.
    ENDLOOP.

  elseif ( LOT_TOTAL_PCS_AMT > 5000000 and LOT_TOTAL_PCS_AMT <= 10000000 )
               and ( G_USER_PERSK between 'E3' and 'E9' ).
    clear l_tabix.
    LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
      l_tabix = sy-tabix .
      if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
                 AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
        "// Level 2 check for the row is OK.
      else.
        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
        WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
      endif.

      CLEAR: WA_9920_PAY_SEL.
    ENDLOOP.

  elseif ( LOT_TOTAL_PCS_AMT > 10000000 and LOT_TOTAL_PCS_AMT <= L_MAX_AMT )
               and ( G_USER_PERSK between 'E4' and 'E9' ).

    clear l_tabix.
    LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
      l_tabix = sy-tabix .
      if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
                 AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
        "// Level 2 check for the row is OK.
      else.
        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
        WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
      endif.

      CLEAR: WA_9920_PAY_SEL.
    ENDLOOP.

  else.
    P_FLAG_LEVEL_2_CHECK = 'F'.
    message e116(zhr) with G_USER_PERNR G_USER_PERSK. "Payment not permitted by
  endif.

*end RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt

*============================================
  LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.

    if WA_9920_PAY_SEL-taxable = 'Y' or WA_9920_PAY_SEL-taxable = 'N'.
    else.
      P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
      WA_9920_PAY_SEL-message = 'Specify Amount is Taxable or not'.
      MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX sy-tabix.

      message s000(zmsg) with 'Specify Amount is Taxable or not'.
    endif.

    CLEAR: WA_9920_PAY_SEL.
  ENDLOOP.


ENDFORM.                    " LEVEL_2_CHECK_0605

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_1001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_1001 .

  DATA: submit_pernr TYPE pernr_d.
  DATA: submit_name TYPE emnam.
  DATA: submit_orgeh TYPE orgeh.
  DATA: submit_plans TYPE plans.
  DATA: submit_persa TYPE persa.
  DATA: submit_bukrs TYPE bukrs.

  PERFORM GETDATA_IST_9920_REV tables IST_9920_REV using G_USER_BUKRS. "submit_bukrs .

ENDFORM.                    " GET_DATA_1001
*&---------------------------------------------------------------------*
*&      Form  GETDATA_IST_9920_REV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_9920_PAY  text
*      -->P_G_USER_BUKRS  text
*----------------------------------------------------------------------*


* Begin RD1K981765 CR: 30007609 CAB_ALOK
*FORM GETDATA_IST_9920_REV TABLES IST_9920_REV  USING G_USER_BUKRS.
FORM GETDATA_IST_9920_REV  tables IST_9920_REV STRUCTURE IST_9920_REV using submit_bukrs.
* End RD1K981765 CR: 30007609 CAB_ALOK
  DATA: wa_9920_rev1 TYPE ty_pay,
               l_tabix  TYPE sy-tabix.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = ZPMED_SUBMIT-ZLOT_NO_LOW
    IMPORTING
      OUTPUT = ZPMED_SUBMIT-ZLOT_NO_LOW.

  select * from PA9920
    into corresponding fields of table IST_9920_REV
      where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
        and BELNR   = ZPMED_SUBMIT-BELNR
        and GJAHR   = ZPMED_SUBMIT-GJAHR
        and BUKRS   = ZPMED_SUBMIT-BUKRS
        and ZSTATUS = 'PAID'
        and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or  SUBTY = '07' ) .

* Begin RD1K981765 CR: 30007609 CAB_ALOK
  Sort IST_9920_REV by CNTER ASCENDING.
* End RD1K981765 CR: 30007609 CAB_ALOK

** Fill INFTY, serial no., MO_AMOUNT
  loop at IST_9920_REV into wa_9920_REV1.
    l_tabix = sy-tabix.
    wa_9920_REV1-INFTY = '9920'.
    wa_9920_REV1-serial_no = l_tabix.
    MODIFY IST_9920_REV FROM WA_9920_REV1 INDEX l_tabix.
  endloop.

ENDFORM.                    " GETDATA_IST_9920_REV

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC_REV                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC_REV USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
    WHEN 'REV'.
      PERFORM REVERSE_1005.
      CLEAR P_OK.

    WHEN 'INSR'.                      "insert row
      PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                        P_TABLE_NAME.
      CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME.
      CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC_REV

*&---------------------------------------------------------------------*
*&      Form  REVERSE_1005
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REVERSE_1005 .

*  Take lock on all the pernrs.
*  if any one already locked, get information about who has taken the lock,
*       release all locks, return to screen & display error msg.
*  elseif all pernrs are locked
*    run BDC of FB08 or FBU8 .
*       .
*       .
*      if BDC successful.
*        Reverse records of 9920 corresponding to records of IST_REV:
*           update STBLG (reversal doc no.), set status = UNLOCKED,
*           clear BELNR GJAHR BUKRS CHECKED_BY_PERNR CHECKED_BY_LEVEL PAID_BY_PERNR PAID_BY_LEVEL
*           insert Negative (Credit) entry into the Recovery_amt field of the ZHRMED_EMP_RECOV table .
*              .
*              .
*      endif
*     unlock all pernrs
*   endif
  Data :   L_GLAC like zhrhospsanction-glhead ,
          L_FISCAL_YEAR TYPE GJAHR ,
          l_bukrs type bukrs.

  data: WA_9920_REV_SEL1 TYPE TY_PAY,
        WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
        ERROR_PERNR_LOCK type char1,
        l_tabix TYPE  sy-tabix .
  data : bdc_subrc_rev like sy-subrc. " capture status of BDC success
  Data : ist_mesg type ESP1_MESSAGE_TAB_TYPE with header line.
  data cnt type i.
  data: count type i.
  data: SAVE_PAID_BY_PERNR type PA9920-PAID_BY_PERNR,
        SAVE_PAID_BY_LEVEL type PA9920-PAID_BY_LEVEL,
        SAVE_BELNR type PA9920-BELNR,
        SAVE_BUKRS type PA9920-BUKRS,
        SAVE_GJAHR type PA9920-GJAHR,
        SAVE_CHECKED_BY_PERNR type PA9920-CHECKED_BY_PERNR,
        SAVE_CHECKED_BY_LEVEL type PA9920-CHECKED_BY_LEVEL.

  data : IST_PA9920 type  table of  PA9920,
         WA_PA9920 type PA9920.

  data : IST_ZHRMED_EMP_RECOV type table of ZHRMED_EMP_RECOV,
         WA_ZHRMED_EMP_RECOV type ZHRMED_EMP_RECOV.

* Remove previous MESSAGEs & ERROR_FLAGs before each run of table control
  clear l_tabix.
  CLEAR: WA_9920_REV_SEL1 .
  LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1 WHERE ZSTATUS = 'PAID'.
    l_tabix =   sy-tabix .
    clear: WA_9920_REV_SEL1-MESSAGE, WA_9920_REV_SEL1-ERROR_FLAG.
    MODIFY IST_9920_REV  FROM  WA_9920_REV_SEL1 INDEX l_tabix.
    CLEAR: WA_9920_REV_SEL1 .
  endloop.

*Lock all Pernrs of IST_9920_REV.
  clear l_tabix.
  CLEAR: WA_9920_REV_SEL1, WA_9920_MSG.
  LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1 WHERE ZSTATUS = 'PAID'.
    l_tabix =   sy-tabix .
    MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_9920_MSG.

    CALL FUNCTION 'ZHR_MED_PERNR_LOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
      CHANGING
        WA_9920_MSG = WA_9920_MSG.

    if WA_9920_MSG-ERROR_FLAG = '1'.   " at least one pernr lock failed
      ERROR_PERNR_LOCK = '1'.
    endif.

    MOVE-CORRESPONDING WA_9920_MSG to WA_9920_REV_SEL1. " if lock failed then ERROR_FLAG set to '1'

    MODIFY IST_9920_REV  FROM  WA_9920_REV_SEL1 INDEX l_tabix.
    CLEAR: WA_9920_REV_SEL1 , WA_9920_MSG.
  ENDLOOP.

  IF ERROR_PERNR_LOCK = '1'.

    MESSAGE i113(zhr). "At least one pernr is locked. See message column.
    clear ERROR_PERNR_LOCK.
    " at least one pernr lock failed so release other locked PERNRs of the IST_9920_REV before exiting
    clear l_tabix.
    CLEAR: WA_9920_REV_SEL1, WA_9920_MSG.
    LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1 WHERE ZSTATUS = 'PAID' AND ERROR_FLAG = ''.
      l_tabix =   sy-tabix .
      MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_9920_MSG.

      CALL FUNCTION 'ZHR_MED_PERNR_UNLOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
        CHANGING
          WA_9920_MSG = WA_9920_MSG.

      MOVE-CORRESPONDING WA_9920_MSG to WA_9920_REV_SEL1.

      MODIFY IST_9920_REV  FROM  WA_9920_REV_SEL1 INDEX l_tabix.
      CLEAR: WA_9920_REV_SEL1 , WA_9920_MSG.
    ENDLOOP.

  ELSE. "Locks acquired on all the pernrs, now process BDC for Reversal ( FBU8 or FB08)

****
* FBU8 takes BVORG  as input, FB08 takes BELNR as input
**find BVORG for above ( belnr, bukrs, gjahr ) in BKPF table
* if BVORG exists => IUT Doc => run FBU8 BDC for  reversal of the doc
* else non-IUT Doc => run FB08 BDC for  reversal of the doc

*    ZPMED_SUBMIT-BELNR.
*    ZPMED_SUBMIT-GJAHR.
*    ZPMED_SUBMIT-BUKRS.
*    ZPMED_SUBMIT-STGRD
*    ZPMED_SUBMIT-BUDAT
*IST_9920_REV-LOT No. "8000000429

    data : l_bvorg type bkpf-bvorg.

    SELECT single BVORG
      into l_bvorg
      from bkpf
        where BUKRS = ZPMED_SUBMIT-BUKRS
          and BELNR = ZPMED_SUBMIT-BELNR
          and GJAHR = ZPMED_SUBMIT-GJAHR.

    clear: bdc_subrc_rev, wa_messtab, messtab.
    refresh: messtab.
    if l_bvorg is not initial. " IUT DOC
      PERFORM BDC_FBU8 using ZPMED_SUBMIT l_bvorg
             CHANGING bdc_subrc_rev . "
    else. "non-IUT doc
      PERFORM BDC_FB08 using ZPMED_SUBMIT
             CHANGING bdc_subrc_rev . "

    endif.
* bdc_subrc_rev doesn't give correct indication of BDC's
* success in case of FBU8,
* revised logic: If Reversal doc no. has been updated in BKPF
* => doc has been reversed.

    data: L_STBLG type BKPF-STBLG. "Reversal Doc no.

    select single STBLG
      into L_STBLG
        from BKPF
          where BUKRS = ZPMED_SUBMIT-BUKRS
            and BELNR = ZPMED_SUBMIT-BELNR
            and GJAHR = ZPMED_SUBMIT-GJAHR.
*  if bdc_subrc_rev = 0. "BDC successful
    if L_STBLG is not INITIAL. " Doc reversed
      G_FLAG_REVERSED = 'X'.  "Flag to disable 'REVERSE' buton
**If Document has been reversed, then
* 1. update PA9920
* 2. update ZHRMED_EMP_RECOV table
      clear: WA_9920_REV_SEL1, WA_9920_MSG.
      LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1 WHERE ZSTATUS = 'PAID'.
        l_tabix =   sy-tabix .


**
        select COUNT(*)
          FROM  ZHRMED_EMP_RECOV
          into l_bvorg
          where CNTER = WA_9920_REV_SEL1-CNTER.



        MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_9920_MSG.
*    WA_9920_MSG-SPRPS = '' .  "to be retained as ''

*begin of CR 30006427 CAB_ALOK

*  clear WA_9920_MSG-SPRPS
*          WA_9920_MSG-ZSTATUS = 'UNLOCKED'.   "  'REVERSED'.
*          WA_9920_MSG-STBLG = L_STBLG.
*
*          SAVE_PAID_BY_PERNR = WA_9920_MSG-PAID_BY_PERNR.
*          SAVE_PAID_BY_LEVEL = WA_9920_MSG-PAID_BY_LEVEL.
*          SAVE_BELNR  =  WA_9920_MSG-BELNR.

**          SAVE_BUKRS  =  WA_9920_MSG-BUKRS.
*          SAVE_GJAHR  =  WA_9920_MSG-GJAHR.

*          SAVE_CHECKED_BY_PERNR  =  WA_9920_MSG-CHECKED_BY_PERNR.
*          SAVE_CHECKED_BY_LEVEL  =  WA_9920_MSG-CHECKED_BY_LEVEL.

*  WA_9920_MSG-ZSTATUS = 'REVERSED'.
*
*end of CR 30006427  CAB_ALOK


**********************

        WA_9920_MSG-ZSTATUS = 'UNLOCKED'.   "  'REVERSED'.
        WA_9920_MSG-STBLG = L_STBLG.

        SAVE_PAID_BY_PERNR = WA_9920_MSG-PAID_BY_PERNR.
        SAVE_PAID_BY_LEVEL = WA_9920_MSG-PAID_BY_LEVEL.
        SAVE_BELNR  =  WA_9920_MSG-BELNR.
        SAVE_BUKRS  =  WA_9920_MSG-BUKRS.
        SAVE_GJAHR  =  WA_9920_MSG-GJAHR.
        SAVE_CHECKED_BY_PERNR  =  WA_9920_MSG-CHECKED_BY_PERNR.
        SAVE_CHECKED_BY_LEVEL  =  WA_9920_MSG-CHECKED_BY_LEVEL.

        clear: WA_9920_MSG-PAID_BY_PERNR,
               WA_9920_MSG-PAID_BY_LEVEL,
               WA_9920_MSG-BELNR,  " FI Doc. no.

               WA_9920_MSG-BUKRS,  " FI Doc. comp. code
               WA_9920_MSG-GJAHR,
               WA_9920_MSG-CHECKED_BY_PERNR,
               WA_9920_MSG-CHECKED_BY_LEVEL.

* functionality of ZHR_MED_PYMT_UPDATE9920_MSG now trifurcated into separate
* FMs (LOCK, UPDATE, UNLOCK) for Payment process
        CALL FUNCTION 'ZHR_MED_PYMT_INFO_OPER_9920' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
          EXPORTING
            OPERATION_TYPE = 'MOD'  "OPERATION of HR_INFOTYPE_OPERATION
            LOCK_INDICATOR = ' '
          CHANGING
            WA_9920_MSG    = WA_9920_MSG.

        if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status & other data to original.
          WA_9920_MSG-ZSTATUS = 'PAID'.
          Clear WA_9920_MSG-STBLG.

          WA_9920_MSG-PAID_BY_PERNR = SAVE_PAID_BY_PERNR.
          WA_9920_MSG-PAID_BY_LEVEL = SAVE_PAID_BY_LEVEL.
          WA_9920_MSG-BELNR = SAVE_BELNR .
          WA_9920_MSG-BUKRS = SAVE_BUKRS .
          WA_9920_MSG-GJAHR = SAVE_GJAHR .
          WA_9920_MSG-CHECKED_BY_PERNR = SAVE_CHECKED_BY_PERNR  .
          WA_9920_MSG-CHECKED_BY_LEVEL = SAVE_CHECKED_BY_LEVEL .

          clear: WA_9920_MSG-PAID_BY_PERNR,
                 WA_9920_MSG-PAID_BY_LEVEL.
          clear: WA_9920_MSG-BELNR,
                 WA_9920_MSG-BUKRS,
                 WA_9920_MSG-GJAHR.
        else.
          " CR30008930 Updation of tables ZHRHOSPSANCTION and  ZHRHOSPSANC_UTL
          " Changes by cab_swetha, specs by cfi_mallik
          " changes frm here
          Clear : L_GLAC , L_FISCAL_YEAR , L_BUKRS.

* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
**         if WA_9920_REV_SEL1-SUBTY = '05'.
**              L_GLAC = '200301'.
**            elseif ( WA_9920_REV_SEL1-SUBTY = '03' or WA_9920_REV_SEL1-SUBTY = '06' ).
**              L_GLAC = '200308'.
**            elseif WA_9920_REV_SEL1-SUBTY = '04'.
**              L_GLAC = '200309'.
**            endif.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

          CLEAR: l_persk, l_persg, L_GLAC .
          SELECT PERSK PERSG
 FROM PA0001 INTO ( L_PERSK , L_PERSG ) UP TO 1 ROWS WHERE PERNR = WA_9920_REV_SEL1-PERNR AND BEGDA =< SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.

          if sy-subrc = 0.

            if l_persg = '2'
               or l_persg = 'B' .    " Retd. Employee

              if WA_9920_REV_SEL1-SUBTY = '05'.
                L_GLAC = '0000200301'.
              elseif ( WA_9920_REV_SEL1-SUBTY = '03' or WA_9920_REV_SEL1-SUBTY = '06' ).
                L_GLAC = '0000200308'.
              elseif WA_9920_REV_SEL1-SUBTY = '04'.
                L_GLAC = '0000200309'.
              endif.

            elseif l_persg = '1' " Activ. Employee (Officer + Staff)
                or l_persg = '7'
                or l_persg = '8'
                or l_persg = '9'
                or l_persg = 'A'
                or l_persg = 'G'
                or l_persg = 'S'.
              " now determine whether Officer or Staff
              if   l_persk = 'C'    " => officer
                or l_persk = 'D'
                or l_persk = 'E0'
                or l_persk = 'E1'
                or l_persk = 'E2'
                or l_persk = 'E3'
                or l_persk = 'E4'
                or l_persk = 'E5'
                or l_persk = 'E6'
                or l_persk = 'E7'
                or l_persk = 'E8'
                or l_persk = 'E9'
                or l_persk = 'GT'.

                if WA_9920_REV_SEL1-SUBTY = '05'.
                  L_GLAC = '0000200301'.
                elseif ( WA_9920_REV_SEL1-SUBTY = '03' or WA_9920_REV_SEL1-SUBTY = '06' ).
                  L_GLAC = '0000200307'.
                elseif WA_9920_REV_SEL1-SUBTY = '04'.
                  L_GLAC = '0000200302'.
                endif.    "//officer

              elseif l_persk = 'A1'    " => Staff
                  or l_persk = 'A2'
                  or l_persk = 'A3'
                  or l_persk = 'A4'
                  or l_persk = 'S1'
                  or l_persk = 'S2'
                  or l_persk = 'S3'
                  or l_persk = 'S4'
                  or l_persk = 'TC'
                  or l_persk = 'W1'
                  or l_persk = 'W2'
                  or l_persk = 'W3'
                  or l_persk = 'W4'
                  or l_persk = 'W5'
                  or l_persk = 'W6'
                  or l_persk = 'W7'.

                if WA_9920_REV_SEL1-SUBTY = '05'.
                  L_GLAC = '0000200301'.
                elseif ( WA_9920_REV_SEL1-SUBTY = '03' or WA_9920_REV_SEL1-SUBTY = '06' ).
                  L_GLAC = '0000200318'.
                elseif WA_9920_REV_SEL1-SUBTY = '04'.
                  L_GLAC = '0000200317'.
                endif.
              endif. "//staff
* Begin RD1K997486 CAB_ALOK Medical Vendor pymt for Contingent workers -CR 30012858
            elseif l_persg = 'C'.  "Contingent worker
*              if l_persk = 'C1'    "
*                   or l_persk = 'C2'
*                   or l_persk = 'C3'.
                L_GLAC = '0000200350'.
*              endif.
* End RD1K997486 CAB_ALOK Medical Vendor pymt for Contingent workers -CR 30012858
            endif.
          endif. "sy-subrc  " // GL Account logic.

          L_FISCAL_YEAR = WA_9920_REV_SEL1-GJAHR.


* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

          data: major_head type HKONT.


* Begin RD1K992265 CAB_ALOK CR 30010881
          if G_BUDAT < '20140401' .
* End RD1K992265 CAB_ALOK CR 30010881

            case  L_GLAC.

              when '0000200301'.
                major_head = '0000200301'.

*begin RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
*          when '0000200302' or '0000200307' or '0000200308' or '0000200309' or
*                 '0000200317' or '0000200318'.
*            major_head = '0000200302'.

* Begin RD1K992265 CAB_ALOK CR 30010881
*          when '0000200302' or '0000200307' or '0000200317' or '0000200318'.
*              major_head = '0000200302'.
*
*          when  '0000200308' or '0000200309' .
*               major_head = '0000200309'.

              when '0000200302' or '0000200307' or '0000200308' or '0000200309' or
                     '0000200317' or '0000200318'.
                major_head = '0000200302'.

* end RD1K992265 CAB_ALOK  CR 30010881
*end RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
            endcase.

* Begin RD1K992265 CAB_ALOK CR 30010881
          else. " posting dt >= '20140401'

            case  L_GLAC.

              when '0000200301'.
                major_head = '0000200301'.

              when '0000200302' or '0000200307' or '0000200317' or '0000200318'.
                major_head = '0000200302'.

              when  '0000200308' or '0000200309' .
                major_head = '0000200309'.

*Begin RD1K997486  CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
              when  '0000200350' .
                major_head = '0000200350'.
*End RD1K997486   CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858

            endcase.

* End RD1K992265 CAB_ALOK CR 30010881
          endif.

* for handling GL A/c prefix issue. (add 0000 to GL A/c)
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = major_head
            IMPORTING
              OUTPUT = major_head.


* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
** get secco
data: l_secco TYPE secco.
data: L_WA_9920_REV  TYPE ty_pay.

READ TABLE IST_9920_REV INTO L_WA_9920_REV INDEX 1.
IF sy-subrc = 0.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*  SELECT SECCO FROM BSEG
* INTO L_SECCO UP TO 1 ROWS WHERE BUKRS = L_WA_9920_REV-BUKRS AND BELNR = L_WA_9920_REV-BELNR AND GJAHR = L_WA_9920_REV-GJAHR AND KOART = 'K'
* ORDER BY PRIMARY KEY .
  SELECT TaxSection AS secco
    FROM i_operationalacctgdocitem
    WHERE CompanyCode          = @l_wa_9920_rev-bukrs
      AND AccountingDocument   = @l_wa_9920_rev-belnr
      AND FiscalYear           = @l_wa_9920_rev-gjahr
      AND FinancialAccountType = 'K'
    ORDER BY CompanyCode, AccountingDocument, FiscalYear, AccountingDocumentItem
    INTO @l_secco UP TO 1 ROWS.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
 ENDSELECT.

Else.
  MESSAGE e067(ZHR) with L_SECCO .
ENDIF.
* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991

**    SELECT SINGLE BUKRS FROM PA0001 INTO L_BUKRS WHERE pernr = sy-uname
**        and begda <= sy-datum and endda >= sy-datum .
*above code doesn't work for CoreTeam members
          L_BUKRS = WA_9920_REV_SEL1-GRPVL.
* This check should be applicable for Fiscal year equal to or greater
*than 2013.
          If L_FISCAL_YEAR => '2013'.
* This check should be excluded for the company codes in table
*ZFIHOSPBUKRSEXEM.
            clear WA_ZFIHOSPBUKRSEXEM.
            select single bukrs
              from ZFIHOSPBUKRSEXEM
              into WA_ZFIHOSPBUKRSEXEM-BUKRS
              where bukrs = WA_9920_REV_SEL1-GRPVL.

*  if WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
**instead of skipping all the checks and updation for
* exempted company codes, give msg and update utilization
* with -ve values (if any).


* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

            Refresh ist_zhrhospsanction.
            Select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction
              where BUKRS = L_BUKRS
* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
                    AND SECCO = L_SECCO
* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*           and GLHEAD = L_GLAC
                   and GLHEAD = major_head
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
                   and GJAHR = L_FISCAL_YEAR.
            Clear t_amt.
            Loop at ist_zhrhospsanction into wa_zhrhospsanction.
              t_amt = t_amt + wa_zhrhospsanction-amt.
            Endloop.

            select single * from zhrhospsanc_utl into  wa_zhrhospsanc_utl
                 where BUKRS = L_BUKRS
* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
                    AND SECCO = L_SECCO
* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*           and GLHEAD = L_GLAC
                   and GLHEAD = major_head
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
                   and GJAHR = L_FISCAL_YEAR.
            If sy-subrc = 0.
* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*        wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + WA_9920_REV_SEL1-ZAMOUNT.
              wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt - WA_9920_REV_SEL1-ZAMOUNT.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

*        wa_zhrhospsanction-utilamt = wa_zhrhospsanction-utilamt - WA_9920_PAY-ZAMTPCSTOTAL.
*        wa_zhrhospsanction-balamt = wa_zhrhospsanction-amt - wa_zhrhospsanction-utilamt.
              wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
*        wa_zhrhospsanc_utl-amt = t_amt.
              Modify zhrhospsanc_utl from wa_zhrhospsanc_utl .
              Commit Work.
            Else.
* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*        Message e028(ZHR)   .
*        Message e028(ZHR) with L_BUKRS  L_GLAC L_FISCAL_YEAR .
* Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
*         Message e028(ZHR) with L_BUKRS  major_head L_FISCAL_YEAR .
          Message e028(ZHR) with L_BUKRS L_SECCO major_head L_FISCAL_YEAR .

* End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991



* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
            Endif.

* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930


*      endif. " // WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
          endif.  "// L_FISCAL_YEAR => '2013'.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

        endif.
        MOVE-CORRESPONDING WA_9920_MSG to WA_9920_REV_SEL1.

        MODIFY IST_9920_REV FROM WA_9920_REV_SEL1 INDEX l_tabix.
        MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_PA9920.
        CLEAR: WA_9920_REV_SEL1, WA_9920_MSG.
*        CLEAR:  WA_9920_MSG.

* 2. insert Negative (Credit) entry into the Recovery_amt field of the ZHRMED_EMP_RECOV table .
        " Modify table ZHRMED_EMP_RECOV

        WA_PA9920-MANDT = sy-mandt.
        if WA_PA9920-ZADV_TKN > 0.  " recovery amt exists

          MOVE-CORRESPONDING WA_PA9920 to WA_ZHRMED_EMP_RECOV .

***begin of CR 30006427 CAB_ALOK
***            L_RECOVERY_AMT = -1 * WA_PA9920-ZADV_TKN .
          WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = -1 * WA_PA9920-ZADV_TKN .
***end of CR 30006427  CAB_ALOK
          WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE = 'REVERSAL'.
*
***   WA_ZHRMED_EMP_RECOV-REMARKS .
***   WA_ZHRMED_EMP_RECOV-VENDOR_NAME

***begin of CR 30006427 CAB_ALOK
          CONCATENATE 'REVERSAL:' WA_PA9920-ZREMARKS ':' l_bvorg into WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE.
***    WA_ZHRMED_EMP_RECOV-UPDATE_STATUS
***    WA_ZHRMED_EMP_RECOV-CREATED_ON
***    WA_ZHRMED_EMP_RECOV-CREATED_BY
          concatenate 'Lot:' WA_PA9920-ZLOT_NO 'REVERSAL' INTO WA_ZHRMED_EMP_RECOV-REMARKS. "'REVERSAL'. "
          WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .

*****end of CR 30006427  CAB_ALOK


          WA_ZHRMED_EMP_RECOV-UPDATE_STATUS = 'N' .
          WA_ZHRMED_EMP_RECOV-CREATED_ON = sy-datum.
          WA_ZHRMED_EMP_RECOV-CREATED_BY = sy-uname.

          append WA_ZHRMED_EMP_RECOV to IST_ZHRMED_EMP_RECOV.
        endif. "//WA_PA9920-ZADV_TKN
        CLEAR:  WA_PA9920, WA_ZHRMED_EMP_RECOV.
*      Clear WA_9920_REV_SEL1 .

      ENDLOOP.

      if IST_ZHRMED_EMP_RECOV is NOT INITIAL.
        insert ZHRMED_EMP_RECOV from table IST_ZHRMED_EMP_RECOV.
        COMMIT WORK.
      endif.

    endif. "//if L_STBLG is not INITIAL.

    " Release all the locked PERNRs of the IST_9920_REV after BDC
    clear l_tabix.
    clear: WA_9920_REV_SEL1, WA_9920_MSG.
    LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1.
      l_tabix =   sy-tabix .
      MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_9920_MSG.

      CALL FUNCTION 'ZHR_MED_PERNR_UNLOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
        CHANGING
          WA_9920_MSG = WA_9920_MSG.

      MOVE-CORRESPONDING WA_9920_MSG to WA_9920_REV_SEL1.

      MODIFY IST_9920_REV  FROM  WA_9920_REV_SEL1 INDEX l_tabix.
      CLEAR: WA_9920_REV_SEL1 , WA_9920_MSG.
    ENDLOOP.
*============*

*     show Popup message
    refresh ist_mesg.
    cnt = 0.
    loop at messtab into wa_messtab.
      cnt = cnt + 1.
      move wa_messtab-MSGTYP   to ist_mesg-msgty.
      move wa_messtab-MSGID     to ist_mesg-msgid.
      move wa_messtab-MSGNR to ist_mesg-msgno.
      move wa_messtab-MSGV1 to ist_mesg-msgv1.
      move wa_messtab-MSGV2 to ist_mesg-msgv2.
      move wa_messtab-MSGV3 to ist_mesg-msgv3.
      move wa_messtab-MSGV4 to ist_mesg-msgv4.
      move cnt to ist_mesg-LINENO.
      append ist_mesg.
      clear wa_messtab.

    endloop.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        I_MESSAGE_TAB = ist_mesg.



  endif.  "Locks acquired on all the pernrs.

ENDFORM.                    " REVERSE_1005
*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
*&---------------------------------------------------------------------*
*&      Form  BDC_FBU8
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZPMED_SUBMIT  text
*      -->P_L_BVORG  text
*      <--P_BDC_SUBRC_REV  text
*----------------------------------------------------------------------*
FORM BDC_FBU8  USING    P_ZPMED_SUBMIT type ZPMED_SUBMIT
                        P_L_BVORG
               CHANGING P_BDC_SUBRC_REV.

  data: tmp_date type DATS.
  data: l_mode(1).

  clear: bdcdata.
  refresh: bdcdata.

  perform bdc_dynpro      using 'SAPMF05U' '0100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RF05U-BUDAT'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BUCH'.
  perform bdc_field       using 'RF05U-BVORG'
                                P_L_BVORG.
  perform bdc_field       using 'RF05U-BUKRS'
                                P_ZPMED_SUBMIT-BUKRS.
  perform bdc_field       using 'RF05U-GJAHR'
                                P_ZPMED_SUBMIT-GJAHR.
  perform bdc_field       using 'RF05U-STGRD'
                                P_ZPMED_SUBMIT-STGRD.

*P_ZPMED_SUBMIT-BUDAT 20120521
  clear: tmp_date.
  CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
    EXPORTING
      YYYYMMDD = P_ZPMED_SUBMIT-BUDAT
    IMPORTING
      DDMMYYYY = tmp_date.

  perform bdc_field       using 'RF05U-BUDAT'
                                tmp_date.
  perform bdc_dynpro      using 'SAPMF05U' '0110'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RF05U-BVORO'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BACK'.
  perform bdc_dynpro      using 'SAPMF05U' '0100'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/EENDE'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RF05U-BVORG'.

*perform bdc_transaction using 'FBU8'.

*Begin RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
*  l_mode = 'N'.
  data: WA_ZFI_MED_FOREGRND TYPE ZFI_MED_FOREGRND.
  SELECT single *
    from ZFI_MED_FOREGRND
      INTO WA_ZFI_MED_FOREGRND
      WHERE UNAME = SY-UNAME.
  if sy-subrc = 0. " Logged-in user maintained in ZFI_MED_FOREGRND.
*Begin RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
*      l_mode = 'E'.
    l_mode = 'A'.
*End RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233

  else.
    l_mode = 'N'.
  endif.
*end RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840


  call transaction 'FBU8' using bdcdata mode l_mode messages into messtab.  " 'N', 'E' , 'A', 'P'
  P_BDC_SUBRC_REV = sy-subrc.


ENDFORM.                                                    " BDC_FBU8
*&---------------------------------------------------------------------*
*&      Form  BDC_FB08
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZPMED_SUBMIT  text
*      <--P_BDC_SUBRC_REV  text
*----------------------------------------------------------------------*
FORM BDC_FB08  USING    P_ZPMED_SUBMIT type ZPMED_SUBMIT
               CHANGING P_BDC_SUBRC_REV.

  data: tmp_date type DATS.
  data: l_mode(1).

  clear: bdcdata.
  refresh: bdcdata.

  perform bdc_dynpro      using 'SAPMF05A' '0105'.
  perform bdc_field       using 'BDC_CURSOR'
                                'BSIS-BUDAT'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BU'.
  perform bdc_field       using 'RF05A-BELNS'
                                P_ZPMED_SUBMIT-BELNR.
  perform bdc_field       using 'BKPF-BUKRS'
                                P_ZPMED_SUBMIT-BUKRS.
  perform bdc_field       using 'RF05A-GJAHS'
                                P_ZPMED_SUBMIT-GJAHR.
  perform bdc_field       using 'UF05A-STGRD'
                                P_ZPMED_SUBMIT-STGRD.

  clear: tmp_date.
  CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
    EXPORTING
      YYYYMMDD = P_ZPMED_SUBMIT-BUDAT
    IMPORTING
      DDMMYYYY = tmp_date.

  perform bdc_field       using 'BSIS-BUDAT'
                                tmp_date.
*perform bdc_transaction using 'FB08'.

*Begin RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
*  l_mode = 'N'.
  data: WA_ZFI_MED_FOREGRND TYPE ZFI_MED_FOREGRND.
  SELECT single *
    from ZFI_MED_FOREGRND
      INTO WA_ZFI_MED_FOREGRND
      WHERE UNAME = SY-UNAME.
  if sy-subrc = 0. " Logged-in user maintained in ZFI_MED_FOREGRND.
*Begin RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
*      l_mode = 'E'.
    l_mode = 'A'.
*End RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
  else.
    l_mode = 'N'.
  endif.
*end RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840

  call transaction 'FB08' using bdcdata mode l_mode messages into messtab.  " 'N', 'E' , 'A', 'P'
  P_BDC_SUBRC_REV = sy-subrc.


ENDFORM.                                                    " BDC_FB08
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
FORM DOWNLOAD_REPORT .
* Download Status Report

*DATA gt_tpar TYPE TABLE OF tpar.
*SELECT * INTO TABLE gt_tpar FROM tpar.
*        IST_9920_STATUS

  types: begin of TY_STATUS_REP,
            SERIAL_NO type  i,
            PERNR type  PA9920-PERNR ,
            SUBTY type  PA9920-SUBTY,
            GRPVL type  PA9920-GRPVL,
            ZCRDNO  type  PA9920-ZCRDNO,
            PATIENT_NAME(80),
            ZLOT_NO type  PA9920-ZLOT_NO  ,
            CNTER type  PA9920-CNTER  ,
            ZHOSPID type  PA9920-ZHOSPID  ,
            ZBILL_NO  type  PA9920-ZBILL_NO ,
*          ZBILL_DATE  type  PA9920-ZBILL_DATE ,
            ZBILL_DATE_CHAR(10),
            ZILLNESS  type  PA9920-ZILLNESS ,
*          ZDATE_FROM  type  PA9920-ZDATE_FROM,
            ZDATE_FROM_CHAR(10),
*          ZDATE_TO  type  PA9920-ZDATE_TO ,
            ZDATE_TO_CHAR(10),
            ZAMOUNT type  PA9920-ZAMOUNT  ,
            ZADV_TKN  type  PA9920-ZADV_TKN ,
            ZREMARKS  type  PA9920-ZREMARKS,
            ZAMTMOTOTAL type  PA9920-ZAMTMOTOTAL,
            ZREMARKSMO  type  PA9920-ZREMARKSMO ,
            ZAMTPCSTOTAL  type  PA9920-ZAMTPCSTOTAL,
            ZREMARKSPCS type  PA9920-ZREMARKSPCS  ,
            ZREF_NO type  PA9920-ZREF_NO  ,
            ZSTATUS type  PA9920-ZSTATUS  ,
*          BEGDA type  PA9920-BEGDA,
            BEGDA_CHAR(10),
            UNAME type  PA9920-UNAME,
*          AEDTM type  PA9920-AEDTM,
            AEDTM_CHAR(10),
         end of TY_STATUS_REP .
  data:   IST_9920_STATUS_REP TYPE STANDARD TABLE OF TY_STATUS_REP,
          WA_9920_STATUS_REP TYPE TY_STATUS_REP.

  DATA : " XXL_SIMPLE_API parameters and tables
          es_filename LIKE gxxlt_f-file, " File name on the workstation
          es_header LIKE gxxlt_p-text, " XXL interface: texts for printing a list
          ls_col_text TYPE gxxlt_v,
          lt_col_text TYPE TABLE OF gxxlt_v, " Headings for DATA columns
          ls_online_text TYPE gxxlt_o,
          lt_online_text TYPE TABLE OF gxxlt_o, " Table with online texts
          ls_print_text TYPE gxxlt_p,
          lt_print_text TYPE TABLE OF gxxlt_p. " Table with print texts

*Prepare Data for downloading
  clear WA_9920_STATUS.
  Loop at IST_9920_STATUS INTO WA_9920_STATUS.
    MOVE-CORRESPONDING WA_9920_STATUS to WA_9920_STATUS_REP.

    CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
      EXPORTING
        YYYYMMDD   = WA_9920_STATUS-ZBILL_DATE
      IMPORTING
        DD_MM_YYYY = WA_9920_STATUS_REP-ZBILL_DATE_CHAR.

    CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
      EXPORTING
        YYYYMMDD   = WA_9920_STATUS-ZDATE_FROM
      IMPORTING
        DD_MM_YYYY = WA_9920_STATUS_REP-ZDATE_FROM_CHAR.

    CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
      EXPORTING
        YYYYMMDD   = WA_9920_STATUS-ZDATE_TO
      IMPORTING
        DD_MM_YYYY = WA_9920_STATUS_REP-ZDATE_TO_CHAR.

    CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
      EXPORTING
        YYYYMMDD   = WA_9920_STATUS-BEGDA
      IMPORTING
        DD_MM_YYYY = WA_9920_STATUS_REP-BEGDA_CHAR.

    CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
      EXPORTING
        YYYYMMDD   = WA_9920_STATUS-AEDTM
      IMPORTING
        DD_MM_YYYY = WA_9920_STATUS_REP-AEDTM_CHAR.

    APPEND WA_9920_STATUS_REP TO IST_9920_STATUS_REP.

  ENDLOOP.

  es_filename = 'MEDICAL_VENDOR_PAYMENT_STATUS.xls'.
  es_header = 'SAP MVPS Table Contents'.

* Headings for DATA columns
  ls_col_text-col_no = '1'.
  ls_col_text-col_name = 'Serial_no'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '2'.
  ls_col_text-col_name = 'CPF_No'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '3'.
  ls_col_text-col_name = 'Facility'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '4'.
  ls_col_text-col_name = 'Company'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '5'.
  ls_col_text-col_name = 'Card_No'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '6'.
  ls_col_text-col_name = 'Patient_Name'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '7'.
  ls_col_text-col_name = 'Lot_No.'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '8'.
  ls_col_text-col_name = 'Submission_No'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '9'.
  ls_col_text-col_name = 'Vendor'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '10'.
  ls_col_text-col_name = 'Bill_No_'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '11'.
  ls_col_text-col_name = 'Bill_Date_'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '12'.
  ls_col_text-col_name = 'Illness'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '13'.
  ls_col_text-col_name = 'Date_From'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '14'.
  ls_col_text-col_name = 'Date_To'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '15'.
  ls_col_text-col_name = 'Amount'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '16'.
  ls_col_text-col_name = 'Recovery_Amt'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '17'.
  ls_col_text-col_name = 'DO_Remarks'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '18'.
  ls_col_text-col_name = 'MO_Amount'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '19'.
  ls_col_text-col_name = 'MO_Remarks'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '20'.
  ls_col_text-col_name = 'PCS_Amount'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '21'.
  ls_col_text-col_name = 'PCS_Remarks'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '22'.
  ls_col_text-col_name = 'Ref_No'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '23'.
  ls_col_text-col_name = 'Status_'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '24'.
  ls_col_text-col_name = 'Creation_Date'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '25'.
  ls_col_text-col_name = 'Submit/Chng_By'.
  APPEND ls_col_text TO lt_col_text.

  ls_col_text-col_no = '26'.
  ls_col_text-col_name = 'Last_Chng_On'.
  APPEND ls_col_text TO lt_col_text.



  CALL FUNCTION 'XXL_SIMPLE_API'
    EXPORTING
      filename          = es_filename " File name on the workstation
      header            = es_header " Heading for exported list object
      n_key_cols        = 2 " Number of (hierarchical) key columns
    TABLES
      col_text          = lt_col_text
      data              = IST_9920_STATUS_REP
      online_text       = lt_online_text
      print_text        = lt_print_text
    EXCEPTIONS
      dim_mismatch_data = 1 " Non-present DATA column is referenced
      file_open_error   = 2 " File FILENAME cannot be opened
      file_write_error  = 3 " File FILENAME cannot be written to
      inv_winsys        = 4 " Wrong window system, DOS windows required
      inv_xxl           = 5 " Installation at the frontend incorrect
      OTHERS            = 6.
  IF sy-subrc <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.




ENDFORM.                    " DOWNLOAD_REPORT
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
*&---------------------------------------------------------------------*
*&      Form  FUND_MGMT_ROLE_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* Begin RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
** now separate role for medical fund mgmt, hence commented
*FORM FUND_MGMT_ROLE_AUTH .
*data: WA_AGR_USERS_FM type AGR_USERS.
*
*  select single * from agr_users  " WA_AGR_USERS-AGR_NAME
*     into wa_agr_users_fm
*       where uname = sy-uname
*         and ( agr_name = 'D:PSM_BDGT_COORD_BASE_ROLE_ONG'
*               or agr_name = 'D:PSM_FUND_VRFR_BASE_ROLE_ONGC'
*                or agr_name = 'D:PSM_BDGT_COORD_BASE_ROLE_OVL'
*                or agr_name = 'D:PSM_FUND_VRFR_BASE_ROLE_OVL' )
*         and from_dat <=   sy-datum
*         and   to_dat >=  sy-datum.
*
*  if wa_agr_users_fm-agr_name is initial.
*    message id 'ZMSG' type 'E' number '000' with 'No authorization to run the application' .
*  endif.

*ENDFORM.                    " FUND_MGMT_ROLE_AUTH
* End RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
