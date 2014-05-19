USING: accessors arrays compiler.cfg compiler.cfg.builder
compiler.cfg.finalization compiler.codegen compiler.cfg.optimizer compiler.tree
examples.trees kernel namespaces sequences stack-checker.values strings ;
QUALIFIED: compiler
IN: examples.compiler

: reset-counters ( -- )
    0 \ <value> set-global
    0 \ basic-block set-global ;

: create-cfg ( word -- cfg )
    reset-counters
    [ compiler:start ]
    [ compiler:frontend ] [ ] tri
    build-cfg [ [ optimize-cfg finalize-cfg ] with-cfg ] map
    first ;

: upload-cfg ( cfg -- out )
    generate ;

! compiler.tree
M: #recursive node-children
    child>> ;
M: #if node-children
    children>> ;
M: #if set-node-children
    >>children ;
M: #recursive set-node-children
    >>child ;
