*&---------------------------------------------------------------------*
*& Report  ZSD_CORRECT_RFBSK
*&
*&---------------------------------------------------------------------*
*Change History
*
* Mod Date     Changed By     Description         Chng ID
* 13022009     Sudhir Sharma  Chn Dbl Acctg stat  <RD1K961813>
*
*&---------------------------------------------------------------------*

REPORT  ZSD_CORRECT_RFBSK    .

Tables :  VBRK ,
          ENT6037,
          ENT6038 ,
          ENT6209  ,
          ENT6210   ,
          ENT6211    ,
          ENT6216     ,
          ENT6217      ,
          ENT6218       ,
          M_VMCFA        ,
          VBRKUK          , "#EC CI_USAGE_OK[2198647]
*          V_BAM_VBRK      ,
          WB2_V_VBRK_VBRL ,
          WB2_V_VBRK_VBRL2,
          WB2_V_VBRK_VBRP ,
          WB2_V_VBRK_VBRP2.

data : ist_vbrk type table of vbrk,
       wa_vbrk type vbrk.

SELECTION-SCREEN BEGIN OF BLOCK REPORT_SELECTION WITH FRAME TITLE
TEXT-001.
SELECT-OPTIONS: fakturen FOR vbrk-vbeln obligatory.
PARAMETERS    : RFBSK type vbrk-RFBSK  obligatory,
                test AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK REPORT_SELECTION.

start-of-selection.

if test = 'X'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
   select * from vbrk into table ist_vbrk where vbeln in fakturen.  "#EC CI_DB_OPERATION_OK[2768887]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
   if sy-subrc = 0.

      uline (55).
      loop at ist_vbrk into wa_vbrk.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        write:/1 '|' no-gap,
          2  wa_vbrk-vbeln,  "#EC CI_NOORDER
          19 '|' no-gap,
          21 wa_vbrk-rfbsk,  "#EC CI_NOORDER
         24  '|' no-gap,
         26  'Will be Changed to --->',
         51  '|' no-gap,
         53  rfbsk,
         55  '|'.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
     new-line.
     uline (55).
*        write : /2 wa_vbrk-vbeln , wa_vbrk-rfbsk.
*        write : /2 'Will be changed to ',19 rfbsk .
      endloop.

   endif.

else.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
   select * from vbrk into table ist_vbrk where vbeln in fakturen.  "#EC CI_DB_OPERATION_OK[2768887]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
   if sy-subrc = 0.
      uline (55).
      loop at ist_vbrk into wa_vbrk.

        update vbrk set rfbsk = rfbsk
                    where vbeln = wa_vbrk-vbeln.
    write:/1 '|' no-gap,
          2  wa_vbrk-vbeln, "#EC CI_NOORDER
          19 '|' no-gap, "#EC CI_NOORDER
          21 wa_vbrk-rfbsk, "#EC CI_NOORDER
         24  '|' no-gap, "#EC CI_NOORDER
         26  'Changed to --->', "#EC CI_NOORDER
         51  '|' no-gap, "#EC CI_NOORDER
         53  rfbsk, "#EC CI_NOORDER
         55  '|'. "#EC CI_NOORDER
     new-line.
     uline (55).
     endloop.
   endif.

endif.
