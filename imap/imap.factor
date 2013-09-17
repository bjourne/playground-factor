USING:
    accessors
    arrays
    calendar
    combinators
    formatting
    io io.crlf
    io.encodings.ascii
    io.sockets io.sockets.secure
    io.streams.duplex
    kernel
    math.parser
    sequences
    splitting
    strings ;
IN: imap

CONSTANT: IMAP4_PORT     143
CONSTANT: IMAP4_SSL_PORT 993

TUPLE: imap4ssl stream remote tagpre tagnum ;

: quote ( str -- str' )
    "\\" "\\\\" replace "\"" "\\" replace "\"" "\"" surround ;

: read-line ( imap4 -- str )
    stream>> [ read-?crlf ] with-stream* ;

: command ( string -- )
    write crlf flush ;

: command-response ( command imap4 -- resp )
    [ tagpre>> ] [ stream>> ] bi
    [ write " " write command read-?crlf ] with-stream* ;

: <imap4ssl> ( host -- welcome imap4 )
    IMAP4_SSL_PORT <inet> <secure> ascii <client> "ABCD" 0 imap4ssl boa
    [ read-line ] keep ;

: capabilities ( imap4 -- resp )
    "CAPABILITY" swap command-response ;

: login ( imap4 user pass -- resp )
    quote "LOGIN %s %s" sprintf swap command-response ;
