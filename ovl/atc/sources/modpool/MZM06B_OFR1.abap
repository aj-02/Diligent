*--- MAIN PROGRAM: MZM06B_OFR1 ---*
*----------------------------------------------------------------------*
***INCLUDE MM06BFR1 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  RM06B-BNFPO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM RM06B-BNFPO.

  READ TABLE TCTAB WITH KEY DYNNR = SY-DYNNR.
  CHECK SY-SUBRC EQ 0.
  CASE SY-DYNNR.
    WHEN '0106'.
      READ TABLE BSN WITH KEY BNFPO = RM06B-BNFPO
        TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
        TC_0106-TOP_LINE = SY-TABIX.
      ELSE.
        TC_0106-TOP_LINE = 1.
      ENDIF.
    WHEN '0111'.
      READ TABLE RFT WITH KEY MANDT = SY-MANDT
                              BANFN = RM06B-REFBN
                              BNFPO = RM06B-BNFPO
        BINARY SEARCH
        TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
        TC_0111-TOP_LINE = SY-TABIX.
      ELSE.
        TC_0111-TOP_LINE = 1.
      ENDIF.
  ENDCASE.

ENDFORM.                    " RM06B-BNFPO
