*--- MAIN PROGRAM: MZMMCONVINSSPRSNVSI01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMCONVINSSPRSNVSI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*  To navigate to screen 0200
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  g_ok_code = ok_code.
  clear ok_code.
  case g_ok_code.
    when 'EXEC'.
*     select * from resb into corresponding fields of table ist_resvitem
*                       where rsnum = wa_resvdtl-rsnum.

      perform upd_resvitem_tbl.

      call screen '0200'.
  endcase.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOV_RSNUM  INPUT
*&---------------------------------------------------------------------*
* To get serach help for reservation number
*----------------------------------------------------------------------*
MODULE GET_LOV_RSNUM INPUT.
  DATA : ist_return_tab      like standard table of ddshretval
                                         with  header line.

  DATA : ist_field_tab like standard table of dfies
                                         with  header line.

  DATA : ist_dynpfld_mapping like standard table of dselc
                                         with  header line.

  DATA : wa_object like wa_resvdtl.

  DATA : Begin of wa_rkpf,
          rsnum type rkpf-rsnum,
          bwart type rkpf-bwart,
         End of wa_rkpf.

  DATA : ist_rkpf like table of wa_rkpf.

  DATA : ist_object_f4 like standard table of wa_object initial size
100.

  DATA : l_object_id(10).
  DATA : l_index type sy-tabix.

  refresh : ist_object_f4,ist_return_tab.

  select rsnum bwart from rkpf into table ist_rkpf
    where bwart in ('X21','X41').

  if sy-subrc = 0.
    select rsnum lgort umlgo from resb
       into corresponding fields of table ist_object_f4
           for all entries in ist_rkpf
                where rsnum = ist_rkpf-rsnum.

    sort ist_object_f4 by rsnum lgort.

    delete adjacent duplicates from ist_object_f4.

    loop at ist_object_f4 into wa_object.

      l_index = sy-tabix.

      loop at ist_rkpf into wa_rkpf
                        where rsnum = wa_object-rsnum.

        move wa_rkpf-bwart to wa_object-bwart.
        modify ist_object_f4 from wa_object index l_index.
        exit.
      endloop.

    endloop.
  endif.

  sort ist_object_f4 by rsnum bwart lgort umlgo.

  delete adjacent duplicates from ist_object_f4.

  refresh : ist_dynpfld_mapping.

  ist_dynpfld_mapping-fldname   = 'F0001'.
  ist_dynpfld_mapping-dyfldname = 'WA_RESVDTL-RSNUM'.
  append ist_dynpfld_mapping.

  ist_dynpfld_mapping-fldname   = 'F0002'.
  ist_dynpfld_mapping-dyfldname = 'WA_RESVDTL-BWART'.
  append ist_dynpfld_mapping.

  ist_dynpfld_mapping-fldname   = 'F0003'.
  ist_dynpfld_mapping-dyfldname = 'WA_RESVDTL-LGORT'.
  append ist_dynpfld_mapping.

  ist_dynpfld_mapping-fldname   = 'F0004'.
  ist_dynpfld_mapping-dyfldname = 'WA_RESVDTL-UMLGO'.
  append ist_dynpfld_mapping.

  clear : ist_dynpfld_mapping.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            retfield        = 'RSNUM'
            dynpprog        = sy-repid
            dynpnr          = sy-dynnr
            dynprofield     = 'WA_RESVDTL-RSNUM'
            value_org       = 'S'
       TABLES
            value_tab       = ist_object_f4
            field_tab       = ist_field_tab
            return_tab      = ist_return_tab
            dynpfld_mapping = ist_dynpfld_mapping
       EXCEPTIONS
            parameter_error = 1
            no_values_found = 2
            OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  WA_RESVDTL-RSNUM =  ist_return_tab-fieldval.

ENDMODULE.                 " GET_LOV_RSNUM  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0100  INPUT
*&---------------------------------------------------------------------*
*   To exit from program at any time
*----------------------------------------------------------------------*
MODULE CANCEL_0100 INPUT.
  save_ok = ok_code.
  clear ok_code.
  case save_ok.
    WHEN 'BACK' or 'CANCEL' OR 'EXIT'.
      leave program.
  endcase.
ENDMODULE.                 " CANCEL_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_validation  INPUT
*&---------------------------------------------------------------------*
*    Checks for input field, if required input field is null
*    display error message - screen 0100                               *
*----------------------------------------------------------------------*
MODULE check_validation INPUT.
  if wa_resvdtl-rsnum is initial.
    message e370(zmm).
  endif.

  perform get_resb_data.

  if wa_resvdtl-bwart is initial.
    message e371(zmm).
  endif.

  if wa_resvdtl-lgort is initial.
    message e372(zmm).
  endif.

  if wa_resvdtl-umlgo is initial.
    message e373(zmm).
  endif.
ENDMODULE.                 " check_validation  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0200  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE CANCEL_0200 INPUT.
  save_ok = ok_code.
  clear ok_code.

  case g_ok_code.
    when 'EXEC'.
      case save_ok.
        WHEN 'BACK' or 'CANCEL' OR 'EXIT'.
          clear : g_ans.

          perform confirm_input.
          if g_ans = '2'.
            clear g_ans.
            clear ok_code.
            clear save_ok.
            clear g_ok_code.
            leave to screen 100.
          elseif g_ans = '1'.
            clear g_ans.
            clear ok_code.
            ok_code = 'SAVE'.
          endif.
      endcase.
  endcase.
ENDMODULE.                 " CANCEL_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_DATA_GL  INPUT
*&---------------------------------------------------------------------*
* To Initialize variable which will be used in Main Screen
*----------------------------------------------------------------------*
MODULE INIT_DATA_GL INPUT.
  refresh : ist_resvitem.

  clear   : wa_resvitem,
            wa_resvitem_tc.

  REFRESH CONTROL 'RESV_CTRL' FROM SCREEN 0200.

  g_change = '1'.
ENDMODULE.                 " INIT_DATA_GL  INPUT

*&---------------------------------------------------------------------*
*&      Module  read_table_control_0200  INPUT
*&---------------------------------------------------------------------*
*  Move table control table data into internal table ist_resvitem
*----------------------------------------------------------------------*
MODULE read_table_control_0200 INPUT.
  MOVE-CORRESPONDING wa_resvitem_tc TO wa_resvitem.

  MODIFY ist_resvitem FROM wa_resvitem INDEX
  resv_ctrl-current_line.
ENDMODULE.                 " read_table_control_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_validation_0200  INPUT
*&---------------------------------------------------------------------*
*    Checks for input field, if input field is invalid, display
*    error message - Screen 0200
*----------------------------------------------------------------------*
MODULE check_validation_0200 INPUT.
  if wa_resvitem_tc-bdmng is initial.
    message e375(zmm).
  endif.

  if wa_resvitem_tc-charg_r is initial.
    loop at ist_resvitem_b into wa_resvitem_b
                  where matnr = wa_resvitem_tc-matnr.
      if wa_resvitem_tc-bdmng > wa_resvitem_b-bdmng.
        message e374(zmm).
      endif.
    endloop.
  else.
    loop at ist_resvitem into wa_resvitem_b
                  where matnr   = wa_resvitem_tc-matnr
                    and charg_r = ''.

      wa_resvitem_tc-bdmng = wa_resvitem_b-bdmng.
      wa_resvitem_tc-chk   = wa_resvitem_b-chk.
    endloop.
  endif.
ENDMODULE.                 " check_validation_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
* To perform operations like convert insurance spares to non valuated
* stock etc by pressing the respective button at application tool bar &
* Tabstrip.
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE g_ok_code.
    WHEN 'EXEC'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.
          PERFORM chk_stk_val.
          PERFORM trans_spares_mvstk.

        WHEN 'CHK'.
          PERFORM chk_stk_val.

        WHEN 'SELE'.
          PERFORM select_all_entries.

        WHEN 'DESE'.
          PERFORM deselect_all_entries.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
