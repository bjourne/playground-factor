USING:
    accessors
    calendar 
    classes.tuple
    db db.sqlite db.tuples db.types
    fry
    io io.files io.files.temp
    kernel
    math math.ranges
    random
    sequences
    strings 
    ;
IN: gmane-db

TUPLE: mail id mid group date sender subject body ;

mail "mail" {
    { "id" "id" +db-assigned-id+ }
    { "mid" "mid" INTEGER }
    { "group" "group_" TEXT }
    { "date" "date" DATETIME }
    { "sender" "sender" TEXT }
    { "subject" "subject" TEXT }
    { "body" "body" TEXT }
} define-persistent

: with-mydb ( quot -- )
    "test.db" temp-file <sqlite-db> swap with-db ; inline

: find-mail ( mid group -- mail/f )
    '[ T{ mail } _ >>mid _ >>group select-tuple ] with-mydb ;

: insert-mail ( mail -- )
    '[ _ insert-tuple ] with-mydb ;

: ascii-lower ( -- seq )
    CHAR: a CHAR: z [a,b] ;

: random-ascii ( n -- str )
    [ ascii-lower random ] replicate >string ;

: random-mail ( -- mail )
    f
    ! Random mid
    5000 random
    ! Random group
    10 random-ascii
    ! Random timestamp
    now 1000 random 500 - days time+ 
    ! Four random strings for sender, subject and body
    ! respectively.
    { 15 30 80 } [ random-ascii ] map first3
    mail boa ;


