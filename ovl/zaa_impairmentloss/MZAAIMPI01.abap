*----------------------------------------------------------------------*
***INCLUDE MZMM_STOI01 .
*----------------------------------------------------------------------*
*Change History
*******************************************************************
*  Date        Transport    USERID       Description              *
* 08/09/2008   RD1K960036   SAB_SRIDHAR  Obsolete FM  "DOWNLAOD"  *
*                                        replaced  "GUI_DOWNLOAD" *
*******************************************************************

*&---------------------------------------------------------------------*
*&      Module  exit200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT200 INPUT.
  CASE OKCODE.
    WHEN 'CANC' OR 'EXIT' OR 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN..
  ENDCASE.
ENDMODULE.                 " exit200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  DATA:L_TABIX LIKE SY-TABIX,
  VAR(22),
  L_REC,
  L_FIELD(20),
  L_VALUE LIKE IST_DISPLAY-ANLN1.
  CASE OKCODE.
    WHEN 'SEL'.
      LOOP AT IST_DISPLAY.
        IST_DISPLAY-SEL = 'X'.
        MODIFY IST_DISPLAY INDEX SY-TABIX.
      ENDLOOP.
      SEL_FLAG = 'X'.
    WHEN 'UNSEL'.
      LOOP AT IST_DISPLAY WHERE SEL = 'X'.
        IST_DISPLAY-SEL = ' '.
        MODIFY IST_DISPLAY INDEX SY-TABIX.
      ENDLOOP.
      LOOP AT IST_DISPLAY.
      ENDLOOP.
      SEL_FLAG = ' '.
    WHEN 'DISP'.
      GET CURSOR FIELD L_FIELD VALUE L_VALUE.
      SET PARAMETER ID 'AN1' FIELD L_VALUE.
      READ TABLE IST_DISPLAY WITH KEY ANLN1 = L_VALUE.
      SET PARAMETER ID 'AN2' FIELD IST_DISPLAY-ANLN2.
      SET PARAMETER ID 'BUK' FIELD P_BUKRS.

      CALL TRANSACTION 'AW01' AND SKIP FIRST SCREEN.

    WHEN 'EXEC'.
*BOC By SAP_ABAP on 27/08/26
* S/4 conversion. Transaction ABAA is no longer a posting
* transaction - SE93 assigns it to dispatcher report RADISPATCH_AB01,
* which forwards with LEAVE TO TRANSACTION. That is illegal inside
* batch input, so the session built below died at step 1 with message
* 00 352 and could never post. Replaced by BAPI_ASSET_VALUE_ADJUST_CHECK / _POST,
* through the posting layer in MZAAIMPF01.
*
* Each row is validated with the _CHECK twin before it is posted, so a
* row that cannot post is reported instead of failing silently. Every
* message is kept per asset and shown at the end of the run - that is
* what the SM35 log used to provide.
*
* Old code:
*      PERFORM OPEN_GROUP.
*      LOOP AT IST_DISPLAY WHERE IMPRATIO <> 0.
*        L_TABIX = SY-TABIX.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0100'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANBZ-BWASL'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BUKRS'
*                                       P_BUKRS.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN1'
*                                      IST_DISPLAY-ANLN1.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN2'
*                                      IST_DISPLAY-ANLN2.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = SY-DATUM
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BLDAT'
*                                      G_DATE.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = P_BUDAT
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BUDAT'
*                                      G_DATE.
*        PERFORM BDC_FIELD       USING 'ANBZ-PERID'
*                                      P_MONAT.
*        PERFORM BDC_FIELD       USING 'ANBZ-BWASL'
*                                      IST_DISPLAY-TTYPE.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0110'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANEK-SGTXT'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '=UPDA'.
*        G_DMBTR = IST_DISPLAY-IMPRATIO.
*        PERFORM BDC_FIELD       USING 'ANBZ-DMBTR'
*                                   G_DMBTR.
*        PERFORM BDC_FIELD       USING 'ANBZ-BZDAT'
*                                      IST_DISPLAY-BZDAT.
*        PERFORM BDC_FIELD       USING 'ANEK-SGTXT'
*                                      P_GJAHR.
*        PERFORM BDC_TRANSACTION USING 'ABAA'.
*        IF SY-SUBRC = 0.
*          DELETE IST_DISPLAY INDEX L_TABIX.
*        ENDIF.
*      ENDLOOP.
*      PERFORM CLOSE_GROUP.
* New code:
      REFRESH: IT_ZAALOG, IT_ZAARET.
      CLEAR:   G_ZOKCNT, G_ZERRCNT.
      LOOP AT IST_DISPLAY WHERE IMPRATIO <> 0.
        L_TABIX = SY-TABIX.
* Validate first. The _CHECK call posts nothing.
        PERFORM ZAA_VALUE_ADJUST TABLES   IT_ZAARET
                                 USING    IST_DISPLAY-ANLN1
                                          IST_DISPLAY-ANLN2
                                          IST_DISPLAY-TTYPE
                                          IST_DISPLAY-IMPRATIO
                                          IST_DISPLAY-BZDAT
                                          P_GJAHR
                                          'X'
                                 CHANGING L_ZSUBRC.
        IF L_ZSUBRC = 0.
          PERFORM ZAA_VALUE_ADJUST TABLES   IT_ZAARET
                                   USING    IST_DISPLAY-ANLN1
                                            IST_DISPLAY-ANLN2
                                            IST_DISPLAY-TTYPE
                                            IST_DISPLAY-IMPRATIO
                                            IST_DISPLAY-BZDAT
                                            P_GJAHR
                                            ' '
                                   CHANGING L_ZSUBRC.
          IF L_ZSUBRC = 0.
            PERFORM ZAA_BAPI_COMMIT.
            G_ZOKCNT = G_ZOKCNT + 1.
            DELETE IST_DISPLAY INDEX L_TABIX.
          ELSE.
            PERFORM ZAA_BAPI_ROLLBACK.
            G_ZERRCNT = G_ZERRCNT + 1.
          ENDIF.
        ELSE.
          G_ZERRCNT = G_ZERRCNT + 1.
        ENDIF.
        PERFORM ZAA_KEEP_LOG.
      ENDLOOP.
* Report what posted and what did not. Nothing else tells the user -
* the SM35 log used to be the record of the run.
      PERFORM ZAA_SHOW_LOG.
*EOC By SAP_ABAP on 27/08/26
    WHEN 'DOWN'.

*Begin of <RD1K960036>

*      CALL FUNCTION 'DOWNLOAD'
*           EXPORTING
*                FILENAME = ' '
*                FILETYPE = 'DAT'
*           TABLES
*                DATA_TAB = IST_DISPLAY.

DATA:  l_filename    TYPE string,
       l_filen       TYPE string,
       l_path        TYPE string,
       l_fullpath    TYPE string,
       l_usr_act     TYPE I.

clear l_filename.
l_filename = SPACE.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
  EXPORTING
    INITIAL_DIRECTORY    = l_filename
  CHANGING
    FILENAME             = l_filen
    PATH                 = l_path
    FULLPATH             = l_fullpath
    USER_ACTION          = l_usr_act
  EXCEPTIONS
    CNTL_ERROR           = 1
    ERROR_NO_GUI         = 2
    NOT_SUPPORTED_BY_GUI = 3
    others               = 4.

    IF sy-subrc = 0
       AND l_usr_act NE
       CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    FILENAME                        = l_fullpath
   FILETYPE                         = g_c_dat
  TABLES
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    DATA_TAB                        = IST_DISPLAY
    DATA_TAB                        = IST_DISPLAY     "#EC CI_FLDEXT_OK[2610650]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
 EXCEPTIONS
   FILE_WRITE_ERROR                = 1
   NO_BATCH                        = 2
   GUI_REFUSE_FILETRANSFER         = 3
   INVALID_TYPE                    = 4
   NO_AUTHORITY                    = 5
   UNKNOWN_ERROR                   = 6
   HEADER_NOT_ALLOWED              = 7
   SEPARATOR_NOT_ALLOWED           = 8
   FILESIZE_NOT_ALLOWED            = 9
   HEADER_TOO_LONG                 = 10
   DP_ERROR_CREATE                 = 11
   DP_ERROR_SEND                   = 12
   DP_ERROR_WRITE                  = 13
   UNKNOWN_DP_ERROR                = 14
   ACCESS_DENIED                   = 15
   DP_OUT_OF_MEMORY                = 16
   DISK_FULL                       = 17
   DP_TIMEOUT                      = 18
   FILE_NOT_FOUND                  = 19
   DATAPROVIDER_EXCEPTION          = 20
   CONTROL_FLUSH_ERROR             = 21
   OTHERS                          = 22 .


IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

   Endif.
*      IF SY-SUBRC <> 0.
*      ENDIF.
*End of <RD1K960036>

    WHEN 'BACK'.
      G_TEXT = 'Do You Want to quit the screen'.
      PERFORM POPUP_MESSAGE USING G_TEXT.
*Begin of <RD1K960036>
*      IF G_ANSWER = 'J'.
       IF G_ANSWER = g_c_one.
*End of <RD1K960036>
        SET SCREEN 0.
        LEAVE SCREEN.
      ELSE.
        SET SCREEN '0200'.
      ENDIF.
  ENDCASE.
  CLEAR OKCODE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_selected_lines  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_SELECTED_LINES INPUT.
  MODIFY IST_DISPLAY FROM IST_DISPLAY INDEX TBC_200-CURRENT_LINE.
  CLEAR G_COUNT.
  IF IST_DISPLAY-IMPRATIO > IST_DISPLAY-NBV.
    MESSAGE E052(ZAA).
  ENDIF.
  IF IST_DISPLAY-TTYPE = 'X20' OR
  IST_DISPLAY-TTYPE =  'X30' OR
  IST_DISPLAY-TTYPE =  '641' OR
  IST_DISPLAY-TTYPE =  '651'.
  ELSE.
    MESSAGE E055(ZAA).
  ENDIF.
ENDMODULE.                 " move_selected_lines  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATA INPUT.
*  if okcode = 'EXEC'.
*    read table ist_display with key sel = 'X'.
*    if sy-subrc <> '0'.
*      message e260(zfi).
*    endif.
*  endif.
  IF OKCODE = 'ENTE'.
    CLEAR P_SAFAP.
    CLEAR IST_DISPLAY.
    LOOP AT IST_DISPLAY.
      P_SAFAP = P_SAFAP + IST_DISPLAY-IMPRATIO.
    ENDLOOP.
  ENDIF.


ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT300 INPUT.
  CASE OKCODE.
    WHEN 'CANC' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN..
  ENDCASE.

ENDMODULE.                 " exit300  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  CASE OKCODE.
    WHEN 'SEL'.
      LOOP AT IST_DISPLAY.
        IST_DISPLAY-SEL = 'X'.
        MODIFY IST_DISPLAY INDEX SY-TABIX.
      ENDLOOP.
      SEL_FLAG = 'X'.
    WHEN 'UNSEL'.
      LOOP AT IST_DISPLAY WHERE SEL = 'X'.
        IST_DISPLAY-SEL = ' '.
        MODIFY IST_DISPLAY INDEX SY-TABIX.
      ENDLOOP.
      LOOP AT IST_DISPLAY.
      ENDLOOP.
      SEL_FLAG = ' '.
    WHEN 'DISP'.
      GET CURSOR FIELD L_FIELD VALUE L_VALUE.
      SET PARAMETER ID 'AN1' FIELD L_VALUE.
      READ TABLE IST_DISPLAY WITH KEY ANLN1 = L_VALUE.
      SET PARAMETER ID 'AN2' FIELD IST_DISPLAY-ANLN2.
      SET PARAMETER ID 'BUK' FIELD P_BUKRS.

      CALL TRANSACTION 'AW01' AND SKIP FIRST SCREEN.

    WHEN 'EXEC'.
*BOC By SAP_ABAP on 27/08/26
* S/4 conversion. Transaction ABZU is no longer a posting
* transaction - SE93 assigns it to dispatcher report RADISPATCH_AB01,
* which forwards with LEAVE TO TRANSACTION. That is illegal inside
* batch input, so the session built below died at step 1 with message
* 00 352 and could never post. Replaced by BAPI_ASSET_WRITEUP_CHECK / _POST,
* through the posting layer in MZAAIMPF01.
*
* Each row is validated with the _CHECK twin before it is posted, so a
* row that cannot post is reported instead of failing silently. Every
* message is kept per asset and shown at the end of the run - that is
* what the SM35 log used to provide.
*
* Old code:
*      PERFORM OPEN_GROUP.
*      LOOP AT IST_DISPLAY WHERE IMPWBRATIO <> 0.
*        L_TABIX = SY-TABIX.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0100'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANBZ-BWASL'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BUKRS'
*                                      P_BUKRS.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN1'
*                                      IST_DISPLAY-ANLN1.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN2'
*                                      IST_DISPLAY-ANLN2.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = SY-DATUM
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BLDAT'
*                                      G_DATE.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = P_BUDAT
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BUDAT'
*                                      G_DATE.
*        PERFORM BDC_FIELD       USING 'ANBZ-PERID'
*                                      P_MONAT.
*        PERFORM BDC_FIELD       USING 'ANBZ-BWASL'
*                                      IST_DISPLAY-TTYPE.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0140'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANEK-SGTXT'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '=UPDA'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BZDAT'
*                                      IST_DISPLAY-BZDAT.
*        G_DMBTR = IST_DISPLAY-IMPWBRATIO.
*        IF IST_DISPLAY-TTYPE = 'X70'.
*          PERFORM BDC_FIELD       USING 'ANBZ-SAFAV'
*                                        G_DMBTR.
*        ELSE.
*          PERFORM BDC_FIELD       USING 'ANBZ-NAFAV'
*                                        G_DMBTR.
*        ENDIF.
*        PERFORM BDC_FIELD       USING 'ANEK-SGTXT'
*                                      P_GJAHR.
*        PERFORM BDC_FIELD       USING 'RA01B-BLART'
*                                      'AA'.
*        PERFORM BDC_TRANSACTION USING 'ABZU'.
*        IF SY-SUBRC = 0.
*          DELETE IST_DISPLAY INDEX L_TABIX.
*        ENDIF.
*      ENDLOOP.
*      PERFORM CLOSE_GROUP.
* New code:
      REFRESH: IT_ZAALOG, IT_ZAARET.
      CLEAR:   G_ZOKCNT, G_ZERRCNT.
      LOOP AT IST_DISPLAY WHERE IMPWBRATIO <> 0.
        L_TABIX = SY-TABIX.
* Validate first. The _CHECK call posts nothing.
        PERFORM ZAA_WRITEUP TABLES   IT_ZAARET
                            USING    IST_DISPLAY-ANLN1
                                     IST_DISPLAY-ANLN2
                                     IST_DISPLAY-TTYPE
                                     IST_DISPLAY-IMPWBRATIO
                                     IST_DISPLAY-BZDAT
                                     P_GJAHR
                                     'AA'
                                     ' '
                                     'X'
                            CHANGING L_ZSUBRC.
        IF L_ZSUBRC = 0.
          PERFORM ZAA_WRITEUP TABLES   IT_ZAARET
                              USING    IST_DISPLAY-ANLN1
                                       IST_DISPLAY-ANLN2
                                       IST_DISPLAY-TTYPE
                                       IST_DISPLAY-IMPWBRATIO
                                       IST_DISPLAY-BZDAT
                                       P_GJAHR
                                       'AA'
                                       ' '
                                       ' '
                              CHANGING L_ZSUBRC.
          IF L_ZSUBRC = 0.
            PERFORM ZAA_BAPI_COMMIT.
            G_ZOKCNT = G_ZOKCNT + 1.
            DELETE IST_DISPLAY INDEX L_TABIX.
          ELSE.
            PERFORM ZAA_BAPI_ROLLBACK.
            G_ZERRCNT = G_ZERRCNT + 1.
          ENDIF.
        ELSE.
          G_ZERRCNT = G_ZERRCNT + 1.
        ENDIF.
        PERFORM ZAA_KEEP_LOG.
      ENDLOOP.
* Report what posted and what did not. Nothing else tells the user -
* the SM35 log used to be the record of the run.
      PERFORM ZAA_SHOW_LOG.
*EOC By SAP_ABAP on 27/08/26
    WHEN 'DOWN'.
*Begin of <RD1K960036>

*      CALL FUNCTION 'DOWNLOAD'
*           EXPORTING
*                FILENAME = ' '
*                FILETYPE = 'DAT'
*           TABLES
*                DATA_TAB = IST_DISPLAY.
CLEAR l_filename.
l_filename = SPACE.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
  EXPORTING
    INITIAL_DIRECTORY    = l_filename
  CHANGING
    FILENAME             = l_filen
    PATH                 = l_path
    FULLPATH             = l_fullpath
    USER_ACTION          = l_usr_act
  EXCEPTIONS
    CNTL_ERROR           = 1
    ERROR_NO_GUI         = 2
    NOT_SUPPORTED_BY_GUI = 3
    others               = 4.

    IF sy-subrc = 0
       AND l_usr_act NE
       CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    FILENAME                        = l_fullpath
   FILETYPE                         = g_c_dat
  TABLES
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    DATA_TAB                        = IST_DISPLAY
    DATA_TAB                        = IST_DISPLAY     "#EC CI_FLDEXT_OK[2610650]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
 EXCEPTIONS
   FILE_WRITE_ERROR                = 1
   NO_BATCH                        = 2
   GUI_REFUSE_FILETRANSFER         = 3
   INVALID_TYPE                    = 4
   NO_AUTHORITY                    = 5
   UNKNOWN_ERROR                   = 6
   HEADER_NOT_ALLOWED              = 7
   SEPARATOR_NOT_ALLOWED           = 8
   FILESIZE_NOT_ALLOWED            = 9
   HEADER_TOO_LONG                 = 10
   DP_ERROR_CREATE                 = 11
   DP_ERROR_SEND                   = 12
   DP_ERROR_WRITE                  = 13
   UNKNOWN_DP_ERROR                = 14
   ACCESS_DENIED                   = 15
   DP_OUT_OF_MEMORY                = 16
   DISK_FULL                       = 17
   DP_TIMEOUT                      = 18
   FILE_NOT_FOUND                  = 19
   DATAPROVIDER_EXCEPTION          = 20
   CONTROL_FLUSH_ERROR             = 21
   OTHERS                          = 22 .

IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

   Endif.
*      IF SY-SUBRC <> 0.
*      ENDIF.
*End of <RD1K960036>

    WHEN 'BACK'.
      G_TEXT = 'Do You Want to quit the screen'.
      PERFORM POPUP_MESSAGE USING G_TEXT.
*Begin of <RD1K960036>
*      IF G_ANSWER = 'J'.
      IF G_ANSWER = g_c_one.
*End of <RD1K960036>
        SET SCREEN 0.
        LEAVE SCREEN.
      ELSE.
        SET SCREEN '0300'.
      ENDIF.
      CLEAR OKCODE.
  ENDCASE.
  CLEAR OKCODE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_selected_lines1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_SELECTED_LINES1 INPUT.
  MODIFY IST_DISPLAY FROM IST_DISPLAY INDEX TBC_300-CURRENT_LINE.
  IF IST_DISPLAY-IMPWBRATIO > IST_DISPLAY-IMPAMT.
    MESSAGE E054(ZAA).
  ENDIF.
  IF IST_DISPLAY-TTYPE = 'X70' OR IST_DISPLAY-TTYPE =  '700' .
  ELSE.
    MESSAGE E056(ZAA).
  ENDIF.
ENDMODULE.                 " move_selected_lines1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.
  CASE OKCODE.
    WHEN 'SEL'.
      LOOP AT IST_DISPLAY.
        IST_DISPLAY-SEL = 'X'.
        MODIFY IST_DISPLAY INDEX SY-TABIX.
      ENDLOOP.
      SEL_FLAG = 'X'.
    WHEN 'UNSEL'.
      LOOP AT IST_DISPLAY WHERE SEL = 'X'.
        IST_DISPLAY-SEL = ' '.
        MODIFY IST_DISPLAY INDEX SY-TABIX.
      ENDLOOP.
      LOOP AT IST_DISPLAY.
      ENDLOOP.
      SEL_FLAG = ' '.
    WHEN 'DISP'.
      GET CURSOR FIELD L_FIELD VALUE L_VALUE.
      SET PARAMETER ID 'AN1' FIELD L_VALUE.
      READ TABLE IST_DISPLAY WITH KEY ANLN1 = L_VALUE.
      SET PARAMETER ID 'AN2' FIELD IST_DISPLAY-ANLN2.
      SET PARAMETER ID 'BUK' FIELD P_BUKRS.

      CALL TRANSACTION 'AW01' AND SKIP FIRST SCREEN.
    WHEN 'EXEC'.
*BOC By SAP_ABAP on 27/08/26
* S/4 conversion. Transaction ABAA is no longer a posting
* transaction - SE93 assigns it to dispatcher report RADISPATCH_AB01,
* which forwards with LEAVE TO TRANSACTION. That is illegal inside
* batch input, so the session built below died at step 1 with message
* 00 352 and could never post. Replaced by BAPI_ASSET_VALUE_ADJUST_CHECK / _POST,
* through the posting layer in MZAAIMPF01.
*
* Each row is validated with the _CHECK twin before it is posted, so a
* row that cannot post is reported instead of failing silently. Every
* message is kept per asset and shown at the end of the run - that is
* what the SM35 log used to provide.
*
* Old code:
*      PERFORM OPEN_GROUP.
*      LOOP AT IST_DISPLAY where NBVDIFF > 0. " where sel = 'X'.
*        L_TABIX = SY-TABIX.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0100'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANBZ-BWASL'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BUKRS'
*                                       P_BUKRS.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN1'
*                                      IST_DISPLAY-ANLN1.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN2'
*                                      IST_DISPLAY-ANLN2.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = SY-DATUM
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BLDAT'
*                                      G_DATE.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = P_BUDAT
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BUDAT'
*                                      G_DATE.
*        PERFORM BDC_FIELD       USING 'ANBZ-PERID'
*                                      P_MONAT.
*        PERFORM BDC_FIELD       USING 'ANBZ-BWASL'
*                                      IST_DISPLAY-TTYPE.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0110'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANEK-SGTXT'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '=UPDA'.
*        G_DMBTR = IST_DISPLAY-NBVDIFF.
*
*        PERFORM BDC_FIELD       USING 'ANBZ-DMBTR'
*                                      G_DMBTR.
*        PERFORM BDC_FIELD       USING 'ANBZ-BZDAT'
*                                      IST_DISPLAY-BZDAT.
*        PERFORM BDC_FIELD       USING 'ANEK-SGTXT'
*                 'DEP.ON IMPAIRMENT WRITTEN BACK'.
*        PERFORM BDC_TRANSACTION USING 'ABAA'.
*        IF SY-SUBRC = 0.
*          DELETE IST_DISPLAY INDEX L_TABIX.
*        ENDIF.
*      ENDLOOP.
*
*      PERFORM CLOSE_GROUP.
* New code:
      REFRESH: IT_ZAALOG, IT_ZAARET.
      CLEAR:   G_ZOKCNT, G_ZERRCNT.
      LOOP AT IST_DISPLAY WHERE NBVDIFF > 0.
        L_TABIX = SY-TABIX.
* Validate first. The _CHECK call posts nothing.
        PERFORM ZAA_VALUE_ADJUST TABLES   IT_ZAARET
                                 USING    IST_DISPLAY-ANLN1
                                          IST_DISPLAY-ANLN2
                                          IST_DISPLAY-TTYPE
                                          IST_DISPLAY-NBVDIFF
                                          IST_DISPLAY-BZDAT
                                          'DEP.ON IMPAIRMENT WRITTEN BACK'
                                          'X'
                                 CHANGING L_ZSUBRC.
        IF L_ZSUBRC = 0.
          PERFORM ZAA_VALUE_ADJUST TABLES   IT_ZAARET
                                   USING    IST_DISPLAY-ANLN1
                                            IST_DISPLAY-ANLN2
                                            IST_DISPLAY-TTYPE
                                            IST_DISPLAY-NBVDIFF
                                            IST_DISPLAY-BZDAT
                                            'DEP.ON IMPAIRMENT WRITTEN BACK'
                                            ' '
                                   CHANGING L_ZSUBRC.
          IF L_ZSUBRC = 0.
            PERFORM ZAA_BAPI_COMMIT.
            G_ZOKCNT = G_ZOKCNT + 1.
            DELETE IST_DISPLAY INDEX L_TABIX.
          ELSE.
            PERFORM ZAA_BAPI_ROLLBACK.
            G_ZERRCNT = G_ZERRCNT + 1.
          ENDIF.
        ELSE.
          G_ZERRCNT = G_ZERRCNT + 1.
        ENDIF.
        PERFORM ZAA_KEEP_LOG.
      ENDLOOP.
* Report what posted and what did not. Nothing else tells the user -
* the SM35 log used to be the record of the run.
      PERFORM ZAA_SHOW_LOG.
*EOC By SAP_ABAP on 27/08/26
    WHEN 'DOWN'.
*Begin of <RD1K960036>

*      CALL FUNCTION 'DOWNLOAD'
*           EXPORTING
*                FILENAME = ' '
*                FILETYPE = 'DAT'
*           TABLES
*                DATA_TAB = IST_DISPLAY.

clear l_filename.
l_filename = SPACE.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
  EXPORTING
    DEFAULT_FILE_NAME    = l_filename
  CHANGING
    FILENAME             = l_filen
    PATH                 = l_path
    FULLPATH             = l_fullpath
    USER_ACTION          = l_usr_act
  EXCEPTIONS
    CNTL_ERROR           = 1
    ERROR_NO_GUI         = 2
    NOT_SUPPORTED_BY_GUI = 3
    others               = 4.

    IF sy-subrc = 0
       AND l_usr_act NE
       CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    FILENAME                        = l_fullpath
   FILETYPE                         = g_c_dat
  TABLES
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    DATA_TAB                        = IST_DISPLAY
    DATA_TAB                        = IST_DISPLAY     "#EC CI_FLDEXT_OK[2610650]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
 EXCEPTIONS
   FILE_WRITE_ERROR                = 1
   NO_BATCH                        = 2
   GUI_REFUSE_FILETRANSFER         = 3
   INVALID_TYPE                    = 4
   NO_AUTHORITY                    = 5
   UNKNOWN_ERROR                   = 6
   HEADER_NOT_ALLOWED              = 7
   SEPARATOR_NOT_ALLOWED           = 8
   FILESIZE_NOT_ALLOWED            = 9
   HEADER_TOO_LONG                 = 10
   DP_ERROR_CREATE                 = 11
   DP_ERROR_SEND                   = 12
   DP_ERROR_WRITE                  = 13
   UNKNOWN_DP_ERROR                = 14
   ACCESS_DENIED                   = 15
   DP_OUT_OF_MEMORY                = 16
   DISK_FULL                       = 17
   DP_TIMEOUT                      = 18
   FILE_NOT_FOUND                  = 19
   DATAPROVIDER_EXCEPTION          = 20
   CONTROL_FLUSH_ERROR             = 21
   OTHERS                          = 22 .

IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

   Endif.

*      IF SY-SUBRC <> 0.
*      ENDIF.
*End of <RD1K960036>

    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
  CLEAR OKCODE.
ENDMODULE.                 " USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_selected_lines2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_SELECTED_LINES2 INPUT.
  MODIFY IST_DISPLAY FROM IST_DISPLAY INDEX TBC_400-CURRENT_LINE.
ENDMODULE.                 " move_selected_lines2  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT400 INPUT.
  CASE OKCODE.
    WHEN 'CANC' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN..
  ENDCASE.
ENDMODULE.                 " exit400  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATA1 INPUT.
  IF OKCODE = 'ENTE'.
    CLEAR P_SAFAP.
    CLEAR IST_DISPLAY.
    LOOP AT IST_DISPLAY.
      P_SAFAP = P_SAFAP + IST_DISPLAY-IMPWBRATIO.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " check_data1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.
  CASE OKCODE.
    WHEN 'DISP'.
      GET CURSOR FIELD L_FIELD VALUE L_VALUE.
      SET PARAMETER ID 'AN1' FIELD L_VALUE.
      READ TABLE IST_DISPLAY WITH KEY ANLN1 = L_VALUE.
      SET PARAMETER ID 'AN2' FIELD IST_DISPLAY-ANLN2.
      SET PARAMETER ID 'BUK' FIELD P_BUKRS.

      CALL TRANSACTION 'AW01' AND SKIP FIRST SCREEN.

    WHEN 'EXEC'.
*BOC By SAP_ABAP on 27/08/26
* S/4 conversion. Transaction ABAA is no longer a posting
* transaction - SE93 assigns it to dispatcher report RADISPATCH_AB01,
* which forwards with LEAVE TO TRANSACTION. That is illegal inside
* batch input, so the session built below died at step 1 with message
* 00 352 and could never post. Replaced by BAPI_ASSET_VALUE_ADJUST_CHECK / _POST,
* through the posting layer in MZAAIMPF01.
*
* Each row is validated with the _CHECK twin before it is posted, so a
* row that cannot post is reported instead of failing silently. Every
* message is kept per asset and shown at the end of the run - that is
* what the SM35 log used to provide.
*
* Old code:
*      PERFORM OPEN_GROUP.
*      LOOP AT IST_DISPLAY WHERE IMPRATIO <> 0.
*        L_TABIX = SY-TABIX.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0100'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANBZ-BWASL'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BUKRS'
*                                       P_BUKRS.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN1'
*                                      IST_DISPLAY-ANLN1.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN2'
*                                      IST_DISPLAY-ANLN2.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = SY-DATUM
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BLDAT'
*                                      G_DATE.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = P_BUDAT
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BUDAT'
*                                      G_DATE.
*        PERFORM BDC_FIELD       USING 'ANBZ-PERID'
*                                      P_MONAT.
*        PERFORM BDC_FIELD       USING 'ANBZ-BWASL'
*                                      IST_DISPLAY-TTYPE.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0110'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANEK-SGTXT'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '=UPDA'.
*        G_DMBTR = IST_DISPLAY-IMPRATIO.
*        PERFORM BDC_FIELD       USING 'ANBZ-DMBTR'
*                                   G_DMBTR.
*        PERFORM BDC_FIELD       USING 'ANBZ-BZDAT'
*                                      IST_DISPLAY-BZDAT.
*        PERFORM BDC_FIELD       USING 'ANEK-SGTXT'
*                                      P_GJAHR.
*        PERFORM BDC_TRANSACTION USING 'ABAA'.
*        IF SY-SUBRC = 0.
*          DELETE IST_DISPLAY INDEX L_TABIX.
*        ENDIF.
*      ENDLOOP.
*      PERFORM CLOSE_GROUP.
* New code:
      REFRESH: IT_ZAALOG, IT_ZAARET.
      CLEAR:   G_ZOKCNT, G_ZERRCNT.
      LOOP AT IST_DISPLAY WHERE IMPRATIO <> 0.
        L_TABIX = SY-TABIX.
* Validate first. The _CHECK call posts nothing.
        PERFORM ZAA_VALUE_ADJUST TABLES   IT_ZAARET
                                 USING    IST_DISPLAY-ANLN1
                                          IST_DISPLAY-ANLN2
                                          IST_DISPLAY-TTYPE
                                          IST_DISPLAY-IMPRATIO
                                          IST_DISPLAY-BZDAT
                                          P_GJAHR
                                          'X'
                                 CHANGING L_ZSUBRC.
        IF L_ZSUBRC = 0.
          PERFORM ZAA_VALUE_ADJUST TABLES   IT_ZAARET
                                   USING    IST_DISPLAY-ANLN1
                                            IST_DISPLAY-ANLN2
                                            IST_DISPLAY-TTYPE
                                            IST_DISPLAY-IMPRATIO
                                            IST_DISPLAY-BZDAT
                                            P_GJAHR
                                            ' '
                                   CHANGING L_ZSUBRC.
          IF L_ZSUBRC = 0.
            PERFORM ZAA_BAPI_COMMIT.
            G_ZOKCNT = G_ZOKCNT + 1.
            DELETE IST_DISPLAY INDEX L_TABIX.
          ELSE.
            PERFORM ZAA_BAPI_ROLLBACK.
            G_ZERRCNT = G_ZERRCNT + 1.
          ENDIF.
        ELSE.
          G_ZERRCNT = G_ZERRCNT + 1.
        ENDIF.
        PERFORM ZAA_KEEP_LOG.
      ENDLOOP.
* Report what posted and what did not. Nothing else tells the user -
* the SM35 log used to be the record of the run.
      PERFORM ZAA_SHOW_LOG.
*EOC By SAP_ABAP on 27/08/26
    WHEN 'DOWN'.
*Begin of <RD1K960036>

*      CALL FUNCTION 'DOWNLOAD'
*           EXPORTING
*                FILENAME = ' '
*                FILETYPE = 'DAT'
*           TABLES
*                DATA_TAB = IST_DISPLAY.

clear l_filename.
l_filename = SPACE.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
  EXPORTING
    DEFAULT_FILE_NAME    = l_filename
  CHANGING
    FILENAME             = l_filen
    PATH                 = l_path
    FULLPATH             = l_fullpath
    USER_ACTION          = l_usr_act
  EXCEPTIONS
    CNTL_ERROR           = 1
    ERROR_NO_GUI         = 2
    NOT_SUPPORTED_BY_GUI = 3
    others               = 4.

    IF sy-subrc = 0
       AND l_usr_act NE
       CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    FILENAME                        = l_fullpath
   FILETYPE                         = g_c_dat
  TABLES
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    DATA_TAB                        = IST_DISPLAY
    DATA_TAB                        = IST_DISPLAY     "#EC CI_FLDEXT_OK[2610650]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
 EXCEPTIONS
   FILE_WRITE_ERROR                = 1
   NO_BATCH                        = 2
   GUI_REFUSE_FILETRANSFER         = 3
   INVALID_TYPE                    = 4
   NO_AUTHORITY                    = 5
   UNKNOWN_ERROR                   = 6
   HEADER_NOT_ALLOWED              = 7
   SEPARATOR_NOT_ALLOWED           = 8
   FILESIZE_NOT_ALLOWED            = 9
   HEADER_TOO_LONG                 = 10
   DP_ERROR_CREATE                 = 11
   DP_ERROR_SEND                   = 12
   DP_ERROR_WRITE                  = 13
   UNKNOWN_DP_ERROR                = 14
   ACCESS_DENIED                   = 15
   DP_OUT_OF_MEMORY                = 16
   DISK_FULL                       = 17
   DP_TIMEOUT                      = 18
   FILE_NOT_FOUND                  = 19
   DATAPROVIDER_EXCEPTION          = 20
   CONTROL_FLUSH_ERROR             = 21
   OTHERS                          = 22 .

  IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

   Endif.
*      IF SY-SUBRC <> 0.
*      ENDIF.
*End of <RD1K960036>

    WHEN 'BACK'.
      G_TEXT = 'Do You Want to quit the screen'.
      PERFORM POPUP_MESSAGE USING G_TEXT.
*Begin of <RD1K960036>
*      IF G_ANSWER = 'J'.
      IF G_ANSWER = g_c_one.
*End of <RD1K960036>
        SET SCREEN 0.
        LEAVE SCREEN.
      ELSE.
        SET SCREEN '0500'.
      ENDIF.
  ENDCASE.
  CLEAR OKCODE.


ENDMODULE.                 " USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_selected_lines3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_SELECTED_LINES3 INPUT.
  MODIFY IST_DISPLAY FROM IST_DISPLAY INDEX TBC_500-CURRENT_LINE.
  CLEAR G_COUNT.
  IF IST_DISPLAY-IMPRATIO > IST_DISPLAY-NBV.
    MESSAGE E052(ZAA).
  ENDIF.
*  if ist_display-ttype = 'X20' or
*  ist_display-ttype =  'X30' or
*  ist_display-ttype =  '641' or
*  ist_display-ttype =  '651'.
*  else.
*    message e055(ZAA).
*  endif.

ENDMODULE.                 " move_selected_lines3  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATA2 INPUT.
  IF OKCODE = 'ENTE'.
    CLEAR P_SAFAP.
    CLEAR IST_DISPLAY.
    LOOP AT IST_DISPLAY.
      P_SAFAP = P_SAFAP + IST_DISPLAY-IMPRATIO.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " check_data2  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT500 INPUT.
  CASE OKCODE.
    WHEN 'CANC' OR 'EXIT' OR 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " exit500  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATA3 INPUT.
  IF OKCODE = 'ENTE'.
    CLEAR P_SAFAP.
    CLEAR IST_DISPLAY.
    LOOP AT IST_DISPLAY.
      P_SAFAP = P_SAFAP + IST_DISPLAY-IMPRATIO.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " check_data3  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0600 INPUT.
  DATA : L_BZDAT LIKE SY-DATUM.
  CASE OKCODE.
    WHEN 'DISP'.
      GET CURSOR FIELD L_FIELD VALUE L_VALUE.
      SET PARAMETER ID 'AN1' FIELD L_VALUE.
      READ TABLE IST_DISPLAY WITH KEY ANLN1 = L_VALUE.
      SET PARAMETER ID 'AN2' FIELD IST_DISPLAY-ANLN2.
      SET PARAMETER ID 'BUK' FIELD P_BUKRS.

      CALL TRANSACTION 'AW01' AND SKIP FIRST SCREEN.
    WHEN 'EXEC'.
*BOC By SAP_ABAP on 27/08/26
* S/4 conversion. Transaction ABZU is no longer a posting
* transaction - SE93 assigns it to dispatcher report RADISPATCH_AB01,
* which forwards with LEAVE TO TRANSACTION. That is illegal inside
* batch input, so the session built below died at step 1 with message
* 00 352 and could never post. Replaced by BAPI_ASSET_WRITEUP_CHECK / _POST,
* through the posting layer in MZAAIMPF01.
*
* Each row is validated with the _CHECK twin before it is posted, so a
* row that cannot post is reported instead of failing silently. Every
* message is kept per asset and shown at the end of the run - that is
* what the SM35 log used to provide.
*
* Old code:
*      PERFORM OPEN_GROUP.
*      LOOP AT IST_DISPLAY WHERE IMPRATIO <> 0.
*        L_TABIX = SY-TABIX.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0100'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANBZ-BWASL'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BUKRS'
*                                       P_BUKRS.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN1'
*                                      IST_DISPLAY-ANLN1.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN2'
*                                      IST_DISPLAY-ANLN2.
*
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = SY-DATUM
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BLDAT'
*                                      G_DATE.
*
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = P_BUDAT
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BUDAT'
*                                      G_DATE.
*        PERFORM BDC_FIELD       USING 'ANBZ-PERID'
*                                      P_MONAT.
*        PERFORM BDC_FIELD       USING 'ANBZ-BWASL'
*                                      IST_DISPLAY-TTYPE.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0140'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANEK-SGTXT'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '=UPDA'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BZDAT'
*                                      IST_DISPLAY-BZDAT.
*        G_DMBTR = IST_DISPLAY-IMPRATIO.
*        PERFORM BDC_FIELD       USING 'ANBZ-SAFAV'
*                                      G_DMBTR.
*        PERFORM BDC_FIELD       USING 'ANEK-SGTXT'
*                                       P_GJAHR.
*        PERFORM BDC_TRANSACTION USING 'ABZU'.
*
**        IF SY-SUBRC = 0.
**          DELETE IST_DISPLAY INDEX L_TABIX.
**        ENDIF.
*      ENDLOOP.
**      PERFORM CLOSE_GROUP.
**      PERFORM OPEN_GROUP.
*
**      LOOP AT IST_DISPLAY WHERE IMPRATIO <> 0.
**        L_TABIX = SY-TABIX.
**        PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0100'.
**        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
**                                      'BKPF-MONAT'.
**        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
**                                      '/00'.
**        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
**             EXPORTING
**                  DATE_INTERNAL = SY-DATUM
**             IMPORTING
**                  DATE_EXTERNAL = G_DATE.
**
**
**        PERFORM BDC_FIELD       USING 'BKPF-BLDAT'
**                                      G_DATE.
**        PERFORM BDC_FIELD       USING 'BKPF-BLART'
**                                    'AA'.
**
**        PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
**                                      P_BUKRS.
**        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
**             EXPORTING
**                  DATE_INTERNAL = P_BUDAT
**             IMPORTING
**                  DATE_EXTERNAL = G_DATE.
**
**        PERFORM BDC_FIELD       USING 'BKPF-BUDAT'
**                                      G_DATE.
**        PERFORM BDC_FIELD       USING 'BKPF-MONAT'
**                                      P_MONAT.
**        PERFORM BDC_FIELD       USING 'BKPF-WAERS'
**                                      'INR'.
**        PERFORM BDC_FIELD       USING 'BKPF-XBLNR'
**                                      'IMPR WRITE BACK'.
***        PERFORM BDC_FIELD       USING 'FS006-DOCID'
***                                      RECORD-DOCID_008.
**        PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
**                                      '40'.
**        IF IST_DISPLAY-ANLKL = '70101'.
**          PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
**                                        '70131'.
**        ELSEIF IST_DISPLAY-ANLKL = '70102'.
**          PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
**                                        '70132'.
**        ELSEIF IST_DISPLAY-ANLKL = '70103'.
**          PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
**                                        '70133'.
**        ELSEIF IST_DISPLAY-ANLKL = '70104'.
**          PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
**                                        '70134'.
**        ENDIF.
**        PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0300'.
**        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
**                                      'BSEG-SGTXT'.
**        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
**                                      '=ZK'.
**        G_DMBTR = IST_DISPLAY-IMPRATIO.
**
**        PERFORM BDC_FIELD       USING 'BSEG-WRBTR'
**                                      G_DMBTR.
**        PERFORM BDC_FIELD       USING 'BSEG-SGTXT'
**                                      'IMPR WRITE BACK'.
**        PERFORM BDC_DYNPRO      USING 'SAPLKACB' '0002'.
**        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
**                                      'COBL-PRCTR'.
**        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
**                                      '=ENTE'.
**        PERFORM BDC_FIELD       USING 'COBL-GSBER'
**                                      IST_DISPLAY-GSBER.
**        PERFORM BDC_FIELD       USING 'COBL-PRCTR'
**                                      IST_DISPLAY-PRCTR.
***        PERFORM BDC_FIELD       USING 'COBL-FIPOS'
***                                      RECORD-FIPOS_015.
**        PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0330'.
**        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
**                                      'RF05A-NEWKO'.
**        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
**                                      '/00'.
**        PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
**                                      '50'.
**        PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
**                                      '209123'.
**        PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0300'.
**        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
**                                      'BSEG-SGTXT'.
**        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
**                                      '=ZK'.
**        G_DMBTR = IST_DISPLAY-IMPRATIO.
**
**        PERFORM BDC_FIELD       USING 'BSEG-WRBTR'
**                                      G_DMBTR.
**        PERFORM BDC_FIELD       USING 'BSEG-SGTXT'
**                                      'IMPR WRITE BACK'.
**        PERFORM BDC_DYNPRO      USING 'SAPLKACB' '0002'.
**        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
**                                      'COBL-KOSTL'.
**        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
**                                      '=ENTE'.
**        PERFORM BDC_FIELD       USING 'COBL-GSBER'
**                                      IST_DISPLAY-GSBER.
**        PERFORM BDC_FIELD       USING 'COBL-KOSTL'
**                                      IST_DISPLAY-KOSTL.
***        PERFORM BDC_FIELD       USING 'COBL-FIPOS'
***                                      RECORD-FIPOS_022.
**        PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0330'.
**        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
**                                      'BSEG-XREF1'.
**        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
**                                      '=BU'.
**        PERFORM BDC_TRANSACTION USING 'F-02'.
**
**      ENDLOOP.
*      PERFORM CLOSE_GROUP1.
*
* The BDC wrote ANBZ-SAFAV here unconditionally, with transaction
* types X21 / X32, so the amount is special depreciation. PV_DEPKIND
* = 'S' says so explicitly - deriving it from the transaction type
* would have moved it into ordinary depreciation.
* New code:
      REFRESH: IT_ZAALOG, IT_ZAARET.
      CLEAR:   G_ZOKCNT, G_ZERRCNT.
      LOOP AT IST_DISPLAY WHERE IMPRATIO <> 0.
        L_TABIX = SY-TABIX.
* Validate first. The _CHECK call posts nothing.
        PERFORM ZAA_WRITEUP TABLES   IT_ZAARET
                            USING    IST_DISPLAY-ANLN1
                                     IST_DISPLAY-ANLN2
                                     IST_DISPLAY-TTYPE
                                     IST_DISPLAY-IMPRATIO
                                     IST_DISPLAY-BZDAT
                                     P_GJAHR
                                     ' '
                                     'S'
                                     'X'
                            CHANGING L_ZSUBRC.
        IF L_ZSUBRC = 0.
          PERFORM ZAA_WRITEUP TABLES   IT_ZAARET
                              USING    IST_DISPLAY-ANLN1
                                       IST_DISPLAY-ANLN2
                                       IST_DISPLAY-TTYPE
                                       IST_DISPLAY-IMPRATIO
                                       IST_DISPLAY-BZDAT
                                       P_GJAHR
                                       ' '
                                       'S'
                                       ' '
                              CHANGING L_ZSUBRC.
          IF L_ZSUBRC = 0.
            PERFORM ZAA_BAPI_COMMIT.
            G_ZOKCNT = G_ZOKCNT + 1.
*     No DELETE here - it was commented out in the BDC version of
*     this branch (screen 0600), so the row stays in the list after
*     posting. Behaviour preserved, not corrected.
          ELSE.
            PERFORM ZAA_BAPI_ROLLBACK.
            G_ZERRCNT = G_ZERRCNT + 1.
          ENDIF.
        ELSE.
          G_ZERRCNT = G_ZERRCNT + 1.
        ENDIF.
        PERFORM ZAA_KEEP_LOG.
      ENDLOOP.
* Report what posted and what did not. Nothing else tells the user -
* the SM35 log used to be the record of the run.
      PERFORM ZAA_SHOW_LOG.
*EOC By SAP_ABAP on 27/08/26
    WHEN 'DOWN'.
*Begin of <RD1K960036>

*      CALL FUNCTION 'DOWNLOAD'
*           EXPORTING
*                FILENAME = ' '
*                FILETYPE = 'DAT'
*           TABLES
*                DATA_TAB = IST_DISPLAY.

clear l_filename.
l_filename = SPACE.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
  EXPORTING
    DEFAULT_FILE_NAME    = l_filename
  CHANGING
    FILENAME             = l_filen
    PATH                 = l_path
    FULLPATH             = l_fullpath
    USER_ACTION          = l_usr_act
  EXCEPTIONS
    CNTL_ERROR           = 1
    ERROR_NO_GUI         = 2
    NOT_SUPPORTED_BY_GUI = 3
    others               = 4.

    IF sy-subrc = 0
       AND l_usr_act NE
       CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    FILENAME                        = l_fullpath
   FILETYPE                         = g_c_dat
  TABLES
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    DATA_TAB                        = IST_DISPLAY
    DATA_TAB                        = IST_DISPLAY     "#EC CI_FLDEXT_OK[2610650]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
 EXCEPTIONS
   FILE_WRITE_ERROR                = 1
   NO_BATCH                        = 2
   GUI_REFUSE_FILETRANSFER         = 3
   INVALID_TYPE                    = 4
   NO_AUTHORITY                    = 5
   UNKNOWN_ERROR                   = 6
   HEADER_NOT_ALLOWED              = 7
   SEPARATOR_NOT_ALLOWED           = 8
   FILESIZE_NOT_ALLOWED            = 9
   HEADER_TOO_LONG                 = 10
   DP_ERROR_CREATE                 = 11
   DP_ERROR_SEND                   = 12
   DP_ERROR_WRITE                  = 13
   UNKNOWN_DP_ERROR                = 14
   ACCESS_DENIED                   = 15
   DP_OUT_OF_MEMORY                = 16
   DISK_FULL                       = 17
   DP_TIMEOUT                      = 18
   FILE_NOT_FOUND                  = 19
   DATAPROVIDER_EXCEPTION          = 20
   CONTROL_FLUSH_ERROR             = 21
   OTHERS                          = 22 .

   IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

   Endif.

*      IF SY-SUBRC <> 0.
*      ENDIF.

*End of <RD1K960036>


    WHEN 'BACK'.
      G_TEXT = 'Do You Want to quit the screen'.
      PERFORM POPUP_MESSAGE USING G_TEXT.
*Begin of <RD1K960036>
*      IF G_ANSWER = 'J'.
      IF G_ANSWER = g_c_one.
*End of <RD1K960036>
        SET SCREEN 0.
        LEAVE SCREEN.
      ELSE.
        SET SCREEN '0600'.
      ENDIF.
  ENDCASE.
  CLEAR OKCODE.

ENDMODULE.                 " USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT600 INPUT.
  CASE OKCODE.
    WHEN 'CANC' OR 'EXIT' OR 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " exit600  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_selected_lines4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_SELECTED_LINES4 INPUT.
  MODIFY IST_DISPLAY FROM IST_DISPLAY INDEX TBC_600-CURRENT_LINE.
  IF IST_DISPLAY-IMPRATIO > IST_DISPLAY-IMPAMT.
    MESSAGE E054(ZAA).
  ENDIF.


ENDMODULE.                 " move_selected_lines4  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0700 INPUT.
  CASE OKCODE.
    WHEN 'SEL'.
      LOOP AT IST_DISPLAY.
        IST_DISPLAY-SEL = 'X'.
        MODIFY IST_DISPLAY INDEX SY-TABIX.
      ENDLOOP.
      SEL_FLAG = 'X'.
    WHEN 'UNSEL'.
      LOOP AT IST_DISPLAY WHERE SEL = 'X'.
        IST_DISPLAY-SEL = ' '.
        MODIFY IST_DISPLAY INDEX SY-TABIX.
      ENDLOOP.
      LOOP AT IST_DISPLAY.
      ENDLOOP.
      SEL_FLAG = ' '.
    WHEN 'DISP'.
      GET CURSOR FIELD L_FIELD VALUE L_VALUE.
      SET PARAMETER ID 'AN1' FIELD L_VALUE.
      READ TABLE IST_DISPLAY WITH KEY ANLN1 = L_VALUE.
      SET PARAMETER ID 'AN2' FIELD IST_DISPLAY-ANLN2.
      SET PARAMETER ID 'BUK' FIELD P_BUKRS.

      CALL TRANSACTION 'AW01' AND SKIP FIRST SCREEN.

    WHEN 'EXEC'.
*BOC By SAP_ABAP on 27/08/26
* S/4 conversion. Transaction ABZU then ABAA is no longer a posting
* transaction - SE93 assigns it to dispatcher report RADISPATCH_AB01,
* which forwards with LEAVE TO TRANSACTION. That is illegal inside
* batch input, so the session built below died at step 1 with message
* 00 352 and could never post. Replaced by the write-up and value-adjust BAPIs,
* through the posting layer in MZAAIMPF01.
*
* Each row is validated with the _CHECK twin before it is posted, so a
* row that cannot post is reported instead of failing silently. Every
* message is kept per asset and shown at the end of the run - that is
* what the SM35 log used to provide.
*
* Old code:
*      PERFORM OPEN_GROUP.
*      LOOP AT IST_DISPLAY WHERE IMPWBRATIO <> 0.
*        L_TABIX = SY-TABIX.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0100'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANBZ-BWASL'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BUKRS'
*                                      P_BUKRS.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN1'
*                                      IST_DISPLAY-ANLN1.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN2'
*                                      IST_DISPLAY-ANLN2.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = SY-DATUM
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BLDAT'
*                                      G_DATE.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = P_BUDAT
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BUDAT'
*                                      G_DATE.
*        PERFORM BDC_FIELD       USING 'ANBZ-PERID'
*                                      P_MONAT.
*        PERFORM BDC_FIELD       USING 'ANBZ-BWASL'
*                                      IST_DISPLAY-TTYPE.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0140'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANEK-SGTXT'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '=UPDA'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BZDAT'
*                                      IST_DISPLAY-BZDAT.
*        G_DMBTR = IST_DISPLAY-IMPWBRATIO.
*        IF IST_DISPLAY-TTYPE = 'X70'.
*          PERFORM BDC_FIELD       USING 'ANBZ-SAFAV'
*                                        G_DMBTR.
*        ELSE.
*          PERFORM BDC_FIELD       USING 'ANBZ-NAFAV'
*                                        G_DMBTR.
*        ENDIF.
*        PERFORM BDC_FIELD       USING 'ANEK-SGTXT'
*                                      P_GJAHR.
*        PERFORM BDC_FIELD       USING 'RA01B-BLART'
*                                      'AA'.
*        PERFORM BDC_TRANSACTION USING 'ABZU'.
**        IF SY-SUBRC = 0.
***          DELETE IST_DISPLAY INDEX L_TABIX.
**        ENDIF.
*      ENDLOOP.
*      PERFORM CLOSE_GROUP.
*      PERFORM OPEN_GROUP1.
*      LOOP AT IST_DISPLAY WHERE DEPDIFF <> 0.
*        L_TABIX = SY-TABIX.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0100'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANBZ-BWASL'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM BDC_FIELD       USING 'ANBZ-BUKRS'
*                                       P_BUKRS.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN1'
*                                      IST_DISPLAY-ANLN1.
*        PERFORM BDC_FIELD       USING 'ANBZ-ANLN2'
*                                      IST_DISPLAY-ANLN2.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = SY-DATUM
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BLDAT'
*                                      G_DATE.
*        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*             EXPORTING
*                  DATE_INTERNAL = P_BUDAT
*             IMPORTING
*                  DATE_EXTERNAL = G_DATE.
*
*        PERFORM BDC_FIELD       USING 'ANEK-BUDAT'
*                                      G_DATE.
*        PERFORM BDC_FIELD       USING 'ANBZ-PERID'
*                                      P_MONAT.
*        PERFORM BDC_FIELD       USING 'ANBZ-BWASL'
*                                      '641'.
*        PERFORM BDC_DYNPRO      USING 'SAPMA01B' '0110'.
*        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                      'ANEK-SGTXT'.
*        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                      '=UPDA'.
*        G_DMBTR = IST_DISPLAY-DEPDIFF.
*        PERFORM BDC_FIELD       USING 'ANBZ-DMBTR'
*                                   G_DMBTR.
*        PERFORM BDC_FIELD       USING 'ANBZ-BZDAT'
*                                      IST_DISPLAY-BZDAT.
*        PERFORM BDC_FIELD       USING 'ANEK-SGTXT'
*                     'DEP.ON IMPAIRMENT WRITTEN BACK'.
*        PERFORM BDC_TRANSACTION USING 'ABAA'.
*        IF SY-SUBRC = 0.
*          DELETE IST_DISPLAY INDEX L_TABIX.
*        ENDIF.
*      ENDLOOP.
*      PERFORM CLOSE_GROUP1.
*
* This branch posts twice per run: a write-up pass over the rows
* with IMPWBRATIO, then an unplanned depreciation pass over the
* rows with DEPDIFF. The BDC version built two separate sessions
* for them, so they were never atomic; the two passes stay
* independent here for the same reason.
* New code:
      REFRESH: IT_ZAALOG, IT_ZAARET.
      CLEAR:   G_ZOKCNT, G_ZERRCNT.
      LOOP AT IST_DISPLAY WHERE IMPWBRATIO <> 0.
        L_TABIX = SY-TABIX.
* Validate first. The _CHECK call posts nothing.
        PERFORM ZAA_WRITEUP TABLES   IT_ZAARET
                            USING    IST_DISPLAY-ANLN1
                                     IST_DISPLAY-ANLN2
                                     IST_DISPLAY-TTYPE
                                     IST_DISPLAY-IMPWBRATIO
                                     IST_DISPLAY-BZDAT
                                     P_GJAHR
                                     'AA'
                                     ' '
                                     'X'
                            CHANGING L_ZSUBRC.
        IF L_ZSUBRC = 0.
          PERFORM ZAA_WRITEUP TABLES   IT_ZAARET
                              USING    IST_DISPLAY-ANLN1
                                       IST_DISPLAY-ANLN2
                                       IST_DISPLAY-TTYPE
                                       IST_DISPLAY-IMPWBRATIO
                                       IST_DISPLAY-BZDAT
                                       P_GJAHR
                                       'AA'
                                       ' '
                                       ' '
                              CHANGING L_ZSUBRC.
          IF L_ZSUBRC = 0.
            PERFORM ZAA_BAPI_COMMIT.
            G_ZOKCNT = G_ZOKCNT + 1.
*     No DELETE here - it was commented out in the BDC version of
*     this branch (screen 0700, first pass), so the row stays in the list after
*     posting. Behaviour preserved, not corrected.
          ELSE.
            PERFORM ZAA_BAPI_ROLLBACK.
            G_ZERRCNT = G_ZERRCNT + 1.
          ENDIF.
        ELSE.
          G_ZERRCNT = G_ZERRCNT + 1.
        ENDIF.
        PERFORM ZAA_KEEP_LOG.
      ENDLOOP.
      LOOP AT IST_DISPLAY WHERE DEPDIFF <> 0.
        L_TABIX = SY-TABIX.
* Validate first. The _CHECK call posts nothing.
        PERFORM ZAA_VALUE_ADJUST TABLES   IT_ZAARET
                                 USING    IST_DISPLAY-ANLN1
                                          IST_DISPLAY-ANLN2
                                          IST_DISPLAY-TTYPE
                                          IST_DISPLAY-DEPDIFF
                                          IST_DISPLAY-BZDAT
                                          'DEP.ON IMPAIRMENT WRITTEN BACK'
                                          'X'
                                 CHANGING L_ZSUBRC.
        IF L_ZSUBRC = 0.
          PERFORM ZAA_VALUE_ADJUST TABLES   IT_ZAARET
                                   USING    IST_DISPLAY-ANLN1
                                            IST_DISPLAY-ANLN2
                                            IST_DISPLAY-TTYPE
                                            IST_DISPLAY-DEPDIFF
                                            IST_DISPLAY-BZDAT
                                            'DEP.ON IMPAIRMENT WRITTEN BACK'
                                            ' '
                                   CHANGING L_ZSUBRC.
          IF L_ZSUBRC = 0.
            PERFORM ZAA_BAPI_COMMIT.
            G_ZOKCNT = G_ZOKCNT + 1.
            DELETE IST_DISPLAY INDEX L_TABIX.
          ELSE.
            PERFORM ZAA_BAPI_ROLLBACK.
            G_ZERRCNT = G_ZERRCNT + 1.
          ENDIF.
        ELSE.
          G_ZERRCNT = G_ZERRCNT + 1.
        ENDIF.
        PERFORM ZAA_KEEP_LOG.
      ENDLOOP.
* Report what posted and what did not. Nothing else tells the user -
* the SM35 log used to be the record of the run.
      PERFORM ZAA_SHOW_LOG.
*EOC By SAP_ABAP on 27/08/26
    WHEN 'DOWN'.

*Begin of <RD1K960036>

*      CALL FUNCTION 'DOWNLOAD'
*           EXPORTING
*                FILENAME = ' '
*                FILETYPE = 'DAT'
*           TABLES
*                DATA_TAB = IST_DISPLAY.

clear l_filename.
l_filename = SPACE.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
  EXPORTING
    DEFAULT_FILE_NAME    = l_filename
  CHANGING
    FILENAME             = l_filen
    PATH                 = l_path
    FULLPATH             = l_fullpath
    USER_ACTION          = l_usr_act
  EXCEPTIONS
    CNTL_ERROR           = 1
    ERROR_NO_GUI         = 2
    NOT_SUPPORTED_BY_GUI = 3
    others               = 4.

    IF sy-subrc = 0
       AND l_usr_act NE
       CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    FILENAME                        = l_fullpath
   FILETYPE                         = g_c_dat
  TABLES
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    DATA_TAB                        = IST_DISPLAY
    DATA_TAB                        = IST_DISPLAY     "#EC CI_FLDEXT_OK[2610650]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
 EXCEPTIONS
   FILE_WRITE_ERROR                = 1
   NO_BATCH                        = 2
   GUI_REFUSE_FILETRANSFER         = 3
   INVALID_TYPE                    = 4
   NO_AUTHORITY                    = 5
   UNKNOWN_ERROR                   = 6
   HEADER_NOT_ALLOWED              = 7
   SEPARATOR_NOT_ALLOWED           = 8
   FILESIZE_NOT_ALLOWED            = 9
   HEADER_TOO_LONG                 = 10
   DP_ERROR_CREATE                 = 11
   DP_ERROR_SEND                   = 12
   DP_ERROR_WRITE                  = 13
   UNKNOWN_DP_ERROR                = 14
   ACCESS_DENIED                   = 15
   DP_OUT_OF_MEMORY                = 16
   DISK_FULL                       = 17
   DP_TIMEOUT                      = 18
   FILE_NOT_FOUND                  = 19
   DATAPROVIDER_EXCEPTION          = 20
   CONTROL_FLUSH_ERROR             = 21
   OTHERS                          = 22 .

   IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

   Endif.

*      IF SY-SUBRC <> 0.
*      ENDIF.

*End of <RD1K960036>

    WHEN 'BACK'.
      G_TEXT = 'Do You Want to quit the screen'.
      PERFORM POPUP_MESSAGE USING G_TEXT.
*Begin of <RD1K960036>
*      IF G_ANSWER = 'J'.
      IF G_ANSWER = g_c_one.
*End of <RD1K960036>
        SET SCREEN 0.
        LEAVE SCREEN.
      ELSE.
        SET SCREEN '0700'.
      ENDIF.
      CLEAR OKCODE.
  ENDCASE.
  CLEAR OKCODE.
ENDMODULE.                 " USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_selected_lines5  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_selected_lines5 INPUT.
  MODIFY IST_DISPLAY FROM IST_DISPLAY INDEX TBC_700-CURRENT_LINE.
  IF IST_DISPLAY-IMPWBRATIO > IST_DISPLAY-IMPAMT.
    MESSAGE E054(ZAA).
  ENDIF.
  IF IST_DISPLAY-TTYPE = 'X70' OR IST_DISPLAY-TTYPE =  '700' .
  ELSE.
    MESSAGE E056(ZAA).
  ENDIF.
ENDMODULE.                 " move_selected_lines5  INPUT

*BOC By SAP_ABAP on 27/08/26
*&---------------------------------------------------------------------*
*&  Run log for the BAPI posting that replaced the batch input
*&---------------------------------------------------------------------*
*  These live here rather than in MZAAIMPTOP / MZAAIMPF01 so the change
*  stays inside the include that actually needed changing. Global data
*  declared at top level of any include is program-wide, so position does
*  not matter to the compiler.
*&---------------------------------------------------------------------*
DATA: IT_ZAARET LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF IT_ZAALOG OCCURS 0,
        ANLN1   LIKE ANLC-ANLN1,
        ANLN2   LIKE ANLC-ANLN2,
        TYPE    LIKE BAPIRET2-TYPE,
        MESSAGE LIKE BAPIRET2-MESSAGE,
      END OF IT_ZAALOG.

DATA: G_ZOKCNT  TYPE I,
      G_ZERRCNT TYPE I,
      L_ZSUBRC  LIKE SY-SUBRC.

*&---------------------------------------------------------------------*
*&      Form  ZAA_KEEP_LOG
*&---------------------------------------------------------------------*
*       Keeps the messages the BAPI returned for the IST_DISPLAY row
*       currently in the header line, so the run log can name the asset
*       each message belongs to.
*----------------------------------------------------------------------*
FORM ZAA_KEEP_LOG.

  LOOP AT IT_ZAARET.
    CLEAR IT_ZAALOG.
    IT_ZAALOG-ANLN1   = IST_DISPLAY-ANLN1.
    IT_ZAALOG-ANLN2   = IST_DISPLAY-ANLN2.
    IT_ZAALOG-TYPE    = IT_ZAARET-TYPE.
    IT_ZAALOG-MESSAGE = IT_ZAARET-MESSAGE.
    APPEND IT_ZAALOG.
  ENDLOOP.

ENDFORM.                    " ZAA_KEEP_LOG

*&---------------------------------------------------------------------*
*&      Form  ZAA_SHOW_LOG
*&---------------------------------------------------------------------*
*       Shows what posted and what did not. Without this the user gets no
*       feedback at all - the SM35 session log used to be the record of
*       the run, and it no longer exists.
*
*       Returns to the screen it was called from, so the user is left
*       where they were.
*----------------------------------------------------------------------*
FORM ZAA_SHOW_LOG.

  DATA: L_DYNNR LIKE SY-DYNNR.

  L_DYNNR = SY-DYNNR.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN L_DYNNR.

  WRITE: / 'Result of posting'.
  ULINE.
  WRITE: / 'Assets posted', 25 G_ZOKCNT.
  WRITE: / 'Assets in error', 25 G_ZERRCNT.
  SKIP.

  IF IT_ZAALOG[] IS INITIAL.
    WRITE: / 'No messages were returned.'.
  ELSE.
    WRITE: /  'Asset',
           14 'Sub number',
           27 'Type',
           33 'Message'.
    ULINE.
    LOOP AT IT_ZAALOG.
      WRITE: /  IT_ZAALOG-ANLN1,
             14 IT_ZAALOG-ANLN2,
             27 IT_ZAALOG-TYPE,
             33 IT_ZAALOG-MESSAGE.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " ZAA_SHOW_LOG
*EOC By SAP_ABAP on 27/08/26
