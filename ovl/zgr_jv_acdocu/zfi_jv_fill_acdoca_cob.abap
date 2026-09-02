*&---------------------------------------------------------------------*
*& Report  ZFI_JV_FILL_ACDOCA_COB
*&---------------------------------------------------------------------*
*& Title   : Fill ACDOCA coding block JV field from standard VNAME
*& Author  : Arnav
*& Created : 02.09.2026
*&
*& Purpose : TEST TOOL. Reads ACDOCA for one ledger / company code /
*&           fiscal year / period, and where the standard Joint Venture
*&           field VNAME is filled, copies it into the key user coding
*&           block extension field ZZ1_JV_NAME_COB. Used to prove whether
*&           the business scenario "Accounting: Coding Block to
*&           Consolidation Journal Entry" then carries the value into
*&           ACDOCU-ZZ1_JV_NAME_CJE on Release Universal Journal.
*&
*& WARNING : This updates ACDOCA directly. ACDOCA is owned by the
*&           accounting document framework and is not meant to be
*&           updated outside it. The entry view (BSEG) is NOT touched,
*&           so after an update run the two are inconsistent for this
*&           field. Run in DEV only, on test data only. Never schedule.
*&           Default is test mode - the update needs an explicit
*&           deselection plus a confirmation popup.
*&
*& ASSUMPTION: ACDOCA carries the coding block extension field
*&             ZZ1_JV_NAME_COB with the same type/length as VNAME
*&             (CHAR 6). If the generated name differs, adjust the
*&             TYPES block, the SELECT list and the UPDATE together -
*&             the field list and target type match by POSITION.
*&---------------------------------------------------------------------*
REPORT zfi_jv_fill_acdoca_cob.

TYPES: BEGIN OF ty_acdoca,
         rldnr           TYPE acdoca-rldnr,
         rbukrs          TYPE acdoca-rbukrs,
         gjahr           TYPE acdoca-gjahr,
         belnr           TYPE acdoca-belnr,
         docln           TYPE acdoca-docln,
         poper           TYPE acdoca-poper,
         vname           TYPE acdoca-vname,
         zz1_jv_name_cob TYPE acdoca-zz1_jv_name_cob,
       END OF ty_acdoca.

DATA: gt_acdoca TYPE STANDARD TABLE OF ty_acdoca,
      gs_acdoca TYPE ty_acdoca,
      gv_upd    TYPE i,
      gv_skip   TYPE i,
      gv_err    TYPE i,
      gv_answer TYPE c LENGTH 1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS: p_rldnr TYPE acdoca-rldnr  OBLIGATORY DEFAULT '0L',
            p_bukrs TYPE acdoca-rbukrs OBLIGATORY,
            p_gjahr TYPE acdoca-gjahr  OBLIGATORY DEFAULT '2025',
            p_poper TYPE acdoca-poper  OBLIGATORY DEFAULT '005'.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_max  TYPE i DEFAULT 100,
            p_test AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF p_max <= 0.
    MESSAGE 'Enter a maximum number of rows greater than zero' TYPE 'E'.
  ENDIF.
  IF p_test IS INITIAL.
    MESSAGE 'Update mode: ACDOCA will be changed. DEV test data only' TYPE 'W'.
  ENDIF.

*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM read_acdoca.

  IF gt_acdoca IS INITIAL.
    MESSAGE 'No ACDOCA rows with a Joint Venture found for that selection' TYPE 'S'.
    RETURN.
  ENDIF.

  IF p_test IS INITIAL.
    PERFORM confirm_update CHANGING gv_answer.
    IF gv_answer <> '1'.
      MESSAGE 'Update cancelled - nothing was changed' TYPE 'S'.
      p_test = 'X'.
    ENDIF.
  ENDIF.

  PERFORM process_rows.
  PERFORM write_summary.

*&---------------------------------------------------------------------*
*&      Form  READ_ACDOCA
*&---------------------------------------------------------------------*
FORM read_acdoca.

  SELECT rldnr, rbukrs, gjahr, belnr, docln, poper, vname, zz1_jv_name_cob
    FROM acdoca
    WHERE rldnr  = @p_rldnr
      AND rbukrs = @p_bukrs
      AND gjahr  = @p_gjahr
      AND poper  = @p_poper
      AND vname <> @space
    ORDER BY belnr, docln
    INTO TABLE @gt_acdoca
    UP TO @p_max ROWS.

  IF sy-subrc <> 0.
    CLEAR gt_acdoca.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CONFIRM_UPDATE
*&---------------------------------------------------------------------*
FORM confirm_update CHANGING cv_answer TYPE c.

  DATA lv_question TYPE c LENGTH 200.

  CLEAR cv_answer.

  CONCATENATE 'This will UPDATE ACDOCA for company code' p_bukrs
              'period' p_poper '/' p_gjahr '. Continue?'
         INTO lv_question SEPARATED BY space.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Update ACDOCA'
      text_question         = lv_question
      text_button_1         = 'Update'
      text_button_2         = 'Cancel'
      default_button        = '2'
      display_cancel_button = ' '
    IMPORTING
      answer                = cv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    CLEAR cv_answer.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PROCESS_ROWS
*&---------------------------------------------------------------------*
FORM process_rows.

  DATA lv_status TYPE c LENGTH 10.

  PERFORM write_header.

  LOOP AT gt_acdoca INTO gs_acdoca.

    IF gs_acdoca-zz1_jv_name_cob = gs_acdoca-vname.
      gv_skip = gv_skip + 1.
      lv_status = 'same'.

    ELSEIF p_test = 'X'.
      lv_status = 'would set'.

    ELSE.
      UPDATE acdoca
         SET zz1_jv_name_cob = @gs_acdoca-vname
       WHERE rldnr  = @gs_acdoca-rldnr
         AND rbukrs = @gs_acdoca-rbukrs
         AND gjahr  = @gs_acdoca-gjahr
         AND belnr  = @gs_acdoca-belnr
         AND docln  = @gs_acdoca-docln.

      IF sy-subrc = 0.
        gv_upd = gv_upd + 1.
        lv_status = 'updated'.
      ELSE.
        gv_err = gv_err + 1.
        lv_status = 'FAILED'.
      ENDIF.
    ENDIF.

    WRITE: /  gs_acdoca-belnr,
           12 gs_acdoca-docln,
           25 gs_acdoca-poper,
           32 gs_acdoca-vname,
           42 gs_acdoca-zz1_jv_name_cob,
           52 lv_status.

  ENDLOOP.

  IF p_test IS INITIAL AND gv_upd > 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  WRITE_HEADER
*&---------------------------------------------------------------------*
FORM write_header.

  IF p_test = 'X'.
    WRITE: / 'Mode: TEST - no database change'.
  ELSE.
    WRITE: / 'Mode: UPDATE - ACDOCA is being changed'.
  ENDIF.

  SKIP.
  WRITE: /  'Document',
         12 'Item',
         25 'Period',
         32 'VNAME',
         42 'COB field',
         52 'Status'.
  ULINE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  WRITE_SUMMARY
*&---------------------------------------------------------------------*
FORM write_summary.

  DATA lv_read TYPE i.

  lv_read = lines( gt_acdoca ).

  SKIP.
  ULINE.
  WRITE: / 'Rows read with a Joint Venture :', lv_read.
  WRITE: / 'Already carrying the same value:', gv_skip.

  IF p_test = 'X'.
    lv_read = lv_read - gv_skip.
    WRITE: / 'Would be updated               :', lv_read.
    SKIP.
    WRITE: / 'Test mode - deselect the test flag to write the values'.
  ELSE.
    WRITE: / 'Updated                        :', gv_upd.
    WRITE: / 'Failed                         :', gv_err.
  ENDIF.

  IF gv_err > 0.
    MESSAGE 'Some rows could not be updated - see the FAILED lines' TYPE 'S'
            DISPLAY LIKE 'W'.
  ENDIF.

ENDFORM.
