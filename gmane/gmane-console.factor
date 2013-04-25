USING:
    accessors
    db db.sqlite db.tuples db.types
    formatting
    fry
    gmane-db gmane-scraper gmane-utils
    io
    kernel
    prettyprint
    sequences
    strings
    ;
IN: gmane-console

: show-tuples ( quot -- )
    with-mydb table-format simple-tuple-table ; inline

! Commands a gmane reader is able to issue on the listener
: recent ( -- )
    [
        <query> T{ mail } >>tuple "date desc" >>order 25 >>limit
        select-tuples
    ] show-tuples ;

: group-recent ( group -- )
    '[
        <query> T{ mail }
        _ >>group >>tuple
        "date desc" >>order
        25 >>limit
        select-tuples
    ] show-tuples ;

: read ( x -- )
    [ T{ mail } swap >>id select-tuple ] with-mydb
    [
        dup header-format swap format-tuple
        swap body>>
        suffix "\n" join 
    ] [ "Error: No such mail" ] if* print ;

: init ( -- )
    [ mail recreate-table ] with-mydb
    "Database created." print ;

: reset ( -- )
    [ mail dup drop-table recreate-table ] with-mydb
    "Database resetted." print ;

: import ( seq group -- )
    '[
        _ 2dup find-mail
        [ 2drop ]
        [
            2dup
            safe-parse-mail
            [ insert-mail "mail imported" ]
            [ "failed to parse mail" ]
            if*
            swapd "%s/%d: %s" sprintf print flush
        ]
        if
    ] each ;
    


