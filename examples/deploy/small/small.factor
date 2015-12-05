USING: accessors kernel kernel.private
math.ranges memory quotations sequences slots.private system words ;
IN: examples.deploy.small

: main-word ( -- ) 99 (exit) ;

: clear-specials ( start end -- )
    [a,b] [ f swap set-special-object ] each ;

: strip-word ( id-quot word -- )
    f >>props f >>name f >>vocabulary def<< ;

: small-image ( -- )
    ! Stripped and pre-compiled identity quot.
    [ ] dup jit-compile dup f swap 1 set-slot

    [ word? ] instances [ strip-word ] with each

    ! Can't get rid of c-to-factor primitive because it's tied to a
    ! callback.
    f C-TO-FACTOR-WORD special-object 8 set-slot
    \ main-word 9 slot C-TO-FACTOR-WORD special-object 9 set-slot
    \ main-word C-TO-FACTOR-WORD set-special-object

    ! Startup quot, global and shutdown quot
    OBJ-STARTUP-QUOT OBJ-SHUTDOWN-QUOT clear-specials

    ! JIT removal, must be done almost last.
    JIT-PROLOG JIT-DECLARE-WORD clear-specials

    ! Entry points and signal handlers we can do without
    LAZY-JIT-COMPILE-WORD REDEFINITION-COUNTER clear-specials

    ! PIC things, megamorphic caches, undefined and stderr
    PIC-LOAD OBJ-STDERR clear-specials
    "whatever.image" save-image-and-exit ;

MAIN: small-image
