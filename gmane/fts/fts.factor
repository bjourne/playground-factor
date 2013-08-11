USING:
    accessors
    arrays
    assocs
    db db.queries db.sqlite db.tuples db.tuples.private db.types
    destructors
    formatting
    fry
    gmane.db
    io
    kernel
    math.parser
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

: <word> ( str -- word )
  f swap word boa ;

: init ( -- )
  [ { word word-to-mail indexed-mail } ensure-tables ] with-mydb ;

: get-search-string ( mail -- str )
    <mirror> { "group" "sender" "subject" "body" } [ of ] with map "\n" join ;

: string>tokens ( str -- seq )
  >lower [ letter? not ] split-when harvest members ;

: select-words ( seq -- word-ids )
    <word> select-tuples ;

: insert-missing-words ( seq -- )
    dup select-words [ str>> ] map diff [ <word> insert-tuple ] each ;

: ensure-words ( seq -- word-ids )
  dup insert-missing-words select-words [ id>> ] map ;

: index-mail ( mail -- index-result )
  [
    [ id>> dup indexed-mail boa insert-tuple ]
    [ subject>> ]
    [
      [ get-search-string string>tokens ensure-words ] keep
      id>> '[ _ word-to-mail boa insert-tuple t ] count
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

! My own string interpolation syntax. Does something usable exist in stdlib?
: interpolate-string ( params format -- str )
  [ "$%d" sprintf swap replace ] reduce-index ;

: join-format ( -- format )
  "join word_to_mail wtm$1 on wtm$1.mail_id = m.id "
  "join word w$1 on wtm$1.word_id = w$1.id and w$1.str = '$0'"
  append ;

: tokens>search-query ( tokens -- str )
  [ number>string 2array join-format interpolate-string ] map-index
  " " join "select m.* from mail m %s" sprintf ;
