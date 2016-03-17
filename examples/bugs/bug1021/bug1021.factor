USING: alien alien.c-types alien.libraries alien.libraries.finder alien.syntax
arrays formatting io io.pathnames kernel kernel.private math math.private
sequences slots.private system ;
IN: examples.bugs.bug1021

<< "factor-ffi-test" dup os windows? [ "lib" prepend ] when
find-library absolute-path cdecl add-library >>

LIBRARY: factor-ffi-test

FUNCTION: void* bug1021_test_1 ( void* s, int x )

: dummy ( -- ) ;

: each-to100 ( ... quot: ( ... i -- ... ) i -- ... )
    dup 100 < [
        2dup swap (call) 1 + each-to100
    ] [ 2drop ] if ; inline recursive

: run-test ( alien -- seq )
    100 33 <array> swap over
    [
        pick swapd
        bug1021_test_1
        ! dummy
        -rot swap 2 fixnum+fast

        set-slot
    ] curry curry 0 each-to100 ;

: small-ex ( -- )
     [
        "%d loop!\n" printf flush
         101 <alien> run-test [ alien-address ] map drop
    ] 2000 iota swap each  ;

! This example doesn't fail unless you apply my pr which empties the
! nursery because of shadow data.
FUNCTION: int bug1021_test_2 ( int a, char* b, void* c )
FUNCTION: void* bug1021_test_3 ( c-string a )
USING: byte-arrays alien.strings ;

: doit ( a -- d )
    33 1byte-array "bar" bug1021_test_3 bug1021_test_2 ;

: doit-tests ( -- )
    100000 [ 0 doit 33 assert= ] times ;
