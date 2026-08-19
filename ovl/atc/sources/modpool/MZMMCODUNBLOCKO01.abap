*--- MAIN PROGRAM: MZMMCODUNBLOCKO01 ---*
*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE tct110_change_tc_attr OUTPUT.
  LOOP AT tct110-cols INTO col110 WHERE index EQ 10.
      col110-invisible = '1'.
      MODIFY tct110-cols FROM col110 INDEX sy-tabix.
  ENDLOOP.

  DESCRIBE TABLE g_tc110_itab LINES tct110-lines.
ENDMODULE.

*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct110_get_lines OUTPUT.
  g_tct110_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA : l_mode(3) TYPE c.
*****To set the mode to 'BLK'.
  IMPORT wa_mode TO l_mode FROM MEMORY ID 'CODUNBLK'.
  IF sy-subrc = 0.
    g_mode = l_mode.
  ENDIF.
  FREE MEMORY ID 'CODUNBLK'.
*  clear g_section.
*  IMPORT wa_section TO g_section FROM MEMORY ID 'CODUNBLK_SEC'.
*  FREE MEMORY ID 'CODUNBLK_SEC'.
*****
  PERFORM fill_sttab.
  SET PF-STATUS 'OPTNS' EXCLUDING it_tab1.
  CASE g_mode.
    WHEN 'CRE'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Create Request'.
    WHEN 'CHA'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Change Request'.
    WHEN 'DIS'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Display Request'.
    WHEN 'DEL'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Delete Request'.
    WHEN 'REL'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Release Request'.
    WHEN OTHERS.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ''.
  ENDCASE.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_MATTY_TCT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_matty_tct OUTPUT.
  DATA : l_reqno(10) TYPE c.
  IF g_mode = 'BLK'.
    GET PARAMETER ID 'ZDNO' FIELD l_reqno.
    zmm_matblockhd_st-reqno = l_reqno.
  ENDIF.
  PERFORM fill_mattyp_itemdt.
*  set parameter id 'ZMATGP' field ''.
*  set parameter id 'MTA' field ZMM_CDHD_ST-MTART.
  IF dynnr IS INITIAL.
*    dynnr = '0101'.
    dynnr = '0110'.
  ENDIF.

ENDMODULE.                 " GET_MATTY_TCT  OUTPUT

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE tct120_change_tc_attr OUTPUT.
  LOOP AT tct120-cols INTO col120 WHERE index EQ 18.
      col120-invisible = '1'.
      MODIFY tct120-cols FROM col120 INDEX sy-tabix.
  ENDLOOP.
  DESCRIBE TABLE g_tc120_itab LINES tct120-lines.
ENDMODULE.

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct120_get_lines OUTPUT.
  g_tct120_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SCR100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.
  CASE g_mode.
    WHEN ''.
      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN 'CRE'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_MATBLOCKHD_ST-REQNO'  OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REQCPF' OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REQDATE' OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REQCL'  OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REL_FLAG'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'CHA'.
      IF zmm_matblockhd_st-reqno IS INITIAL.
        LOOP AT SCREEN.
          IF screen-name <> 'ZMM_MATBLOCKHD_ST-REQNO'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_MATBLOCKHD_ST-REQNO' OR
             screen-name = 'PB_CORS' OR
             screen-name = 'ZMM_MATBLOCKHD_ST-WERKS' OR
             screen-name = 'ZMM_MATBLOCKHD_ST-ADDR1' OR
             screen-name = 'ZMM_MATBLOCKHD_ST-TEL'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN 'REL'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_MATBLOCKHD_ST-REQNO' OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REL_FLAG' OR
           screen-name = 'PB_CORS'.
          screen-input = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_MATBLOCKHD_ST-REQNO' OR
           screen-name = 'PB_CORS'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
        IF g_mode = 'BLK'.
          IF screen-name = 'ZMM_MATBLOCKHD_ST-REQCL'.
            IF zmm_matblockhd_st-reqcl = 'N' OR
               zmm_matblockhd_st-reqcl = 'IC' OR
               zmm_matblockhd_st-reqcl = 'IR'.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " SCR100_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct110_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct110_init OUTPUT.
  Data : l_matgp110(2) type c.
  IF g_tct110_copied IS INITIAL.
    IF g_mode <> 'CRE'.
      SELECT * FROM zmm_matblock_dt
           INTO CORRESPONDING FIELDS
           OF TABLE g_tc110_itab
        WHERE reqno = zmm_matblockhd_st-reqno.
    ENDIF.
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if g_mode = 'BLK'.
      select single * from zmm_blkcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        select single * from zmm_blkcodifier
               where codifier = sy-uname.
        if sy-subrc = 0.
          if g_section = 'I'.
            delete g_tc110_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc110_itab where mstae = 'NM'.
          endif.
          loop at g_tc110_itab into g_tc110_wa.
            l_matgp110 = g_tc110_wa-matcode+0(2).
            select single * from zmm_blkcodifier
                 where codifier = sy-uname
                 and   matgp    = l_matgp110.
            if sy-subrc <> 0.
              delete g_TC110_itab index sy-tabix.
            endif.
            clear l_matgp110.
          endloop.
        endif.
      else.
        if g_section = 'I'.
            delete g_tc110_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc110_itab where mstae = 'NM'.
        endif.
      endif.
    endif.
****
    g_tct110_copied = 'X'.
    REFRESH CONTROL 'TCT110' FROM SCREEN '0110'.
  ENDIF.
ENDMODULE.                 " tct110_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct120_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct120_init OUTPUT.
 Data : l_matgp120(2) type c.
  IF g_tct120_copied IS INITIAL.
    IF g_mode <> 'CRE'.
      SELECT * FROM zmm_matblock_dt
           INTO CORRESPONDING FIELDS
           OF TABLE g_tc120_itab
        WHERE reqno = zmm_matblockhd_st-reqno.
    ENDIF.
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if g_mode = 'BLK'.
      select single * from zmm_blkcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        select single * from zmm_blkcodifier
               where codifier = sy-uname.
        if sy-subrc = 0.
          if g_section = 'I'.
            delete g_tc120_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc120_itab where mstae = 'NM'.
          endif.
          loop at g_tc120_itab into g_tc120_wa.
            l_matgp120 = g_tc120_wa-matcode+0(2).
            select single * from zmm_blkcodifier
                 where codifier = sy-uname
                 and   matgp    = l_matgp120.
            if sy-subrc <> 0.
              delete g_TC120_itab index sy-tabix.
            endif.
            clear l_matgp120.
          endloop.
        endif.
      else.
         if g_section = 'I'.
            delete g_tc120_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc120_itab where mstae = 'NM'.
          endif.
      endif.
    endif.
****
    g_tct120_copied = 'X'.
    REFRESH CONTROL 'TCT120' FROM SCREEN '0120'.
  ENDIF.

ENDMODULE.                 " tct120_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct110_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct110_move OUTPUT.
  DATA : l_srno TYPE i,
         l_labst LIKE mard-labst.
*  MOVE-CORRESPONDING g_tc110_wa TO zmm_matblock_dt.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tc110_wa-matcode IS INITIAL.
      CLEAR: l_srno.
      IF g_tc110_wa-srno = 0.
        PERFORM get_nextsrno_sto.
        MOVE l_srno TO g_tc110_wa-srno.
        MODIFY g_tc110_itab FROM g_tc110_wa
        INDEX tct110-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.
  ENDIF.
***Plant Stock***********
  IF NOT g_tc110_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc110_wa-p_stock
      WHERE werks = zmm_matblockhd_st-werks
      AND   matnr = g_tc110_wa-matcode.
    MODIFY g_tc110_itab FROM g_tc110_wa
    INDEX tct110-current_line TRANSPORTING p_stock.
  ENDIF.
***ONGC Stock***********
  IF NOT g_tc110_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc110_wa-c_stock
    WHERE matnr = g_tc110_wa-matcode.

    MODIFY g_tc110_itab FROM g_tc110_wa
    INDEX tct110-current_line TRANSPORTING c_stock.
  ENDIF.


ENDMODULE.                 " tct110_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.
  IF NOT zmm_matblockhd_st-reqno IS INITIAL.
*    IF g_hd_copied IS INITIAL.
      IF g_mode <> 'CRE' and g_hd_copied is initial.
        if ( g_mode = 'CHA' ) OR ( g_mode = 'DEL' )
                              OR ( g_mode = 'BLK' ).
            perform lock_reqhd.
        endif.
        SELECT SINGLE * FROM zmm_matblock_hd
        INTO CORRESPONDING FIELDS OF zmm_matblockhd_st
            WHERE reqno = zmm_matblockhd_st-reqno.
        IF g_relflag = 'J'.
          zmm_matblockhd_st-rel_flag = ''.
          zmm_matblockhd_st-apr_flag = ''.
          CLEAR g_relflag.
        ENDIF.
        g_hd_copied = 'X'.
      ENDIF.
*    ENDIF.
  ENDIF.
  PERFORM get_correspondense.
  SET PARAMETER ID 'ZMAT_TY' FIELD zmm_matblockhd_st-mtart.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct110_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct110_change_field_attr OUTPUT.
  CASE g_mode.
    WHEN 'CRE' OR 'CHA'.
      LOOP AT SCREEN.
        IF screen-name = 'G_TC110_WA-ERRCD'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF NOT zmm_matblockhd_st-werks IS INITIAL AND
           NOT zmm_matblockhd_st-tel IS INITIAL.
          IF NOT g_tc110_wa-matcode IS INITIAL.
            IF g_tc110_wa-mstae <> 'NM'.
              IF screen-name    = 'G_TC110_WA-MATDESC'.
                screen-required = '1'.
                MODIFY SCREEN.
              ELSEIF screen-name    = 'G_TC110_WA-RES_NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ELSE.
              IF screen-group1 = 'NM'.
                screen-required = '1'.
                MODIFY SCREEN.
              ELSE.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
            IF zmm_matblockhd_st-reqcl = 'IR'.
              IF g_tc110_wa-mstae = ''.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
              IF screen-name    = 'G_TC110_WA-MATCODE'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'DIS' OR 'DEL' OR 'REL'.
      LOOP AT SCREEN.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN 'BLK'.
      LOOP AT SCREEN.
        IF g_tc110_wa-mstae = ''.
          screen-input = '0'.
          MODIFY SCREEN.
        ELSE.
          IF screen-name = 'G_TC110_WA-MARK'.
             screen-input = '1'.
             MODIFY SCREEN.
          ELSEIF screen-name = 'G_TC110_WA-MATDESC'.
            IF g_tc110_wa-mstae = 'NM'.
              screen-input = '0'.
              MODIFY SCREEN.
            ELSE.
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC110_WA-ERRCD'.
            IF g_tc110_wa-errcd = 'S'.
              screen-input = '0'.
              MODIFY SCREEN.
            ELSE.
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC110_WA-MATCODE'.
            IF NOT g_tc110_wa-matcode IS INITIAL.
              screen-input = '0'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC110_WA-RES_NM'.
            screen-input = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF zmm_matblockhd_st-reqcl = 'C' OR
           zmm_matblockhd_st-reqcl = 'AC'.
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
ENDMODULE.                 " tct110_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct120_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct120_move OUTPUT.
*  DATA : l_mara LIKE mara.

****Serial Number.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tc120_wa-matcode IS INITIAL.
**********To get the maximum srno in the internal table***
      CLEAR: l_srno.
      IF g_tc120_wa-srno = 0.
        PERFORM get_nextsrno_spr.
        MOVE l_srno TO g_tc120_wa-srno.
        MODIFY g_tc120_itab FROM g_tc120_wa INDEX
             tct120-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.
  ENDIF.

***Plant Stock***********
  IF NOT g_tc120_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc120_wa-p_stock
      WHERE werks = zmm_matblockhd_st-werks
      AND   matnr = g_tc120_wa-matcode.
    MODIFY g_tc120_itab FROM g_tc120_wa
    INDEX tct120-current_line TRANSPORTING p_stock.
  ENDIF.
***ONGC Stock***********
  IF NOT g_tc120_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc120_wa-c_stock
    WHERE matnr = g_tc120_wa-matcode.

    MODIFY g_tc120_itab FROM g_tc120_wa
    INDEX tct120-current_line TRANSPORTING c_stock.
  ENDIF.


ENDMODULE.                 " tct120_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct120_change_field_attr OUTPUT.
  CASE g_mode.
    WHEN 'CRE' OR 'CHA'.
      LOOP AT SCREEN.
        IF screen-name = 'G_TC120_WA-ERRCD'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF NOT zmm_matblockhd_st-werks IS INITIAL AND
           NOT zmm_matblockhd_st-tel IS INITIAL.
          IF NOT g_tc120_wa-matcode IS INITIAL.
            IF g_tc120_wa-mstae <> 'NM'.
              IF screen-name    = 'G_TC120_WA-NPARTNO'.
                IF g_tc120_wa-opartno IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC120_WA-NMDLNO'.
                IF g_tc120_wa-omdlno IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC120_WA-NCAPNO'.
                IF g_tc120_wa-ocapno IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC120_WA-NOEM'.
                IF g_tc120_wa-ooem IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC120_WA-RES_NM'.
                screen-input     = '0'.
                MODIFY SCREEN.
              ENDIF.
            ELSE.
              IF SCREEN-GROUP1 <> 'NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ELSE.
                screen-required = '1'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
          ENDIF.
          IF zmm_matblockhd_st-reqcl = 'IR'.
            IF g_tc120_wa-mstae = ''.
              screen-input = '0'.
              MODIFY SCREEN.
            ENDIF.
            IF screen-name    = 'G_TC120_WA-MATCODE'.
              screen-input = '0'.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
        ELSE.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
  WHEN 'DIS' OR 'DEL' OR 'REL'.
    LOOP AT SCREEN.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDLOOP.
  WHEN 'BLK'.
    LOOP AT SCREEN.
      IF g_tc120_wa-mstae = ''.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
        IF screen-name = 'G_TC120_WA-MARK'.
           screen-input = '1'.
           MODIFY SCREEN.
        ELSEIF screen-name = 'G_TC120_WA-MATDESC'.
          IF g_tc120_wa-mstae = 'NM'.
            screen-input = '0'.
            MODIFY SCREEN.
          ELSE.
            screen-input = '1'.
            MODIFY SCREEN.
          ENDIF.
        ELSEIF screen-name = 'G_TC120_WA-ERRCD'.
          IF g_tc120_wa-errcd = 'S'.
            screen-input = '0'.
            MODIFY SCREEN.
          ELSE.
            screen-input = '1'.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
      IF zmm_matblockhd_st-reqcl = 'C' OR
         zmm_matblockhd_st-reqcl = 'AC'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
ENDCASE.
ENDMODULE.                 " tct120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.

  SET PF-STATUS 'STAT105'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0105  OUTPUT
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
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).

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
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).

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
*&      Module  change_attr_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_attr_120 OUTPUT.
  IF g_mode <> 'BLK'.
*    LOOP AT SCREEN.
*      IF screen-name = 'T_SPCHK'.
*        screen-invisible = '1'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'TCT120_INSERT' OR
         screen-name = 'TCT120_DELETE'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " change_attr_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_attr_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_attr_110 OUTPUT.
  IF g_mode <> 'BLK'.
*    LOOP AT SCREEN.
*      IF screen-name = 'T_SPCH'.
*        screen-invisible = '1'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'TCT110_INSERT' OR
         screen-name = 'TCT110_DELETE'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " change_attr_110  OUTPUT

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE tct130_change_tc_attr OUTPUT.
  LOOP AT tct130-cols INTO col130 WHERE index EQ 20.
      col130-invisible = '1'.
      MODIFY tct130-cols FROM col130 INDEX sy-tabix.
  ENDLOOP.
  DESCRIBE TABLE g_tc130_itab LINES tct130-lines.
ENDMODULE.

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct130_get_lines OUTPUT.
  g_tct130_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  tct130_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct130_init OUTPUT.
 Data  : l_matgp130(2) type c.
  IF g_tct130_copied IS INITIAL.
    IF g_mode <> 'CRE'.
      SELECT * FROM zmm_matblock_dt
           INTO CORRESPONDING FIELDS
           OF TABLE g_tc130_itab
        WHERE reqno = zmm_matblockhd_st-reqno.
    ENDIF.
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if g_mode = 'BLK'.
      select single * from zmm_blkcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        select single * from zmm_blkcodifier
               where codifier = sy-uname.
        if sy-subrc = 0.
          if g_section = 'I'.
            delete g_tc130_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc130_itab where mstae = 'NM'.
          endif.
          loop at g_tc130_itab into g_tc130_wa.
            l_matgp130 = g_tc130_wa-matcode+0(2).
            select single * from zmm_blkcodifier
                 where codifier = sy-uname
                 and   matgp    = l_matgp130.
            if sy-subrc <> 0.
              delete g_TC130_itab index sy-tabix.
            endif.
            clear l_matgp130.
          endloop.
        endif.
      else.
        if g_section = 'I'.
            delete g_tc130_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc130_itab where mstae = 'NM'.
        endif.
      endif.
    endif.
****
    g_tct130_copied = 'X'.
    REFRESH CONTROL 'TCT130' FROM SCREEN '0130'.
  ENDIF.

ENDMODULE.                 " tct130_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_attr_130  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_attr_130 OUTPUT.
  IF g_mode <> 'BLK'.
*    LOOP AT SCREEN.
*      IF screen-name = 'T_SPCHC'.
*        screen-invisible = '1'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'TCT130_INSERT' OR
         screen-name = 'TCT130_DELETE'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " change_attr_130  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct130_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct130_move OUTPUT.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tc130_wa-matcode IS INITIAL.
      CLEAR: l_srno.
      IF g_tc130_wa-srno = 0.
        PERFORM get_nextsrno_cap.
        MOVE l_srno TO g_tc130_wa-srno.
        MODIFY g_tc130_itab FROM g_tc130_wa
        INDEX tct130-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.
  ENDIF.

***Plant Stock***********
  IF NOT g_tc130_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc130_wa-p_stock
      WHERE werks = zmm_matblockhd_st-werks
      AND   matnr = g_tc130_wa-matcode.
    MODIFY g_tc130_itab FROM g_tc130_wa
    INDEX tct130-current_line TRANSPORTING p_stock.
  ENDIF.
***ONGC Stock***********
  IF NOT g_tc130_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc130_wa-c_stock
    WHERE matnr = g_tc130_wa-matcode.

    MODIFY g_tc130_itab FROM g_tc130_wa
    INDEX tct130-current_line TRANSPORTING c_stock.
  ENDIF.


ENDMODULE.                 " tct130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct130_change_field_attr OUTPUT.
  CASE g_mode.
    WHEN 'CRE' OR 'CHA'.
      LOOP AT SCREEN.
        IF screen-name = 'G_TC130_WA-ERRCD'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF NOT zmm_matblockhd_st-werks IS INITIAL AND
           NOT zmm_matblockhd_st-tel IS INITIAL.
          IF NOT g_tc130_wa-matcode IS INITIAL.
            IF g_tc130_wa-mstae <> 'NM'.
              IF screen-name    = 'G_TC130_WA-MATDESC'.
                screen-required = '1'.
                MODIFY SCREEN.
              ELSEIF screen-name    = 'G_TC130_WA-MATCOST'.
                IF g_tc130_wa-omatcost IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-MAT_LIFE'.
                IF g_tc130_wa-omat_life IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-MATLOC'.
                IF g_tc130_wa-omatloc IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-MATGP'.
*                IF g_tc130_wa-omatgp IS INITIAL.
                  screen-input      = '0'.
                  MODIFY SCREEN.
*                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-MATCATG'.
                IF g_tc130_wa-omatcatg IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-RES_NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ELSE.
              IF SCREEN-GROUP1 <> 'NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ELSE.
                screen-required = '1'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
            IF zmm_matblockhd_st-reqcl = 'IR'.
              IF g_tc130_wa-mstae = ''.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
              IF screen-name    = 'G_TC130_WA-MATCODE'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'DIS' OR 'DEL' OR 'REL'.
      LOOP AT SCREEN.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN 'BLK'.
      LOOP AT SCREEN.
        IF g_tc130_wa-mstae = ''.
          screen-input = '0'.
          MODIFY SCREEN.
        ELSE.
          IF screen-name = 'G_TC130_WA-MARK'.
             screen-input = '1'.
             MODIFY SCREEN.
          ELSEIF screen-name = 'G_TC130_WA-MATDESC'.
            IF g_tc130_wa-mstae = 'NM'.
              screen-input = '0'.
              MODIFY SCREEN.
            ELSE.
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC130_WA-ERRCD'.
            IF g_tc130_wa-errcd = 'S'.
              screen-input = '0'.
              MODIFY SCREEN.
            ELSE.
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name    = 'G_TC130_WA-MATGP'.
            IF g_tc130_wa-omatgp IS INITIAL.
              IF g_tc130_wa-mstae = 'NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ELSE.
                screen-required = '1'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
          ELSEIF screen-name = 'G_TC130_WA-MATCODE'.
            IF NOT g_tc130_wa-matcode IS INITIAL.
              screen-input = '0'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC130_WA-RES_NM' OR
                 screen-name = 'G_TC130_WA-MATCOST' OR
                 screen-name = 'G_TC130_WA-MAT_LIFE' OR
                 screen-name = 'G_TC130_WA-MATLOC' OR
                 screen-name = 'G_TC130_WA-MATCATG'.
            screen-input = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF zmm_matblockhd_st-reqcl = 'C' OR
           zmm_matblockhd_st-reqcl = 'AC'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " tct130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
  SET PF-STATUS 'STAT_REL'.
ENDMODULE.                 " STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  WRITE_CERTIFICATE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE write_certificate OUTPUT.
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

ENDMODULE.                 " WRITE_CERTIFICATE  OUTPUT
