USING:
    arrays
    assocs
    calendar.format
    combinators
    formatting formatting.private
    fry
    io io.streams.string
    kernel
    locals
    math.parser
    mirrors
    prettyprint
    sequences
    strings ;
IN: gmane.formatting

: printf>write-quot ( quot -- quot' )
    {
        { [ dup string? ] [ '[ _ ] ] }
        { [ dup [ "%" ] = ] [ '[ _ first ] ] }
        [ '[ unclip @ ] ]
    } cond [ write ] append ;

: vprintf ( seq format -- )
    parse-printf reverse [ first printf>write-quot ] map
    compose-all call( x -- x ) drop ;

: vsprintf ( seq format -- str )
    [ vprintf ] with-string-writer ;

: vsprintf1 ( elt format -- str )
    [ 1array ] dip vsprintf ;

: db-assigned-id>string ( number/f -- str )
    [ number>string ] [ "f" ] if* ;

: mail-format ( -- seq )
    {
        { "id" t 6 db-assigned-id>string }
        { "mid" t 5 number>string }
        { "group" f 12 >string }
        { "date" f 10 timestamp>ymd }
        { "sender" f 15 >string }
        { "subject" f 45 >string }
    } ;

: table-header ( format -- header-cells )
    [ first3 nip "%%-%ds" vsprintf1 vsprintf1 ] map ;

: table-cell-format ( right-align width -- str )
    [ "" "-" ? ] dip 2array "%%%s%ds" vsprintf ;

: table-cell ( right-align width word value -- str )
    swap execute( x -- x ) over short head -rot table-cell-format vsprintf1 ;

: table-row ( format row -- row-cells )
    <mirror> '[ unclip _ at suffix first4 table-cell ] map ;

: print-table ( seq format -- )
    [ '[ _ swap table-row ] map ] [ table-header ] bi prefix simple-table. ;

: print-row ( seq -- )
    1array simple-table. flush ;

: generate-table ( seq quot format -- )
  dup table-header print-row
  '[
    @ _ swap dup string? [ print flush drop ] [ table-row print-row ] if
  ] each ; inline
