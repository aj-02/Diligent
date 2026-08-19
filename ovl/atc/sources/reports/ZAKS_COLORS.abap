*--- MAIN PROGRAM: ZAKS_COLORS ---*
*&---------------------------------------------------------------------*
*& Report  ZAKS_COLORS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZAKS_COLORS.
DATA sum TYPE i.

FORMAT COLOR COL_NORMAL.
FORMAT COLOR COL_TOTAL.

DO 10 TIMES.
  WRITE / sy-index.
  sum = sum + sy-index.
  WRITE sum COLOR  COL_TOTAL .
ENDDO.
 WRITE sum COLOR 1 .
  WRITE sum COLOR 2 .
   WRITE sum COLOR 3 .
     WRITE sum COLOR 4  .
  WRITE sum COLOR 5 .
    WRITE sum COLOR 6 .
      WRITE sum COLOR 7 .

ULINE.
WRITE sum UNDER sum COLOR COL_GROUP.

*--- INCLUDE: DB__SSEL ---*
* INCLUDE DB__SSEL
