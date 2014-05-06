USING: alien alien.c-types alien.libraries alien.libraries.finder alien.syntax
arrays formatting io io.pathnames kernel kernel.private math math.private
sequences slots.private ;
IN: bug1021

<< "factor-ffi-test" dup find-library absolute-path cdecl add-library >>

LIBRARY: factor-ffi-test

FUNCTION: void* openssl_ffi ( void* s, int x ) ;

: dummy ( -- ) ;

: each-to100 ( ... quot: ( ... i -- ... ) i -- ... )
    dup 100 < [
        2dup swap (call) 1 + each-to100
    ] [ 2drop ] if ; inline recursive

: run-test ( alien -- seq )
    100 33 <array> swap over
    [
        pick swapd
        openssl_ffi
        -rot swap 2 fixnum+fast set-slot
    ] curry curry 0 each-to100 ;

: small-ex ( -- )
     [
        "%d loop!\n" printf flush
         101 <alien> run-test [ alien-address ] map drop
    ] 2000 iota swap each  ;
