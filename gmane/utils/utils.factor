USING:
    assocs
    calendar.format
    fry
    kernel
    math
    math.order
    math.parser
    mirrors
    prettyprint
    sequences
    strings
    ;
IN: gmane-utils

! For printing of stuff
! !!!!!!!!!!!!!!!!!!!!!
: table-format-sender ( str -- str )
    dup length 20 min head ;

: table-format ( -- alist )
    {
        { "id" number>string }
        { "group" >string }
        { "date" timestamp>ymd }
        { "sender" table-format-sender }
        { "subject" >string }
    } ;

: header-format ( -- alist )
    {
        { "id" number>string }
        { "group" >string }
        { "mid" number>string }
        { "date" timestamp>ymdhms }
        { "sender" >string }
        { "subject" >string }
    } ;

: pad-strings ( strings -- strings )
    dup longest length '[ _ CHAR: \s  pad-tail  ] map ;

: format-alist ( alist -- lines )
    [ keys pad-strings ] [ values ] bi zip [ " : " join ] map ;

! This awesome introspective code enables one to output a table of
! tuples in the style of their liking.
: printable-tuple ( slots tuple -- values )
    <mirror> >alist '[ first2 swap _ at swap execute( x -- x ) ] map ;

: simple-tuple-table ( tuples slots -- )
    [ '[ _ swap printable-tuple ] map ] keep keys prefix simple-table. ;

: format-tuple ( slots tuple -- lines )
    dupd printable-tuple [ keys ] dip zip format-alist ;

