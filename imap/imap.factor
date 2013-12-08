USING:
    accessors
    arrays
    assocs
    formatting
    fry
    io io.crlf
    io.encodings.ascii
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

! Input stream
: check-status ( ind data -- )
    over "OK" = not [ imap4-error ] [ 2drop ]  if ;

: read-response-chunk ( stop-expr -- item ? )
    read-?crlf swap dupd pcre:findall
    [
        dup "^.*{(\\d+)}$" pcre:findall
        [
            dup "^\\* (\\d+) [A-Z-]+ (.*)$" pcre:findall
            [ ] [ nip first third second ] if-empty
        ]
        [
            ! Literal item to read, such as message body.
            nip first second second string>number read
            read-?crlf drop
        ] if-empty t
    ]
    [ nip first 1 tail values f ] if-empty ;

: read-response ( tag -- lines )
    "^%s (BAD|NO|OK) (.*)$" sprintf
    '[ _ read-response-chunk [ suffix ] dip ] { } swap loop
    unclip-last first2 check-status ;

: quote ( str -- str' )
    "\\" "\\\\" replace "\"" "\\" replace "\"" "\"" surround ;

: command-response ( command -- obj )
    "ABCD" [ swap " " glue write crlf flush ] [ read-response ] bi ;

! Special parsing
: parse-items ( seq -- items )
    first " " split 2 tail ;

: parse-list-folders ( str -- folder )
    "\\* LIST \\(([^\\)]+)\\) \"([^\"]+)\" \"([^\"]+)\"" pcre:findall
    first 1 tail values ;

: parse-select-folder ( seq -- count )
    [ "\\* (\\d+) EXISTS" pcre:findall [ f ] when-empty ] map-find
    drop first second second string>number ;

: parse-search-mails ( seq -- uids )
    parse-items [ string>number ] map ;

! Constructor
: <imap4ssl> ( host -- imap4 )
    IMAP4_SSL_PORT <inet> <secure> ascii <client> drop
    ! Read the useless welcome message.
    dup [ "\\*" read-response drop ] with-stream* ;

! IMAP commands
: capabilities ( -- caps )
    "CAPABILITY" command-response parse-items ;

: login ( user pass -- caps )
    quote "LOGIN %s %s" sprintf command-response parse-items ;

: list-folders ( directory -- folders )
    "LIST \"%s\" *" sprintf command-response [ parse-list-folders ] map ;

: select-folder ( mailbox -- count )
    "SELECT %s" sprintf command-response parse-select-folder ;

: search-mails ( query -- uids )
    "UID SEARCH %s" sprintf command-response parse-search-mails ;

: fetch-mails ( seq<number> data-spec -- texts )
    [ [ number>string ] map "," join ] dip
    "UID FETCH %s %s" sprintf command-response ;
