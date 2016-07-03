USING: formatting kernel kernel.private math memory sequences.private
tools.time ;
IN: examples.bugs.bug789

: foo1 ( x -- n ) { array-capacity } declare 200000000 [ 1 + ] times ;

: foo2 ( x -- n )
    { array-capacity } declare 200000000 [ { array-capacity } declare 1 + ] times ;

: time2 ( -- )
    gc [ 10 foo2 drop ] time ;

: main ( -- )
    time2 ;

MAIN: main
