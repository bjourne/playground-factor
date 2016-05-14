USING: arrays assocs classes.mixin classes.tuple.private compiler.units
compiler.units.private definitions examples.deploy.mini.utils fry
generic kernel memory namespaces sequences strings vectors vocabs
words ;
IN: examples.deploy.mini.generics
QUALIFIED: sets

: filter-generic ( generic classes -- )
    [ "methods" word-prop values ] dip
    '[ "method-class" word-prop _ member? ] reject
    [ forget ] each ;

: filter-generics ( generics classes -- )
    '[ _ filter-generic ] each ;

: begin-simple-compilation-unit ( -- )
    V{ } clone definition-observers set-global
    V{ } clone vocab-observers set-global
    <definitions> new-definitions set
    <definitions> old-definitions set
    HS{ } clone forgotten-definitions set
    HS{ } clone changed-definitions set
    HS{ } clone maybe-changed set
    HS{ } clone changed-effects set
    HS{ } clone outdated-generics set
    HS{ } clone new-words set
    H{ } clone outdated-tuples set ;

: finish-simple-compilation-unit ( -- )
    "Remaking generics..." safe-show
    remake-generics
    to-recompile [
        dup length "Recompiling %d words..." printff
        recompile
        outdated-tuples get update-tuples
        forgotten-definitions get process-forgotten-definitions
    ] keep update-existing? reset-pics?
    "Modifying code heap..." safe-show
    modify-code-heap ;

: with-simple-compilation-unit ( quot -- )
    begin-simple-compilation-unit
    call finish-simple-compilation-unit ; inline

: instances-to-remove ( classes mixin -- instances )
    "instances" word-prop keys swap sets:diff ;

: filter-mixin ( classes mixin -- )
    [
        instances-to-remove
        dup "Removing instances %u\n" printff
    ] keep
    '[ _ remove-mixin-instance ] each ;
    ! 2drop ;

: filter-mixins ( classes -- )
    dup [ "mixin" word-prop ] filter [ filter-mixin ] with each ;

: forget-other-methods ( generics classes -- )
    [
        dup filter-mixins
        filter-generics
    ] with-simple-compilation-unit ;
