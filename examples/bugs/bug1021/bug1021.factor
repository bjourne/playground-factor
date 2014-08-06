USING: alien alien.c-types alien.libraries alien.libraries.finder alien.syntax
arrays formatting io io.pathnames kernel kernel.private math math.private
sequences slots.private system ;
IN: examples.bugs.bug1021

<< "factor-ffi-test" dup os windows? [ "lib" prepend ] when
find-library absolute-path cdecl add-library >>

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
        ! dummy
        -rot swap 2 fixnum+fast

        set-slot
    ] curry curry 0 each-to100 ;

: small-ex ( -- )
     [
        "%d loop!\n" printf flush
         101 <alien> run-test [ alien-address ] map drop
    ] 2000 iota swap each  ;



FUNCTION: int test_create_window_ex ( int a, int b, int c ) ;
FUNCTION: void* test_get_module_handle ( int a ) ;

! If any of the alien calls, then writes the array can disappear. I
! can't make the bug happen yet but it should be possible. :)
: my-create-window4 ( a -- b )
    20 7 <array> "bar" test_get_module_handle test_create_window_ex ;
