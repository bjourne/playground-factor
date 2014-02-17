USING:
    accessors
    calendar calendar.format
    combinators
    constructors
    http.client
    http-sync.utils
    formatting
    kernel
    logging
    math math.order
    present
    sequences ;
IN: http-sync.syncitem

TUPLE: syncitem
    url-format
    real-url
    poll-interval
    last-poll
    content
    content-hash
    quot ;

CONSTRUCTOR: syncitem ( url-format poll-interval quot -- syncitem ) ;

M: syncitem present
    {
        [ url-format>> ]
        [ poll-interval>> ]
        [
            last-poll>> [
                [ timestamp>ymdhms ]
                [ now swap time- duration>seconds >fixnum ] bi
                "%s (%d seconds ago)" sprintf
            ] [ "" ] if*
        ]
        [ content-hash>> ]
        [ content>> length ]
    } cleave "syncitem<%s %d %s %s %s bytes>" sprintf ;

: poll-needed? ( interval last-poll -- ? )
    [ swap time+ now <=> +lt+ = ] [ drop t ] if* ;

: refresh-content ( syncitem -- syncitem' equal )
    dup [ real-url>> http-get* dup content-hash dup ]
    [ content-hash>> ] bi =
    [ swapd >>content-hash swap >>content now >>last-poll ] dip ;

: invoke-callback ( syncitem -- vars )
    dup present \ invoke-callback NOTICE log-message
    dup quot>> call( syncitem -- vars ) ;

: poll-url ( syncitem -- syncitem' vars )
    dup [ poll-interval>> seconds ] [ last-poll>> ] bi poll-needed? [
        refresh-content [ { } ] [ dup invoke-callback ] if
    ] [ { } ] if ;
