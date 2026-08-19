*--- MAIN PROGRAM: MZMMNMUNBLKO01 ---*
***INCLUDE MZMMNMUNBLKO01 .
*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tct100_init OUTPUT.
  IF g_tct100_copied IS INITIAL.
*&spwizard: copy ddic-table 'ZMM_NMBLKCDDT'
*&spwizard: into internal table 'g_TCT100_itab
   IF g_mode <> 'CRE'.
    SELECT * FROM zmm_nmblkcddt
       INTO CORRESPONDING FIELDS
       OF TABLE g_tct100_itab
    where reqno = zmm_nmblkcdhd_st-reqno.
   ENDIF.
    g_tct100_copied = 'X'.
    REFRESH CONTROL 'TCT100' FROM SCREEN '0100'.
  ENDIF.
*break cab_subodhk.
  if ( g_mode = 'CRE' or
       g_mode = 'CHA' ) and sy-ucomm = 'SEND'.
     if not g_tx100_itab[] is initial.
       describe table g_tx100_itab[] lines g_txlines.
     endif.
     describe table g_tct100_itab lines g_tctlines.
**Setting number of lines.
     if g_tctlines = 0.
       tct100-lines = g_txlines.
     else.
       tct100-lines = g_txlines + g_tctlines.
     endif.
***
     perform get_data_from_tx100.
     clear sy-ucomm.
  endif.
  sort g_tct100_itab ascending by matcode descending srno.
  delete adjacent duplicates from g_tct100_itab comparing matcode.
  sort g_tct100_itab ascending by srno.
ENDMODULE.

*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tct100_move OUTPUT.
 DATA : l_srno TYPE i,
        l_labst LIKE mard-labst,
        l_spmon like s034-spmon,
        l_mm(2) type n,
        l_yy(4) type n.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tct100_wa-matcode IS INITIAL.
      CLEAR: l_srno.
      IF g_tct100_wa-srno = 0.
        PERFORM get_nextsrno.
        MOVE l_srno TO g_tct100_wa-srno.
        MODIFY g_tct100_itab FROM g_tct100_wa
        INDEX tct100-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.
*  ENDIF.
***Plant Stock***********
  IF NOT g_tct100_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tct100_wa-plant_stk
      WHERE werks = zmm_nmblkcdhd_st-werks
      AND   matnr = g_tct100_wa-matcode.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING plant_stk.
  ENDIF.
***ONGC Stock***********
  IF NOT g_tct100_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tct100_wa-ongc_stk
    WHERE matnr = g_tct100_wa-matcode.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING ongc_stk.
  ENDIF.
****Plant Consumption **********
  Clear: l_mm,l_yy.
  l_mm = sy-datum+4(2).
   if l_mm < '04'.
     l_yy = sy-datum+0(4) - 1.
    concatenate l_yy '04' into l_spmon.
   else.
    concatenate sy-datum+0(4) '04'  into l_spmon.
   endif.
   IF NOT g_tct100_wa-matcode IS INITIAL.
    SELECT SUM( cmgvbr ) FROM s034 INTO g_tct100_wa-cmgvbr
      WHERE werks = zmm_nmblkcdhd_st-werks
      AND   matnr = g_tct100_wa-matcode
      AND   spmon GE l_spmon.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING cmgvbr.
   ENDIF.
****ONGC Consumption *************
   IF NOT g_tct100_wa-matcode IS INITIAL.
    SELECT SUM( cmgvbr ) FROM s034 INTO g_tct100_wa-ongc_cons
      WHERE matnr = g_tct100_wa-matcode
      and   spmon GE l_spmon.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING ongc_cons.
   ENDIF.
  ENDIF.               "CRE or CHA
  MOVE-CORRESPONDING g_tct100_wa TO zmm_nmblkcddt.
ENDMODULE.

*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct100_get_lines OUTPUT.
  g_tct100_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA : l_mode(3) TYPE c,
         l_reqno(10) TYPE c.
*****To set the mode to 'BLK'.
  IMPORT wa_mode TO l_mode FROM MEMORY ID 'CODUNBLK'.
  IF sy-subrc = 0.
    g_mode = l_mode.
  ENDIF.
  FREE MEMORY ID 'CODUNBLK'.
*****
  PERFORM fill_sttab.
  SET PF-STATUS 'OPTNS' EXCLUDING it_tab1.
  CASE g_mode.
    WHEN 'CRE'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Create Request'.
    WHEN 'CHA'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Change Request'.
    WHEN 'DIS'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Display Request'.
    WHEN 'DEL'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Delete Request'.
    WHEN 'REL'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Release Request'.
    WHEN 'APR'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Approve Request'.
    WHEN OTHERS.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.
  ENDCASE.
***
  IF g_mode = 'BLK'.
    GET PARAMETER ID 'ZDNO' FIELD l_reqno.
    zmm_nmblkcdhd_st-reqno = l_reqno.
  ENDIF.

*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize OUTPUT.
  PERFORM get_correspondense.
ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE splitter_ctrl_vorbereiten1 OUTPUT.
  IF gv_splitter1 IS INITIAL.
    CREATE OBJECT gv_custom_container
                  EXPORTING container_name = 'C_DIS'.

    CREATE OBJECT gv_splitter1
           EXPORTING
                  parent = gv_custom_container
                  orientation = 1
                  sash_position = 1.
  ENDIF.

  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
     ( g_mode = 'APR' ).

    IF gv_splitter2 IS INITIAL.

      CREATE OBJECT gv_custom_container
                    EXPORTING container_name = 'C_WRT'.


      CREATE OBJECT gv_splitter2
             EXPORTING
                    parent = gv_custom_container
                    orientation = 1
                    sash_position = 1.

    ENDIF.
  ENDIF.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_vorbereiten1 OUTPUT.
  IF gv_text_editor1 IS INITIAL.
    CREATE OBJECT gv_text_editor1
       EXPORTING
            parent = gv_splitter1->bottom_right_container
            wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
            wordwrap_to_linebreak_mode = cl_gui_textedit=>false
       EXCEPTIONS
            error_cntl_create      = 1
            error_cntl_init        = 2
            error_cntl_link        = 3
            error_dp_create        = 4
            gui_type_not_supported = 5.
  ENDIF.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
     ( g_mode = 'APR' ).

    IF gv_text_editor2 IS INITIAL.
      CREATE OBJECT gv_text_editor2
         EXPORTING
              parent = gv_splitter2->bottom_right_container
              wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
              wordwrap_to_linebreak_mode = cl_gui_textedit=>false
         EXCEPTIONS
              error_cntl_create      = 1
              error_cntl_init        = 2
              error_cntl_link        = 3
              error_dp_create        = 4
              gui_type_not_supported = 5.
    ENDIF.
  ENDIF.

  PERFORM text_control_eingabebereit1.
  PERFORM text_control_set_text_table1.
ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  SET PF-STATUS 'STAT105'.
ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr_attr_header  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr_attr_header OUTPUT.
  CASE g_mode.
    WHEN ''.
      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN 'CRE'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO'  OR
           screen-name = 'ZMM_NMBLKCDHD_ST-STATUS' OR
           screen-name = 'ZMM_NMBLKCDHD_ST-RELFLAG' OR
*code added by CAB_AMITMOZA  CR:30001048  WR:RD1K983014
           screen-name = 'ZMM_NMBLKCDHD_ST-TEL' OR
*code END by CAB_AMITMOZA  CR:30001048
           screen-name = 'ZMM_NMBLKCDHD_ST-APPFLAG'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

*code added by CAB_AMITMOZA  CR:30001048  WR:RD1K983014
        SELECT * FROM  PA9205 APPENDING
      CORRESPONDING FIELDS OF TABLE IT_9205
      WHERE Pernr = SY-UNAME AND
            Subty = '01' AND
            Endda = '99991231' .
      clear ZMM_NMBLKCDHD_ST-TEL.
IF SY-SUBRC = 0.          "" It means PHONE NO. HAS BEEN FOUND

  SORT  IT_9205 By Begda DESCENDING  .

  READ TABLE It_9205 INTO Wa_9205 INDEX 1  .

  CONCATENATE '91' Wa_9205-ZPHONE+1(10) INTO  ZMM_NMBLKCDHD_ST-TEL .
  ENDIF.
*code END by CAB_AMITMOZA  CR:30001048
      ENDLOOP.
    WHEN 'CHA'.
      IF zmm_nmblkcdhd_st-reqno IS INITIAL.
        LOOP AT SCREEN.
          IF screen-name <> 'ZMM_NMBLKCDHD_ST-REQNO'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
         IF g_result = '2'.
          IF SCREEN-GROUP1 = 'MOD' OR
             SCREEN-GROUP1 = 'PAG' OR
             SCREEN-GROUP1 = 'MAR' OR
             SCREEN-GROUP1 = 'LOD' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
             screen-name = 'PB_CORS' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-WERKS' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-ADDR1' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-TEL'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
         ELSE.
           screen-input = 0.
           MODIFY SCREEN.
         ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN 'REL'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
           screen-name = 'ZMM_NMBLKCDHD_ST-RELFLAG' OR
           screen-name = 'PB_CORS' OR
           screen-group1 = 'PAG'.
          screen-input = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'APR'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
           screen-name = 'ZMM_NMBLKCDHD_ST-APPFLAG' OR
           screen-name = 'PB_CORS' OR
           screen-group1 = 'PAG'.
          screen-input = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
           screen-name = 'PB_CORS' OR
           screen-group1 = 'PAG' OR
           screen-group1 = 'MAR'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
        IF g_mode = 'BLK'.
          IF screen-name = 'ZMM_NMBLKCDHD_ST-STATUS'.
            IF zmm_NMBLKCDHD_st-status = 'N' OR
               zmm_NMBLKCDHD_st-status = 'IC' OR
               zmm_NMBLKCDHD_st-status = 'IR'.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
          IF screen-name = 'T_TX1' OR
             screen-name = 'T_TX2'.
             screen-invisible = '1'.
             modify screen.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " scr_attr_header  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_header_data output.
 IF NOT zmm_nmblkcdhd_st-reqno IS INITIAL.
*    IF g_hd_copied IS INITIAL.
      IF g_mode <> 'CRE' and g_hd_copied is initial.
        if ( g_mode = 'CHA' ) OR ( g_mode = 'DEL' )
                              OR ( g_mode = 'BLK' ).
*            perform lock_reqhd.
        endif.
        SELECT SINGLE * FROM zmm_nmblkcdhd
        INTO CORRESPONDING FIELDS OF zmm_nmblkcdhd_st
            WHERE reqno = zmm_nmblkcdhd_st-reqno.
***code added by CAB_AMITMOZA CR:30001048  WR:RD1K983014
         CLEAR : NAME1 , NAME2 , NAME3 .
IF NOT ZMM_NMBLKCDHD_ST-REQCPF IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME1
  WHERE PERNR = ZMM_NMBLKCDHD_ST-REQCPF.
  ENDIF.
  IF NOT ZMM_NMBLKCDHD_ST-RELBY IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME2
  WHERE PERNR = ZMM_NMBLKCDHD_ST-RELBY.
  ENDIF.
  IF NOT ZMM_NMBLKCDHD_ST-APPBY IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME3
  WHERE PERNR = ZMM_NMBLKCDHD_ST-APPBY.
  ENDIF.
**CODE END BY CAB_AMITMOZA CR:30001048  WR:RD1K983014

        IF g_relflag = 'J'.
          zmm_nmblkcdhd_st-relflag = ''.
          zmm_nmblkcdhd_st-appflag = ''.
          CLEAR g_relflag.
        ENDIF.
        g_hd_copied = 'X'.
      ENDIF.
*    ENDIF.
  ENDIF.
  PERFORM get_correspondense.

endmodule.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module STATUS_0103 output.
*  SET PF-STATUS 'STAT_REL'.
*  SET TITLEBAR 'xxx'.

endmodule.                 " STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  write_certificate  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module write_certificate output.
  SUPPRESS DIALOG.
  SET PF-STATUS 'STAT_REL'.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*
  NEW-PAGE NO-TITLE.
  CASE g_mode .
    WHEN 'REL'.
WRITE : / '                   Acknowledgement                         '
                                                COLOR 3.
WRITE : / '-----------------------------------------------------------'.
WRITE : / 'This is to certify that information provided by me is '.
WRITE : / 'accurate. Kindly unblock the material codes.'.

  ENDCASE.

endmodule.                 " write_certificate  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT100_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TCT100_change_field_attr output.
CASE g_mode.
    WHEN 'CRE' OR 'CHA'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDDT-ERRCD'.
           screen-input  = '0'.
           MODIFY SCREEN.
        ENDIF.
        IF NOT zmm_nmblkcdhd_st-werks IS INITIAL AND
           NOT zmm_nmblkcdhd_st-tel IS INITIAL.
          IF NOT ZMM_NMBLKCDDT-matcode IS INITIAL.
            IF zmm_nmblkcdhd_st-status = 'IR'.
              IF ZMM_NMBLKCDDT-UNBLKBY <> ''.
                screen-input = '0'.
                MODIFY SCREEN.
                if screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
                   screen-INTENSIFIED = '1'.
                   MODIFY SCREEN.
                endif.
              ENDIF.
              IF screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
            if screen-name = 'G_TCT100_WA-FLAG'.
             screen-input     = '1'.
             MODIFY SCREEN.
            endif.
          ENDIF.
          IF ZMM_NMBLKCDDT-errcd = 'M'.
           if screen-name <> 'G_TCT100_WA-FLAG'.
             screen-input     = '0'.
             MODIFY SCREEN.
           endif.
          ENDIF.
        ELSE.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF g_result = '1'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'DIS' OR 'DEL' OR 'REL' OR 'APR'.
      LOOP AT SCREEN.
        screen-input = '0'.
        MODIFY SCREEN.
        IF G_TCT100_WA-unblkby <> ''.
          if screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
            screen-INTENSIFIED = '1'.
            MODIFY SCREEN.
          endif.
        ENDIF.
      ENDLOOP.
    WHEN 'BLK'.
      LOOP AT SCREEN.
        IF G_TCT100_WA-UNBLKBY <> ''.
          screen-input = '0'.
          MODIFY SCREEN.
          if screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
            screen-INTENSIFIED = '1'.
            MODIFY SCREEN.
          endif.
        ELSE.
          if screen-name = 'G_TCT100_WA-FLAG' OR
             screen-name = 'ZMM_NMBLKCDDT-ERRCD'.
             screen-input     = '1'.
             MODIFY SCREEN.
          else.
             screen-input     = '0'.
             MODIFY SCREEN.
          endif.
        ENDIF.
        IF zmm_nmblkcdhd_st-status = 'C' OR
           zmm_nmblkcdhd_st-status = 'AC'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN ''.
      LOOP AT SCREEN.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

endmodule.                 " TCT100_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  display_message  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module display_message output.
Data:l_100msg type t_tct100.
IF G_ERRCD_M IS INITIAL.
 Read table g_tct100_itab into l_100msg with key errcd = 'M'.
 if sy-subrc = 0.
   G_ERRCD_M = 'X'.
   message i122(zmm_oth).
 endif.

ENDIF.
* clear g_errstat.

endmodule.                 " display_message  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISABLE_CREATE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISABLE_CREATE OUTPUT.

        LOOP AT SCREEN.
          IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO'  OR
             screen-name = 'ZMM_NMBLKCDHD_ST-STATUS' OR
             screen-name = 'G_REL_FLAG' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-TEL' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-APPFLAG'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.

ENDMODULE.                 " DISABLE_CREATE  OUTPUT
