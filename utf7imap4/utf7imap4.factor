USING:
    arrays
    base64
    combinators
    io.encodings.utf16 io.encodings.string
    kernel
    math math.functions
    sequences
    splitting
    strings ;
IN: utf7imap4

: modified-unbase64 ( seq -- seq' )
    "," "/" replace dup length 4 / ceiling 4 * CHAR: = pad-tail
    base64> utf16be decode ;


: process-char ( result buffer ch -- result buffer )
    2dup [ empty? ] [ [ CHAR: & = ] [ CHAR: - = ] bi ] bi* 3array
    {
        { { f f t } [
            drop 1 tail
            [ "&" ] [ modified-unbase64 ] if-empty append { }
        ] }
        { { t t f } [ suffix ] }
        { { f f f } [ suffix ] }
        [ drop swapd suffix swap ]
    } case ;

: decode-utf7imap4 ( array -- str )
    { { } { } } [
        [ first2 ] dip process-char 2array
    ] reduce first >string ;
