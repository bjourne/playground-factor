USING: arrays assocs classes.tuple.private compiler.units
compiler.units.private definitions examples.deploy.mini.utils fry
generic kernel memory namespaces sequences strings vectors vocabs
words ;
IN: examples.deploy.mini.generics

: walk-decision-tree-rec ( seq quot: ( method -- method' ) -- seq' )
    dup '[
        dup array? [ _ walk-decision-tree-rec ] [
            dup [ @ ] when
        ] if
    ] map! ; inline recursive

: walk-decision-tree ( word quot: ( method -- method' ) -- )
    [
        "decision-tree" word-prop
    ] dip walk-decision-tree-rec drop ; inline

: reject-default-method-quot ( word -- quot: ( method -- method' ) )
    "default-method" word-prop '[ _ dupd = [ drop f ] when ] ; inline

: prune-default-method ( word -- )
    dup reject-default-method-quot walk-decision-tree ;


! tough oness: string, vector

! These are the classes that are required to finish deploying the
! image.
: base-classes ( -- seq )
    { array string vector } ;

: forgettable-generics ( -- seq )
    [ generic? ] instances ;

: forget-generic ( required-classes generic -- )
    dup prune-default-method
    "methods" word-prop values
    [ "method-class" word-prop swap member? not ] with filter
    [ forget ] each ;

: set-compile-vars ( -- )
    V{ } clone definition-observers set-global
    V{ } clone vocab-observers set-global
    <definitions> new-definitions set
    <definitions> old-definitions set
    HS{ } clone forgotten-definitions set
    HS{ } clone changed-definitions set
    HS{ } clone maybe-changed set
    HS{ } clone changed-effects set
    HS{ } clone outdated-generics set
    H{ } clone outdated-tuples set
    HS{ } clone new-words set ;

: do-generic-recompile ( -- )
    "Remaking generics..." printff
    remake-generics
    to-recompile [
        recompile
        outdated-tuples get update-tuples
        forgotten-definitions get process-forgotten-definitions
    ] keep update-existing? reset-pics? modify-code-heap ;

: forget-other-methods ( required-classes affected-generics -- )
    set-compile-vars
    [ base-classes append ] dip
    [ forget-generic ] with each
    do-generic-recompile ;
