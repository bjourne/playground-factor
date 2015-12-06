! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs examples.deploy.mini.features
examples.deploy.mini.generics examples.deploy.mini.utils io.backend
io.pathnames kernel kernel.private literals locals memory
memory.private namespaces parser quotations sequences slots.private
vocabs vocabs.loader words ;
IN: examples.deploy.mini

: strip-word ( id-quot word -- )
    dup clear-word-props
    dup word-pic-def [ jit-compile ] when*
    dup word-pic-tail-def [ jit-compile ] when*
    word-set-def ;

: strip-all-words ( -- )
    "Setting slot..." safe-show
    [ ] dup jit-compile dup f swap 1 set-slot

    "Stripping words.." safe-show
    all-instances [
        dup word? [ strip-word ] [ 2drop ] if
    ] with each ;

: strip-jit-compiler ( -- )
    "Stripping JIT compiler" safe-show

    ! JIT removal, must be done almost last.
    JIT-PROLOG JIT-DECLARE-WORD clear-specials

    ! PIC things, megamorphic caches, undefined and stderr
    PIC-LOAD OBJ-STDERR clear-specials ;

: clean-special-words ( redir-word -- )
    "Setting images main word" safe-show
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

: simplify-generics ( required-classes -- )
    "Simplifying generics" safe-show
    forget-other-methods ;

: cleanup-globals ( -- )
    "Cleaning globals" safe-show
    OBJ-GLOBAL special-object 2 slot safe-clear-hash ;

:: word>factor-image ( image-path word features -- )

    image-path normalize-path saving-path :> ( saving-path real-path )

    features required-classes safe-of simplify-generics

    ! After generic stripping we have to be *very* careful because a
    ! lot of words won't work.
    strip-all-words

    word clean-special-words

    ! Startup quot, global and shutdown quot
    f OBJ-STARTUP-QUOT set-special-object
    f OBJ-SHUTDOWN-QUOT set-special-object

    features global-hash? safe-of [ cleanup-globals ] [
        f OBJ-GLOBAL set-special-object
    ] if

    ! Entry points and signal handlers we can do without
    LAZY-JIT-COMPILE-WORD REDEFINITION-COUNTER clear-specials

    f OBJ-UNDEFINED set-special-object

    "Checking if stripping JIT" safe-show
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
