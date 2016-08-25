    USING: functors io lexer namespaces ;
    IN: examples.functors

    FUNCTOR: define-table ( NAME -- )

    name-datasource DEFINES-CLASS ${NAME}-datasource

    clear-name DEFINES clear-${NAME}
    init-name DEFINES init-${NAME}

    WHERE

    SINGLETON: name-datasource

    : clear-name ( -- ) "clear table code here" print ;

    : init-name ( -- ) "init table code here" print ;

    name-datasource [ "hello-hello" ] initialize

    ;FUNCTOR

    SYNTAX: SQL-TABLE:
        scan-token define-table ;
