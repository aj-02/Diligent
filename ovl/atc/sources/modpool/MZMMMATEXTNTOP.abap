*--- MAIN PROGRAM: MZMMMATEXTNTOP ---*
*&---------------------------------------------------------------------*
*& Include ZMMMATEXTTOP                                                *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  zmm_matextention              .

TABLES : mara,marc,mbew,zmm_matextension,usr04,
         fmfpo,zmm_matextnmast. "USTYP_T_PROFILES.

CONTROLS: tabctrl TYPE TABLEVIEW USING SCREEN 0100.

DATA: BEGIN OF ist_matr OCCURS 100,
          matnr       LIKE zmm_matextension-matnr,
          werks       LIKE zmm_matextension-werks,
          val_type    LIKE zmm_matextension-val_type,
         mrpctrl       LIKE zmm_matextension-mrpctrl,
          dismm       LIKE zmm_matextension-dismm,
          fipos       LIKE skb1-fipos,
          status_flag LIKE zmm_matextension-status_flag,
          msgtext1(30) TYPE c,
          msgtext2(30) TYPE c,
          msgtext3(30) TYPE c,
          msgtext4(30) TYPE c,

     END OF ist_matr.

PARAMETERS: p_file LIKE ibipparms-path.

TYPES: BEGIN OF t_tabctrl,
         mark(1) TYPE c,
          srno LIKE zmm_matextension-srno,
         matnr LIKE zmm_matextension-matnr,
         werks LIKE zmm_matextension-werks,
         val_type LIKE zmm_matextension-val_type,
         mrpctrl LIKE zmm_matextension-mrpctrl,
          bname       LIKE usr04-bname,
         dismm LIKE zmm_matextension-dismm,
         status_flag LIKE zmm_matextension-status_flag,
         fipos LIKE skb1-fipos,
          msgtype(4)  TYPE c,
          msgtype1  TYPE c,
          msgtype2  TYPE c,
          msgtype3  TYPE c,
          msgtype4  TYPE c,
          msgtype5  TYPE c,
          msgtext(120) TYPE c,
          msgtext1(50) TYPE c,
          msgtext2(50) TYPE c,
          msgtext3(50) TYPE c,
          msgtext4(50) TYPE c,
          msgtext5(50) TYPE c,

       END OF t_tabctrl.

TYPES: BEGIN OF tab_type,
       fcode LIKE rsmpe-func,
     END OF tab_type.

DATA: tab TYPE STANDARD TABLE OF tab_type WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
      wa_tab TYPE tab_type.

TYPES : BEGIN OF ty_message,
          srno(3)  TYPE c,
          msgtype(4)  TYPE c,
          msgtype1  TYPE c,
          msgtype2  TYPE c,
          msgtype3  TYPE c,
          msgtype4  TYPE c,
          msgtype5 TYPE c,
          msgcode  TYPE c,
          msgtext(120) TYPE c,
          msgtext1(50) TYPE c,
          msgtext2(50) TYPE c,
          msgtext3(50) TYPE c,
          msgtext4(50) TYPE c,
          msgtext5(50) TYPE c,
        END OF ty_message.

DATA : wa_message TYPE ty_message.
DATA : ist_message LIKE STANDARD TABLE OF wa_message .

DATA : g_tabctrl_itab   TYPE t_tabctrl OCCURS 0,
       g_tabctrl_wa     TYPE t_tabctrl. "work area
DATA : g_tabctrl_copied.           "copy flag
DATA : ok_code LIKE sy-ucomm,save_ok LIKE ok_code.

DATA:  g_tabctrl_lines  LIKE sy-loopc.
DATA:  wa_tabctrl_cols LIKE LINE OF tabctrl-cols.

DATA : mark(1) TYPE c.
DATA : l_pstat TYPE marc-pstat.
DATA : g_flag(1) TYPE c.
DATA : l_flag(1) TYPE c.

DATA : upl_flag(1) TYPE c,
       chk_flag(1) TYPE c.

DATA:  ok_code101 LIKE sy-ucomm,
       save_ok101 LIKE ok_code101.

DATA : cnt(3) TYPE c VALUE IS INITIAL.

DATA : msgcnt(3) TYPE c.
DATA : msg_flag(1) TYPE c.

DATA : g_filname(40) TYPE c,
       g_filval(40) TYPE c.

DATA : l_remark LIKE zmm_matextnmast-remarks.

DATA : L_SYTABIX TYPE SY-TABIX.

SELECTION-SCREEN BEGIN OF BLOCK lblk WITH FRAME.

PARAMETERS p_rd1 RADIOBUTTON GROUP grp DEFAULT 'X'.
PARAMETERS p_rd2 RADIOBUTTON GROUP grp .

SELECTION-SCREEN END OF BLOCK lblk .
