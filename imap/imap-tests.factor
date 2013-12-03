USING:
    accessors
    arrays
    continuations
    imap
    kernel
    namespaces
    pcre
    sequences
    sets
    tools.test ;
IN: imap.tests

CONSTANT: host "imap.gmail.com"
! Set these to your email account.
SYMBOLS: email password ;

[ t ] [
    host <imap4ssl> imap4ssl?
] unit-test

[ t ] [
    host <imap4ssl> capabilities
    { "IMAP4rev1" "UNSELECT" "IDLE" "NAMESPACE" "QUOTA" } swap subset?
] unit-test

[ "NO" ] [
    [ host <imap4ssl> "dont@exist.com" "foo" login ] [ ind>> ] recover
] unit-test

[ "BAD" ] [
    [ host <imap4ssl> f f login ] [ ind>> ] recover
] unit-test

[ t ] [
    host <imap4ssl> email get password get login empty? not
] unit-test
