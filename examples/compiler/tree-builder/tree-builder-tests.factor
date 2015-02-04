USING: classes.tuple compiler.tree compiler.tree.optimizer
examples.compiler.tree-builder fry kernel math namespaces sequences
stack-checker.values tools.test ;
IN: examples.compiler.tree-builder.tests

! Because node is an identity-tuple
: node-seqs-eq? ( seq1 seq2 -- ? )
    [ [ tuple-slots ] map concat ] bi@ = ;

: tree-generator-test ( nodes quot -- )
    swap '[ 0 \ <value> set-global _ quot>tree _ node-seqs-eq? ] { t } swap
    unit-test ;

{
    T{ #push { literal 33 } { out-d { 1 } } }
    T{ #return { in-d { 1 } } }
} [ 33 ] tree-generator-test

: foo ( x -- )
    drop ;
{
    T{ #push { literal [ foo ] } { out-d { 1 } } }
    T{ #return { in-d { 1 } } }
} [ [ foo ] ] tree-generator-test

{
    T{ #push { literal 3 } { out-d { 1 } } }
    T{ #call { word foo } { in-d { 1 } } { out-d { } } }
    T{ #return { in-d { } } }
} [ 3 foo ] tree-generator-test

: foo1 ( x -- y )
    ;

{
    T{ #push { literal 4 } { out-d { 1 } } }
    T{ #call
       { word foo1 }
        { in-d { 1 } }
        { out-d { 2 } }
    }
    T{ #return { in-d { 2 } } }
} [ 4 foo1 ] tree-generator-test

{
    T{ #introduce { out-d { 1 2 } } }
    T{ #shuffle
       { mapping { { 3 1 } { 4 2 } { 5 1 } } }
       { in-d { 1 2 } }
       { out-d { 3 4 5 } }
    }
    T{ #return { in-d { 3 4 5 } } }
} [ over ] tree-generator-test

{
    T{ #push { literal [ 3 foo ] } { out-d { 1 } } }
    T{ #shuffle { mapping { } } { in-d { 1 } } { out-d { } } }
    T{ #push { literal 3 } { out-d { 2 } } }
    T{ #call { word foo } { in-d { 2 } } { out-d { } } }
    T{ #return { in-d { } } }
} [ [ 3 foo ] call ] tree-generator-test

{ } [
    [ 7 ] quot>tree optimize-tree drop
] unit-test

! build-tree optimize-tree gensym build-cfg first dup optimize-cfg cfg.
