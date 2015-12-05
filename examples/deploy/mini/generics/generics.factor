USING: arrays assocs compiler.units definitions fry hashtables kernel sequences slots.private words ;
IN: examples.deploy.mini.generics

! We cant use any generic methods here
: hashtable$at ( key assoc -- value/f )
    M\ hashtable at* execute( k h -- v/f ? ) drop ;

: word$word-prop ( word name -- value )
    swap 5 slot hashtable$at ;

: walk-decision-tree-rec ( seq quot: ( method -- method' ) -- seq' )
    dup '[
        dup array? [ _ walk-decision-tree-rec ] [
            dup [ @ ] when
        ] if
    ] map! ; inline recursive

: walk-decision-tree ( word quot: ( method -- method' ) -- )
    [
        "decision-tree" word$word-prop
    ] dip walk-decision-tree-rec drop ; inline

: filter-by-classes-quot ( classes -- quot: ( method -- method' ) )
    '[
        dup "method-class" word$word-prop _ member? [ drop f ] unless
    ] ; inline

: reject-default-method-quot ( word -- quot: ( method -- method' ) )
    "default-method" word$word-prop '[ _ dupd = [ drop f ] when ] ; inline

! The decision tree array is directly referred from assembly code.
: prune-decision-tree ( word classes -- )
    filter-by-classes-quot walk-decision-tree ;

: prune-default-method ( word -- )
    dup reject-default-method-quot walk-decision-tree ;

: forget-other-methods ( generic classes -- )
    [
        [ "methods" word-prop ] [ '[ drop _ member? ] ] bi*
        assoc-reject values [ forget ] each
        ! "methods" word-prop { byte-array } '[ drop _ member? ] assoc-reject
        ! values [ forget ] each
    ] with-compilation-unit ;
