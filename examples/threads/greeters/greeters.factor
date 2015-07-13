! How to spawn threads
USING: accessors calendar formatting io kernel math sequences threads ;
IN: examples.threads.greeters

: greeting ( n -- )
    self id>> "greeting %d from %d...\n" printf flush ;
: delay ( -- )
    1 seconds sleep ;
: greeter ( -- )
    10 iota [ greeting delay ] each ;

: main ( -- )
    10 [ [ greeter ] "printer" spawn drop ] times
    20 seconds sleep ;

MAIN: main
