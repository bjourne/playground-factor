USING: accessors arrays assocs calendar calendar.format combinators constructors
formatting http.client kernel locals logging math math.order namespaces present
sequences threads urls ;
IN: http-sync

CONSTANT: tick-seconds 5

! content then last-poll
SYMBOL: fetch-cache
fetch-cache [ H{ } clone ] initialize

: update-cache ( url content -- eq? )
    over fetch-cache get at ?first dupd =
    [ now 2array swap fetch-cache get set-at ] dip ;

TUPLE: item url poll-duration cb-quot children ;

CONSTRUCTOR: item ( url poll-duration cb-quot -- item ) ;

M: item present
    [ url>> ]
    [ poll-duration>> duration>seconds ]
    [ children>> length ] tri "item<%s %d %d children>" sprintf ;

: poll-needed? ( item -- ? )
    [ poll-duration>> ] [ url>> ] bi fetch-cache get at
    [ second time+ now <=> +lt+ = ] [ drop t ] if* ;

: log-download-failed ( url response -- )
    [ code>> ] [ message>> ] bi "download of %s failed: %d %s" sprintf
    \ log-download-failed NOTICE log-message ;

: http-get-safe ( url -- content )
    dup http-get over code>> success?
    [ 2nip ] [ drop log-download-failed "" ] if ;
\ http-get-safe NOTICE add-input-logging

: poll ( item -- content eq? )
    url>> dup http-get-safe [ update-cache ] keep swap ;

: run-callback ( item content -- children )
    dupd over cb-quot>> call( x y -- z ) >>children ;

: check ( item -- item' )
    dup poll-needed? [
        dup poll [ drop ] [ run-callback ] if
    ] when [ [ check ] map ] change-children ;

: spider-loop ( items times -- )
    [ [ check ] map ] dip 1 -
    [ drop ] [ tick-seconds seconds sleep spider-loop ] if-zero ;
\ spider-loop NOTICE add-input-logging
