USING:
    accessors
    arrays
    assocs
    calendar calendar.format
    combinators
    continuations
    formatting
    imap
    io.streams.duplex
    kernel
    math math.parser math.statistics
    namespaces
    pcre
    random
    sequences
    sets
    strings
    tools.test ;
IN: imap.tests

! Set these to your email account.
CONSTANT: host "imap.gmail.com"
SYMBOLS: email password ;

: make-mail ( from -- mail )
    now timestamp>rfc822 swap 10000 random
    3array {
        "Date: %s"
        "From: %s"
        "Subject: afternoon meeting"
        "To: mooch@owatagu.siam.edu"
        "Message-Id: <%d@Blurdybloop.COM>"
        "MIME-Version: 1.0"
        "Content-Type: TEXT/PLAIN; CHARSET=US-ASCII"
        ""
        "Hello Joe, do you think we can meet at 3:30 tomorrow?"
    } "\r\n" join vsprintf ;

: sample-mail ( -- mail )
    "Fred Foobar <foobar@Blurdybloop.COM>" make-mail ;

[ t ] [
    host <imap4ssl> duplex-stream?
] unit-test

[ t ] [
    host <imap4ssl> [ capabilities ] with-stream
    { "IMAP4rev1" "UNSELECT" "IDLE" "NAMESPACE" "QUOTA" } swap subset?
] unit-test

[ "NO" ] [
    [ host <imap4ssl> [ "dont@exist.com" "foo" login ] with-stream ]
    [ ind>> ] recover
] unit-test

[ "BAD" ] [
    [ host <imap4ssl> [ f f login ] with-stream ] [ ind>> ] recover
] unit-test

! Fails unless you have set the settings.
: imap-login ( -- imap4 )
    host <imap4ssl> dup [ email get password get login drop ] with-stream* ;

[ f ] [
    host <imap4ssl> [
        email get password get login
    ] with-stream empty?
] unit-test

[ f ] [
    imap-login [ "*" list-folders empty? ] with-stream
] unit-test

! You need to have some mails in your inbox!
[ t ] [
    imap-login [ "INBOX" select-folder ] with-stream 0 >
] unit-test

[ f ] [
    imap-login [
        "INBOX" select-folder drop "ALL" "" search-mails
    ] with-stream empty?
] unit-test

! Read some mails
[ t ] [
    imap-login [
        "INBOX" select-folder drop "ALL" "" search-mails
        5 sample "(RFC822)" fetch-mails
    ] with-stream [ [ string? ] all? ] [ length 5 = ] bi and
] unit-test

! Subject searching. This test is specific to my account.
[ f ] [
    imap-login [
        "py-lists/python-list" select-folder drop
        "SUBJECT" "google groups" search-mails
        "BODY.PEEK[HEADER.FIELDS (SUBJECT)]" fetch-mails
        empty?
        ! Another search with an UNSEEN flag
        "INBOX" select-folder drop
        "UNSEEN SUBJECT" "week" search-mails
        "BODY.PEEK[HEADER.FIELDS (SUBJECT)]" fetch-mails
        empty?
        ! Mails since
        "INBOX" select-folder drop
        "(SINCE \"01-Jan-2014\")" "" search-mails
        "BODY.PEEK[HEADER.FIELDS (SUBJECT)]" fetch-mails
        empty?
    ] with-stream or or
] unit-test

! Folder management
[ 0 ] [
    imap-login [
        "örjan" [ create-folder ] [ select-folder ] [ delete-folder ] tri
    ] with-stream
] unit-test

! Stat folder. Again specific to my account.
[ t ] [
    imap-login [
        "INBOX" { "MESSAGES" "UNSEEN" } status-folder
    ] with-stream [ "MESSAGES" of 0 > ] [ "UNSEEN" of 0 > ] bi and
] unit-test

! Rename folder
[ ] [
    imap-login [
        "日本語" [ create-folder ] [
            "ascii-name" [ rename-folder ] [ delete-folder ] bi
        ] bi
    ] with-stream
] unit-test

! Create a folder hierarchy
[ t ] [
    imap-login [
        "*" list-folders length
        "foo/bar/baz/日本語" [
            create-folder "*" list-folders length 4 - =
        ] [ delete-folder ] bi
    ]  with-stream
] unit-test

! A gmail compliant way of creating a folder hierarchy.
[ ] [
    imap-login [
        "foo/bar/baz/boo" "/" split { } [ suffix ] cum-map [ "/" join ] map
        [ [ create-folder ] each ] [ [ delete-folder ] each ] bi
    ] with-stream
] unit-test

! Interacting with gmail threads
[ f ] [
    imap-login [
        "INBOX" select-folder drop
        "SUBJECT" "datetime" search-mails
        "(UID X-GM-THRID)" fetch-mails
    ] with-stream empty?
] unit-test

[ ] [
    imap-login [
        "örjan" {
            [ create-folder ]
            [ select-folder drop ]
            ! Append mail with a seen flag
            [ "(\\Seen)" now sample-mail append-mail drop ]
            ! And one without
            [ "" now sample-mail append-mail drop ]
            [ delete-folder ]
        } cleave
    ] with-stream
] unit-test

! Exercise store-mail
[ t ] [
    imap-login [
        "INBOX" select-folder drop "ALL" "" search-mails
        5 sample "+FLAGS" "(\\Recent)" store-mail
    ] with-stream length 5 =
] unit-test
