USING: accessors furnace.actions html.forms http.server
http.server.dispatchers http.server.responses namespaces ;
IN: examples.web.chloe-template

TUPLE: template-app < dispatcher ;

: <index-action> ( -- action )
    <page-action>
        [ "hello there" "content" set-value ] >>init
        { template-app "index" } >>template ;

: run-site ( -- )
    dispatcher new-dispatcher
    <index-action> "" add-responder
    main-responder set-global ;
