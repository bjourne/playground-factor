! Credit goes to this python module:
! http://svn.plone.org/svn/collective/mxmImapClient/trunk/imapUTF7.pyö
USING:
    arrays
    ascii
    base64
    io.encodings.utf16 io.encodings.string
    kernel
    math math.functions math.order
    sequences
    splitting
    strings ;
IN: utf7imap4

: modified-unbase64 ( str -- str' )
    "," "/" replace dup length 4 / ceiling 4 * CHAR: = pad-tail
    base64> utf16be decode ;

: modified-base64 ( str -- str' )
    [ "" ] [
        >string utf16be encode >base64 "/" "," replace
        [ CHAR: = = ] trim-tail "&" "-" surround
    ] if-empty ;

: decode-char ( result buffer ch -- result buffer )
    2dup CHAR: & = swap empty? not or [
        dup CHAR: - = [
            drop 1 tail [ "&" ] [ modified-unbase64 ] if-empty append ""
        ] [ suffix ] if
    ] [ swapd suffix swap ] if ;

: decode-utf7imap4 ( array -- str )
    { "" "" } [
        [ first2 ] dip decode-char 2array
    ] reduce first >string ;

: encode-char ( result buffer ch -- result buffer )
    dup printable? [
        -rot modified-base64 append swap
        dup CHAR: & = [ drop "&-" append ] [ suffix ] if ""
    ] [ suffix ] if ;

: encode-utf7imap4 ( str -- str )
    { "" "" } [
        [ first2 ] dip encode-char 2array
    ] reduce first2 modified-base64 append >string ;
