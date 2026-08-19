*--- MAIN PROGRAM: MZFIPREPROLE1_PHASEIII01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZFIPREPROLEI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  okcode = sy-ucomm.

  CASE okcode.

    WHEN 'BAC' OR 'CAN'.

      PERFORM bac_confirm.
*      refresh control 'TABCTRL100' from screen '0100'.
      CLEAR okcode.
      LEAVE PROGRAM.

    WHEN 'CREATE'.

      g_mode = 'CRE'.
      CLEAR okcode.

    WHEN 'CHANGE'.

      g_mode = 'CHA'.
      CLEAR okcode.

    WHEN 'DISPLAY'.

      g_mode = 'DIS'.
      CLEAR okcode.

    WHEN 'DELETE'.

      g_mode = 'DEL'.
      CLEAR okcode.

    WHEN 'SAVE'.

*        perform check_items.
*        Perform Check_dupl_rec1.
      .
*        Perform Save_request.

      CLEAR okcode.

    WHEN 'RELEASE'.

      g_mode = 'REL'.
      CLEAR okcode.

    WHEN 'APPROVE'.

      g_mode = 'APR'.
      CLEAR okcode.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_glac INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-gl_account' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  DATA  :  ist_return_tab LIKE STANDARD TABLE OF ddshretval
                                               WITH  HEADER LINE.
  TYPES :
    BEGIN OF ty_saknr,
      saknr LIKE skb1-saknr,
      stext LIKE skb1-stext,
    END OF ty_saknr.

  DATA   : it_saknr TYPE TABLE OF ty_saknr WITH HEADER LINE.

  SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF     "#EC CI_DB_OPERATION_OK[2431747]
             TABLE it_saknr  WHERE bukrs =  zic_prep_rolereq-ccode.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SAKNR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-GL_ACCOUNT'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_saknr
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_saknr,ist_return_tab.
  FREE : it_saknr,ist_return_tab.

ENDMODULE.                 " POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_grp INPUT.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000'  zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
             d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c    " Bipin + 02/08/2016
                ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1. "#EC CI_NOORDER
      g_ccode = ist_data-bukrs.
    ENDIF.

*SELECT single *
*       FROM pa0027
*       INTO wa_pa0027
*       WHERE pernr = cpf_lfb1 AND
*             endda = '99991231' AND
*             sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*G_CCODE = wa_pa0027-kbu01+0(3).

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-GRP' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : l_ekgrp LIKE t024-ekgrp.
  REFRESH : it_cond.
  CONCATENATE 'EKGRP'  'LIKE'  INTO g_line1  SEPARATED BY
  space.
  IF g_ccode = 'SBS' OR g_ccode = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
*  IF G_CCODE = 'JOR'.
  IF g_ccode = 'DVP'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'BDA' OR g_ccode = 'BDW'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF g_ccode = 'KKL'.
    g_select = 'M%'.
    g_select_flag = 'X'.

    CONCATENATE g_line1+0(10)  '''' g_select '''' INTO g_line1 .
    APPEND g_line1 TO it_cond.
    SELECT * FROM t024 INTO TABLE it_t024 WHERE (it_cond).
    REFRESH it_cond.
    g_select = 'V%'.
    CONCATENATE  g_line1+0(10)  '''' g_select '''' INTO g_line1.
    APPEND g_line1 TO it_cond.
    SELECT * FROM t024 INTO TABLE it_t024_1 WHERE (it_cond).
    REFRESH it_cond.
    APPEND LINES OF it_t024_1 TO it_t024.
    REFRESH it_t024_1.

  ENDIF.
*
  IF g_ccode <> 'KKL'.
    REFRESH it_cond.
    CONCATENATE  g_line1+0(10)  '''' g_select '''' INTO g_line1.
    APPEND g_line1 TO it_cond.
    SELECT * FROM t024 INTO TABLE it_t024 WHERE (it_cond).
    REFRESH it_cond.
  ENDIF.

  IF g_select_flag <> 'X'.
    SELECT * FROM t024 INTO TABLE it_t024 WHERE
            ( ekgrp NOT BETWEEN 'A' AND 'EZZ' ) AND
            ( ekgrp NOT BETWEEN 'K' AND 'MZZ' ) AND
            ( ekgrp NOT BETWEEN 'G' AND 'GZZ' ) AND
            ( ekgrp NOT BETWEEN 'R' AND 'TZZ' ) AND
            ( ekgrp NOT BETWEEN 'V' AND 'WZZ' ).
  ENDIF.

  DATA : loop_step LIKE sy-stepl.
  DATA : l_role_name LIKE zic_prep_rolerei-role_name.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_role_name.

  IF l_role_name = 'M6' OR  l_role_name = 'M7' OR
      l_role_name = 'M8'.

  ELSE.

    IF  zic_prep_rolereq-disc_mm_flag <> 'X'.

      LOOP AT it_t024 INTO wa_t024.

        l_ekgrp = wa_t024-ekgrp.

        IF l_ekgrp+1(1) BETWEEN '0' AND 'A'.
          DELETE it_t024.
        ENDIF.

      ENDLOOP.


    ELSE.

      LOOP AT it_t024 INTO wa_t024.

        l_ekgrp = wa_t024-ekgrp.

        IF l_ekgrp+1(1) < '0'  OR
        l_ekgrp+1(1) > 'A'.
          DELETE it_t024.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'T024'.
  g_field_wa-fieldname = 'EKGRP'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T024'.
  g_field_wa-fieldname = 'EKNAM'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-GRP'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_t024
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_t024,ist_return_tab, g_field_tab.
  FREE : it_t024,ist_return_tab, g_field_tab.
  CLEAR g_field_wa.

ENDMODULE.                 " POV_GRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  TYPES : BEGIN OF z_role_des,
            role_type        LIKE zfi_prep_roledes-role_type,
            brief_desc       LIKE zfi_prep_roledes-brief_desc,
            detail_desc1     LIKE zfi_prep_roledes-detail_desc1,
            detail_desc2     LIKE zfi_prep_roledes-detail_desc2,
            sort_field       LIKE zfi_prep_roledes-brief_desc,
            role_sensitivity LIKE zfi_prep_roledes-role_sensitivity,
*            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
          END OF z_role_des.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : it_role TYPE TABLE OF z_role_des WITH HEADER LINE.

  IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'.

    SELECT * FROM zmm_prep_rolecrc INTO CORRESPONDING FIELDS OF
               TABLE it_role.

  ELSE.

    SELECT * FROM zfi_prep_roledes INTO CORRESPONDING FIELDS OF
               TABLE it_role.

  ENDIF.

  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_header_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_header_data INPUT.

  IF old_ok_code = 'DISPLAY' OR old_ok_code = 'CHANGE' OR
        old_ok_code = 'DELETE' OR old_ok_code = 'CREATE' OR
        old_ok_code = 'ROLE_DEL' OR
        old_ok_code = 'CROSSCO' OR ( old_ok_code = 'CRCROLES' )
        OR old_ok_code = 'RELEASE' OR ( old_ok_code = 'APPROVE' ).

    IF NOT  zic_prep_rolereq-userid IS INITIAL.
      PERFORM check_tel.
    ENDIF.

    IF old_ok_code = 'CREATE' OR old_ok_code = 'ROLE_DEL'.

      IF  zic_prep_rolereq-persa IS INITIAL AND
          zic_prep_rolereq-rsn_code = '01'.
        PERFORM pop_up_message.
      ENDIF.

      IF  zic_prep_rolereq-userid IS INITIAL.
        MESSAGE e035(zhelp).
      ENDIF.

      IF  zic_prep_rolereq-userid <> old_userid AND
        old_userid <> ''.
        CLEAR  zic_prep_rolereq-disc_fi_flag.
        CLEAR  zic_prep_rolereq-ccode.
        CLEAR  zic_prep_rolereq-fundc1.
        CLEAR  zic_prep_rolereq-fundc.
        CLEAR  zic_prep_rolereq-s_desc.
        CLEAR  zic_prep_rolereq-rsn_code.
        CLEAR  zic_prep_rolereq-rsn_text1.
        CLEAR  zic_prep_rolereq-reason1.
        CLEAR  zic_prep_rolereq-telno.
        CLEAR  zic_prep_rolereq-name.
        CLEAR  zic_prep_rolereq-designation.
        CLEAR set_disc_fi_flag.
        CLEAR help_list_flag.
        REFRESH it_m_fistb.
        CLEAR wa_m_fistb.
      ENDIF.

*        select single * from zusrmst where cpfno =
*                                    ZIC_PREP_ROLEREQ-userid.

      SELECT SINGLE * FROM usr02 WHERE bname =
                                  zic_prep_rolereq-userid.

      IF sy-subrc NE 0.
        MESSAGE e043(zhelp).
      ELSE.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-name = zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-designation = zusrmst-designation.

        SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text AS designation d~adesig_text AS adesignation
           d~disc_cd AS disc_cd
             INTO CORRESPONDING FIELDS OF TABLE ist_data
        FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c   " Bipin + 02/08/2016
              ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                 ON c~designo = d~desig_code AND
                     c~r_p_cd  = d~r_p_cd AND
                     c~version = d~version )
                  WHERE a~pernr =  zic_prep_rolereq-userid AND
                        a~sprps = ' ' AND
                        a~endda = '99991231' AND
                        c~sprps = ' ' AND
                        c~endda = '99991231' .

        IF sy-subrc = 0.
          READ TABLE ist_data INDEX 1. "#EC CI_NOORDER
          zic_prep_rolereq-name = ist_data-name.
          zic_prep_rolereq-designation = ist_data-designation.
          zic_prep_rolereq-desig_level = ist_data-persk.
          IF ist_data-disc_cd = '13' AND set_disc_fi_flag <> 'X'.
            zic_prep_rolereq-disc_fi_flag = 'X'.
            set_disc_fi_flag = 'X'.
          ENDIF.
***************************************************31.05.2006
          IF old_ok_code = 'CREATE' OR old_ok_code = 'CRCROLES'.
            zic_prep_rolereq-ccode = ist_data-bukrs.
          ELSE.
            g_ccode_crossco        = ist_data-bukrs.
          ENDIF.

***************************************************31.05.2006
*            if ist_data-disc_cd = '36' and
*             ZIC_PREP_ROLEREQ-disc_mm_flag <> old_disc_mm_flag.
*                 ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*            endif.

          IF old_ok_code = 'CREATE'.
            IF  zic_prep_rolereq-persa <> ist_data-werks AND
               NOT  zic_prep_rolereq-persa IS INITIAL.
              MESSAGE e108(zhelp).
            ENDIF.
          ENDIF.

        ENDIF.

        CLEAR : ist_data.
        REFRESH : ist_data.

** Change company code, fund centre, costcentre logic 02.02.2006


        CONCATENATE '000'  zic_prep_rolereq-userid INTO cpf_lfb1.

*          select single * from lfb1 where lifnr = cpf_lfb1.

* Select Company-KBU01, Cost Centre-kst01
* from pa0027  .
        CLEAR wa_pa0027.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*        SELECT SINGLE *
*           FROM pa0027
*           INTO wa_pa0027
*           WHERE pernr = cpf_lfb1 AND
*                 endda = '99991231' AND
*                 sprps = ' ' . " SPRPS - Lock Indicator 'X'
        SELECT *
           FROM pa0027 UP TO 1 ROWS
           INTO wa_pa0027
           WHERE pernr = cpf_lfb1 AND
                 endda = '99991231' AND
                 sprps = ' ' ORDER BY PRIMARY KEY.ENDSELECT. " SPRPS - Lock Indicator 'X'
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
        IF sy-subrc = 0.
          IF old_ok_code <> 'CROSSCO'.
            CONCATENATE  '''' '%' wa_pa0027-kst01
                         '''' INTO  g_line1.
            CONCATENATE  'OBJNR'  'LIKE' g_line1 INTO g_line1
            SEPARATED BY space.
            REFRESH :  it_cond.
            APPEND g_line1 TO it_cond.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*            SELECT SINGLE * FROM fmzuob WHERE (it_cond).
            SELECT * FROM fmzuob UP TO 1 ROWS WHERE (it_cond) ORDER BY PRIMARY KEY. ENDSELECT.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
          ENDIF.
          IF sy-subrc = 0.
            IF old_ok_code = 'CREATE' OR old_ok_code = 'CRCROLES'.
              zic_prep_rolereq-fundc1 = fmzuob-fistl.
              zic_prep_rolereq-fundc_fl = 'X'.
*               ZIC_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
              zic_prep_rolereq-costc = wa_pa0027-kst01.
            ELSE.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
              zic_prep_rolereq-costc = wa_pa0027-kst01.
            ENDIF.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*            SELECT SINGLE * FROM cskt WHERE
*                          kostl =  zic_prep_rolereq-costc.
            SELECT * FROM cskt UP TO 1 rows WHERE
                          kostl =  zic_prep_rolereq-costc ORDER BY PRIMARY KEY.ENDSELECT.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
            IF sy-subrc =  0.
              zic_prep_rolereq-s_desc = cskt-ltext.
            ENDIF.

            REFRESH it_cond[].
            CLEAR it_cond.
          ELSE.
          ENDIF.
        ENDIF.

      ENDIF.

    ELSE.

***************************************************

***************************************************

      IF  zic_prep_rolereq-docno IS INITIAL.
        MESSAGE e041(zhelp).
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

  IF sy-tcode = 'ZIC_AUTH_FI_REP'.

    IF okcode = 'DBLCLK'.

      CALL TRANSACTION 'ZROLE_REQ2_COPY' AND SKIP FIRST SCREEN.

    ENDIF.

    CASE okcode_100.

      WHEN 'BAC' OR 'CAN'.

        PERFORM exit_confirm.
      WHEN 'EXT'.
        LEAVE PROGRAM.

      WHEN 'ROLE_CR'.

        IF l_del_request <> 'X'.
          IF zic_prep_rolereq-status = 'C'.
            MESSAGE e086(zhelp).
          ELSE.
            CASE moduleid.
              WHEN 'FI'.
                PERFORM create_roles.
                SET PARAMETER ID 'FI' FIELD moduleid.
            ENDCASE.

          ENDIF.
        ELSE.

        ENDIF.


      WHEN 'SUIM'.

        CALL SCREEN 120.
        IF okcode_100 = 'BAC'.
          CLEAR old_ok_code.
        ENDIF.

      WHEN  'DISROLE'.

        IF zic_prep_rolereq-userid = ' ' .
          MESSAGE i146(zhelp).
          SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-userid'.
        ENDIF.

        CALL SCREEN 210 STARTING AT 10 15  ENDING AT 90 25.

      WHEN 'CORR'.

        CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
        IF g_clines <> 0.
          corr_code = okcode_100.
        ENDIF.

        CLEAR okcode_100.
        g_reset_change = 'X'.

      WHEN 'ROLE_DEL'.

        REFRESH : ist_seltab.
        CLEAR   : seltab.

        seltab-selname = 'P_REM'.
        seltab-sign    = 'I'.
        seltab-option = 'EQ'.
*        concatenate zic_prep_rolereq-docno ' -' into seltab-low.
        MOVE zic_prep_rolereq-docno  TO seltab-low.
*          seltab-low   = p_docno.
        APPEND seltab TO ist_seltab.

        seltab-selname = 'P_REM1'.
        seltab-sign    = 'I'.
        seltab-option = 'EQ'.
*          concatenate zmm_prep_rolereq-docno ' -' into seltab-low.
        seltab-low   = zic_prep_rolereq-userid.
        APPEND seltab TO ist_seltab.

        IF zic_prep_rolereq-status = 'C' OR
           zic_prep_rolereq-status = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'..
          MESSAGE e121(zhelp).

        ELSE.

          SUBMIT zhelprole3 WITH SELECTION-TABLE ist_seltab AND RETURN.

          GET PARAMETER ID 'ZROLEREQNO' FIELD zrolereqno.

          GET PARAMETER ID 'EXIT_VALUE' FIELD g_exit_value.

          IF NOT zrolereqno IS INITIAL AND zrolereqno <> '00000000' AND
            g_exit_value <> 'X'.
            SUBMIT zbc_role_rep01_rfc_del AND RETURN.
*
            SET PARAMETER ID 'ZROLEREQNO' FIELD ''.
            CLEAR zrolereqno.
*            perform send_sapmail.
          ELSE.
            SET PARAMETER ID 'EXIT_VALUE' FIELD ''.
            CLEAR g_exit_value.
          ENDIF.

        ENDIF.

        CLEAR sy-ucomm.

      WHEN 'DEL_ROLE'.

        REFRESH : ist_seltab.
        CLEAR   : seltab.

        seltab-selname = 'P_REM'.
        seltab-sign    = 'I'.
        seltab-option = 'EQ'.
*        concatenate zic_prep_rolereq-docno ' -' into seltab-low.
        MOVE zic_prep_rolereq-docno  TO seltab-low.
*          seltab-low   = p_docno.
        APPEND seltab TO ist_seltab.

        seltab-selname = 'P_REM1'.
        seltab-sign    = 'I'.
        seltab-option = 'EQ'.
*          concatenate zmm_prep_rolereq-docno ' -' into seltab-low.
        seltab-low   = zic_prep_rolereq-userid.
        APPEND seltab TO ist_seltab.

        IF zic_prep_rolereq-status = 'C' OR
           zic_prep_rolereq-status = 'IC'.
          MESSAGE e121(zhelp).

        ELSE.

          SUBMIT zhelprole3 WITH SELECTION-TABLE ist_seltab AND RETURN.

          GET PARAMETER ID 'ZROLEREQNO' FIELD zrolereqno.

          GET PARAMETER ID 'EXIT_VALUE' FIELD g_exit_value.

          IF NOT zrolereqno IS INITIAL AND zrolereqno <> '00000000' AND
            g_exit_value <> 'X'.
            SUBMIT zbc_role_rep01_rfc_del AND RETURN.
*
            IF NOT zrolereqno IS INITIAL.
              SET PARAMETER ID 'ZROLEREQNO' FIELD ''.
              CLEAR zrolereqno.
              zic_prep_rolereq-status = 'C'.
              MODIFY zic_prep_rolereq FROM zic_prep_rolereq.
              PERFORM send_sapmail1.
            ELSE.
              SET PARAMETER ID 'EXIT_VALUE' FIELD ''.
              CLEAR g_exit_value.
            ENDIF.

          ENDIF.

        ENDIF.

        CLEAR sy-ucomm.


      WHEN 'MAIL'.

        PERFORM confirm_mail.

      WHEN 'POSTING'.

        CALL TRANSACTION 'ZMMUSERDATA' AND SKIP FIRST SCREEN.

      WHEN 'STAT_MOD'.

        SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                    FIELD zic_prep_rolereq-docno.

        CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.

      WHEN 'SUMMARY'.

        SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                    FIELD zic_prep_rolereq-docno.

        CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.

      WHEN 'LIST'.

        PERFORM list_files.
        IF zic_prep_rolereq-status = 'C' OR
           zic_prep_rolereq-status = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'.
          old_ok_code = 'DISPLAY'.
        ELSE.
          old_ok_code = 'CHANGE'.
        ENDIF.
        g_reset_change = 'X'.


      WHEN 'ATTACH'.

        PERFORM attach_files.
        IF zic_prep_rolereq-status = 'C' OR
           zic_prep_rolereq-status = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'.
          old_ok_code = 'DISPLAY'.
        ELSE.
          old_ok_code = 'CHANGE'.
        ENDIF.
        g_reset_change = 'X'.

      WHEN 'SAV'.

        IF old_ok_code = 'DELETE'.

          IF  zic_prep_rolereq-useridcr = sy-uname.

*            if  ZIC_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

            IF sy-ucomm = 'BAC'.
              PERFORM exit_confirm.
            ENDIF.
            IF  zic_prep_rolereq-status = ''.
              PERFORM delete_request.
            ELSE.
              MESSAGE e138(zhelp).
            ENDIF.
          ELSE.
            MESSAGE e056(zhelp).
          ENDIF.

        ELSE.
          IF old_ok_code = 'RELEASE' AND
                 zic_prep_rolereq-req_cr_fl <> 'X'.
            MESSAGE i083(zhelp).

          ELSEIF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
            MESSAGE i089(zhelp).

          ELSEIF old_ok_code = 'APPROVE' AND
                (  zic_prep_rolereq-req_appfi_fl <> 'X' ).
            MESSAGE i087(zhelp).
          ELSE.

            PERFORM save_request.

          ENDIF.
**       endif.
        ENDIF.

      WHEN OTHERS.

        CLEAR okcode_100.

    ENDCASE.

  ELSE. " If not through tcode 'ZIC_AUTH_FI_REP
    CASE okcode_100.

      WHEN 'BAC' OR 'CAN'.

        PERFORM exit_confirm.
      WHEN 'EXT'.
        LEAVE PROGRAM.

      WHEN 'CREATE'.

        old_ok_code = okcode_100.

      WHEN  'ROLE_DEL'.
        old_ok_code = okcode_100.

      WHEN 'CHANGE'.

        old_ok_code = okcode_100.

      WHEN 'RELEASE'.

        old_ok_code = okcode_100.


      WHEN 'APPROVE'.

        old_ok_code = okcode_100.

      WHEN 'COPY'.


      WHEN 'DISPLAY'.

        old_ok_code = okcode_100.

      WHEN 'SAV'.

************* Start of changes : changes by Bipin Shukla (SAB_BIPIN ) on 27/11/2013
*        IF OLD_OK_CODE = 'CREATE'.
*
*          CLEAR GT_FI_USR[].
*
*          SELECT * FROM AGR_USERS INTO CORRESPONDING FIELDS OF TABLE GT_FI_USR
*            WHERE AGR_NAME = 'M:COMMON_USER_TOOLS' AND
*                  UNAME = ZIC_PREP_ROLEREQ-USERID.
*
*          IF GT_FI_USR[] IS INITIAL.
*
*            MESSAGE 'You are not authorized to created the request for the user.' TYPE 'E'.
*
*          ENDIF.
*
*        ENDIF.
************* Start of changes : changes by Bipin Shukla (SAB_BIPIN ) on 27/11/2013
        IF old_ok_code = 'DELETE'.

          IF  zic_prep_rolereq-useridcr = sy-uname.

*            if  ZIC_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

            IF sy-ucomm = 'BAC'.
              PERFORM exit_confirm.
            ENDIF.
            IF  zic_prep_rolereq-status = ''.
              PERFORM delete_request.
            ELSE.
              MESSAGE e138(zhelp).
            ENDIF.
          ELSE.
            MESSAGE e056(zhelp).
          ENDIF.

        ELSE.

********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT

          IF old_ok_code = 'APPROVE' AND
                (  zic_prep_rolereq-req_appfi_fl <> 'X' ).
            MESSAGE i087(zhelp).
*            ENDIF.
          ELSE.
            SELECT * FROM zgrc_sod_result INTO CORRESPONDING FIELDS OF TABLE gt_risk WHERE docno = zic_prep_rolereq-docno.
            IF gt_risk[] IS NOT INITIAL.
              DESCRIBE TABLE gt_risk LINES lv_rcount.
            ENDIF.
            SELECT * FROM zgrc_log INTO CORRESPONDING FIELDS OF TABLE gt_log WHERE docno = zic_prep_rolereq-docno.
            IF gt_log[] IS NOT INITIAL.
              READ TABLE gt_log INTO wa_log WITH KEY docno = zic_prep_rolereq-docno.
            ENDIF.

            IMPORT gt_text FROM MEMORY ID 'TABLE1'.
            IMPORT zice_comment FROM MEMORY ID 'ZICE_IM'.   "ZICE_EX  26022015

*            DESCRIBE TABLE GT_RISK LINES LV_RCOUNT.
********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT

*            IF OLD_OK_CODE = 'APPROVE' AND GT_TEXT IS INITIAL AND ZICE_EX NOT BETWEEN '1' AND '4'.
            IF old_ok_code = 'APPROVE' AND wa_log-app_fl_app NE 'A'.

              CLEAR gt_bucket[].
              LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

                MOVE-CORRESPONDING g_tablctrl111_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.

              ENDLOOP.

              DELETE gt_bucket WHERE rej_fl = 'H'.

              IF gt_bucket IS NOT INITIAL.

                IF lv_rcount GT 1.
*            IF GT_TEXT IS NOT INITIAL AND OLD_OK_CODE = 'APPROVE'. " BIPIN
                  CLEAR : it_tvarv.
                  SELECT * FROM tvarvc INTO CORRESPONDING FIELDS OF TABLE it_tvarv
                  WHERE name = 'ZGRC_CALL'.
                  IF it_tvarv[] IS NOT INITIAL.
                    READ TABLE it_tvarv INTO wa_tvarv WITH KEY name = 'ZGRC_CALL'.
                  ENDIF.
                  IF wa_tvarv-low IS NOT INITIAL.
                    lv_grccall = wa_tvarv-low.
                  ENDIF.

                  IF syst-sysid = 'RD1'.

                    lv_rfc_1 = 'GRDCLNT500'.

                  ELSEIF syst-sysid = 'RQ1'.

                    lv_rfc_1 = 'GRDCLNT500'.

                  ELSEIF syst-sysid = 'RP1'.

                    lv_rfc_1 = 'GRPCLNT500'.
                  ENDIF.

                  CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
                    EXPORTING
                      rfcdestination = lv_rfc_1 "'GRDCLNT500'
                    IMPORTING
                      rfc_subrc      = lv_subrc.

                  IF  lv_grccall = 'X' AND lv_subrc = '0'.
                    MESSAGE i232(zhelp) WITH zic_prep_rolereq-docno.
                    reqnum_ex = zic_prep_rolereq-docno.
                    EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.

                    PERFORM grc_risk_analysis.
                    IMPORT gt_rdesc FROM MEMORY ID 'IM_GT_RDESC'.

*                  IF GT_BUCKET1[] IS NOT INITIAL.
                    CALL TRANSACTION 'ZGRC_RESULT'.
*                  ENDIF.
*                  MESSAGE 'No risk found!!' TYPE 'I'.
*                ENDIF.
                    IMPORT oc_9001_rj FROM MEMORY ID 'OC_9001_IM'.
                    IF oc_9001_rj = 'REJECT'.
                      LEAVE PROGRAM.
                    ENDIF.

                    CLEAR reqnum_ex.
                    CLEAR oc_9001_rj.

                  ENDIF.

                ENDIF.
              ELSE.
                MESSAGE 'ALL ROLE REJECTED BY HOF' TYPE 'I'.
              ENDIF.
            ENDIF.

*            IF OLD_OK_CODE = 'RELEASE'.                   " 26022015
            DESCRIBE TABLE gt_risk LINES lv_risk.
*              IF LV_RISK EQ 1.
*                ZICE_EX = '6'.
*              ENDIF.
*            ENDIF.

            IF old_ok_code = 'RELEASE' AND
                   zic_prep_rolereq-req_cr_fl <> 'X'.
              MESSAGE i083(zhelp).

********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT


            ELSEIF old_ok_code = 'RELEASE' AND
*                    GT_RISK IS NOT INITIAL AND    "27022015
                    lv_risk > 1            AND
                    gt_text IS INITIAL     AND
*              ( ZICE_EX eq '6' or ZICE_EX eq '7' or ZICE_EX eq '8' or ZICE_EX eq '9' or
*                  ZICE_EX eq'2' or ZICE_EX eq '3') .
* Begin of <> 26022015
*                ( ZICE_EX NOT BETWEEN '6' AND '10' and
*                 ZICE_EX NOT BETWEEN '2' AND '3'). "AND LV_GRCCALL = 'X' AND LV_SUBRC = '0'.
                  zice_comment IS INITIAL.
* End of <> 26022015
*              MESSAGE S233(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
              MESSAGE e234(zhelp) WITH zic_prep_rolereq-docno.

********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT


            ELSEIF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
              MESSAGE i089(zhelp).

*          ELSEIF OLD_OK_CODE = 'APPROVE' AND
*                (  ZIC_PREP_ROLEREQ-REQ_APPFI_FL <> 'X' ).
*            MESSAGE I087(ZHELP).

**************************** Start changes : Changes by Bipin Shukla on 24 july 2013
            ELSE.
*          Perform check_items.
*          if moduleid <> 'MM'.
*            g_approver_level = 'L3'.
*          endif.

********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT
              IF old_ok_code = 'RELEASE' AND g_lines_rl NE 0 . "AND GT_TEXT IS  NOT INITIAL.
                FREE MEMORY ID 'TABLE1'."+ by vikas
                FREE MEMORY ID 'ZICE_IM'.
              ENDIF.

              IMPORT oc_9001_rj FROM MEMORY ID 'OC_9001_IM'.
              IMPORT oc_9002_rj FROM MEMORY ID 'OC_9002_IM'.
              IMPORT oc_9003_rj FROM MEMORY ID 'OC_9003_IM'.
              IMPORT lv_expo FROM MEMORY ID 'LV_IMP'.

              IF oc_9001_rj = 'SUBMIT' OR oc_9002_rj = 'SUBMIT' OR oc_9003_rj = 'SUBMIT'
                 OR old_ok_code = 'CHANGE' OR old_ok_code = 'CREATE' OR lv_rcount EQ '1' OR lv_rcount EQ '0'.
                CLEAR lv_expo.
              ENDIF.
              CLEAR oc_9001_rj.

********************************End of changes : Changes by Bipin Shukla on 24 july 2013
*            BREAK-POINT.
              IF lv_expo = ''. " ADDED BY BIPIN
                PERFORM save_request.
              ENDIF.
              CLEAR lv_expo.     " ADDED BY BIPIN

            ENDIF.
**       endif.
          ENDIF.
        ENDIF. " +bIPIN



      WHEN 'MULTI'.

*      clear help_list_flag.

        CALL SCREEN 120 STARTING AT 10 5
                    ENDING   AT 90 15.
        CLEAR okcode_100.


      WHEN 'DELETE'.

        old_ok_code = okcode_100.

      WHEN 'ATTACH'.

        IF old_ok_code = 'CREATE' OR
           old_ok_code = 'CROSSCO' OR
           old_ok_code = 'CRCROLES'.
          MESSAGE i137(zhelp).
        ELSE.
          PERFORM attach_files.
        ENDIF.
*       old_ok_code = okcode_100.

      WHEN 'LIST'.

        PERFORM list_files.

*       old_ok_code = okcode_100.

      WHEN 'CORR'.

        CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
        CLEAR okcode_100.


      WHEN 'SUMMARY'.

        SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                    FIELD zic_prep_rolereq-docno.
*      call transaction 'ZIC_DETAILS' .

        CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.

      WHEN 'DISROLE'.
*            field zic_prep_rolereq-userid.
        IF zic_prep_rolereq-userid = ' ' .
          MESSAGE i146(zhelp).
          SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-userid'.
        ENDIF.

        CALL SCREEN 210 STARTING AT 10 15  ENDING AT 90 25.

      WHEN 'BAC'.

        CALL SCREEN 100.

      WHEN 'DELIMIT'.
        IF zic_prep_rolereq-userid = ' ' .
          MESSAGE i146(zhelp).
          SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-userid'.
        ENDIF.

        CALL SCREEN 211 STARTING AT 10 15  ENDING AT 90 25.

      WHEN OTHERS.

        CLEAR okcode_100.


    ENDCASE.
  ENDIF.

ENDMODULE.                 " user_command_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0120 INPUT.


ENDMODULE.                 " USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_ok_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_ok_code INPUT.

********************* Added by Bipin to export the value for ZGRC_RISK_NALYSIS_RESULT.
  okcode_rj = old_ok_code.
  crt_name = zic_prep_rolereq-useridcr.
  tcode_rj = sy-tcode.

  EXPORT okcode_rj TO MEMORY ID 'OKCODE_RJ'.
  EXPORT crt_name TO MEMORY ID 'CRT_NAME_RJ'.
  EXPORT tcode_rj TO MEMORY ID 'TCODE_IM'.
********************* Added by Bipin to export the value for ZGRC_RISK_NALYSIS_RESULT.


  IF sy-ucomm = 'DBLCLK'.
    CLEAR sy-ucomm.
  ENDIF.

  IF sy-ucomm = 'TABLCTRL111_INSR' AND  okcode_insert_line = 1.
    CLEAR sy-ucomm.
    okcode_insert_line = 0.
  ENDIF.

  okcode_100 = sy-ucomm.

  CLEAR :  err_flg.
********************** Start of changes : Bipin Shukla
  CASE okcode .

    WHEN 'GRC_RISK'.

      CLEAR gt_bucket_ex.

      LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

        MOVE-CORRESPONDING g_tablctrl111_wa TO wa_bucket_ex.
        APPEND wa_bucket_ex TO gt_bucket_ex.
        CLEAR wa_bucket_ex.

      ENDLOOP.

      EXPORT gt_bucket_ex TO MEMORY ID 'TABLE_IM'.
      CLEAR : it_tvarv.
      SELECT * FROM tvarvc INTO CORRESPONDING FIELDS OF TABLE it_tvarv
      WHERE name = 'ZGRC_CALL'.
      IF it_tvarv[] IS NOT INITIAL.
        READ TABLE it_tvarv INTO wa_tvarv WITH KEY name = 'ZGRC_CALL'.
      ENDIF.
      IF wa_tvarv-low IS NOT INITIAL.
        lv_grccall = wa_tvarv-low.
      ENDIF.
      IF syst-sysid = 'RD1'.

        lv_rfc_2 = 'GRDCLNT500'.

      ELSEIF syst-sysid = 'RQ1'.

        lv_rfc_2 = 'GRDCLNT500'.

      ELSEIF syst-sysid = 'RP1'.

        lv_rfc_2 = 'GRPCLNT500'.
      ENDIF.
      CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
        EXPORTING
          rfcdestination = lv_rfc_2 "'GRDCLNT500'
        IMPORTING
*         MSGV1          =
*         MSGV2          =
          rfc_subrc      = lv_subrc.
      IF  lv_grccall = 'X' AND lv_subrc = '0'.

        reqnum_ex = zic_prep_rolereq-docno.
        EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.
        okcode_ex = old_ok_code.
        EXPORT okcode_ex TO MEMORY ID 'OKCODE_IM'.
        CALL TRANSACTION 'ZGRC_RISK_RESULT'.

        IMPORT oc_9001_rj FROM MEMORY ID 'OC_9001_IM'.
        IF oc_9001_rj = 'REJECT'.
          LEAVE PROGRAM.
        ENDIF.

*        IMPORT LV_EXPO FROM MEMORY ID 'LV_IMP'.
*********************************End of changes : Changes by Bipin Shukla on 24 july 2013
*        IF LV_EXPO = ''. " ADDED BY BIPIN
*          PERFORM SAVE_REQUEST.
*        ENDIF.       " ADDED BY BIPIN

      ENDIF.
*      IF OLD_OK_CODE EQ 'CREATE' OR OLD_OK_CODE EQ 'CHANGE'.
*        LEAVE PROGRAM.
*      ENDIF.
      CLEAR reqnum_ex.
      CLEAR: okcode.
      CLEAR okcode_ex.

    WHEN 'GRC_RAL'.
      reqnum_ex = zic_prep_rolereq-docno.
      EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.
      okcode_ex = old_ok_code.
      EXPORT okcode_ex TO MEMORY ID 'OKCODE_IM'.
      CALL TRANSACTION 'ZGRC_SEC_RESULT'.

      CLEAR reqnum_ex.
      CLEAR okcode_ex.

    WHEN  'GRC_RPL'.
      reqnum_ex = zic_prep_rolereq-docno.
      EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.
      okcode_ex = old_ok_code.
      EXPORT okcode_ex TO MEMORY ID 'OKCODE_IM'.
      CALL TRANSACTION 'ZGRC_VIOL'.

      CLEAR reqnum_ex.
      CLEAR okcode_ex.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " move_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_data INPUT.

  IF NOT  zic_prep_rolereq-docno IS INITIAL.

*  data : l_docno like  ZIC_PREP_ROLEREQ-docno.

    l_docno =  zic_prep_rolereq-docno.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = l_docno
      IMPORTING
        output = l_docno.

    zic_prep_rolereq-docno = l_docno.

  ENDIF.

  IF old_doc_no <>  zic_prep_rolereq-docno.
    CLEAR g_hd_copied.
    CLEAR g_mult_module_fl.
    PERFORM destroy_ctrl.
  ENDIF.

  IF NOT moduleid IS INITIAL AND old_moduleid <> moduleid.
    g_tablctrl110_copied = ''.
    g_tablctrl111_copied = ''.
    g_tablctrl112_copied = ''.
    g_tablectrl_215_copied = ''.
  ENDIF.
*  clear l_del_request.
ENDMODULE.                 " clear_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_uebernehmen1 INPUT.

  gv_xthead_updkz = 0.

  CALL METHOD gv_text_editor1->get_text_as_stream
    IMPORTING
      text                   = lt_text_table1
      is_modified            = gv_xthead_updkz
    EXCEPTIONS
      error_dp               = 1
      error_cntl_call_method = 2
      OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      text_stream = lt_text_table1
      itf_text    = tlinetab1.
*
  IF ( old_ok_code = 'CREATE' )
  OR ( old_ok_code = 'CROSSCO' )
  OR ( old_ok_code = 'CRCROLES' )
  OR ( old_ok_code = 'CHANGE' )
  OR ( ok_code_assign = 'ASSIGN' )
  OR ( old_ok_code = 'RELEASE' )
  OR ( old_ok_code = 'APPROVE' )
   OR ( old_ok_code = 'DISPLAY' AND  zic_prep_rolereq-comm_fl = 'X'
        AND  zic_prep_rolereq-status <> 'C' ).

    CALL METHOD gv_text_editor2->get_text_as_stream
      IMPORTING
        text                   = lt_text_table2
        is_modified            = gv_xthead_updkz
      EXCEPTIONS
        error_dp               = 1
        error_cntl_call_method = 2
        OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
      TABLES
        text_stream = lt_text_table2
        itf_text    = tlinetab2.
    DESCRIBE TABLE tlinetab2 LINES g_lines_2.
  ENDIF..

ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.

  DATA: okcode105 LIKE sy-ucomm.

  okcode105 = sy-ucomm.

  CASE okcode105.
    WHEN 'OK'.
      DESCRIBE TABLE tlinetab2 LINES g_clines.
      CLEAR okcode105.
    WHEN 'CANCEL'.
      REFRESH tlinetab2[].
      CLEAR okcode105.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_sloc INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SLOC' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : l_plant LIKE zic_prep_rolerei-plant.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'PLANT'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_plant.


  DATA   : it_t001l TYPE TABLE OF t001l WITH HEADER LINE.
  DATA   : it_excp_sl TYPE TABLE OF zmm_prep_sl_excp WITH HEADER LINE.
  DATA   : wa_t001l LIKE t001l.
  DATA   : l_zarea LIKE zmm_consm-zarea.

  SELECT * FROM t001l INTO CORRESPONDING FIELDS OF
             TABLE it_t001l  WHERE werks = l_plant.

  IF  zic_prep_rolereq-disc_mm_flag = 'X'.

    LOOP AT it_t001l INTO wa_t001l.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc = 0.

        IF l_zarea+0(1) <> 'M'.
          DELETE it_t001l.
        ENDIF.

      ELSE.

        DELETE it_t001l.

      ENDIF.

    ENDLOOP.

  ELSE.

    LOOP AT it_t001l INTO wa_t001l.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc = 0.

        IF l_zarea+0(1) = 'M'.
          DELETE it_t001l.
        ENDIF.

      ELSE.

        DELETE it_t001l.

      ENDIF.

    ENDLOOP.

  ENDIF.

  SELECT * FROM zmm_prep_sl_excp INTO TABLE it_excp_sl.

************************************

  LOOP AT it_excp_sl.

    READ TABLE it_t001l WITH KEY werks = it_excp_sl-werks
    lgort = it_excp_sl-lgort.

    IF sy-subrc = 0.

      DELETE it_t001l WHERE werks = it_excp_sl-werks
      AND lgort = it_excp_sl-lgort.

    ENDIF.

  ENDLOOP.

************************************
  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'WERKS'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGORT'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGOBE'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LGORT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SLOC'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_t001l
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_t001l,ist_return_tab,g_field_tab..
  FREE  : it_t001l,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_approver INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-APPROVER' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : it_approver LIKE TABLE OF zmm_prep_approve.
  DATA : wa_approver LIKE zmm_prep_approve.

  DATA : it_approver1 LIKE TABLE OF zmm_prep_app_crc.
  DATA : wa_approver1 LIKE zmm_prep_app_crc.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_role_name.

  IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'.

    SELECT * FROM zmm_prep_app_crc INTO TABLE it_approver1.

  ELSE.

    SELECT * FROM zmm_prep_approve INTO TABLE it_approver.

  ENDIF.


*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*
*
*              if l_role_name = 'M11'.
*
*                  loop at it_approver into wa_approver.
*
*                    if wa_approver-M11_FLAG <> 'X'.
*                      delete it_approver.
*                    endif.
*
*                  endloop.
*
*              endif.
*
*      endif.


*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*         if l_role_name = 'M11'.
*
*            loop at it_approver into wa_approver.
*
*                if wa_approver-M11_FLAG <> 'X'.
*                    delete it_approver.
*                 endif.
*
*            endloop.
*
*         endif.
*
*      endif.
*******************************************************
  IF l_role_name = 'M11S'.                                  "22.05.06

    LOOP AT it_approver INTO wa_approver.

      CASE  zic_prep_rolereq-disc_mm_flag.

        WHEN 'X'.
          IF wa_approver-mm_flag <> 'X'.
            DELETE it_approver.
          ENDIF.
        WHEN OTHERS.
          IF wa_approver-m11s_flag <> 'X'.
            DELETE it_approver.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.

  IF l_role_name = 'M11M'.

    LOOP AT it_approver INTO wa_approver.

      CASE  zic_prep_rolereq-disc_mm_flag.

        WHEN 'X'.
          IF wa_approver-mm_flag <> 'X'
             OR wa_approver-m11m_flag <> 'X'.
            DELETE it_approver.
          ENDIF.
        WHEN OTHERS.
          IF wa_approver-mm_flag = 'X'
             OR wa_approver-m11m_flag <> 'X'.
            DELETE it_approver.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.
**************************************************22.05.06

  IF l_role_name = 'M8'.

    LOOP AT it_approver INTO wa_approver.

      IF wa_approver-m8_flag <> 'X'.
        DELETE it_approver.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'..

    IF l_role_name = 'M3'.

      LOOP AT it_approver1 INTO wa_approver1.

        IF wa_approver1-m3_flag <> 'X'.
          DELETE it_approver1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF l_role_name = 'M3A'.                                 "22.05.06

      LOOP AT it_approver1 INTO wa_approver1.

        IF wa_approver1-m3a_flag <> 'X'.
          DELETE it_approver1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF l_role_name = 'M3B'.

      LOOP AT it_approver1 INTO wa_approver1.

        IF wa_approver1-m3b_flag <> 'X'.
          DELETE it_approver1.
        ENDIF.

      ENDLOOP.

    ENDIF.                                                  " 22.05.06


    IF l_role_name = 'M11S'.

      LOOP AT it_approver1 INTO wa_approver1.

*                    if wa_approver1-M11S_FLAG <> 'X'.
*                        delete it_approver1.
*                    endif.
        CASE  zic_prep_rolereq-disc_mm_flag.

          WHEN 'X'.
            IF wa_approver1-mm_flag <> 'X'
               OR wa_approver1-m11s_flag <> 'X'.
              DELETE it_approver1.
            ENDIF.
          WHEN OTHERS.
            IF wa_approver1-mm_flag = 'X'
               OR wa_approver1-m11s_flag <> 'X'.
              DELETE it_approver1.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IF l_role_name = 'M11M'.

      LOOP AT it_approver1 INTO wa_approver1.

*                    if wa_approver1-M11M_FLAG <> 'X'.
*                        delete it_approver1.
*                     endif.

        CASE  zic_prep_rolereq-disc_mm_flag.

          WHEN 'X'.
            IF wa_approver1-mm_flag <> 'X'
               OR wa_approver1-m11m_flag <> 'X'.
              DELETE it_approver1.
            ENDIF.
          WHEN OTHERS.
            IF wa_approver1-mm_flag = 'X'
               OR wa_approver1-m11m_flag <> 'X'.
              DELETE it_approver1.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    it_approver[] = it_approver1[].

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
  g_field_wa-fieldname = 'APP_LEVEL'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
  g_field_wa-fieldname = 'L_DESC'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'APP_LEVEL'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-APPROVER'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_approver
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_approver,ist_return_tab, it_approver1,g_field_tab.
  FREE  : it_approver,ist_return_tab, it_approver1,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_receipt_loc INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC' AND screen-input =
0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : it_recpt LIKE TABLE OF zmm_location.
  DATA : wa_recpt LIKE zmm_location.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_role_name.

  SELECT * FROM zmm_location INTO TABLE it_recpt.


  IF l_role_name = 'M12'.

    LOOP AT it_recpt INTO wa_recpt.

      IF wa_recpt-loccg <> 'RL'.
        DELETE it_recpt.
      ENDIF.

    ENDLOOP.

  ENDIF.


  IF l_role_name = 'M17'.

    LOOP AT it_recpt INTO wa_recpt.

      IF wa_recpt-loccg <> 'CF'.
        DELETE it_recpt.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZMM_LOCATION'.
  g_field_wa-fieldname = 'LOCCD'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_LOCATION'.
  g_field_wa-fieldname = 'LOCCG'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_LOCATION'.
  g_field_wa-fieldname = 'LOCDS'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LOCCD'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_recpt
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_recpt,ist_return_tab,g_field_tab.
  FREE  : it_recpt,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  IF sy-ucomm = 'EXT'.
*    perform exit_confirm.
    LEAVE PROGRAM.
  ENDIF.

  IF sy-ucomm = 'BAC' AND old_ok_code = 'CREATE' OR old_ok_code =
'APPROVE'.
    PERFORM bac_confirm_100.
  ENDIF.

  IF sy-ucomm = 'BAC' AND sy-tcode = 'ZIC_AUTH_FI_REP'.
    CLEAR old_ok_code.
*    call transaction 'ZIC_AUTH_REP' and SKIP FIRST SCREEN.
    CALL TRANSACTION 'ZICE_ARMS_REP' AND SKIP FIRST SCREEN.
  ENDIF.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_data INPUT.

  old_doc_no =  zic_prep_rolereq-docno.
  old_userid =  zic_prep_rolereq-userid.
  old_disc_fi_flag =  zic_prep_rolereq-disc_fi_flag.
  old_moduleid = moduleid.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE record_rej_id_data INPUT.

  IF old_ok_code <> 'DISPLAY' OR sy-tcode = 'ZIC_AUTH_FI_REP'.
**
    IF zic_prep_rolerei-rej_id IS INITIAL.
      zic_prep_rolerei-rej_id = sy-uname.
      zic_prep_rolerei-rej_date = sy-datum.
    ENDIF.

    IF NOT zic_prep_rolerei-rej_fl IS INITIAL AND
       zic_prep_rolerei-rej_fl_save IS INITIAL.

      SELECT SINGLE * FROM  zmm_prep_rej_lis  WHERE
        rej_code = zic_prep_rolerei-rej_fl .
      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        MESSAGE e111(zhelp).
      ELSE.
        IF g_user = 'HF' AND ( zic_prep_rolerei-rej_fl <> 'H' AND
         zic_prep_rolerei-rej_fl <> 'F' ).
          g_e_fl = 'X'.
          MESSAGE e111(zhelp).
        ENDIF.

        IF g_user_assign = 'X' AND zic_prep_rolerei-rej_fl <> 'F'.
          g_e_fl = 'X'.
          MESSAGE e111(zhelp).
        ENDIF.

      ENDIF.
    ENDIF.
**
  ENDIF.
ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tel INPUT.

  DATA : tel_len TYPE i.
  tel_len = strlen(  zic_prep_rolereq-telno ).
  IF   zic_prep_rolereq-telno CN ' 0123456789-'.
    MESSAGE e097(zhelp).
  ELSE.
    IF tel_len < 7.
      MESSAGE e098(zhelp).
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_read  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_read INPUT.
  CLEAR g_read_fl.
ENDMODULE.                 " clear_read  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno INPUT.
  CLEAR g_srno.
  LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa.
    g_srno = g_srno + 1.
    g_tablctrl110_wa-srno = g_srno.
    MODIFY g_tablctrl110_itab FROM g_tablctrl110_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl110_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl110_itab  LINES tablctrl110-lines.
  CLEAR g_srno.

ENDMODULE.                 " change_srno  INPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup INPUT.
  IF NOT g_tabctrl100_itab[] IS INITIAL .

    DELETE ADJACENT DUPLICATES FROM g_tabctrl100_itab
    COMPARING role_name plant grp sloc receipt_loc approver.

  ENDIF.
ENDMODULE.                 " delete_dup  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data INPUT.
  g_role_name_prev = zic_prep_rolerei-role_name.

ENDMODULE.                 " init_data  INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: modify table
MODULE tablctrl111_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl111_wa.

****  select single * from zfi_prep_roledes where role_type =
****                    ZIC_PREP_ROLEREI-role_name.
****
****  if sy-subrc <> 0 .
****    g_val_err = 'X'.
****    message i102(zhelp) with zic_prep_rolerei-role_name .
****    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
****  endif.

  g_tablctrl111_wa-role_desc = zfi_prep_roledes-brief_desc.

  MODIFY g_tablctrl111_itab
    FROM g_tablctrl111_wa
    INDEX tablctrl111-current_line.

  IF sy-subrc <> 0.
    APPEND g_tablctrl111_wa TO g_tablctrl111_itab.
  ENDIF.

  IF g_tablctrl111_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl111_wa-flag.
    APPEND g_tablctrl111_wa TO g_tablctrl111_itab.
  ENDIF.


  IF sy-tcode = 'ZIC_AUTH_FI_REP'.

    IF g_curfield = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
       g_curr_line_111 = sy-stepl.
      SET PARAMETER ID 'ZAUTHREQ' FIELD
                  zic_prep_rolerei-role_request.
    ENDIF.

*        if g_curr_line_111 = sy-stepl and okcode_100 =
*                                'TABLCTRL111_DELE' and
*        g_TABLCTRL111_wa-rej_fl <> ''.
*        g_rej_fl = 'X'.
*        endif.
  ENDIF.

ENDMODULE.                    "TABLCTRL111_modify INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: mark table
MODULE tablctrl111_mark INPUT.

  IF tablctrl111-line_sel_mode = 1 AND
   g_tablctrl111_wa-flag = 'X'.
    LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa
      WHERE flag = 'X'.
      g_tablctrl111_wa-flag = ''.
      MODIFY g_tablctrl111_itab
        FROM g_tablctrl111_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl111_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl111_itab
    FROM g_tablctrl111_wa
    INDEX tablctrl111-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABLCTRL111_mark INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: process user command
MODULE tablctrl111_user_command INPUT.
  ok_code = sy-ucomm.

  IF ok_code = 'TABLCTRL111_INSR'.
    okcode_insert_line = 1.
  ENDIF.

  PERFORM user_ok_tc USING    'TABLCTRL111'
                              'G_TABLCTRL111_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.

ENDMODULE.                    "TABLCTRL111_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_111 INPUT.

  GET CURSOR FIELD g_curfield.
  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl111-top_line + g_cursor_line - 1.
  g_curr_line_111 = g_curr_line.

ENDMODULE.                 " get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data11 INPUT.

  SELECT SINGLE * FROM zfi_prep_roledes WHERE role_type =
                             zic_prep_rolerei-role_name.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data11a INPUT.



  g_ccode =  zic_prep_rolereq-ccode.


*  if g_read_fl <> 'X'.
*
*    select single * from zfi_prep_roledes where role_type =
*                    ZIC_PREP_ROLEREI-role_name.
*    if sy-subrc <> 0.
*      g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
*      message i118(zhelp).
*    endif.
*
*  elseif g_e_fl = 'X'.
*    clear g_e_fl.
*  else.
*    clear  ZIC_PREP_ROLEREI-GL_ACCOUNT.
*    clear  ZIC_PREP_ROLEREI-BUSSINESS_AREA.
*    clear g_read_fl.
*
*  endif.

  IF g_role_name_flag = 'X'.
    CLEAR g_role_name_flag.
    CLEAR  zic_prep_rolerei-gl_account.
    CLEAR  zic_prep_rolerei-bussiness_area.
    CLEAR  zic_prep_rolerei-fund_ctr_gp.
    CLEAR zic_prep_rolerei-jva_grp.
  ENDIF.


  g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

  g_i = g_curr_line.

  l_role_name = zic_prep_rolerei-role_name.

**********************************************************

  IF old_ok_code <> 'DISPLAY'.


    IF NOT zic_prep_rolerei-gl_account IS INITIAL.

      SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF         "#EC CI_DB_OPERATION_OK[2431747]
                 TABLE it_saknr  WHERE bukrs =  zic_prep_rolereq-ccode
                            AND saknr = zic_prep_rolerei-gl_account.
      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-GL_ACCOUNT'.
        g_i = g_curr_line.
        MESSAGE e058(zhelp) WITH zic_prep_rolerei-role_name.

      ENDIF.

    ENDIF.


    IF NOT zic_prep_rolerei-sub_module IS INITIAL.

      SELECT * FROM zfi_prep_submod INTO CORRESPONDING FIELDS OF
         TABLE it_submod WHERE sub_module = zic_prep_rolerei-sub_module.

      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-SUB_MODULE'.
        g_i = g_curr_line.
        MESSAGE e062(zhelp) WITH zic_prep_rolerei-role_name.

      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-bussiness_area IS INITIAL.

      SELECT * FROM tgsb INTO CORRESPONDING FIELDS OF
          TABLE it_b_area WHERE gsber = zic_prep_rolerei-bussiness_area.

      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-BUSSINESS_AREA'.
        g_i = g_curr_line.
        MESSAGE e063(zhelp) WITH zic_prep_rolerei-role_name.

      ENDIF.

    ENDIF.


    IF NOT zic_prep_rolerei-fund_ctr_gp IS INITIAL.

      SELECT * FROM  fmfctr INTO CORRESPONDING FIELDS OF
             TABLE it_f_ctr1 WHERE fictr = zic_prep_rolerei-fund_ctr_gp.

      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-FUND_CTR_GP'.
        g_i = g_curr_line.
        MESSAGE e064(zhelp) WITH zic_prep_rolerei-role_name.

      ENDIF.

    ENDIF.



    IF NOT zic_prep_rolerei-role_name IS INITIAL.

      SELECT * FROM zfi_prep_roledes INTO CORRESPONDING FIELDS OF
                  TABLE it_role.
*Specific conditions for the company code

*      if zic_prep_rolereq-ccode = 'BDW' or
*         zic_prep_rolereq-ccode = 'SBW'.
*      else.
*        delete it_role where role_type = 'PM14' or
*        role_type = 'PM15' or role_type = 'PM16'.
*      endif.

      LOOP AT it_role .
        IF it_role-role_type = zic_prep_rolerei-role_name.
          check_role_flag = 'X'.
        ENDIF.
      ENDLOOP.

      IF check_role_flag = 'X'.
        CLEAR check_role_flag.
      ELSE.
        MESSAGE e164(zhelp) WITH zic_prep_rolerei-role_name
        zic_prep_rolereq-ccode .
      ENDIF.

    ENDIF.

  ENDIF.
ENDMODULE.                 " validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno11 INPUT.

  CLEAR g_srno.
  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.
    g_srno = g_srno + 1.
    g_tablctrl111_wa-srno = g_srno.
    MODIFY g_tablctrl111_itab FROM g_tablctrl111_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl111_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl111_itab  LINES tablctrl111-lines.
  CLEAR g_srno.



ENDMODULE.                 " change_srno11  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_FI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role_fi INPUT.
  DATA : g_fldval TYPE zfi_prep_roledes-role_type.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

*  TYPES : Begin of z_role_des,
*            role_type like zmm_prep_roledes-role_type,
*            brief_desc like zmm_prep_roledes-brief_desc,
*            DETAIL_DESC1 like zmm_prep_roledes-detail_desc1,
*            DETAIL_DESC2 like zmm_prep_roledes-detail_desc2,
*            sort_field like zmm_prep_roledes-brief_desc,
*            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
*          end of z_role_des.

*  DATA   : it_role type table of z_role_des with header line.
*
  CLEAR : g_fldval.

  REFRESH : ist_dyfields.

  ist_dyfields-fieldname = 'ZIC_PREP_ROLEREI-SUB_MODULE'.

  GET CURSOR LINE ist_dyfields-stepl.

  APPEND ist_dyfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = ist_dyfields.

  IF NOT ist_dyfields-fieldvalue IS INITIAL.
    IF ist_dyfields-fieldvalue = 'CFM'.
      CONCATENATE 'CF' '%' INTO g_fldval.
    ELSEIF ist_dyfields-fieldvalue = 'REP'.
      CONCATENATE 'FR' '%' INTO g_fldval.
    ELSEIF ist_dyfields-fieldvalue = 'PRA1'. " PRA Module changes
      CONCATENATE  'BU' '%' INTO g_fldval.   " PRA Module changes
    ELSEIF ist_dyfields-fieldvalue = 'PRA2'. " PRA Module changes
      CONCATENATE  'APP' '%' INTO g_fldval.   " PRA Module changes
    ELSEIF ist_dyfields-fieldvalue = 'PRA3'. " PRA Module changes
      CONCATENATE  'CP' '%' INTO g_fldval.   " PRA Module changes
    ELSE.
      CONCATENATE ist_dyfields-fieldvalue '%' INTO g_fldval.
    ENDIF.
  ENDIF.

  SELECT * FROM zfi_prep_roledes INTO CORRESPONDING FIELDS OF
             TABLE it_role WHERE role_type LIKE g_fldval.

  SORT it_role ASCENDING BY sort_field.

*  if zic_prep_rolereq-ccode = 'BDW' or
*     zic_prep_rolereq-ccode = 'SBW'.
*  else.
*    delete it_role where role_type = 'PM14' or
*    role_type = 'PM15' or role_type = 'PM16'.
*  endif.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  g_field_wa-tabname = 'Zfi_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_SENSITIVITY'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.
*  Added to mark the Role Sensitivity field CAB_PAREEK -Start
  IF it_role-role_sensitivity = 'X'.
    zic_prep_rolerei-role_sensitivity = 'A'.
  ENDIF.
*  Added to mark the Role Sensitivity field CAB_PAREEK - End

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_ROLE_FI  INPUT


*&---------------------------------------------------------------------*
*&      Module  POV_SUBMOD_FI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_submod_fi INPUT.




  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SUB_MODULE' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.




  SELECT * FROM zfi_prep_submod INTO CORRESPONDING FIELDS OF
             TABLE it_submod.


  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-sub_module.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZFI_PREP_SUBMOD'.
  g_field_wa-fieldname = 'SUB_MODULE'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SUB_MODULE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SUB_MODULE'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_submod
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_submod,ist_return_tab, g_field_tab.
  FREE  : it_submod,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_SUBMOD_FI  INPUT

*&---------------------------------------------------------------------*
*&      Module  POV_Bussi_Area  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_bussi_area INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-Bussiness_area' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.


  SELECT * FROM tgsb INTO CORRESPONDING FIELDS OF
             TABLE it_b_area. "  where werks =  '53C1' or
  "   werks =  '24C1'.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'GSBER'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-BUSSINESS_AREA'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_b_area
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_b_area,ist_return_tab.
  FREE : it_b_area,ist_return_tab.

ENDMODULE.                 " POV_Bussi_Area  INPUT

*&---------------------------------------------------------------------*
*&      Module  POV_FUND_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_fund_grp INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-FUND_CTR_GP' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.

  DATA   : len TYPE i.
  DATA   : l_ccode TYPE string.
  SELECT * FROM  fmfctr INTO CORRESPONDING FIELDS OF
             TABLE it_f_ctr1 . "  where werks =  '53C1' or
  "   werks =  '24C1'.

  LOOP AT it_f_ctr1.
    len = strlen( it_f_ctr1-fictr ).
    l_ccode = it_f_ctr1-fictr(3).
    IF  len = 6 AND l_ccode = zic_prep_rolereq-ccode.
      it_f_ctr-fictr = it_f_ctr1-fictr.
      APPEND it_f_ctr.
    ENDIF.

  ENDLOOP.


  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FICTR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-FUND_CTR_GP'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_f_ctr
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_f_ctr,ist_return_tab.
  FREE : it_f_ctr,ist_return_tab.

ENDMODULE.                 " POV_FUND_GRP  INPUT


*&---------------------------------------------------------------------*
*&      Module  POV_JVA_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_jva_grp INPUT.


  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-JVA_GRP' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  TYPES : BEGIN OF z_jva_grp,
            bukrs LIKE t001-bukrs,
            butxt LIKE t001-butxt,
            rcomp LIKE t001-rcomp,
          END OF z_jva_grp.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : it_jva_grp TYPE TABLE OF z_jva_grp WITH HEADER LINE.



*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.


  SELECT * FROM  t001 INTO CORRESPONDING FIELDS OF
             TABLE it_jva_grp WHERE xjvaa = 'X'.




  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BUKRS'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-JVA_GRP'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_jva_grp
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_f_ctr,ist_return_tab.
  FREE : it_f_ctr,ist_return_tab.

ENDMODULE.                 " POV_JVA_GRP  INPUT


*&---------------------------------------------------------------------*
*&      Module  POV_MODULEID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_moduleid INPUT.


  DATA : wa_module LIKE zic_modules.

*  data : l_docno like zic_prep_rolereq-DOCNO.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREQ'
      field = 'DOCNO'
      repid = sy-cprog
      dynnr = '0100'
    IMPORTING
      value = l_docno.


  IF old_ok_code = 'CREATE'  OR
     old_ok_code = 'CHANGE'.

    SELECT  moduleid FROM zice_prep_module INTO CORRESPONDING FIELDS
     OF TABLE it_module.

  ELSE.

    SELECT DISTINCT moduleid FROM zic_prep_rolerei INTO
      CORRESPONDING FIELDS OF TABLE it_module WHERE docno = l_docno.

  ENDIF.

  LOOP AT it_module INTO wa_module.
    SELECT SINGLE * FROM zice_prep_module WHERE moduleid =
    wa_module-moduleid.
    wa_module-z_desc = zice_prep_module-z_desc.
    MODIFY it_module FROM wa_module.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MODULEID'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'MODULEID'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_module
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_module,ist_return_tab.
  FREE  : it_module,ist_return_tab.

ENDMODULE.                 " POV_MODULEID  INPUT

*&---------------------------------------------------------------------*
*&      Module  dummy  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE dummy INPUT.
  IF NOT old_moduleid IS INITIAL AND old_moduleid <> moduleid AND
     old_ok_code = 'CHANGE'.
    okcode_100 = 'SAV'.
    new_moduleid = moduleid.
    moduleid = old_moduleid.
    module_changed_flag = 'X'.
    CLEAR old_moduleid.
  ENDIF.
ENDMODULE.                 " dummy  INPUT

*&---------------------------------------------------------------------*
*&      Module  value_list1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_list1 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  DATA : l_desc(30).
  SORT ist_item DESCENDING.

  LOOP AT ist_item INTO wa_item.
    CASE wa_item-moduleid.
      WHEN 'FI'.
        PERFORM check_module_status_fi.
    ENDCASE.
  ENDLOOP.

  LOOP AT ist_item INTO wa_item.

    CASE wa_item-moduleid .

      WHEN 'FI'.

        AT NEW moduleid.

          WRITE :/.

          IF fi_not_ok = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.

          WRITE: / 'FI Module', 'Role', 'Description',
                 AT 48  'GL Account',
                 AT 53  'Bussiness Area',
                 AT 59  'Fund Ctr Gp',
                 AT 64  'JVA Gp',
                 AT 73  'User level' .

          FORMAT INTENSIFIED OFF COLOR OFF.

*     uline.

        ENDAT.


        SELECT SINGLE brief_desc FROM zfi_prep_roledes INTO l_desc
            WHERE role_type = wa_item-role_name.


        WRITE: / wa_item-moduleid, AT 12 wa_item-role_name, AT 17 l_desc,
                    AT 48 wa_item-gl_account,
                    AT 53 wa_item-bussiness_area,
                    AT 59 wa_item-fund_ctr_gp,
                    AT 64 wa_item-jva_grp,
                    AT 73 wa_item-approver.


    ENDCASE.

*
*
    HIDE : wa_item-moduleid, wa_item-role_name, wa_item-gl_account,
             wa_item-bussiness_area, wa_item-fund_ctr_gp,
             wa_item-jva_grp,wa_item-approver.

  ENDLOOP.
**************************************
ENDMODULE.                 " value_list1  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  validate_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_header_data OUTPUT.

  IF old_ok_code =  'CREATE' OR old_ok_code = 'ROLE_DEL'.




*    if old_ok_code = 'CREATE'.
*
*      if  ZIC_PREP_ROLEREQ-PERSA is initial and
*          ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
*        perform pop_up_message.
*      endif.

    IF  zic_prep_rolereq-userid IS INITIAL.
      MESSAGE e035(zhelp).
    ENDIF.

****      if  ZIC_PREP_ROLEREQ-userid <> old_userid and
****        old_userid <> ''.
****        clear  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.
****        clear  ZIC_PREP_ROLEREQ-CCODE.
****        clear  ZIC_PREP_ROLEREQ-FUNDC1.
****        clear  ZIC_PREP_ROLEREQ-FUNDC.
****        clear  ZIC_PREP_ROLEREQ-S_DESC.
****        clear  ZIC_PREP_ROLEREQ-RSN_CODE.
****        clear  ZIC_PREP_ROLEREQ-RSN_TEXT1.
****        clear  ZIC_PREP_ROLEREQ-REASON1.
****        clear  ZIC_PREP_ROLEREQ-TELNO.
****        clear  ZIC_PREP_ROLEREQ-NAME.
****        clear  ZIC_PREP_ROLEREQ-DESIGNATION.
****        clear set_disc_fi_flag.
****        clear help_list_flag.
****        refresh it_m_fistb.
****        clear wa_m_fistb.
****      endif.


    SELECT SINGLE * FROM usr02 WHERE bname =
                                zic_prep_rolereq-userid.

    IF sy-subrc NE 0.
      MESSAGE e043(zhelp).
    ELSE.
*Begin of <RD1K964434>.
      DATA : l_date TYPE datum.
      MOVE sy-datum TO l_date.
*End of <RD1K964434>.

      SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
           a~persk a~sbmod  c~designo c~r_p_cd c~version
         d~sdesig_text AS designation d~adesig_text AS adesignation
         d~disc_cd AS disc_cd
           INTO CORRESPONDING FIELDS OF TABLE ist_data
      FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
            ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
               ON c~designo = d~desig_code AND
                   c~r_p_cd  = d~r_p_cd AND
                   c~version = d~version )
                WHERE a~pernr =  zic_prep_rolereq-userid AND
                      a~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        a~endda = '99991231' AND
                         a~endda GE l_date AND
*End of <RD1K964434>.
                         c~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        c~endda = '99991231' .
                         c~endda GE l_date .
*End of <RD1K964434>.

*Begin of <RD1K964434>.
      DATA : l_count TYPE i.
      DESCRIBE TABLE ist_data[] LINES l_count.
*End of <RD1K964434>.

      IF sy-subrc = 0.
        READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
        zic_prep_rolereq-name = ist_data-name.
        zic_prep_rolereq-designation = ist_data-designation.
        zic_prep_rolereq-desig_level = ist_data-persk.
        IF ist_data-disc_cd = '13' AND set_disc_fi_flag <> 'X'.
          zic_prep_rolereq-disc_fi_flag = 'X'.
          set_disc_fi_flag = 'X'.
        ENDIF.
***************************************************31.05.2006
        IF old_ok_code = 'CREATE' OR old_ok_code = 'ROLE_DEL' .
          zic_prep_rolereq-ccode = ist_data-bukrs.
        ELSE.
          g_ccode_crossco        = ist_data-bukrs.
        ENDIF.

***************************************************31.05.2006

        IF old_ok_code = 'CREATE'.
          IF  zic_prep_rolereq-persa <> ist_data-werks AND
             NOT  zic_prep_rolereq-persa IS INITIAL.
            MESSAGE e108(zhelp).
          ENDIF.
        ENDIF.

      ENDIF.

      CLEAR : ist_data.
      REFRESH : ist_data.

** Change company code, fund centre, costcentre logic 02.02.2006


      CONCATENATE '000'  zic_prep_rolereq-userid INTO cpf_lfb1.

      CLEAR wa_pa0027.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*      SELECT SINGLE *
*         FROM pa0027
*         INTO wa_pa0027
*         WHERE pernr = cpf_lfb1 AND
*               endda = '99991231' AND
*               sprps = ' ' . " SPRPS - Lock Indicator 'X'
            SELECT *
         FROM pa0027  UP TO 1 ROWS
         INTO wa_pa0027
         WHERE pernr = cpf_lfb1 AND
               endda = '99991231' AND
               sprps = ' ' ORDER BY PRIMARY KEY. ENDSELECT. " SPRPS - Lock Indicator 'X'
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
      IF sy-subrc = 0.
        IF old_ok_code <> 'CROSSCO'.
          CONCATENATE  '''' '%' wa_pa0027-kst01
                       '''' INTO  g_line1.
          CONCATENATE  'OBJNR'  'LIKE' g_line1 INTO g_line1
          SEPARATED BY space.
          REFRESH :  it_cond.
          APPEND g_line1 TO it_cond.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*          SELECT SINGLE * FROM fmzuob WHERE (it_cond).
          SELECT * FROM fmzuob UP TO 1 ROWS WHERE (it_cond) ORDER BY PRIMARY KEY. ENDSELECT.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
        ENDIF.
        IF sy-subrc = 0.
          IF old_ok_code = 'CREATE' OR old_ok_code = 'CRCROLES'.
            zic_prep_rolereq-fundc1 = fmzuob-fistl.
            zic_prep_rolereq-fundc_fl = 'X'.
*               ZIC_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
            zic_prep_rolereq-costc = wa_pa0027-kst01.
          ELSE.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
            zic_prep_rolereq-costc = wa_pa0027-kst01.
          ENDIF.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*          SELECT SINGLE * FROM cskt WHERE
*                        kostl =  zic_prep_rolereq-costc.
                    SELECT * FROM cskt UP TO 1 ROWS WHERE
                        kostl =  zic_prep_rolereq-costc ORDER BY PRIMARY KEY. ENDSELECT.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
          IF sy-subrc =  0.
            zic_prep_rolereq-s_desc = cskt-ltext.
          ENDIF.

          REFRESH it_cond[].
          CLEAR it_cond.
        ELSE.
        ENDIF.
      ENDIF.

    ENDIF.



*    endif.

  ENDIF.

ENDMODULE.                 " validate_header_data  OUTPUT

*&spwizard: output module for tc 'TABLECTRL_215'. do not change this
*line!
*&spwizard: copy ddic-table to itab
MODULE tablectrl_215_init OUTPUT.

  DATA : l_srno TYPE i.

  IF g_tablectrl_215_copied IS INITIAL AND old_ok_code <> 'ROLE_DEL'.
    REFRESH g_tablectrl_215_itab[].
    CLEAR   g_tablectrl_215_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL111_itab'

    SELECT * FROM zic_prep_delrole INTO CORRESPONDING FIELDS
                   OF TABLE g_tablectrl_215_itab WHERE moduleid = 'FI'
                   AND docno = zic_prep_rolereq-docno.

    LOOP AT g_tablectrl_215_itab INTO g_tablectrl_215_wa.
      g_tablectrl_215_wa-role_sel ='X'.
      MODIFY g_tablectrl_215_itab FROM g_tablectrl_215_wa.
    ENDLOOP.
    g_tablectrl_215_copied = 'X'.
    REFRESH CONTROL 'TABLECTRL_215' FROM SCREEN '0215'.
  ELSE.
    IF g_tablectrl_215_copied IS INITIAL.
*&spwizard: copy ddic-table 'ZIC_PREP_DELROLE'
*&spwizard: into internal table 'g_TABLECTRL_215_itab'

      SELECT agr_name from_dat to_dat FROM agr_users
             INTO CORRESPONDING FIELDS OF TABLE g_tablectrl_215_itab1
             WHERE uname = zic_prep_rolereq-userid .
      l_srno = 1.
      LOOP AT g_tablectrl_215_itab1 INTO g_tablectrl_215_wa1.
        g_tablectrl_215_wa-srno         = l_srno.
        g_tablectrl_215_wa-moduleid     = moduleid.
        g_tablectrl_215_wa-role_name    = g_tablectrl_215_wa1-agr_name.
        g_tablectrl_215_wa-fr_date_auth = g_tablectrl_215_wa1-from_dat.
        g_tablectrl_215_wa-to_date_auth  = g_tablectrl_215_wa1-to_dat.
        APPEND g_tablectrl_215_wa TO g_tablectrl_215_itab.
        l_srno = l_srno + 1.
      ENDLOOP.

      g_tablectrl_215_copied = 'X'.
      REFRESH CONTROL 'TABLECTRL_215' FROM SCREEN '0215'.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLECTRL_215_init OUTPUT

*&spwizard: output module for tc 'TABLECTRL_215'. do not change this
*line!
*&spwizard: move itab to dynpro
MODULE tablectrl_215_move OUTPUT.
  MOVE-CORRESPONDING g_tablectrl_215_wa TO wa_zic_prep_delrole.
ENDMODULE.                    "TABLECTRL_215_move OUTPUT

*&spwizard: output module for tc 'TABLECTRL_215'. do not changethisline!
*&spwizard: get lines of tablecontrol
MODULE tablectrl_215_get_lines OUTPUT.
  g_tablectrl_215_lines = sy-loopc.
ENDMODULE.                    "TABLECTRL_215_get_lines OUTPUT

*&spwizard: input module for tc 'TABLECTRL_215'. do not change thisline!
*&spwizard: modify table
MODULE tablectrl_215_modify INPUT.
  MOVE-CORRESPONDING wa_zic_prep_delrole TO g_tablectrl_215_wa.

  MODIFY g_tablectrl_215_itab
    FROM g_tablectrl_215_wa
    INDEX tablectrl_215-current_line.
ENDMODULE.                    "TABLECTRL_215_modify INPUT

*&spwizard: input module for tc 'TABLECTRL_215'.do not change thisline!
*&spwizard: mark table
MODULE tablectrl_215_mark INPUT.
  IF tablectrl_215-line_sel_mode = 1 AND
     g_tablectrl_215_wa-flag = 'X'.
    LOOP AT g_tablectrl_215_itab INTO g_tablectrl_215_wa
      WHERE flag = 'X'.
      g_tablectrl_215_wa-flag = ''.
      MODIFY g_tablectrl_215_itab
        FROM g_tablectrl_215_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablectrl_215_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablectrl_215_itab
    FROM g_tablectrl_215_wa
    INDEX tablectrl_215-current_line
    TRANSPORTING flag.

*    loop at g_TABLECTRL_215_itab into g_TABLECTRL_215_wa.
*      g_TABLECTRL_215_wa-role_sel ='X'.
*      modify g_TABLECTRL_215_itab from g_TABLECTRL_215_wa.
*    endloop.

ENDMODULE.                    "TABLECTRL_215_mark INPUT

*&spwizard: input module for tc 'TABLECTRL_215'. do not changethisline!
*&spwizard: process user command
MODULE tablectrl_215_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLECTRL_215'
                              'G_TABLECTRL_215_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TABLECTRL_215_user_command INPUT

*&---------------------------------------------------------------------*
*&      Module  change_srno215  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno215 INPUT.

  CLEAR g_srno.
  LOOP AT g_tablectrl_215_itab INTO g_tablectrl_215_wa.
    g_srno = g_srno + 1.
    g_tablectrl_215_wa-srno = g_srno.
    MODIFY g_tablectrl_215_itab FROM g_tablectrl_215_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablectrl_215_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablectrl_215_itab  LINES tablectrl_215-lines.
  CLEAR g_srno.



ENDMODULE.                 " change_srno215  INPUT

*&---------------------------------------------------------------------*
*&      Module  scr215_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr215_attrib OUTPUT.
  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLECTRL_215_DELETE' OR
             screen-name = 'TABLECTRL_215_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr215_attrib  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TABLCTRL215_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl215_attrib OUTPUT.


  IF old_ok_code = 'ROLE_DEL' OR old_ok_code = 'CHANGE'.


    LOOP AT SCREEN.
      IF screen-name <> 'WA_ZIC_PREP_DELROLE-ROLE_SEL'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ELSE.
    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " TABLCTRL215_attrib  OUTPUT
