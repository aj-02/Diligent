*----------------------------------------------------------------------*
***INCLUDE MZPZ9920_MED_INPATIENT_I01 .
*----------------------------------------------------------------------*


*****&---------------------------------------------------------------------*
*****&      Module  SCREEN_ATTRIB_101_I  INPUT
*****&---------------------------------------------------------------------*
*****       text
*****----------------------------------------------------------------------*
****MODULE SCREEN_ATTRIB_101_I INPUT.
****
****
****  IF G_FACILITY = '0004'
****      or G_FACILITY = '0005'
****       or G_FACILITY = '0006'.
****    loop at screen.
****      if screen-name = 'P9920-ZDATE_TO'.
*****        screen-invisible = 0.
****        screen-input = 0.
****        modify screen.
****      endif.
****     endloop.
****  ENDIF.
****
****
****ENDMODULE.                 " SCREEN_ATTRIB_101_I  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CARD_LOV INPUT.

  if P9920-pernr is not INITIAL.
    PERFORM get_list_box USING 'P9920-ZCRDNO'.
  endif.

ENDMODULE.                 " GET_LOV_CARD   INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0101 INPUT.
  if ok_code_0101 = 'XYZ'.
* PERFORM get_list_box USING 'P9920-ZCRDNO'.
*call screen '0101'.
  else . " normal exit
    CASE ok_code_0101.

      WHEN 'BACK' OR 'CANC'.
        clear : P9920.
        clear: ok_code_0101, SAVE_OK.
        clear G_FACILITY.
        PERFORM reset_list_box USING 'P9920-ZCRDNO'.
        LEAVE TO SCREEN 0.

      when 'EXIT' .
        clear : P9920.
        clear: ok_code_0101, SAVE_OK.
        clear G_FACILITY.
        PERFORM reset_list_box USING 'P9920-ZCRDNO'.
        LEAVE program.

    ENDCASE.

  endif.

ENDMODULE.                 " USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_MODIFIED_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_MODIFIED_PERNR INPUT.
  Data : ist_dynpflds like dynpread occurs 1 with header line.

  ist_dynpflds-fieldname = 'P9920-PERNR'.

  append ist_dynpflds.

*  if P9920-ZCRDNO is initial.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = sy-cprog
      DYNUMB               = sy-dynnr
    TABLES
      DYNPFIELDS           = ist_dynpflds
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  endif.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = sy-cprog
      DYNUMB               = sy-dynnr
    TABLES
      DYNPFIELDS           = ist_dynpflds
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDMODULE.                 " GET_MODIFIED_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  RESET_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE RESET_DATA INPUT.
  clear p9920-zcrdno.
ENDMODULE.                 " RESET_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  save_ok = ok_code_0101.
  CLEAR ok_code_0101.
  CASE save_ok.
    WHEN 'BACK' or 'EXIT' or 'CANC'.
      clear p9920.
*      g_greyoff = space.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
*      P9920-ZAMTCLTOTAL = P9920-ZAMOUNT.
      perform calculate_values.
      perform validate_0101.

*Begin RD1K976756  CAB_ALOK  HR infotype update thro' RFC
**      PERFORM confirm_save.
**      IF g_answer = 'J'.
*      PERFORM lock_and_update_user_0101.
** Unnlocking the employee number after updatation
*      PERFORM unlock_user_0101.
**      ELSEIF g_answer <> 'J'.
**        g_disp = space.
**        MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
**          WITH 'Process Cancelled'.
**      ENDIF.

      PERFORM lock_update_unlock_user_0101.

*End RD1K976756  CAB_ALOK  HR infotype update thro' RFC
    WHEN 'SHVEND'.
      clear g_claim_not_save.
      SELECT * FROM ZHR_MED_VENDORS UP TO 1 ROWS
 WHERE LIFNR = P9920-ZHOSPID
 AND BUKRS = P9920-GRPVL
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      if zhr_med_vendors-taxable is INITIAL.
        g_claim_not_save = 'X'.
        message s000(zmsg)
        with 'Claim can not be saved - Hospital category for taxation '
             'not maintained'.
      endif.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_VENDOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_VENDOR INPUT.
  data: tmp_lifnr type lfa1-lifnr.
  REFRESH : DYFIELDS_1.
  refresh: IST_ZHR_MED_VENDORS, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  select BUKRS LIFNR NAME1 from ZHR_MED_VENDORS   " BUKRS, LIFNR
    into CORRESPONDING FIELDS OF TABLE IST_ZHR_MED_VENDORS
*  where BUKRS = G_BUKRS.  " Now P9920-GRPVL
      where BUKRS = P9920-GRPVL.

***
***   IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
***   IST_DYNPFLD_MAPPING-DYFLDNAME = 'P9920-ZHOSPID'.
***
***   APPEND IST_DYNPFLD_MAPPING.
***   CLEAR : IST_DYNPFLD_MAPPING.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'LIFNR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'P9920-ZHOSPID'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IST_ZHR_MED_VENDORS
      FIELD_TAB       = IST_FIELD
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  P9920-ZHOSPID = IST_RETURN_TAB-FIELDVAL.

  clear tmp_lifnr.
  tmp_lifnr = P9920-ZHOSPID.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = tmp_lifnr
    IMPORTING
      OUTPUT = tmp_lifnr.

  P9920-ZHOSPID  = tmp_lifnr.

ENDMODULE.                 " GET_VENDOR  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_VENDOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_VENDOR_list INPUT.
*  data: tmp_lifnr type lfa1-lifnr.
  REFRESH : DYFIELDS_1.
  refresh: IST_ZHR_MED_VENDORS, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  select BUKRS LIFNR NAME1 from ZHR_MED_VENDORS   " BUKRS, LIFNR
    into CORRESPONDING FIELDS OF TABLE IST_ZHR_MED_VENDORS
*  where BUKRS = G_BUKRS.  " Now P9920-GRPVL
      where BUKRS = P9920-GRPVL.


****  IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
****  IST_DYNPFLD_MAPPING-DYFLDNAME = 'P9920-ZHOSPID'.
****
****  APPEND IST_DYNPFLD_MAPPING.
****  CLEAR : IST_DYNPFLD_MAPPING.
****
****  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
****    EXPORTING
****      RETFIELD        = 'LIFNR'
****      DYNPPROG        = SY-CPROG
****      DYNPNR          = SY-DYNNR
****      DYNPROFIELD     = 'P9920-ZHOSPID'
****      VALUE_ORG       = 'S'
****    TABLES
****      VALUE_TAB       = IST_ZHR_MED_VENDORS
****      FIELD_TAB       = IST_FIELD
****      RETURN_TAB      = IST_RETURN_TAB
****      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
****    EXCEPTIONS
****      PARAMETER_ERROR = 1
****      NO_VALUES_FOUND = 2
****      OTHERS          = 3.
****  IF SY-SUBRC <> 0.
****    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
****            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
****  ENDIF.

****  P9920-ZHOSPID = IST_RETURN_TAB-FIELDVAL.

  clear tmp_lifnr.
  tmp_lifnr = P9920-ZHOSPID.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = tmp_lifnr
    IMPORTING
      OUTPUT = tmp_lifnr.

  P9920-ZHOSPID  = tmp_lifnr.



  REFRESH : g_list.  CLEAR g_value.
  CLEAR g_list.

  loop at IST_ZHR_MED_VENDORS into WA_ZHR_MED_VENDORS.
    g_value-key  = WA_ZHR_MED_VENDORS-LIFNR.
    CONCATENATE WA_ZHR_MED_VENDORS-BUKRS
                WA_ZHR_MED_VENDORS-NAME1 into  g_value-text separated by '-'.
    APPEND g_value TO g_list.
    CLEAR g_value.
  endloop.

  g_id = 'P9920-ZHOSPID'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_id
      values = g_list.


ENDMODULE.                 " GET_VENDOR  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0050  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0050 INPUT.
  case ok_code_0050.
    when 'CREA'.
      CALL SCREEN 0101.
    WHEN 'EDIT'.
      CALL SCREEN 0301.
*    WHEN 'DEL'.
*      CALL SCREEN 0601.
    WHEN 'MASSUPD'.
      SUBMIT ZHRMED_PYMT_MASS_UPLOAD AND RETURN.
*      AND RETURN.
    WHEN 'SUBMIT'.
      CALL SCREEN 0401.
    WHEN 'UNLOCK'.
      CALL SCREEN 0501.
    WHEN 'PAY'.
      CALL SCREEN 0601.
    WHEN 'STT'.           " status report , FS1.2
      CALL SCREEN 0701.
    WHEN 'DEL'.           " Delete claims, FS1.2
      CALL SCREEN 0801.
    WHEN 'PRINT'.           " Print Payment order, FS1.2
      CALL SCREEN 0901.
*Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP-Payment rreversal
    WHEN 'PYMT_REV'.
      CAll SCREEN 1001.
*End RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
    WHEN 'PAY_SANC'.
*BEGIN RD1K984471       CAB_ALOK     ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
* Begin RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
** now separate role for medical fund mgmt, hence commented
*      PERFORM fund_mgmt_role_auth.
* End RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
*End RD1K984471       CAB_ALOK     ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
      CALL SCREEN 0051.

  endcase.

ENDMODULE.                 " USER_COMMAND_0050  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_LEADING_ZERO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FILL_LEADING_ZERO INPUT.
* Data returned from F4 for ZHOSPID (vendor code) doesn't have leading
* Zeros. Even calling CONVERSION_EXIT_ALPHA_INPUT after F4 didn't help.
* ( Leading zeros got appended in P9920-ZHOSPID but got over-written in PAI
* as screen was still having value without leading zeros returned by F4)
*  So, Reading the screen element P9920-ZHOSPID in PAI, adding zeros and
*  then updating it again.

  Data : ist_dynpflds_zhospid like dynpread occurs 1 with header line.
  data : tmp_zhospid type lfa1-lifnr.
  ist_dynpflds_zhospid-fieldname = 'P9920-ZHOSPID'.

  append ist_dynpflds_zhospid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = sy-cprog
      DYNUMB               = sy-dynnr
    TABLES
      DYNPFIELDS           = ist_dynpflds_zhospid
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



  clear tmp_zhospid.
  tmp_zhospid = P9920-ZHOSPID.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = tmp_zhospid
    IMPORTING
      OUTPUT = tmp_zhospid.

  P9920-ZHOSPID  = tmp_zhospid.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = sy-cprog
      DYNUMB               = sy-dynnr
    TABLES
      DYNPFIELDS           = ist_dynpflds_zhospid
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

****  if not P9920-ZHOSPID is INITIAL.
****    data wa_medved type ZHR_MED_VENDORS.
****    READ TABLE IST_ZHR_MED_VENDORS into wa_medved with key
****                            lifnr = P9920-ZHOSPID.
****    if sy-subrc ne 0.
****      set CURSOR FIELD 'P9920-ZHOSPID'.
****      message e000(zmsg) with 'Please select vendor from drop down only'.
****    endif.
****
****
****
****    clear g_claim_not_save.
****    select single * from zhr_med_vendors where lifnr = P9920-zhospid and
****                                               BUKRS = P9920-GRPVL.
****
****    if zhr_med_vendors-taxable is INITIAL.
****      g_claim_not_save = 'X'.
****      message s000(zmsg)
****      with 'Claim can not be saved - Hospital category for taxation '
****           'not maintained'.
****    endif.
****
****
****  endif.

ENDMODULE.                 " FILL_LEADING_ZERO  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0301  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0301 INPUT.
  case OK_CODE_0301.
    when 'GETREC'.
      PERFORM GET_DATA_0301 . "on the basis of ZPMED_SUBMIT
**Struct.     ZPMED_SUBMIT
**    BEGDA_LOW          20100831
**    BEGDA_HIGH         20100929
**    UNAME_LOW          CAB_ALOK
**    UNAME_HIGH
**    ZHOSPID_LOW        800000
**    ZHOSPID_HIGH       800001
      CALL SCREEN 0305.

  endcase.

ENDMODULE.                 " USER_COMMAND_0301  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0401  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0401 INPUT.
  case OK_CODE_0401.
    when 'GETREC'.
      PERFORM GET_DATA_0401 . "on the basis of ZPMED_SUBMIT
**Struct.     ZPMED_SUBMIT
**    BEGDA_LOW          20100831
**    BEGDA_HIGH         20100929
**    UNAME_LOW          CAB_ALOK
**    UNAME_HIGH
**    ZHOSPID_LOW        800000
**    ZHOSPID_HIGH       800001
      CALL SCREEN 0405.

  endcase.
ENDMODULE.                 " USER_COMMAND_0401  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0401  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0401 INPUT.
  CASE ok_code_0401.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0401.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0401 .
      LEAVE program.

  ENDCASE.

ENDMODULE.                 " EXIT_0401  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0050  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0050 INPUT.
  CASE ok_code_0050.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0050.
      clear: G_USER_PERNR, G_USER_BUKRS, g_user_werks, g_user_name, g_user_desig .
      clear:  WA_AGR_USERS.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0050.
      clear: G_USER_PERNR, G_USER_BUKRS, g_user_werks, g_user_name, g_user_desig .
      clear:  WA_AGR_USERS.
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_0050  INPUT

MODULE EXIT_0051 INPUT.
  CASE ok_code_0051.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0051, ZHRHOSPSANCTION.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0051, ZHRHOSPSANCTION.
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_0050  INPUT





*&SPWIZARD: INPUT MODUL FOR TC 'TC_SUBMIT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_SUBMIT_MARK INPUT.
  DATA: g_TC_SUBMIT_wa2 like line of IST_9920_SUBMIT.
  if TC_SUBMIT-line_sel_mode = 1
  and WA_9920_SUBMIT-SEL = 'X'.
    loop at IST_9920_SUBMIT into g_TC_SUBMIT_wa2
      where SEL = 'X'.
      g_TC_SUBMIT_wa2-SEL = ''.
      modify IST_9920_SUBMIT
        from g_TC_SUBMIT_wa2
        transporting SEL.
    endloop.
  endif.
  MODIFY IST_9920_SUBMIT
    FROM WA_9920_SUBMIT
    INDEX TC_SUBMIT-CURRENT_LINE
    TRANSPORTING SEL.
ENDMODULE.                    "TC_SUBMIT_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_SUBMIT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_SUBMIT_USER_COMMAND INPUT.
  OK_CODE_0405 = SY-UCOMM.
  PERFORM USER_OK_TC_SUBMIT USING    'TC_SUBMIT'
                              'IST_9920_SUBMIT'
                              'SEL'
                     CHANGING OK_CODE_0405.
  SY-UCOMM = OK_CODE_0405.
ENDMODULE.                    "TC_SUBMIT_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0405  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0405 INPUT.

  CASE ok_code_0405.

    WHEN 'BACK' OR 'CANC'.
      clear : IST_9920_SUBMIT , WA_9920_SUBMIT .
      refresh : IST_9920_SUBMIT.
      clear: ok_code_0405.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : IST_9920_SUBMIT , WA_9920_SUBMIT .
      refresh : IST_9920_SUBMIT.
      clear: ok_code_0405.
      LEAVE program.

  ENDCASE.

ENDMODULE.                 " EXIT_0405  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0501  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0501 INPUT.

  CASE ok_code_0501.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0501.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0501.
      LEAVE program.

  ENDCASE.

ENDMODULE.                 " EXIT_0501  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0501  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0501 INPUT.
  case OK_CODE_0501.
    when 'GETREC'.

      PERFORM GET_DATA_0501 . "on the basis of ZPMED_SUBMIT
**Struct.     ZPMED_SUBMIT
**    BEGDA_LOW          20100831
**    BEGDA_HIGH         20100929
**    UNAME_LOW          CAB_ALOK
**    UNAME_HIGH
**    ZHOSPID_LOW        800000
**    ZHOSPID_HIGH       800001
      CALL SCREEN 0505.

  endcase.

ENDMODULE.                 " USER_COMMAND_0501  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0505  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0505 INPUT.   "unlock

  CASE ok_code_0505.

    WHEN 'BACK' OR 'CANC'.
      clear : IST_9920_UNLOCK , WA_9920_UNLOCK .
      refresh : IST_9920_UNLOCK.
      clear: ok_code_0505.
      clear: G_FLAG_EDITMO,  G_FLAG_SAVEMO.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : IST_9920_UNLOCK , WA_9920_UNLOCK .
      refresh : IST_9920_UNLOCK.
      clear: ok_code_0505.
      clear: G_FLAG_EDITMO,  G_FLAG_SAVEMO.
      LEAVE program.

  ENDCASE.

ENDMODULE.                 " EXIT_0505  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0505  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0505 INPUT.

ENDMODULE.                 " USER_COMMAND_0505  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_UNLOCK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_UNLOCK_MODIFY INPUT.
  MODIFY IST_9920_UNLOCK
    FROM WA_9920_UNLOCK
    INDEX TC_UNLOCK-CURRENT_LINE.
ENDMODULE.                    "TC_UNLOCK_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_UNLOCK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_UNLOCK_MARK INPUT.
  DATA: g_TC_UNLOCK_wa2 like line of IST_9920_UNLOCK.
  if TC_UNLOCK-line_sel_mode = 1
  and WA_9920_UNLOCK-SEL = 'X'.
    loop at IST_9920_UNLOCK into g_TC_UNLOCK_wa2
      where SEL = 'X'.
      g_TC_UNLOCK_wa2-SEL = ''.
      modify IST_9920_UNLOCK
        from g_TC_UNLOCK_wa2
        transporting SEL.
    endloop.
  endif.
  MODIFY IST_9920_UNLOCK
    FROM WA_9920_UNLOCK
    INDEX TC_UNLOCK-CURRENT_LINE
    TRANSPORTING SEL.
ENDMODULE.                    "TC_UNLOCK_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_UNLOCK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_UNLOCK_USER_COMMAND INPUT.
*begin RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
  if G_FLAG_RESTRICT is INITIAL.
*end RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
    OK_CODE_0505 = SY-UCOMM.
    PERFORM USER_OK_TC_UNLOCK USING    'TC_UNLOCK'
                                'IST_9920_UNLOCK'
                                'SEL'
                       CHANGING OK_CODE_0505.
    SY-UCOMM = OK_CODE_0505.
*begin RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
  endif.
*end RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
ENDMODULE.                    "TC_UNLOCK_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0301  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0301 INPUT.
  CASE ok_code_0301.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0301.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0301.
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_0301  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_EDIT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_EDIT_MODIFY INPUT.
  MODIFY IST_9920_EDIT
    FROM WA_9920_EDIT
    INDEX TC_EDIT-CURRENT_LINE.
ENDMODULE.                    "TC_EDIT_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_EDIT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_EDIT_MARK INPUT.
  DATA: g_TC_EDIT_wa2 like line of IST_9920_EDIT.
  if TC_EDIT-line_sel_mode = 1
  and WA_9920_EDIT-SEL = 'X'.
    loop at IST_9920_EDIT into g_TC_EDIT_wa2
      where SEL = 'X'.
      g_TC_EDIT_wa2-SEL = ''.
      modify IST_9920_EDIT
        from g_TC_EDIT_wa2
        transporting SEL.
    endloop.
  endif.
  MODIFY IST_9920_EDIT
    FROM WA_9920_EDIT
    INDEX TC_EDIT-CURRENT_LINE
    TRANSPORTING SEL.
ENDMODULE.                    "TC_EDIT_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_EDIT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_EDIT_USER_COMMAND INPUT.
  OK_CODE_0305 = SY-UCOMM.
  PERFORM USER_OK_TC_EDIT USING    'TC_EDIT'
                              'IST_9920_EDIT'
                              'SEL'
                     CHANGING OK_CODE_0305.
  SY-UCOMM = OK_CODE_0305.
ENDMODULE.                    "TC_EDIT_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0305  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0305 INPUT.
  CASE ok_code_0305.

    WHEN 'BACK' OR 'CANC'.
      clear : IST_9920_EDIT , WA_9920_EDIT .
      refresh : IST_9920_EDIT.
      clear: ok_code_0305.
      clear: G_FLAG_EDITDO,  G_FLAG_SAVEDO.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' .
      clear : IST_9920_EDIT , WA_9920_EDIT .
      refresh : IST_9920_EDIT.
      clear: ok_code_0305.
      clear: G_FLAG_EDITDO,  G_FLAG_SAVEDO.
      LEAVE program.
  ENDCASE.
ENDMODULE.                 " EXIT_0305  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0601  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0601 INPUT.
  CASE ok_code_0601.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0601.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0601.
      LEAVE program.

  ENDCASE.

ENDMODULE.                 " EXIT_0601  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0601  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0601 INPUT.
  case OK_CODE_0601.
    when 'GETREC'.



      if ZPMED_SUBMIT-ZLOT_NO_LOW is not INITIAL.
* begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
        Perform CHECK_LOT_LOCK .
* end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
        PERFORM GET_DATA_0601 . "on the basis of ZPMED_SUBMIT
      endif.
      CALL SCREEN 0605.

  endcase.
ENDMODULE.                 " USER_COMMAND_0601  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOTNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_LOTNO_UNLOCKED INPUT.

  REFRESH : DYFIELDS_1.
  refresh: IST_LOT, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .

  select ZLOT_NO BEGDA from PA9920   "BEGDA, lot no, Submission no.,
    into CORRESPONDING FIELDS OF TABLE IST_LOT
      where zstatus = 'UNLOCKED'
      and GRPVL = G_USER_BUKRS.

  SORT IST_LOT BY ZLOT_NO BEGDA ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IST_LOT COMPARING ZLOT_NO .
*    IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
*   IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-ZLOT_NO_LOW'.
*
*   APPEND IST_DYNPFLD_MAPPING.
*   CLEAR : IST_DYNPFLD_MAPPING.


*    IST_FIELD-TABNAME   = 'ZPMED_SUBMIT'.
*   IST_FIELD-FIELDNAME = 'ZLOT_NO_LOW'.
*   IST_FIELD-REPTEXT = 'LOT_NO'.
*
*  APPEND IST_FIELD.
*  CLEAR IST_FIELD.



  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZLOT_NO'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZPMED_SUBMIT-ZLOT_NO_LOW'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IST_LOT
      FIELD_TAB       = IST_FIELD
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  ZPMED_SUBMIT-ZLOT_NO_LOW = IST_RETURN_TAB-FIELDVAL.

*  clear tmp_lifnr.
*  tmp_lifnr = P9920-ZHOSPID.
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      INPUT  = tmp_lifnr
*    IMPORTING
*      OUTPUT = tmp_lifnr.
*
*  P9920-ZHOSPID  = tmp_lifnr.


ENDMODULE.                 " GET_LOTNO  INPUT


*&---------------------------------------------------------------------*
*&      Module  EXIT_0605  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0605 INPUT.
  CASE ok_code_0605.

    WHEN 'BACK' OR 'CANC'.
      clear : IST_9920_PAY , WA_9920_PAY .
      refresh : IST_9920_PAY.
      clear: ok_code_0605.
      clear: G_FLAG_EDITFI,  G_FLAG_SAVEFI.
      Clear: G_BUDAT, G_SECCO, G_KIDNO, G_WT_WITHCD, G_WT_BASE, G_WITHT, WA_PAY.
      refresh: IST_SECCO, IST_WT_WITHCD, IST_WITHT, ist_9920_pay_tmp.
      Clear: IST_RETURN_TAB.
      refresh:  IST_RETURN_TAB.

* Begin RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
* begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
*         SET PARAMETER ID 'ZSPA_LOT_NO' FIELD SPACE .
*         DELETE FROM ZHRMED_LOT_LOCK
*           WHERE  ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.

      perform UNLOCK_LOT_NO using ZPMED_SUBMIT-ZLOT_NO_LOW.

* end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
* end RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : IST_9920_PAY , WA_9920_PAY .
      refresh : IST_9920_PAY.
      clear: ok_code_0605.
      clear: G_FLAG_EDITFI,  G_FLAG_SAVEFI.
      Clear: G_BUDAT, G_SECCO, G_KIDNO, G_WT_WITHCD, G_WT_BASE, G_WITHT, WA_PAY.
      refresh: IST_SECCO, IST_WT_WITHCD, IST_WITHT, ist_9920_pay_tmp.
      Clear: IST_RETURN_TAB.
      refresh:  IST_RETURN_TAB.
* Begin RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
* begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
*         SET PARAMETER ID 'ZSPA_LOT_NO' FIELD SPACE .
*         DELETE FROM ZHRMED_LOT_LOCK
*           WHERE  ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.

      perform UNLOCK_LOT_NO using ZPMED_SUBMIT-ZLOT_NO_LOW.
* end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
* end RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_0605  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_PAY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_PAY_MODIFY INPUT.
  MODIFY IST_9920_PAY
    FROM WA_9920_PAY
    INDEX TC_PAY-CURRENT_LINE.
ENDMODULE.                    "TC_PAY_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_PAY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_PAY_MARK INPUT.
  DATA: g_TC_PAY_wa2 like line of IST_9920_PAY.
  if TC_PAY-line_sel_mode = 1
  and WA_9920_PAY-SEL = 'X'.
    loop at IST_9920_PAY into g_TC_PAY_wa2
      where SEL = 'X'.
      g_TC_PAY_wa2-SEL = ''.
      modify IST_9920_PAY
        from g_TC_PAY_wa2
        transporting SEL.
    endloop.
  endif.
  MODIFY IST_9920_PAY
    FROM WA_9920_PAY
    INDEX TC_PAY-CURRENT_LINE
    TRANSPORTING SEL.
ENDMODULE.                    "TC_PAY_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_PAY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_PAY_USER_COMMAND INPUT.
  OK_CODE_0605 = SY-UCOMM.
  PERFORM USER_OK_TC_PAY USING    'TC_PAY'
                              'IST_9920_PAY'
                              'SEL'
                     CHANGING OK_CODE_0605.
  SY-UCOMM = OK_CODE_0605.
ENDMODULE.                    "TC_PAY_USER_COMMAND INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_0701  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0701 INPUT.
  CASE ok_code_0701.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0701.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0701.
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_0701  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0701  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0701 INPUT.
  case OK_CODE_0701.
    when 'GETREC'.

      PERFORM GET_DATA_701 . "on the basis of ZPMED_SUBMIT

      CALL SCREEN 0705.

  endcase.
ENDMODULE.                 " USER_COMMAND_0701  INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_STATUS_REP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_STATUS_REP_MARK INPUT.
  DATA: g_TC_STATUS_REP_wa2 like line of IST_9920_STATUS.
  if TC_STATUS_REP-line_sel_mode = 1
  and WA_9920_STATUS-SEL = 'X'.
    loop at IST_9920_STATUS into g_TC_STATUS_REP_wa2
      where SEL = 'X'.
      g_TC_STATUS_REP_wa2-SEL = ''.
      modify IST_9920_STATUS
        from g_TC_STATUS_REP_wa2
        transporting SEL.
    endloop.
  endif.
  MODIFY IST_9920_STATUS
    FROM WA_9920_STATUS
    INDEX TC_STATUS_REP-CURRENT_LINE
    TRANSPORTING SEL.
ENDMODULE.                    "TC_STATUS_REP_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_STATUS_REP'. DO NOT CHANGE THIS LINE
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_STATUS_REP_USER_COMMAND INPUT.
  OK_CODE_0705 = SY-UCOMM.
  PERFORM USER_OK_TC_STATUS_REP USING    'TC_STATUS_REP'
                              'IST_9920_STATUS'
                              'SEL'
                     CHANGING OK_CODE_0705.
  SY-UCOMM = OK_CODE_0705.
ENDMODULE.                    "TC_STATUS_REP_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0705  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0705 INPUT.
  CASE ok_code_0705.

    WHEN 'BACK' OR 'CANC'.
      clear : IST_9920_STATUS , WA_9920_STATUS .
      refresh : IST_9920_STATUS.
      clear: ok_code_0705.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : IST_9920_STATUS , WA_9920_STATUS .
      refresh : IST_9920_STATUS.
      clear: ok_code_0705.
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_0705  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_G_SECCO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_G_SECCO INPUT.
  REFRESH : DYFIELDS_1.
  refresh: IST_SECCO, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  select SECCODE from SECCODE     "V_SECCODE
    into CORRESPONDING FIELDS OF TABLE IST_SECCO
      where BUKRS =  G_USER_BUKRS.

  SORT IST_SECCO BY SECCODE ASCENDING.  "NAME
  DELETE ADJACENT DUPLICATES FROM IST_SECCO COMPARING SECCODE . "NAME
*    IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
*   IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-ZLOT_NO_LOW'.
*
*   APPEND IST_DYNPFLD_MAPPING.
*   CLEAR : IST_DYNPFLD_MAPPING.


*    IST_FIELD-TABNAME   = 'ZPMED_SUBMIT'.
*   IST_FIELD-FIELDNAME = 'ZLOT_NO_LOW'.
*   IST_FIELD-REPTEXT = 'LOT_NO'.
*
*  APPEND IST_FIELD.
*  CLEAR IST_FIELD.



  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SECCODE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'G_SECCO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IST_SECCO
      FIELD_TAB       = IST_FIELD
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  G_SECCO = IST_RETURN_TAB-FIELDVAL.

*  clear tmp_lifnr.
*  tmp_lifnr = P9920-ZHOSPID.
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      INPUT  = tmp_lifnr
*    IMPORTING
*      OUTPUT = tmp_lifnr.
*
*  P9920-ZHOSPID  = tmp_lifnr.

ENDMODULE.                 " LOV_G_SECCO  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_LOTNO_ALL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_LOTNO_ALL INPUT.

  REFRESH : DYFIELDS_1.
  refresh: IST_LOT, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  select ZLOT_NO BEGDA from PA9920   "lot no, Submission no., Submission No.,
    into CORRESPONDING FIELDS OF TABLE IST_LOT
      where GRPVL = G_USER_BUKRS.

  SORT IST_LOT BY ZLOT_NO BEGDA ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IST_LOT COMPARING ZLOT_NO.
  DELETE IST_LOT where ZLOT_NO = '' .

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZLOT_NO'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZPMED_SUBMIT-ZLOT_NO_LOW'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IST_LOT
      FIELD_TAB       = IST_FIELD
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  ZPMED_SUBMIT-ZLOT_NO_LOW = IST_RETURN_TAB-FIELDVAL.



ENDMODULE.                 " LOV_LOTNO_ALL  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_G_KIDNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_G_KIDNO INPUT.

*DATA : ist_return_tab LIKE STANDARD TABLE OF ddshretval
*                 WITH HEADER LINE.
  DATA : BEGIN OF wa_ims,
          trackno   TYPE zmm_ims-trackno,
*          trackno   TYPE char30,
          lifnr     TYPE zmm_ims-lifnr,
          ebeln     TYPE zmm_ims-ebeln,
          invoiceno TYPE zmm_ims-invoiceno,
          invoicedt TYPE zmm_ims-invoicedt,
          reqloc    TYPE zmm_ims-reqloc,
         END OF wa_ims.
  DATA : BEGIN OF wa_ims2,
*          trackno   TYPE zmm_ims-trackno,
          trackno   TYPE char30,
          lifnr     TYPE zmm_ims-lifnr,
          ebeln     TYPE zmm_ims-ebeln,
          invoiceno TYPE zmm_ims-invoiceno,
          invoicedt TYPE zmm_ims-invoicedt,
          reqloc    TYPE zmm_ims-reqloc,
         END OF wa_ims2.
  DATA : ist_ims   LIKE TABLE OF wa_ims,
         ist_ims_t LIKE TABLE OF wa_ims.
  DATA : ist_ims2   LIKE TABLE OF wa_ims2.


  DATA : BEGIN OF wa_loc,
          locid TYPE zlocmst-locid,
         END OF wa_loc.

  DATA : ist_loc LIKE TABLE OF wa_loc.

  clear: WA_PAY .
  clear:  IST_RETURN_TAB .

  REFRESH : ist_return_tab,
            ist_ims,
            ist_ims_t.

  CLEAR  : wa_ims,wa_ims2.
  REFRESH : ist_ims2.
  read table ist_9920_pay into wa_pay index 1.

  if sy-subrc = 0.

    SELECT trackno ebeln FROM zmm_ims_status
             INTO CORRESPONDING FIELDS OF TABLE ist_ims_t
                       WHERE mbli_stat IN ('R','Y') AND
                             mbli_asn NOT IN ('A','D').


    IF sy-subrc = 0.
      SELECT trackno lifnr ebeln invoiceno invoicedt
                 FROM zmm_ims INTO TABLE ist_ims
                    FOR ALL ENTRIES IN ist_ims_t
                      WHERE trackno = ist_ims_t-trackno.

      IF sy-subrc = 0.

        IF NOT WA_PAY-ZHOSPID IS INITIAL.
          DELETE ist_ims WHERE lifnr <> WA_PAY-ZHOSPID.
        ENDIF.

*Location wise validation for tracking no
        REFRESH ist_loc.

        SELECT locid FROM zlocmst INTO TABLE ist_loc
            WHERE bukrs = G_USER_BUKRS.

        IF sy-subrc = 0.

          REFRESH ist_ims_t.

          LOOP AT ist_ims INTO wa_ims.

            READ TABLE ist_loc INTO wa_loc WITH KEY locid = wa_ims-trackno+6(3).

            IF sy-subrc = 0.

              APPEND wa_ims TO ist_ims_t.

            ENDIF.

          ENDLOOP.

          ist_ims[] = ist_ims_t[].

        ENDIF.

        IF ist_ims2[] IS INITIAL.
          LOOP AT ist_ims INTO wa_ims.
            MOVE-CORRESPONDING wa_ims TO wa_ims2.
            APPEND wa_ims2 TO ist_ims2.
          ENDLOOP.
          CLEAR wa_ims2.
*       wa_ims2-trackno = 'CONT/LABOUR/DRS'.
          wa_ims2-trackno = 'CONT LABOUR'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'IMP/CONT'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'PAYROLL'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'LEASE EMPLOYEE'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'CSR'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'AUDIT-SCHOOL'.
          APPEND wa_ims2 TO ist_ims2.
*       wa_ims2-trackno = 'LSC'.
          wa_ims2-trackno = 'LSC/LC'.
          APPEND wa_ims2 TO ist_ims2.
*       wa_ims2-trackno = 'EMD/SD/TF'.
          wa_ims2-trackno = 'EMD/SD/TFS/LD'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'INSURANCE'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'LAQ'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'LEASE OFFICE'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'LEGAL'.
          APPEND wa_ims2 TO ist_ims2.
*       wa_ims2-trackno = 'JV'.
          wa_ims2-trackno = 'JV CASH CALL'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'STAT PAYMENTS'.
          APPEND wa_ims2 TO ist_ims2.

          wa_ims2-trackno = 'Utility Payments'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'Doctor'.
          APPEND wa_ims2 TO ist_ims2.
          wa_ims2-trackno = 'CLEARING'.
          APPEND wa_ims2 TO ist_ims2.


          wa_ims2-trackno = 'TRVL-HTL'.
          APPEND wa_ims2 TO ist_ims2.


        ENDIF.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            retfield        = 'TRACKNO'
            dynpprog        = SY-CPROG
            dynpnr          = SY-DYNNR
            dynprofield     = 'G_KIDNO'
            value_org       = 'S'
          TABLES
*           value_tab       = ist_ims
            value_tab       = ist_ims2
            return_tab      = ist_return_tab
          EXCEPTIONS
            parameter_error = 1
            no_values_found = 2
            OTHERS          = 3.

        IF sy-subrc <> 0.

          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.

        G_KIDNO =  ist_return_tab-fieldval.

      ENDIF.

    ENDIF.

  endif . "sy-subrc = 0.
ENDMODULE.                 " LOV_G_KIDNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_G_WITHT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_G_WITHT INPUT.   "W/tax type
  data: WA_WITHT type TY_WITHT.
  REFRESH : DYFIELDS_1.
  refresh: IST_WITHT, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  clear: WA_PAY.
  REFRESH : ist_9920_pay_tmp.

  ist_9920_pay_tmp[] =  ist_9920_pay[].
  read table ist_9920_pay_tmp into wa_pay index 1.

  if sy-subrc = 0.

    select WITHT from LFBW
      into CORRESPONDING FIELDS OF TABLE IST_WITHT
        where LIFNR = WA_PAY-ZHOSPID
             and BUKRS = G_USER_BUKRS
* begin RD1K979096 CAB_ALOK ZHRHOSP - Modification in Tax code logic- CR 30006712
             and WT_SUBJCT = 'X'.  "  Indicator: Subject to withholding tax    .
* end RD1K979096 CAB_ALOK ZHRHOSP - Modification in Tax code logic- CR 30006712


    SORT IST_WITHT BY WITHT ASCENDING.
    DELETE ADJACENT DUPLICATES FROM IST_WITHT COMPARING WITHT.
    delete IST_WITHT where WITHT CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
*   if WA-WITHT CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.

*  DELETE IST_WITHT where WITHT = '' .
    clear WA_WITHT.
    loop at IST_WITHT into WA_WITHT.
      select SINGLE TEXT40
        into WA_WITHT-TEXT40
          from T059U
            where  SPRAS = 'EN'
               and LAND1 = 'IN'
               and WITHT = WA_WITHT-WITHT.
      concatenate WA_WITHT-WITHT ':' WA_WITHT-TEXT40 into WA_WITHT-TEXT40.
      MODIFY  IST_WITHT from WA_WITHT.
    endloop.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'WITHT'
        DYNPPROG        = SY-CPROG
        DYNPNR          = SY-DYNNR
        DYNPROFIELD     = 'G_WITHT'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = IST_WITHT
        FIELD_TAB       = IST_FIELD
        RETURN_TAB      = IST_RETURN_TAB
        DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    G_WITHT = IST_RETURN_TAB-FIELDVAL.
  endif. " sy-subrc = 0.
ENDMODULE.                 " LOV_G_WITHT  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_G_WT_WITHCD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_G_WT_WITHCD INPUT.
  data: WA_WT_WITHCD type TY_WT_WITHCD.
  REFRESH : DYFIELDS_1.
  refresh: IST_WT_WITHCD, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .


  select WT_WITHCD from t059z
     into CORRESPONDING FIELDS OF TABLE IST_WT_WITHCD
       where land1 = 'IN'
         and WITHT = G_WITHT.

  if sy-subrc = 0.


    SORT IST_WT_WITHCD BY WT_WITHCD ASCENDING.
    DELETE ADJACENT DUPLICATES FROM IST_WT_WITHCD COMPARING WT_WITHCD.
*  DELETE IST_WITHT where WITHT = '' .

    clear WA_WT_WITHCD.
    loop at IST_WT_WITHCD into WA_WT_WITHCD.
      select SINGLE TEXT40
        into WA_WT_WITHCD-TEXT40
          from T059ZT
            where  SPRAS = 'EN'
               and LAND1 = 'IN'
               and WITHT = G_WITHT
               and WT_WITHCD = WA_WT_WITHCD-WT_WITHCD.

      concatenate WA_WT_WITHCD-WT_WITHCD ':' WA_WT_WITHCD-TEXT40 into WA_WT_WITHCD-TEXT40.

      MODIFY  IST_WT_WITHCD from WA_WT_WITHCD.
    endloop.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'WT_WITHCD'
        DYNPPROG        = SY-CPROG
        DYNPNR          = SY-DYNNR
        DYNPROFIELD     = 'G_WT_WITHCD'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = IST_WT_WITHCD
        FIELD_TAB       = IST_FIELD
        RETURN_TAB      = IST_RETURN_TAB
        DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    G_WT_WITHCD = IST_RETURN_TAB-FIELDVAL.
  endif. " sy-subrc = 0.
ENDMODULE.                 " LOV_G_WT_WITHCD  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0801  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0801 INPUT.
  CASE ok_code_0801.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0801.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0801.
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_0801  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0801  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0801 INPUT.
  case OK_CODE_0801.
    when 'GETREC'.

      PERFORM GET_DATA_801 . "on the basis of ZPMED_SUBMIT

      CALL SCREEN 0805.

  endcase.
ENDMODULE.                 " USER_COMMAND_0801  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_LOTNO_REJ_NEW  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_LOTNO_REJ_NEW INPUT.
  REFRESH : DYFIELDS_1.
  refresh: IST_LOT, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .

  select ZLOT_NO BEGDA from PA9920   "lot no, Submission no., Submission No.,
    into CORRESPONDING FIELDS OF TABLE IST_LOT
      where GRPVL = G_USER_BUKRS
         and ( zstatus = 'NEW' or zstatus = 'REJMO' or zstatus = 'REJFI' ).

  SORT IST_LOT BY ZLOT_NO BEGDA ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IST_LOT COMPARING ZLOT_NO BEGDA.
  DELETE IST_LOT where ZLOT_NO = '' .


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZLOT_NO'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZPMED_SUBMIT-ZLOT_NO_LOW'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IST_LOT
      FIELD_TAB       = IST_FIELD
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  ZPMED_SUBMIT-ZLOT_NO_LOW = IST_RETURN_TAB-FIELDVAL.


ENDMODULE.                 " LOV_LOTNO_REJ_NEW  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_STATUS_REJ_NEW  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_STATUS_REJ_NEW INPUT.
  REFRESH : DYFIELDS_1.
  refresh: IST_STATUS, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .

  DATA: WA_STATUS type TY_STATUS.

  WA_STATUS-zstatus = 'NEW' .
  append WA_STATUS to IST_STATUS.
  WA_STATUS-zstatus = 'REJMO' .
  append WA_STATUS to IST_STATUS.
  WA_STATUS-zstatus = 'REJFI' .
  append WA_STATUS to IST_STATUS.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZSTATUS'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZPMED_SUBMIT-ZSTATUS'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IST_STATUS
      FIELD_TAB       = IST_FIELD
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  ZPMED_SUBMIT-ZSTATUS_LOW = IST_RETURN_TAB-FIELDVAL.

ENDMODULE.                 " LOV_STATUS_REJ_NEW  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_DELETE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_DELETE_MODIFY INPUT.
  MODIFY IST_9920_DELETE
    FROM WA_9920_DELETE
    INDEX TC_DELETE-CURRENT_LINE.
ENDMODULE.                    "TC_DELETE_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_DELETE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_DELETE_MARK INPUT.
  DATA: g_TC_DELETE_wa2 like line of IST_9920_DELETE.
  if TC_DELETE-line_sel_mode = 1
  and WA_9920_DELETE-SEL = 'X'.
    loop at IST_9920_DELETE into g_TC_DELETE_wa2
      where SEL = 'X'.
      g_TC_DELETE_wa2-SEL = ''.
      modify IST_9920_DELETE
        from g_TC_DELETE_wa2
        transporting SEL.
    endloop.
  endif.
  MODIFY IST_9920_DELETE
    FROM WA_9920_DELETE
    INDEX TC_DELETE-CURRENT_LINE
    TRANSPORTING SEL.
ENDMODULE.                    "TC_DELETE_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_DELETE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_DELETE_USER_COMMAND INPUT.
  OK_CODE_0805 = SY-UCOMM.
  PERFORM USER_OK_TC_DELETE USING    'TC_DELETE'
                              'IST_9920_DELETE'
                              'SEL'
                     CHANGING OK_CODE_0805.
  SY-UCOMM = OK_CODE_0805.
ENDMODULE.                    "TC_DELETE_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0805  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0805 INPUT.
  CASE ok_code_0805.

    WHEN 'BACK' OR 'CANC'.
      clear : IST_9920_DELETE , WA_9920_DELETE .
      refresh : IST_9920_DELETE.
      clear: ok_code_0805.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : IST_9920_DELETE , WA_9920_DELETE .
      refresh : IST_9920_DELETE.
      clear: ok_code_0805.
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_0805  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0901  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0901 INPUT.
  CASE ok_code_0901.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_0901.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_0901.
      LEAVE program.

  ENDCASE.

ENDMODULE.                 " EXIT_0901  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0901  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0901 INPUT.
  case OK_CODE_0901.
    when 'PRINTL'.

      if ZPMED_SUBMIT-ZLOT_NO_LOW is not INITIAL.

        PERFORM PRINT_LETTER_0901 . "on the basis of ZPMED_SUBMIT-ZLOT_NO_LOW

      endif.


  endcase.
ENDMODULE.                 " USER_COMMAND_0901  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* begin RD1K978193 CAB_ALOK CR 30006378
MODULE EXIT_0510 INPUT.
  CASE ok_code_0510.

    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      CLEAR  g_srch_flag.
      clear: ok_code_0510.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      CLEAR  g_srch_flag.
      clear: ok_code_0510.
      LEAVE program.

  ENDCASE.

ENDMODULE.                 " EXIT_0510  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0510 INPUT.

  CLEAR  g_srch_flag.
  CASE ok_code_0510.

    when 'ENTR'.
*    clear g_lifnr.
*    clear g_panno.
      If ZPMED_SUBMIT-PERNR_LOW is not initial.
*  g_lifnr = j_1imovend-lifnr.
        g_srch_flag = 'X'.
*  elseif not j_1imovend-j_1ipanno is initial.
*  g_panno = j_1imovend-j_1ipanno.
*    g_vflag = 'X'.
      endif.

      clear: ok_code_0510.
      leave  to screen  0.
    when 'CANC'.
      clear: ok_code_0510.
      Leave to  screen 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0510  INPUT
* end RD1K978193 CAB_ALOK CR 30006378

*&---------------------------------------------------------------------*
*&      Module  TC_UNLOCK_RESTRICT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
MODULE TC_UNLOCK_RESTRICT INPUT.
  data: wa_9920_UNLOCK_RESTRICT TYPE ty_submit,
        sel_count type i.
  data: MAX_UNLOCK type i.

  clear G_FLAG_RESTRICT.
* Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
*  MAX_UNLOCK = 200.       " Max No. of rows that can be unlocked under single LOT
  MAX_UNLOCK = 700.
* End RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832

  if sy-ucomm = 'TC_UNLOCK_UNLOCK'.
    sel_count = 0.
    Loop at IST_9920_UNLOCK into wa_9920_UNLOCK_RESTRICT where SEL = 'X' and zstatus = 'SUBMITTED'.
      sel_count = sel_count + 1.
    Endloop.

    if sel_count > MAX_UNLOCK.
      message w100(ZHR) with MAX_UNLOCK.
      G_FLAG_RESTRICT = 'X'.
    endif.
  endif.

ENDMODULE.                 " TC_UNLOCK_RESTRICT  INPUT

*&---------------------------------------------------------------------*
*&      Module  CALCULATE_TOTALS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CALCULATE_TOTALS INPUT.
  perform CALCULATE_TOTALS .
ENDMODULE.                 " CALCULATE_TOTALS  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_1001 INPUT.
  CASE ok_code_1001.
    WHEN 'BACK' OR 'CANC'.
      clear : ZPMED_SUBMIT.
      clear: ok_code_1001.
      LEAVE TO SCREEN 0.
    when 'EXIT' .
      clear : ZPMED_SUBMIT.
      clear: ok_code_1001.
      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_1001  INPUT


*&---------------------------------------------------------------------*
*&      Module  LOV_BELNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_LOT_BELNR INPUT.

  REFRESH : DYFIELDS_1.
  refresh: IST_LOT_BELNR, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
  Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .

  select ZLOT_NO BELNR GJAHR BUKRS from PA9920
    into CORRESPONDING FIELDS OF TABLE IST_LOT_BELNR
      where zstatus = 'PAID'.

  SORT IST_LOT_BELNR BY ZLOT_NO BELNR GJAHR BUKRS ASCENDING .
  DELETE ADJACENT DUPLICATES FROM IST_LOT_BELNR COMPARING ALL FIELDS .


  IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
  IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-ZLOT_NO_LOW'.

  APPEND IST_DYNPFLD_MAPPING.
  CLEAR : IST_DYNPFLD_MAPPING.

  IST_DYNPFLD_MAPPING-FLDNAME   = 'F0002'.
  IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-BELNR'.

  APPEND IST_DYNPFLD_MAPPING.
  CLEAR : IST_DYNPFLD_MAPPING.

  IST_DYNPFLD_MAPPING-FLDNAME   = 'F0003'.
  IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-GJAHR'.

  APPEND IST_DYNPFLD_MAPPING.
  CLEAR : IST_DYNPFLD_MAPPING.

  IST_DYNPFLD_MAPPING-FLDNAME   = 'F0004'.
  IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-BUKRS'.

  APPEND IST_DYNPFLD_MAPPING.
  CLEAR : IST_DYNPFLD_MAPPING.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZLOT_NO'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZPMED_SUBMIT-ZLOT_NO_LOW'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IST_LOT_BELNR
      FIELD_TAB       = IST_FIELD
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  ZPMED_SUBMIT-ZLOT_NO_LOW = IST_RETURN_TAB-FIELDVAL.
ENDMODULE.                 " LOV_BELNR  INPUT



*&---------------------------------------------------------------------*
*&      Module  VALIDATE_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_1001 INPUT.

* format data
  shift ZPMED_SUBMIT-ZLOT_NO_LOW LEFT DELETING LEADING SPACE.
  shift ZPMED_SUBMIT-BELNR LEFT DELETING LEADING SPACE.
  shift ZPMED_SUBMIT-GJAHR LEFT DELETING LEADING SPACE.
  shift ZPMED_SUBMIT-BUKRS LEFT DELETING LEADING SPACE.

* Validate Input
  select single * from PA9920
    WHERE ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
      AND BELNR = ZPMED_SUBMIT-BELNR
      AND GJAHR = ZPMED_SUBMIT-GJAHR
      AND BUKRS = ZPMED_SUBMIT-BUKRS.
  IF sy-subrc <> 0.
    message e117(ZHR).
  ENDIF.

  if ZPMED_SUBMIT-ZLOT_NO_LOW is INITIAL
      or ZPMED_SUBMIT-BELNR is INITIAL
        or ZPMED_SUBMIT-GJAHR is INITIAL
          or ZPMED_SUBMIT-BUKRS is INITIAL   .

    MESSAGE  e118(ZHR).
  endif.



ENDMODULE.                 " VALIDATE_1001  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1001 INPUT.
  case OK_CODE_1001.
    when 'GETREC'.



      if ZPMED_SUBMIT-ZLOT_NO_LOW is not INITIAL.
        PERFORM GET_DATA_1001 . "on the basis of ZPMED_SUBMIT
      endif.

      clear G_FLAG_REVERSED . " To enable 'REVERSE' Button
      CALL SCREEN 1005.

  endcase.


ENDMODULE.                 " USER_COMMAND_1001  INPUT



*&---------------------------------------------------------------------*
*&      Module  EXIT_1005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_1005 INPUT.
  CASE ok_code_1005.

    WHEN 'BACK' OR 'CANC'.
      clear : ok_code_1005, IST_9920_REV , WA_9920_REV .
      refresh : IST_9920_REV.
      Clear: IST_RETURN_TAB.
      refresh:  IST_RETURN_TAB.
      LEAVE TO SCREEN 0.

    when 'EXIT' .
      clear : ok_code_1005, IST_9920_REV , WA_9920_REV .
      refresh : IST_9920_REV.
      Clear: IST_RETURN_TAB.
      refresh:  IST_RETURN_TAB.

      LEAVE program.

  ENDCASE.
ENDMODULE.                 " EXIT_1005  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_REV'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_REV_USER_COMMAND INPUT.
  OK_CODE_1005 = SY-UCOMM.
  PERFORM USER_OK_TC_REV USING    'TC_REV'
                              'IST_9920_REV'
                              ' '
                     CHANGING OK_CODE_1005.
  SY-UCOMM = OK_CODE_1005.
ENDMODULE.                    "TC_REV_USER_COMMAND INPUT
*end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0051  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module USER_COMMAND_0051 input.
  Data join_conf.

  Case sy-ucomm.

*Begin RD1K997486       CAB_ALOK     Medical Vendor pymt for Contingent workers -CR 30012858
    When 'SANCREP'.
      CALL TRANSACTION 'ZFIMEDSANCREP'.

*End RD1K997486       CAB_ALOK     Medical Vendor pymt for Contingent workers -CR 30012858

    When 'BACK_SANC'.
      clear ZHRHOSPSANCTION.
      CALL SCREEN 0050.

    When 'ADD_SANC'.

      If ZHRHOSPSANCTION-BUKRS is initial or
**Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
         ZHRHOSPSANCTION-SECCO is initial or
**End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
         ZHRHOSPSANCTION-GLHEAD is initial or
         ZHRHOSPSANCTION-GJAHR is initial or
         ZHRHOSPSANCTION-FILENO is initial or
         ZHRHOSPSANCTION-AMT is initial .
        MESSAGE i008(zhr).


      Else.
* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930


**        Clear join_conf.
**           CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
**           EXPORTING
**           DEFAULTOPTION        = 'J'
**           textline1            = 'Please chose YES to confirm the amount and other details'
***          TEXTLINE2            = ' '
**           titel                = 'Warning'
***          START_COLUMN         = 25
***          START_ROW            = 6
***          CANCEL_DISPLAY       = 'X'
**          IMPORTING
**          ANSWER               =  join_conf.

**        If join_conf = 'J'.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930


        Select single * from zhrhospsanction into wa_zhrhospsanction
          where BUKRS = ZHRHOSPSANCTION-BUKRS
            and GLHEAD = ZHRHOSPSANCTION-GLHEAD
**Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
            and SECCO = ZHRHOSPSANCTION-SECCO
**End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
            and GJAHR = ZHRHOSPSANCTION-GJAHR
            and FILENO = ZHRHOSPSANCTION-FILENO.
        If sy-subrc = 0.
*        wa_zhrhospsanction-amt =   ZHRHOSPSANCTION-AMT + wa_zhrhospsanction-amt .
*        Modify ZHRHOSPSANCTION from wa_zhrhospsanction .
*        Commit work.
          Message i026(zhr).
*        Clear ZHRHOSPSANCTION.
          CALL SCREEN 0051.

        Else.

          MOVE-CORRESPONDING ZHRHOSPSANCTION to wa_zhrhospsanction.
* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

          Data L_ANS.
          data: L_SANC_AMT type zhrhospsanction-AMT,
                C_SANC_AMT(16),
                L_UTIL_AMT TYPE ZHRHOSPSANC_UTL-UTILAMT,
                C_UTIL_AMT(16),
                L_MSG(255).

          Clear: L_ANS, L_SANC_AMT, L_UTIL_AMT, L_MSG .

          Select sum( AMT ) from zhrhospsanction
            into L_SANC_AMT
            where BUKRS = ZHRHOSPSANCTION-BUKRS
**Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
              and SECCO = ZHRHOSPSANCTION-SECCO
**End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
              and GLHEAD = ZHRHOSPSANCTION-GLHEAD
              and GJAHR = ZHRHOSPSANCTION-GJAHR.

** now only two commitment items
**case  ZHRHOSPSANCTION-GLHEAD.
**
**when '0000200301'.
**        Select sum( UTILAMT ) from ZHRHOSPSANC_UTL
**          into L_UTIL_AMT
**          where BUKRS = ZHRHOSPSANCTION-BUKRS
**            and GLHEAD = ZHRHOSPSANCTION-GLHEAD
**            and GJAHR = ZHRHOSPSANCTION-GJAHR.
**
**when '0000200302'.
**
**        Select sum( UTILAMT ) from ZHRHOSPSANC_UTL
**          into L_UTIL_AMT
**          where BUKRS = ZHRHOSPSANCTION-BUKRS
**            and ( GLHEAD = '0000200302'
**                  OR GLHEAD = '0000200307'
**                  OR GLHEAD = '0000200308'
**                  OR GLHEAD = '0000200309'
**                  OR GLHEAD = '0000200317'
**                  OR GLHEAD = '0000200318'
**                 )
**            and GJAHR = ZHRHOSPSANCTION-GJAHR.
**endcase.

          Select sum( UTILAMT ) from ZHRHOSPSANC_UTL
            into L_UTIL_AMT
            where BUKRS = ZHRHOSPSANCTION-BUKRS
**Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
              and SECCO = ZHRHOSPSANCTION-SECCO
**End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
              and GLHEAD = ZHRHOSPSANCTION-GLHEAD
              and GJAHR = ZHRHOSPSANCTION-GJAHR.

          move L_SANC_AMT to  C_SANC_AMT .
          move L_UTIL_AMT to  C_UTIL_AMT .

          Concatenate 'Already entered sanction amount is RS'
            C_SANC_AMT ' out of which utilised is Rs' C_UTIL_AMT
            ' Do you want to enter this amount ?' into L_MSG RESPECTING BLANKS.

*           CALL FUNCTION 'POPUP_TO_CONFIRM_step'
*           EXPORTING
*           DEFAULTOPTION        = 'J'
*           textline1            = L_MSG
*           titel                = 'Message'
*           IMPORTING
*           ANSWER               =  L_ANS.
*            if  L_ANS = 'J' .

          CALL FUNCTION 'POPUP_TO_CONFIRM'
            EXPORTING
              text_question = L_MSG
            IMPORTING
              answer        = L_ANS.

          if  L_ANS = '1' .

*End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930

* Begin RD1K996913       CAB_ALOK     Report for hospital Sanction Utilization - CR 30012633

  CLEAR l_timestamp.
  CONVERT DATE SY-DATUM TIME SY-UZEIT INTO
          TIME STAMP l_timestamp TIME ZONE 'UTC   '.
  wa_zhrhospsanction-TIMESTAMP = l_timestamp.
  wa_zhrhospsanction-AENAM = SY-UNAME.

* update logs
  MOVE-CORRESPONDING wa_zhrhospsanction to WA_ZFIHOSPSANCLOG.
  Insert into ZFIHOSPSANCLOG  values WA_ZFIHOSPSANCLOG.
* End RD1K996913       CAB_ALOK   Report for hospital Sanction Utilization - CR 30012633

            Insert into ZHRHOSPSANCTION  values wa_zhrhospsanction.
            Commit work.
            Message i022(zhr).
*Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*     Clear ZHRHOSPSANCTION.
*End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
          endif.
*Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
          Clear ZHRHOSPSANCTION.
*End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
          CALL SCREEN 0050.
        Endif.
* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*        Endif. ""
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930


      Endif.

    when 'CHA_SANC'.
*begin RD1K984471  CAB_ALOK CR: 30008930 ZHRHOSP and ZHRNEHOSP sanction limits
      if sy-uname+0(3) <> 'CFI'
        and sy-uname+0(3) <> 'CAB' .
        MESSAGE e053(zhr).
      endif.
*end RD1K984471  CAB_ALOK CR: 30008930 ZHRHOSP and ZHRNEHOSP sanction limits

      If ZHRHOSPSANCTION-BUKRS is initial or
**Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
          ZHRHOSPSANCTION-SECCO IS INITIAL or
**End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
         ZHRHOSPSANCTION-GLHEAD is initial or
         ZHRHOSPSANCTION-GJAHR is initial or
         ZHRHOSPSANCTION-FILENO is initial or
         ZHRHOSPSANCTION-AMT is initial .
        MESSAGE i008(zhr).
      Else.

        Clear join_conf.
        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            DEFAULTOPTION  = 'J'
            textline1      = 'Please chose YES to confirm the amount and other details'
*           TEXTLINE2      = ' '
            titel          = 'Warning'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = 'X'
          IMPORTING
            ANSWER         = join_conf.

        If join_conf = 'J'.
          Select single * from zhrhospsanction into wa_zhrhospsanction
            where BUKRS = ZHRHOSPSANCTION-BUKRS
**Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
              and SECCO = ZHRHOSPSANCTION-SECCO
**End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
              and GLHEAD = ZHRHOSPSANCTION-GLHEAD
              and GJAHR = ZHRHOSPSANCTION-GJAHR
              and FILENO = ZHRHOSPSANCTION-FILENO.
          If sy-subrc = 0.
            wa_zhrhospsanction-amt =   ZHRHOSPSANCTION-AMT .

* Begin RD1K996913       CAB_ALOK     Report for hospital Sanction Utilization - CR 30012633

  CLEAR l_timestamp.
  CONVERT DATE SY-DATUM TIME SY-UZEIT INTO
          TIME STAMP l_timestamp TIME ZONE 'UTC   '.
  wa_zhrhospsanction-TIMESTAMP = l_timestamp.
  wa_zhrhospsanction-AENAM = SY-UNAME.

* update logs
  MOVE-CORRESPONDING wa_zhrhospsanction to WA_ZFIHOSPSANCLOG.
  Insert into ZFIHOSPSANCLOG  values WA_ZFIHOSPSANCLOG.

* End RD1K996913       CAB_ALOK     Report for hospital Sanction Utilization - CR 30012633

            Modify ZHRHOSPSANCTION from wa_zhrhospsanction .
            Commit work.
            Message i022(zhr).
            Clear ZHRHOSPSANCTION.
            CALL SCREEN 0050.
          Else.
*          MOVE-CORRESPONDING ZHRHOSPSANCTION to wa_zhrhospsanction.
*          Insert into ZHRHOSPSANCTION  values wa_zhrhospsanction.
*          Commit work.
          Endif.
        Endif.
      Endif.

    WHEN OTHERS.
      If ZHRHOSPSANCTION-BUKRS is not initial and
**Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
         ZHRHOSPSANCTION-SECCO IS INITIAL or
**End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
         ZHRHOSPSANCTION-GLHEAD is not initial and
         ZHRHOSPSANCTION-GJAHR is not initial AND
         ZHRHOSPSANCTION-FILENO is not initial.
        Select single amt from zhrhospsanction into ZHRHOSPSANCTION-AMT
          where BUKRS = ZHRHOSPSANCTION-BUKRS and GLHEAD = ZHRHOSPSANCTION-GLHEAD
           and GJAHR = ZHRHOSPSANCTION-GJAHR and FILENO = ZHRHOSPSANCTION-FILENO.
      Endif.
  Endcase.

endmodule.                 " USER_COMMAND_0051  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_FILENO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module GET_FILENO input.
  DATA : g_t_id TYPE vrm_id,
       g_t_list TYPE vrm_values,
       g_t_value  LIKE LINE OF g_t_list.

*  DATA: ist_return_tab TYPE STANDARD TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : g_t_list.
  CLEAR g_t_list.

  Types : begin of ty_file ,
          fileno type char25 ,
          end of ty_file .
  data : ist_fileno type table of ty_file WITH HEADER LINE,
         wa_fileno type ty_file.

  select fileno into CORRESPONDING FIELDS OF TABLE ist_fileno from zhrhospsanction
      where BUKRS = ZHRHOSPSANCTION-BUKRS and GLHEAD = ZHRHOSPSANCTION-GLHEAD
        and GJAHR = ZHRHOSPSANCTION-GJAHR.
*           and GLHEAD = ZHRHOSPSANCTION-GLHEAD.

  Loop at ist_fileno into wa_fileno.
    CLEAR g_t_value.
*      g_t_value-key  = wa_state-BEZEI.
    g_t_value-key  = wa_fileno-fileno.
*     g_t_value-text = wa_state-BEZEI.
    APPEND g_t_value TO g_t_list.
  Endloop.

*  g_t_id = 'ZHRHOSPSANCTION-FILENO'.
*
*    CALL FUNCTION 'VRM_SET_VALUES'
*   EXPORTING
*    id     = g_t_id
*    values = g_t_list.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
               retfield    = 'FILENO'
               dynpprog    = 'SAPMZPZ9920_MED_INPATIENT'
               dynpnr      = '0051'
               dynprofield = 'ZHRHOSPSANCTION-FILENO'
               value_org   = 'S'
          TABLES
               value_tab   = ist_fileno
               return_tab  = ist_return_tab
*Begin of <RD1K960036>
          EXCEPTIONS
              PARAMETER_ERROR        = 1
              NO_VALUES_FOUND        = 2
              OTHERS                 = 3  .

  IF sy-subrc <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

endmodule.                 " GET_FILENO  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_BUKRS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module VALIDATE_BUKRS input.

  If zhrhospsanction-bukrs is not initial.
    select single *  from BKPF where bukrs = zhrhospsanction-bukrs.
    If sy-subrc <> 0 .
      MESSAGE e020(zhr).
    Endif.
  Endif.


endmodule.                 " VALIDATE_BUKRS  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_GLHEAD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module VALIDATE_GLHEAD input.

  If zhrhospsanction-GLHEAD is not initial.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    select single *  from SKB1 where SAKNR = zhrhospsanction-GLHEAD.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    If sy-subrc <> 0 .
      MESSAGE e021(zhr).
    Endif.
  Endif.

endmodule.                 " VALIDATE_GLHEAD  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_GLHEAD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module GET_GLHEAD input.

*  DATA : g_t_id TYPE vrm_id,
*       g_t_list TYPE vrm_values,
*       g_t_value  LIKE LINE OF g_t_list.
*
  REFRESH : g_t_list.
  CLEAR g_t_list.


  Types : begin of ty_glhead ,
          SAKNR type SAKNR ,
          end of ty_glhead .

  data : ist_glhead type table of ty_glhead,
         wa_glhead type ty_glhead.

*select SAKNR into CORRESPONDING FIELDS OF TABLE ist_glhead from SKA1 .
*    where BUKRS = ZHRHOSPSANCTION-BUKRS .
  Refresh : ist_glhead ,g_t_list .

  wa_glhead-SAKNR = '0000200301'.
  append wa_glhead to ist_glhead.
  wa_glhead-SAKNR = '0000200302'.
  append wa_glhead to ist_glhead.

* Begin RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
  wa_glhead-SAKNR = '0000200309'.
  append wa_glhead to ist_glhead.
* End RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772

*Begin RD1K997486  CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
  wa_glhead-SAKNR = '0000200350'.
  append wa_glhead to ist_glhead.
*End RD1K997486   CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858


* Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
*wa_glhead-SAKNR = '0000200308'.
*append wa_glhead to ist_glhead.
*wa_glhead-SAKNR = '0000200309'.
*append wa_glhead to ist_glhead.
*wa_glhead-SAKNR = '0000200307'.
*append wa_glhead to ist_glhead.
*wa_glhead-SAKNR = '0000200317'.
*append wa_glhead to ist_glhead.
*wa_glhead-SAKNR = '0000200318'.
*append wa_glhead to ist_glhead.
* End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930


  Loop at ist_glhead  into wa_glhead .
    CLEAR g_t_value.
*      g_t_value-key  = wa_state-BEZEI.
    g_t_value-key  = wa_glhead-SAKNR.
*     g_t_value-text = wa_state-BEZEI.
    APPEND g_t_value TO g_t_list.
  Endloop.

  g_t_id = 'ZHRHOSPSANCTION-GLHEAD'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_t_id
      values = g_t_list.

endmodule.                 " GET_GLHEAD  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_0101 INPUT.
  data: l_persg1 type persg,
        l_kwert type ABRWT,
        l_fromdt type datum,
        l_tp9920 type pa9920.
  SELECT PERSG INTO L_PERSG1 FROM PA0001 UP TO 1 ROWS WHERE PERNR = P9920-PERNR
 AND ENDDA GE P9920-ZDATE_FROM AND BEGDA LE P9920-ZDATE_FROM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
* Begin of <RD1K994992> CAB_PAREEK 20.10.2014
*  if l_persg1 = '9' or l_persg1 = 'T' or l_persg1 = 'C'.
*    if g_facility ne '07'.
*      message e000(zmsg) with 'Only PME claim allowed for term/tenure'
*       '/contingent Employees'.
*    endif.
*  else.
*    if g_facility = '07'.
*      message e000(zmsg) with 'PME claim allowed for term/tenure/contingent'
*          'Employees'.
*    endif.
*  endif.

*Begin RD1K997911 CAB_ALOK Med Vend pymt:incl of contngt & term emp -CR 30013034

*  if l_persg1 = '9' or l_persg1 = 'T'.
*    if g_facility ne '07'.
*      message e000(zmsg) with 'Only PME claim allowed for term/tenure'
*       ' Employees'.
   if l_persg1 = 'T'.     "Tenure
     if g_facility = '03' or  g_facility = '04' or g_facility = '05' or g_facility = '06' .
      message e000(zmsg) with 'Only PME claim allowed for tenure'
       ' Employees'.
*End RD1K997911 CAB_ALOK Med Vend pymt:incl of contngt & term emp - contngt -CR 30013034


    endif.
  elseif  l_persg1 = 'C'.
*Begin RD1K997911 CAB_ALOK Med Vend pymt:incl of contngt & term emp -CR 30013034
*    if g_facility = '05' or g_facility = '06' or g_facility = '07'.
    if g_facility = '04' or g_facility = '05' or g_facility = '06' or g_facility = '07'.
    "// allowed
    else.
       message e000(zmsg) with 'Only Doctor/Pharmacy/Diagnostic/PME claim allowed for '
       'contingent Employees'.
    endif.
*End RD1K997911 CAB_ALOK Med Vend pymt:incl of contngt & term emp -CR 30013034

  else.
    if g_facility = '07'.
      message e000(zmsg) with 'PME claim allowed for tenure/contingent'
          'Employees'.
    endif.
  endif.
* End of <RD1K994992> CAB_PAREEK 20.10.2014

  if g_facility = '07'.


    l_fromdt = P9920-ZDATE_FROM - 730.

    select single * from pa9920 into l_tp9920
                                    where pernr = p9920-pernr and
                                          subty = '07' and
                                          endda gt l_fromdt.
    if sy-subrc = 0.
      message e000(zmsg) with 'PME already claimed in last two years'.
    endif.



    SELECT KWERT INTO L_KWERT FROM T511K UP TO 1 ROWS
 WHERE MOLGA EQ '40' AND KONST EQ 'ZPME' AND ENDDA GE P9920-ZDATE_FROM AND BEGDA LE P9920-ZDATE_FROM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if P9920-ZAMOUNT gt l_kwert.
      message e000(zmsg) with 'Maximum limit for PME is'
           l_kwert.
    endif.
  endif.
ENDMODULE.                 " VALIDATE_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_SECCO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
**Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
*
*MODULE LOV_SECCO INPUT.
*
*REFRESH : DYFIELDS_1.
*  refresh: IST_SECCO1, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
*  clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
*  select SECCODE from SECCODE     "V_SECCODE
*    into CORRESPONDING FIELDS OF TABLE IST_SECCO1
*      where BUKRS =  ZHRHOSPSANCTION-BUKRS.
*
*  SORT IST_SECCO1 BY SECCODE ASCENDING.  "NAME
*  DELETE ADJACENT DUPLICATES FROM IST_SECCO1 COMPARING SECCODE . "NAME
**    IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
**   IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-ZLOT_NO_LOW'.
**
**   APPEND IST_DYNPFLD_MAPPING.
**   CLEAR : IST_DYNPFLD_MAPPING.
*
*
**    IST_FIELD-TABNAME   = 'ZPMED_SUBMIT'.
**   IST_FIELD-FIELDNAME = 'ZLOT_NO_LOW'.
**   IST_FIELD-REPTEXT = 'LOT_NO'.
**
**  APPEND IST_FIELD.
**  CLEAR IST_FIELD.
*
*
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD        = 'SECCODE'
*      DYNPPROG        = SY-CPROG
*      DYNPNR          = SY-DYNNR
*      DYNPROFIELD     = 'ZHRHOSPSANCTION-SECCO'
*      VALUE_ORG       = 'S'
*    TABLES
*      VALUE_TAB       = IST_SECCO1
*      FIELD_TAB       = IST_FIELD
*      RETURN_TAB      = IST_RETURN_TAB
*      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
*    EXCEPTIONS
*      PARAMETER_ERROR = 1
*      NO_VALUES_FOUND = 2
*      OTHERS          = 3.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  ZHRHOSPSANCTION-SECCO = IST_RETURN_TAB-FIELDVAL.
*
**  clear tmp_lifnr.
**  tmp_lifnr = P9920-ZHOSPID.
**  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**    EXPORTING
**      INPUT  = tmp_lifnr
**    IMPORTING
**      OUTPUT = tmp_lifnr.
**
**  P9920-ZHOSPID  = tmp_lifnr.
*
*
*ENDMODULE.                 " LOV_SECCO  INPUT
**End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
