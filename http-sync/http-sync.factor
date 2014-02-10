USING:
    accessors assocs
    ascii
    calendar http.client
    io.encodings.utf8
    io.files
    io.pathnames
    kernel
    logging
    namespaces
    sequences
    unicode.normalize ;
IN: http-sync

SYMBOLS: user-agent ;

: slugify ( str -- str' )
    nfd >lower [ dup alpha? [ drop CHAR: - ] unless ] map ;

: http-get* ( url -- data )
    <get-request> [ header>> user-agent get "user-agent" rot set-at ] keep
    http-request swap check-response drop ;

: download-url ( dir url -- )
    dup http-get* [ slugify append-path ] dip swap utf8 set-file-contents ;

: run-loop ( local-dir urls -- )
    2drop ;
\ run-loop NOTICE add-input-logging

: run-wrapper ( local-dir watch-urls -- )
    "http-sync" [ run-loop ] with-logging ;
