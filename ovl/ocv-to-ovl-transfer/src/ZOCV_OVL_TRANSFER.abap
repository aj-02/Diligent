*&---------------------------------------------------------------------*
*& Report         ZOCV_OVL_TRANSFER
*& Description    Transfer of Documents from Colombia OCV to OVL
*&                - Transfer Cutback Items from Venture 2
*&                - Transfer NB Items from Venture 2
*&                - Transfer Corporate Items
*&
*& Functional Spec: Transfer_of_documents_from_Colombia_OCV_to_OVL.docx
*&
*& Includes:
*&   ZOCV_OVL_TRANSFER_TOP  - Global data / type declarations
*&   ZOCV_OVL_TRANSFER_SEL  - Selection screen
*&   ZOCV_OVL_TRANSFER_E01  - Events (INIT, START-OF-SELECTION)
*&   ZOCV_OVL_TRANSFER_F01  - Form routines (all logic)
*&
*& Custom Z-Tables Required:
*&   ZJVMAP_OCV_OVL  - JV Mapping  (Op Co.Code/JV/RecIn -> Rec Co.Code/JV/RecIn)
*&   ZGLMAP_OCV_OVL  - GL Mapping  (Op Co.Code/GL       -> Rec Co.Code/GL)
*&   ZCCMAP_OCV_OVL  - CC Mapping  (Op Co.Code/CC       -> Rec Co.Code/CC)
*&   ZWBSMAP_OCV_OVL - WBS Mapping (Op Co.Code/WBS      -> Rec Co.Code/WBS)
*&   ZPCMAP_OCV_OVL  - PC Mapping  (Op Co.Code/PC       -> Rec Co.Code/PC)
*&---------------------------------------------------------------------*
REPORT zocv_ovl_transfer.

INCLUDE zocv_ovl_transfer_top.    "Global Data Declarations
INCLUDE zocv_ovl_transfer_sel.    "Selection Screen
INCLUDE zocv_ovl_transfer_e01.    "Events
INCLUDE zocv_ovl_transfer_f01.    "Form Routines
