USING:
    accessors assocs
    calendar
    http-sync.syncitem http-sync.urlvars http-sync.utils
    kernel
    logging
    math
    namespaces
    sequences
    threads ;
IN: http-sync

SYMBOLS: user-agent ;
CONSTANT: tick-seconds 5
SYMBOL: parse-variables

: check-syncitem ( syncitem -- syncitem' )
    parse-variables get
    [ over url-format>> interpolate-string >>real-url poll-url ] keep
    assoc-union parse-variables set ;

: main-recursive ( syncitems times -- )
    [ [ check-syncitem ] map ] dip 1 -
    [ drop ] [ tick-seconds seconds sleep main-recursive ] if-zero ;
\ main-recursive NOTICE add-input-logging

: main ( syncitems times -- )
    time-variables parse-variables set main-recursive ;
\ main NOTICE add-input-logging
