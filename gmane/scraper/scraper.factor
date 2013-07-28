USING:
    accessors
    calendar.format
    combinators
    formatting
    gmane.db gmane.html2text
    html.parser html.parser.analyzer
    kernel
    regexp
    sequences
    splitting ;
IN: gmane.scraper

: mail-url ( n str -- str )
    swap "http://article.gmane.org/gmane.%s/%d" sprintf ;

: remove-all ( seq subseqs -- seq )
    swap [ { } replace ] reduce ;

: select-mail-body ( html -- html' )
    "bodytd" find-by-class-between dup
    [
        [ name>> "script" = ] [ "headers" html-class? ] bi or
    ] find-between-all remove-all ;

: parse-mail-header ( html header -- text )
    [ tags>string ] dip
    ": " append dup "[^\n]+" append <regexp> swapd first-match
    swap "" replace "\t" "" replace ;

: parse-mail ( n str -- mail/f )
    2dup mail-url scrape-html nip dup length 1 =
    [ 3drop f ]
    [
        [ f -rot ] dip
        {
            [ "Date" parse-mail-header ymdhms>timestamp ]
            [ "From" parse-mail-header ]
            [ "Subject" parse-mail-header ]
            [ select-mail-body tags>string ]
        } cleave mail boa
    ] if ;
