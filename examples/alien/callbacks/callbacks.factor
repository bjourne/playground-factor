USING: alien alien.accessors alien.c-types alien.data
alien.syntax kernel math math.functions random sequences
specialized-arrays trees.private ;
IN: examples.alien.callbacks

LIBRARY: libc

FUNCTION: void qsort ( void* base,
                       size_t num,
                       size_t width,
                       void* func ) ;

SPECIALIZED-ARRAY: uint

CALLBACK: int comparer ( void* arg1, void* arg2 ) ;

: <comparer> ( -- alien )
    [
        [ 0 alien-unsigned-4 ] bi@ key-side
    ] comparer ;

: random-array ( length -- seq )
    [ 100 random ] replicate ;

: qsort-seq ( seq type -- seq' )
    2dup >c-array [
        -rot [ length ] [ heap-size ] bi* <comparer> qsort
    ] keep ;
