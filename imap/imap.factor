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

CONSTANT: UNTAGGED_RESPONSE  "^\\* (?P<type>[A-Z-]+)(?: (?P<data>.*))?$"

CONSTANT: IMAP4_PORT     143
CONSTANT: IMAP4_SSL_PORT 993

TUPLE: imap4ssl stream tagpre tagnum ;

! Input stream
: check-status ( ind data -- )
    over "OK" = not [ imap4-error ] [ 2drop ]  if ;

: read-response ( tag -- lines )
    "^%s (?P<ind>BAD|NO|OK) (?P<data>.*)$" sprintf
    ! Can a better combinator than 'loop' be used?
    '[
        read-?crlf dup _ pcre:findall
        [ suffix t ]
        [ nip first 1 tail values suffix f ] if-empty
    ] { } swap loop unclip-last first2 check-status ;

: quote ( str -- str' )
    "\\" "\\\\" replace "\"" "\\" replace "\"" "\"" surround ;

: command-response ( imap4 command -- x )
    swap [ tagpre>> ] [ stream>> ] bi
    [ [ swap " " glue write crlf flush ] [ read-response ] bi ] with-stream* ;

! Special parsing
: parse-capabilities ( seq -- caps )
    first UNTAGGED_RESPONSE pcre:findall first "data" of " " split ;

: parse-list-folders ( str -- folder )
    "\\* LIST \\(([^\\)]+)\\) \"([^\"]+)\" \"([^\"]+)\"" pcre:findall
    first 1 tail values ;

: parse-select-folder ( seq -- count )
    [ "\\* (\\d+) EXISTS" pcre:findall [ f ] when-empty ] map-find
    drop first second second string>number ;

! Constructor
: <imap4ssl> ( host -- imap4 )
    IMAP4_SSL_PORT <inet> <secure> ascii <client> drop "ABCD" 0 imap4ssl boa
    dup stream>> [ "\\*" read-response ] with-stream* drop ;

! IMAP commands
: capabilities ( imap4 -- caps )
    "CAPABILITY" command-response parse-capabilities ;

: login ( imap4 user pass -- caps )
    quote "LOGIN %s %s" sprintf command-response parse-capabilities ;

: list-folders ( imap4 directory -- folders )
    "LIST \"%s\" *" sprintf command-response [ parse-list-folders ] map ;

: select-folder ( imap4 mailbox -- x )
    "SELECT %s" sprintf command-response parse-select-folder ;
