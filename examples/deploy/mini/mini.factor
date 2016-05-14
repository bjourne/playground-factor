! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays examples.deploy.mini.features
examples.deploy.mini.generics examples.deploy.mini.utils
examples.deploy.mini.word-stripping generic growable io.backend
io.pathnames kernel kernel.private literals locals memory
memory.private namespaces parser sequences slots.private strings
vectors vocabs vocabs.loader words ;
IN: examples.deploy.mini

: strip-jit-compiler ( -- )
    "Stripping JIT compiler..." safe-show

    ! JIT removal, must be done almost last.
    JIT-PROLOG JIT-DECLARE-WORD clear-specials

    ! PIC things, megamorphic caches, undefined and stderr
    PIC-LOAD OBJ-STDERR clear-specials ;

: clean-special-words ( redir-word -- )
    "Setting images main word..." safe-show
    ! Primitive words that are required for generics, but whose code
    ! blocks we can overwrite.
    ${
        C-TO-FACTOR-WORD
        JIT-DIP-WORD
        JIT-IF-WORD
        JIT-PRIMITIVE-WORD
    } [
        dup f swap special-object 8 set-slot
        [ 9 slot ] dip special-object 9 set-slot
    ] with each ;

! These are the classes that are required to finish deploying the
! image.
CONSTANT: base-classes {
    array string vector
}

: recompile-generics ( generics classes -- )
    "Recompiling generics..." safe-show
    forget-other-methods ;

: cleanup-globals ( -- )
    "Cleaning globals..." safe-show ;

:: word>factor-image ( image-path word features -- )

    image-path normalize-path saving-path :> ( saving-path real-path )

    [ generic? ] instances
    features required-classes safe-of base-classes append
    recompile-generics

    ! After generic stripping we have to be *very* careful because a
    ! lot of words won't work.
    "Stripping words..." safe-show
    features word-names? safe-of strip-words

    "Cleaning globals..." safe-show
    features global-hash? safe-of [ cleanup-globals ] [
        f OBJ-GLOBAL set-special-object
    ] if

    word clean-special-words

    ! Startup quot, global and shutdown quot
    f OBJ-STARTUP-QUOT set-special-object
    f OBJ-SHUTDOWN-QUOT set-special-object

    ! Canonicals
    f OBJ-BIGNUM-ZERO set-special-object
    f OBJ-BIGNUM-POS-ONE set-special-object
    f OBJ-BIGNUM-NEG-ONE set-special-object
    f OBJ-CANONICAL-TRUE set-special-object

    ! It's fine as long as the value is != f
    20 OBJ-STAGE2 set-special-object

    ! Entry points and signal handlers we can do without
    LAZY-JIT-COMPILE-WORD REDEFINITION-COUNTER clear-specials

    f OBJ-UNDEFINED set-special-object

    features quotation-compiler? safe-of [
        strip-jit-compiler
    ] unless

    saving-path real-path t (save-image) ;

: vocab-main-and-features ( vocab-name -- main-word features )
    [ load-vocab vocab-main dup "loc" word-prop first run-file ]
    [ "features" swap lookup-word execute( -- assoc ) ] bi ;

: main ( -- )
    current-directory get vocab-roots get push
    "output-image" get
    "deploy-vocab" get
    2dup swap "Deploying %u to %u..." printff
    vocab-main-and-features word>factor-image ;

MAIN: main
