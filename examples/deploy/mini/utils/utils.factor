USING: byte-arrays formatting fry hashtables.private io io.streams.c
kernel kernel.private macros math.private sequences sequences.private
slots.private ;
IN: examples.deploy.mini.utils

: printff ( fmt -- )
    sprintf print flush ; inline

! Generic-safe words. These should be used after generic stripping.

MACRO: safe-show ( msg -- quot )
    "\n" append >byte-array dup length '[
        _ _ stdout-handle fwrite
        stdout-handle fflush
    ] ;

: safe-first ( array -- first )
    0 swap array-nth ;

: safe-second ( array -- first )
    1 swap array-nth ;

: safe++ ( fixnum -- fixnum' )
    1 fixnum+fast ;

: (safe-of) ( array key n -- val/f )
    pick 1 slot dupd fixnum< [
        ! array key n
        pick dupd
        ! array key n n array
        array-nth
        ! array key n elt
        pick over
        ! array key n elt key elt
        safe-first eq? [
            2nip nip safe-second
        ] [
            drop safe++ (safe-of)
        ] if
    ] [
        3drop f
    ] if ;

: safe-of ( array key -- val/f )
    0 (safe-of) ;

: clear-specials ( start end -- )
    2dup fixnum> [ 2drop ] [
        swap dup f swap set-special-object
        safe++ swap clear-specials
    ] if ;

: clear-word-props ( word -- )
    f swap 5 set-slot ;

: word-pic-def ( word -- pic-def )
    6 slot ;

: word-pic-tail-def ( word -- pic-tail-def )
    7 slot ;

: word-set-def ( value word -- )
    4 set-slot ;

: safe-clear-hash ( hash -- )
    dup 0 swap 2 set-slot
    dup 0 swap 3 set-slot
    4 slot [ drop ((empty)) ] map! drop ;
