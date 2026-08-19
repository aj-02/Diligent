*--- MAIN PROGRAM: MZMM_STOO01 ---*
*---------------------------------------------------------------------*
*       MODULE STATUS_0200 OUTPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  refresh :ist_pfstatus.
  if flag = ' '.
    import ist_display from memory id 'DISP'.
    import okcode from memory id 'OK'.
    flag = 'X'.
  endif.
  case okcode.
    when 'DELETE'.
      MOVE 'COMP' TO IST_PFSTATUS.
      APPEND IST_PFSTATUS.
      SET PF-STATUS 'S200' EXCLUDING IST_PFSTATUS.
      SET TITLEBAR 'T200' with text-002.
      g_title = text-002.
    WHEN 'COMP'.
      MOVE 'DELETE' TO IST_PFSTATUS.
      APPEND IST_PFSTATUS.
      SET PF-STATUS 'S200' EXCLUDING IST_PFSTATUS.
      SET TITLEBAR 'T200' with text-002.
      g_title = text-002.
***Nitesh S
    WHEN 'DELETE_SD'.
      MOVE 'DELETE_SD' TO IST_PFSTATUS.
      APPEND IST_PFSTATUS.
      SET PF-STATUS 'S300' EXCLUDING IST_PFSTATUS.
      SET TITLEBAR 'T300' with text-002.
      g_title = text-002.

***Nitesh E

  endcase.
  clear okcode.
ENDMODULE.                 " STATUS_0200  OUTPUT
