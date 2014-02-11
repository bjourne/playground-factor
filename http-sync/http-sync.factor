USING:
    accessors assocs
    ascii
    calendar http.client
    io.directories
    io.encodings.utf8
    io.files
    io.pathnames
    kernel
    logging
    math.order
    namespaces
    sequences
    unicode.normalize ;
IN: http-sync

TUPLE: sync-item url poll-interval last-poll ;

: poll-needed? ( sync-item -- ? )
    [ poll-interval>> ] [ last-poll>> ] bi
    [ swap seconds time+ now <=> +lt+ = ] [ drop t ] if* ;

SYMBOLS: user-agent ;

! : http-get* ( url -- data )
!     <get-request> [ header>> user-agent get "user-agent" rot set-at ] keep
!     http-request swap check-response drop ;



: slugify ( str -- str' )
    nfd >lower [ dup alpha? [ drop CHAR: - ] unless ] map ;

: download-to-dir ( url dir -- )
    over slugify append-path download-to ;

: fetch-url ( dir url-def -- )
    swap download-to-dir ;
\ fetch-url NOTICE add-input-logging

: run-loop ( local-dir url-defs -- )
    [ dup make-directories ] dip [ fetch-url ] with each ;
\ run-loop NOTICE add-input-logging

: run-wrapper ( local-dir url-defs -- )
    "http-sync" [ run-loop ] with-logging ;
