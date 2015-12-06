USING: arrays assocs classes.tuple.private compiler.units
compiler.units.private definitions examples.deploy.mini.utils fry
generic kernel memory namespaces sequences strings vectors vocabs
words ;
IN: examples.deploy.mini.generics


! ! Strip default method
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
    {
        array
        ! bignum
        ! byte-array
        ! callable

        ! compose
        ! curry

        ! fixnum

        ! hashtable
        ! object
        ! quotation
        ! sequence
        string
        ! tuple
        vector
        ! word
        ! wrapper
    } ;

: forgettable-generics ( -- seq )
    [ generic? ] instances ;

: forget-generic ( required-classes generic -- )
    dup prune-default-method
    "methods" word-prop values
    [ "method-class" word-prop swap member? not ] with filter
    [ forget ] each ;

: forget-other-methods ( required-classes -- )
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
    HS{ } clone new-words set

    base-classes append
    dup "Preserving classes: %u" printff
    [ generic? ] instances [ forget-generic ] with each

    remake-generics
    to-recompile [
        recompile
        update-tuples
        process-forgotten-definitions
    ] keep update-existing? reset-pics? modify-code-heap ;
