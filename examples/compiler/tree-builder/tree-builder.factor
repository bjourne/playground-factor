USING: accessors arrays assocs compiler.tree effects kernel locals
make math math.order namespaces sequences stack-checker.backend
stack-checker.values words ;
IN: examples.compiler.tree-builder

SYMBOL: literals

DEFER: make-nodes
DEFER: (quot>tree)


! Canned instruction creators
: drop-shuffle ( value -- )
    { } swap 1array { } f f #shuffle boa , ;

! known words
: my-infer-call ( ds -- ds' )
    unclip-last dup drop-shuffle literals get at swap (quot>tree) ;

: my-infer-dip ( ds -- ds' )
    my-infer-call \ swap make-nodes ;

CONSTANT: special-words {
    { call my-infer-call }
    { dip my-infer-dip }
}

: cut-remaining ( seq n -- before after missing )
    [ short cut* ] [ swap length - 0 max ] 2bi ;

: measure-effect ( effect -- in out )
    [ in>> ] [ out>> ] bi [ length ] bi@ ;

: consume-inputs ( ds in -- ds' values )
    cut-remaining make-values dup [ #introduce boa , ] unless-empty prepend ;

: consume/produce ( ds in out -- ins outs ds' )
    [ consume-inputs ] [ make-values rot over append ] bi* ;

PREDICATE: shuffle-word < word "shuffle" word-prop ;

GENERIC: make-nodes ( ds obj -- ds' )

:: concreete-word ( ds obj -- ds' )
    obj required-stack-effect :> eff
    ds eff measure-effect consume/produce :> ( ins outs ds' )
    obj shuffle-word?
    [ outs ins eff shuffle zip ins outs f f #shuffle boa ]
    [ obj ins outs f f f f #call boa ] if , ds' ;

M: word make-nodes ( ds obj -- ds' )
    dup special-words at [ nip execute( x -- x' ) ] [ concreete-word ] if* ;

M: object make-nodes ( ds obj -- ds' )
    <value>
    [ 1array #push boa , ]
    [ literals get set-at ]
    [ nip suffix ] 2tri ;

: make-return ( ds -- )
    f #return boa , ;

: (quot>tree) ( quot ds -- ds' )
    [ make-nodes ] reduce ;

: quot>tree ( quot -- nodes )
    H{ } clone literals set [ { } (quot>tree) make-return ] { } make ;
