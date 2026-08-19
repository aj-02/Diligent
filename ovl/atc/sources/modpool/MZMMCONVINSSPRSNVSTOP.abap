*--- MAIN PROGRAM: MZMMCONVINSSPRSNVSTOP ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMCONVINSSPRSNVSTOP                                      *
*----------------------------------------------------------------------*
TABLES : RKPF              ,
         RESB              ,
         MAKT              ,
         MARD              ,
         MBEW              ,
         ANLA              .

TABLES  : GOHEAD.

TYPE-POOLS: VRM            ,
            ESP1           .
CONTROLS : RESV_CTRL TYPE TABLEVIEW USING SCREEN 0200.

*Declartion of structure for storing Reservation header
DATA : Begin of wa_resvdtl,
         rsnum  type resb-rsnum,
         bwart  type resb-bwart,
         lgort  type resb-lgort,
         umlgo  type resb-umlgo,
       End of wa_resvdtl.

*Declartion of structure & internal table for storing reservation detail
DATA : Begin of wa_resvitem,
        matnr      type resb-matnr,
        maktx      type makt-maktx,
        bdmng      type resb-bdmng,
        enmng      type resb-enmng,
        meins      type resb-meins,
        werks      type resb-werks,
        ps_psp_pnr type rkpf-ps_psp_pnr,
        bwart      type resb-bwart,
        charg      type resb-charg,
        lgort      type resb-lgort,
        umlgo      type resb-umlgo,
        charg_r    type resb-charg,
        chk(1),
        selcol(1),
       End of wa_resvitem.

DATA : ist_resvitem   like table of wa_resvitem,
       wa_resvitem_tc like wa_resvitem.

DATA : ist_resvitem_b like table of wa_resvitem,
       wa_resvitem_b  like wa_resvitem.

DATA : ist_resb type table of resb with header line.

*Internal table for BDC - Tr. code MB22
DATA : ist_bdcdata like bdcdata occurs 0  with header line.

DATA : ist_msg type table of bdcmsgcoll.

*Declartion of structure - table control columns
DATA : wa_resvitem_tctrl-cols type cxtab_column.

*Declaration of List box - Movement type
DATA: g_task_cd       type vrm_id,
      ist_task_list   type vrm_values,
      wa_task_value   like line of ist_task_list.

DATA : g_mat_doc_no   type bapi2017_gm_head_ret-mat_doc.

DATA : ok_code     type sy-ucomm ,
       save_ok     type sy-ucomm ,
       g_ok_code   type sy-ucomm .

DATA : g_lines type sy-tabix.

DATA : g_change(1).

DATA : g_ans(1).
