USING:
    accessors
    arrays
    calendar.format
    db.tuples
    formatting
    fry
    gmane.db gmane.formatting gmane.scraper
    io
    kernel
    lists lists.lazy
    locals
    math.order
    namespaces
    prettyprint
    sequences ;
IN: gmane.console

: init ( -- )
    [ mail ensure-table ] with-mydb
    "Database created." print ;

:: next-mids ( n group -- seq )
    n 1 lfrom [ group mail-exists? not ] lfilter ltake list>array ;

: import-one ( mid group -- row/err )
  [ "Mail %d:%s does not exist!" sprintf ] 2keep
  parse-mail [ dup insert-mail >>id nip ] when* ;

: import-many ( n group -- )
  [ next-mids reverse ] keep '[ _ import-one ] mail-format generate-table ;

SYMBOL: pagesize
SYMBOL: group

: get-pagesize ( -- n )
    pagesize get [ 25 pagesize set get-pagesize ] unless* ;

: set-pagesize ( n -- )
    dup 1 1000 between?
    [ dup pagesize set "Page size set to %d." sprintf ]
    [ "%d not in range 1-100." sprintf ]
    if print ;

: get-group ( -- group )
    group get [ "comp.lang.factor.general" group set get-group ] unless* ;

: set-group ( group -- )
    dup group set "Group set to %s.\n" printf ;

: import ( -- )
    get-pagesize get-group import-many ;

: recent ( -- )
    [
        <query> T{ mail } get-group >>group >>tuple
        "date desc" >>order get-pagesize >>limit select-tuples
    ] with-mydb mail-format print-table ;

: read-mail ( id -- )
    '[ T{ mail } _ >>id select-tuple ] with-mydb
     [
        dup
        { { "ID" [ id>> ] }
          { "Group" [ group>> ] }
          { "Mid" [ mid>> ] }
          { "Date" [ date>> timestamp>ymdhms ] }
          { "Sender" [ sender>> ] }
          { "Subject" [ subject>> ] }
        } object-table.
        body>>
    ]
    [ "No such mail :-(" ]
    if* print ;
