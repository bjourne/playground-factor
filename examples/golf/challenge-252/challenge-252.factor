USING: arrays assocs fry kernel locals math sequences splitting ;
IN: examples.golf.challenge-252

:: refine-index ( max-i index prev-index -- )
    index keys [ [ prev-index at ] [ index set-at ] bi ] each
    index [ nip max-i >= ] assoc-filter! drop ;

! Pair is either passed through unchanged, or if we find a better
! match, it is narrowed.
:: update-pair ( pair ch i index prev-index -- pair' )
    index ch of :> char-i
    pair
    char-i [
        i char-i - pair first > [
            drop i char-i - char-i i ch 4array
        ] when
        prev-index ch of index prev-index refine-index
    ] [ i ch index set-at ] if
    i ch prev-index set-at ;

: widest-leftmost-pair ( str -- pair/f )
    { 0 0 0 f } swap
    H{ } clone H{ } clone '[ _ _ update-pair ] each-index
    dup last [ drop f ] unless ;

: update-string ( str pair -- str' )
    [ [ second ] [ third ] bi rot remove-nth remove-nth ]
    [ second swap nth ] 2bi suffix ;

: (decode) ( str -- str' )
    dup widest-leftmost-pair [ update-string (decode) ] when* ;

: decode ( str -- str' )
    "\n" "" replace (decode) "_" split first ;
