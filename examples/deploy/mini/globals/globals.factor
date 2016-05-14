USING: accessors assocs compiler.units definitions
examples.deploy.mini.utils fry kernel kernel.private namespaces
namespaces.private sequences words ;
IN: examples.deploy.mini.globals

: uninline-word ( word -- )
    [ f "flushable" set-word-prop ]
    [ f "foldable" set-word-prop ]
    [ [ changed-definition ] with-compilation-unit ] tri ;

: uninline-globals-word ( -- )
    "Uninlining global word..." safe-show
    \ global uninline-word ;

: copy-global-vars ( required-vars -- globals )
    "Copying global variables..." safe-show
    global boxes>> [ drop member? ] with assoc-filter global-hashtable boa ;
