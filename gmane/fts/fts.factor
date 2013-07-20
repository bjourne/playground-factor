USING:
    accessors
    assocs
    db db.queries db.sqlite db.tuples db.tuples.private db.types
    destructors
    formatting
    fry
    gmane.db gmane.formatting
    io
    kernel
    math math.parser
    mirrors
    sequences
    sets
    splitting
    strings
    tools.time
    unicode.case unicode.categories ;
IN: gmane.fts

TUPLE: word id str ;

word "word" {
  { "id" "id" +db-assigned-id+ }
  { "str" "str" TEXT }
} define-persistent

TUPLE: word-to-mail word-id mail-id ;

word-to-mail "word_to_mail" {
  { "word-id" "word_id" INTEGER }
  { "mail-id" "mail_id" INTEGER }
} define-persistent

TUPLE: indexed-mail mail-id ;

indexed-mail "indexed_mail" {
  { "mail-id" "mail_id" INTEGER }
} define-persistent

TUPLE: index-result id subject word-count elapsed-time ;

: nanoseconds>string ( n -- str )
  1000000000 /f "%.2f" sprintf ;

: index-result-format ( -- seq )
    {
        { "id" t 5 number>string }
        { "subject" f 50 >string }
        { "word-count" t 10 number>string }
        { "elapsed-time" t 20 nanoseconds>string }
    } ;

: <word> ( str -- word )
    f swap word boa ;

: db-init ( -- )
    [ { word word-to-mail indexed-mail } ensure-tables ] with-mydb ;

: get-search-string ( mail -- str )
    <mirror> '[ _ at ] { "body" "group" "sender" "subject" } swap map " " join ;

: string>tokens ( str -- seq )
    >lower [ letter? not ] split-when harvest members ;

: ensure-words ( seq -- word-ids )
    dup T{ word } swap >>str select-tuples
    [ [ str>> ] map diff [ <word> insert-tuple last-insert-id ] map ] keep
    [ id>> ] map append ;

: index-mail ( mail -- index-result )
  [
    [ id>> dup indexed-mail boa insert-tuple ]
    [ subject>> ]
    [
      [ get-search-string string>tokens ensure-words dup ] keep
      id>> '[ _ word-to-mail boa insert-tuple ] each length
    ] tri
  ] benchmark index-result boa ;

: raw-select-tuples ( sql class -- seq )
    dup new -rot sql-props swap <simple-statement>
    [ query-tuples ] with-disposal ;

: missing-mails ( -- seq )
    {
        "select m.*"
        "from mail m left join indexed_mail im on im.mail_id = m.id"
        "where im.mail_id is null"
    } " " join mail raw-select-tuples ;

: update ( -- )
  index-result-format table-header print-row
  [
    missing-mails
    [ index-mail index-result-format swap table-row print-row ] each
  ] with-mydb ;
