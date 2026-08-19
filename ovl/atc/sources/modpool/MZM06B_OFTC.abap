*--- MAIN PROGRAM: MZM06B_OFTC ---*
*-------------------------------------------------------------------
***INCLUDE MM06BFTC .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  TC_MODIFY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TC_MODIFY.

   READ TABLE TCTAB WITH KEY SY-DYNNR.
   IF SY-SUBRC EQ 0.
      TCNAME(3) = 'TC_'.
      TCNAME+3(4) = SY-DYNNR.
      TCNAME+7(5) = '-COLS'.
      ASSIGN (TCNAME) TO <COLTAB>.
      LOOP AT <COLTAB> INTO HTC-COLS.
         READ TABLE TCINVISIBLE WITH KEY NAME = HTC-COLS-SCREEN-NAME.
         IF SY-SUBRC EQ 0.
            HTC-COLS-INVISIBLE = 'X'.
         ELSE.
            CLEAR HTC-COLS-INVISIBLE.
         ENDIF.
         MODIFY <COLTAB> FROM HTC-COLS.
      ENDLOOP.
   ENDIF.

ENDFORM.                    " TC_MODIFY
