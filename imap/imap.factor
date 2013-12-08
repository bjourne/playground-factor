USING:
    accessors
    arrays
    assocs
    formatting
    fry
    io io.crlf
    io.encodings.ascii
    io.encodings.binary
    io.encodings.string
    io.encodings.utf8
    io.sockets io.sockets.secure
    io.streams.duplex
    kernel
    math.parser
    sequences
    splitting ;
QUALIFIED: pcre
IN: imap

ERROR: imap4-error ind data ;

CONSTANT: IMAP4_PORT     143
CONSTANT: IMAP4_SSL_PORT 993

: check-status ( ind data -- )
    over "OK" = not [ imap4-error ] [ 2drop ]  if ;

: read-response-chunk ( stop-expr -- item ? )
    read-?crlf ascii decode swap dupd pcre:findall
    [
        dup "^.*{(\\d+)}$" pcre:findall
        [
            dup "^\\* (\\d+) [A-Z-]+ (.*)$" pcre:findall
            [ ] [ nip first third second ] if-empty
        ]
        [
            ! Literal item to read, such as message body.
            nip first second second string>number read ascii decode
            read-?crlf drop
        ] if-empty t
    ]
    [ nip first 1 tail values f ] if-empty ;

: read-response ( tag -- lines )
    "^%s (BAD|NO|OK) (.*)$" sprintf
    '[ _ read-response-chunk [ suffix ] dip ] { } swap loop
    unclip-last first2 check-status ;

: write-command ( command literal tag -- )
    -rot [
        [ "%s %s\r\n" sprintf ] [ length "%s %s {%d}\r\n" sprintf ] if-empty
        ascii encode write flush
    ] keep [
        read-?crlf drop "\r\n" append write flush
    ] unless-empty ;

: command-response ( command literal -- obj )
    "ABCD" [ write-command ] [ read-response ] bi ;

: quote ( str -- str' )
    "\\" "\\\\" replace "\"" "\\" replace "\"" "\"" surround ;

! Special parsing
: parse-items ( seq -- items )
    first " " split 2 tail ;

: parse-list-folders ( str -- folder )
    "\\* LIST \\(([^\\)]+)\\) \"([^\"]+)\" \"([^\"]+)\"" pcre:findall
    first 1 tail values ;

: parse-select-folder ( seq -- count )
    [ "\\* (\\d+) EXISTS" pcre:findall [ f ] when-empty ] map-find
    drop first second second string>number ;

! Constructor
: <imap4ssl> ( host -- imap4 )
    IMAP4_SSL_PORT <inet> <secure> binary <client> drop
    ! Read the useless welcome message.
    dup [ "\\*" read-response drop ] with-stream* ;

! IMAP commands
: capabilities ( -- caps )
    "CAPABILITY" "" command-response parse-items ;

: login ( user pass -- caps )
    quote "LOGIN %s %s" sprintf "" command-response parse-items ;

: list-folders ( directory -- folders )
    "LIST \"%s\" *" sprintf "" command-response [ parse-list-folders ] map ;

: select-folder ( mailbox -- count )
    "SELECT %s" sprintf "" command-response parse-select-folder ;

: search-mails ( data-spec str -- uids )
    [ "UID SEARCH CHARSET UTF-8 %s" sprintf ] dip utf8 encode
    command-response parse-items [ string>number ] map ;

: fetch-mails ( seq<number> data-spec -- texts )
    [ [ number>string ] map "," join ] dip
    "UID FETCH %s %s" sprintf "" command-response ;
