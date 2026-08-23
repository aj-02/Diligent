*&---------------------------------------------------------------------*
*&  Change to existing include ZFM06LFFR (package ZMM_PO)
*&---------------------------------------------------------------------*
*  ZFM06LFFR today includes the SAP standard sub-includes, which is why
*  the tender committee checks never fire on S/4. Swap exactly one line.
*
*  BEFORE:
*    INCLUDE FM06LFFR_FRG_SET .  " FRG_SET
*
*  AFTER:
*    INCLUDE ZFM06LFFR_FRG_SET .  " FRG_SET  "+TC001
*   *INCLUDE FM06LFFR_FRG_SET .  " FRG_SET
*
*  Full include list after the change - everything else stays SAP
*  standard, so notes on the other release routines still apply:
*&---------------------------------------------------------------------*

  INCLUDE fm06lffr_frg_check_update .   " FRG_CHECK_UPDATE
  INCLUDE fm06lffr_frg_fekko_aufbauen . " FRG_FEKKO_AUFBAUEN

  INCLUDE fm06lffr_frg_info .           " FRG_INFO
  INCLUDE fm06lffr_frg_init .           " FRG_INIT

  INCLUDE fm06lffr_frg_reset .          " FRG_RESET

  INCLUDE fm06lffr_frg_save_check .     " FRG_SAVE_CHECK

  INCLUDE zfm06lffr_frg_set .           " FRG_SET            "+TC001
* INCLUDE fm06lffr_frg_set .            " FRG_SET

  INCLUDE fm06lffr_frg_update .         " FRG_UPDATE
  INCLUDE fm06lffr_frg_update_nachrichte . " FRG_UPDATE_NACHRICHTEN
  INCLUDE fm06lffr_frg_zeile .          " FRG_ZEILE

  INCLUDE fm06lffr_frg_zeile_update .   " FRG_ZEILE_UPDATE

  INCLUDE fm06lffr_frg_update_fb .      " FRG_UPDATE_FB
  INCLUDE fm06lffr_beleg_buchen .       " BELEG_BUCHEN

  INCLUDE fm06lffr_send_message .       " SEND_MESSAGE
