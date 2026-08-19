*--- MAIN PROGRAM: SAPMZMM_POPRF01 ---*
*----------------------------------------------------------------------*
***INCLUDE SAPMZMM_POPRF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_DISPLAY_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPUP_TO_DISPLAY_TEXT .
 CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel        = 'Important Information'
      textline1    = 'Please use this  for dynamic selection'
*      textline2    = 'else the output may be slow'
      start_column = 25
      start_row    = 6.
ENDFORM.                    " POPUP_TO_DISPLAY_TEXT
