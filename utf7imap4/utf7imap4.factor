! Credit goes to this python module:
! http://svn.plone.org/svn/collective/mxmImapClient/trunk/imapUTF7.py
USING:
    arrays
    ascii
    base64
    combinators
    io.encodings.utf16 io.encodings.string
    kernel
    math math.functions math.order
    sequences
    splitting
    strings ;
IN: utf7imap4

: modified-unbase64 ( seq -- seq' )
    "," "/" replace dup length 4 / ceiling 4 * CHAR: = pad-tail
    base64> utf16be decode ;

: modified-base64 ( seq -- seq' )
    [ { } ] [
        >string utf16be encode >base64 "/" "," replace
        [ CHAR: = = ] trim-tail "&" "-" surround
    ] if-empty ;

: decode-char ( result buffer ch -- result buffer )
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
        [ first2 ] dip decode-char 2array
    ] reduce first >string ;

: encode-char ( result buffer ch -- result buffer )
    dup printable? [
        -rot modified-base64 append swap
        dup CHAR: & = [ drop "&-" append ] [ suffix ] if { }
    ] [ suffix ] if ;

: encode-utf7imap4 ( str -- str )
    { { } { } } [
        [ first2 ] dip encode-char 2array
    ] reduce first2 modified-base64 append >string ;
