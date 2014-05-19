USING: fry io kernel namespaces math prettyprint sequences strings ;
IN: examples.trees

GENERIC: node-children ( node -- nodes )
GENERIC# set-node-children 1 ( node nodes -- node' )

SYMBOL: visited-nodes

: (tree-walker) ( quot: ( .. node depth -- ... ) depth node -- )
    dup visited-nodes get member? [ 3drop ] [
        dup visited-nodes [ swap suffix ] change
        [ rot swapd call( node depth -- ) ]
        [ [ 1 + ] dip node-children [ (tree-walker) ] with with each ] 3bi
    ] if ;

: tree-walker ( node quot: ( .. node depth -- ... ) -- )
    { } visited-nodes [ 0 rot (tree-walker) ] with-variable ;

: node-print ( node depth -- )
    2 * CHAR: \s <string> write short. ;

: tree-printer ( node -- )
    [ node-print ] tree-walker ;

: tree-filter ( node quot: ( ... elt -- ... ? ) -- node' )
    over node-children swap [ filter ] keep
    '[ _ tree-filter ] map set-node-children ; inline recursive

M: object set-node-children ( node nodes -- node' )
    drop ;
M: sequence set-node-children ( node nodes -- node' )
    nip ;

M: object node-children drop f ;
M: sequence node-children ;
