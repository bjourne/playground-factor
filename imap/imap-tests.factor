USING:
    accessors
    arrays
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

CONSTANT: host "imap.gmail.com"
! Set these to your email account.
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

! Subject searching
[ f ] [
    imap-login [
        "py-lists/python-list" select-folder drop
        "SUBJECT" "google groups" search-mails
        "BODY.PEEK[HEADER.FIELDS (SUBJECT)]" fetch-mails
    ] with-stream empty?
] unit-test
