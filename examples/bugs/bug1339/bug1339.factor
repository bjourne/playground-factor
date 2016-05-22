USING: arrays bit-arrays formatting fry kernel kernel.private math
math.private sequences sequences.private ;
IN: examples.bugs.bug1339

: my-nth-unsafe ( n seq -- el )
    [ { array-capacity } declare ] dip nth-unsafe ; inline

: bar2 ( n -- m )
    [ 0 ] dip dup <bit-array>
    '[ _ nth [ 77 + ] when ] each-integer ;

: bar ( n -- m )
    [ 0 ] dip dup <bit-array>
    '[ _ nth-unsafe [ 77 + ] when ] each-integer ;

: bar3 ( n -- m )
    [ 0 ] dip <bit-array> dup length swap
    '[ _ nth-unsafe [ 77 + ] when ] each-integer ;

: ok ( x y z -- )
    "%u %u %u\n" printf ;

: foo ( n -- m )
    0 0 rot
    dup 3 <array>
    [
        ! 3dup ok
        bounds-check
        [ integer>fixnum ] dip array-nth +
    ] curry
    (each-integer) ;

: (foo3) ( seq sum n len -- sum' )
    2dup < [
        ! seq sum n len
        [
            ! seq sum n | len
            pick dupd
            ! seq sum n n seq | len
            ! 2dup 1 slot { array-capacity } declare < [ bounds-error ] unless
            ! nth
            nth-unsafe
            ! seq sum n el | len
            rot +
            ! seq n sum' | len
            swap 1 +
        ] dip
        ! seq sum' n len
        (foo3)
    ] [ 2drop nip ] if ; inline recursive

: <my-array> ( n el -- m )
    [ { array-capacity } declare ] dip <array> ; inline

: foo3 ( n -- m )
    dup 3
    ! n n 3
    <array>
    ! n arr
    0 rot
    ! arr 0 n
    0 swap
    ! arr 0 0 n
    (foo3) ; inline


! Better each
: ((my-each)) ( seq -- n quot )
    [ length check-length
      integer>fixnum
    ] keep [ nth-unsafe ] curry ; inline

: (my-each) ( seq quot -- n quot' ) [ ((my-each)) ] dip compose ;
    inline

: my-each ( ... seq quot: ( ... x -- ... ) -- ... )
    (my-each) each-integer ; inline
