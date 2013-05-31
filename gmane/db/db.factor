USING:
    calendar
    db db.sqlite db.tuples db.types
    fry
    kernel
    math math.ranges
    random
    sequences
    strings ;
IN: gmane.db

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
    "gmane.db" <sqlite-db> swap with-db ; inline

: ascii-lower ( -- seq )
    CHAR: a CHAR: z [a,b] ;

: random-ascii ( n -- str )
    [ ascii-lower random ] replicate >string ;

: random-mail ( -- mail )
    f
    5000 random
    10 random-ascii
    now 1000 random 500 - days time+
    { 15 30 80 } [ random-ascii ] map first3
    mail boa ;

: insert-mail ( mail -- id )
    '[ _ insert-tuple last-insert-id ] with-mydb ;

: mail-exists? ( mid group -- mail/f )
    '[ T{ mail } _ >>mid _ >>group select-tuple ] with-mydb ;
