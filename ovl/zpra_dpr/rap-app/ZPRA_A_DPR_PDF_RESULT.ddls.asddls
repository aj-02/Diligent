@EndUserText.label: 'DPR PDF Download - Action Result'
define abstract entity ZPRA_A_DPR_PDF_RESULT
{
  @EndUserText.label: 'PDF File (Base64 encoded)'
  pdf_base64 : abap.string(0);

  @EndUserText.label: 'File Name'
  file_name  : abap.char(100);

  @EndUserText.label: 'MIME Type'
  mime_type  : abap.char(100);

  @EndUserText.label: 'Page Count'
  page_count : abap.int4;

  @EndUserText.label: 'Message'
  message    : abap.char(200);
}
