*--- MAIN PROGRAM: MZMM_STOTOP ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMM_STOTOP                                                *
*----------------------------------------------------------------------*

TABLES:eket,
       ekpo,
       ekko,
       t001w.
SELECTION-SCREEN BEGIN OF BLOCK blk WITH FRAME.
SELECT-OPTIONS:werks FOR t001w-werks OBLIGATORY.
*parameters: matnr like ekpo-matnr.
SELECT-OPTIONS:ebeln FOR eket-ebeln. " obligatory.
PARAMETERS:days(3).
SELECTION-SCREEN END OF BLOCK blk.

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME.
PARAMETERS: rad1 RADIOBUTTON GROUP rad,
            rad2 RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK blk1.
DATA:ist_pfstatus LIKE rsmpe OCCURS 0 WITH HEADER LINE.

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA:   e_group_opened.
DATA:BEGIN OF ist_display OCCURS 1,
      ebeln LIKE eket-ebeln,
      ebelp(6),
      slfdt(12), " like sy-datum , "(12), " like eket-slfdt,
      days(4),
      werks1 LIKE ekpo-werks,
      werks LIKE ekpo-werks,
      matnr LIKE ekpo-matnr,
      menge TYPE ekpo-menge,
      meins TYPE ekpo-meins,
      BWTAR TYPE ekpo-BWTAR,
      txz01 TYPE ekpo-txz01,
      vbeln TYPE lips-vbeln,
      erdat TYPE lips-erdat,


      sel(1),
     END OF ist_display.

DATA:BEGIN OF ist_count OCCURS 1,
      ebeln LIKE eket-ebeln,
      lines(3),
     END OF ist_count.
DATA:ist_display1 LIKE ist_display OCCURS 1 WITH HEADER LINE.
DATA:g_date LIKE sy-datum.
DATA:okcode LIKE sy-ucomm,
     g_okcode100 LIKE sy-ucomm.
CONTROLS tbc_200 TYPE  TABLEVIEW USING SCREEN '0200'.
DATA:sel_flag.
DATA:g_count(4).
DATA:g_title(50).
DATA:g_title1(50),
flag.
