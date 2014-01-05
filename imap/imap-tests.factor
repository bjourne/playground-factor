USING:
    accessors
    arrays
    assocs
    continuations
    imap
    io.streams.duplex
    kernel
    math
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
    host <imap4ssl> [ email get password get login ] with-stream empty?
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
        5 sample "(RFC822)" fetch-mails [ string? ] all?
    ] with-stream
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

! Interacting with gmail threads
[ f ] [
    imap-login [
        "INBOX" select-folder drop
        "SUBJECT" "datetime" search-mails
        "(UID X-GM-THRID)" fetch-mails
    ] with-stream empty?
] unit-test
