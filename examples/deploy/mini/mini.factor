! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays compiler.units
examples.deploy.mini.features examples.deploy.mini.generics formatting
generic.single io io.backend io.pathnames kernel kernel.private
literals locals math.ranges memory memory.private namespaces parser
quotations sequences slots.private vectors vocabs vocabs.loader words
;
IN: examples.deploy.mini

: printff ( fmt -- )
    sprintf print flush ; inline
    ! "\n" append printf flush ; inline

: clear-specials ( start end -- )
    [a,b] [ f swap set-special-object ] each ;

: strip-word ( id-quot word -- )
    f >>props
    f >>name f >>vocabulary
    dup pic-def>> [ jit-compile ] when*
    dup pic-tail-def>> [ jit-compile ] when*
    def<< ;

: strip-default-methods ( -- )
    "Stripping default methods" printff
    [ single-generic? ] instances [ prune-default-method ] each ;

! : clean-generic-word ( word -- )
!     { byte-array }
!     [ "decision-tree" word-prop ]
!     [
!         "methods" word-prop [ drop byte-array = ] assoc-reject values
!     ] bi '[ dup _ member? [ drop f ] when ] map! drop ;

! : strip-unsupported-classes ( -- )
!     "Stripping unsupported classes" printff
!     \ length { byte-array } prune-decision-tree ;
    ! \ length { byte-array } prune-decision-tree ;

: strip-all-words ( -- )
    "Stripping all words..." printff
    [ ] dup jit-compile dup f swap 1 set-slot
    [ word? ] instances [ strip-word ] with each ;

: strip-jit-compiler ( -- )
    "Stripping JIT compiler" printff

    ! JIT removal, must be done almost last.
    JIT-PROLOG JIT-DECLARE-WORD clear-specials

    ! PIC things, megamorphic caches, undefined and stderr
    PIC-LOAD OBJ-STDERR clear-specials ;

: clean-special-words ( redir-word -- )
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

:: word>factor-image ( image-path word features -- )

    image-path normalize-path saving-path :> ( saving-path real-path )

    strip-all-words

    word clean-special-words

    ! Startup quot, global and shutdown quot
    OBJ-STARTUP-QUOT OBJ-SHUTDOWN-QUOT clear-specials

    ! Entry points and signal handlers we can do without
    LAZY-JIT-COMPILE-WORD REDEFINITION-COUNTER clear-specials

    features quotation-compiler? of [
        strip-jit-compiler
    ] unless


    ! \ length { array byte-array vector } prune-decision-tree
    ! [ \ length { byte-array array vector } forget-other-methods ] with-compilation-unit

    saving-path real-path t (save-image) ;

    ! save-image-and-exit ;

    ! strip-default-methods

    ! After this, Factor is broken

    ! strip-unsupported-classes

    ! Entry points and signal handlers we can do without
    ! LAZY-JIT-COMPILE-WORD FFI-LEAF-SIGNAL-HANDLER-WORD clear-specials

    ! After this, lots of stuff is borked.
    ! strip-all-words


    ! drop save-image-and-exit ;

    ! ! dup clean-special-words
    ! C-TO-FACTOR-WORD set-special-object

    ! ! Startup quot, global and shutdown quot
    ! OBJ-STARTUP-QUOT OBJ-SHUTDOWN-QUOT clear-specials
    ! ! disable-generic

    ! MEGA-LOOKUP MEGA-MISS-WORD clear-specials

    ! OBJ-UNDEFINED OBJ-STDERR clear-specials

    ! PIC-LOAD OBJ-STDERR clear-specials
    ! save-image-and-exit ;

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
