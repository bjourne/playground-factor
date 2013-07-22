USING: db gmane.db gmane.formatting gmane.fts ;
IN: gmane.fts.console

: nanoseconds>string ( n -- str )
  1000000000 /f "%.2f" sprintf ;

: index-result-format ( -- seq )
  {
    { "id" t 5 number>string }
    { "subject" f 50 >string }
    { "word-count" t 10 number>string }
    { "elapsed-time" t 20 nanoseconds>string }
  } ;

: search ( string -- )
  [
    string>tokens tokens>search-query mail raw-select-tuples
    mail-format print-table
  ] with-mydb ;

: update ( -- )
  [
    missing-mails [ [ index-mail ] with-transaction ]
    index-result-format generate-table
  ] with-mydb ;
