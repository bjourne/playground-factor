USING: arrays assocs formatting grouping io kernel math math.ranges
sequences sequences.repeating splitting strings ;
IN: chess
: initialize ( -- assoc )
    1 8 [a,b] CHAR: a CHAR: h [a,b] [
        [ 48 + ] dip 2array >string ] cartesian-map concat
    "RWNWBWQWKWBWNWRWPWPWPWPWPWPWPWPW" "PBPBPBPBPBPBPBPBRBNBBBQBKBBBNBRB"
    [ 2 group ] bi@ { f } 32 cycle glue zip ;
: display ( assoc -- )
    values 8 group [
        1 + " %d " sprintf [ [ dup "- " ? ] map " " join ] dip dup surround
    ] map-index reverse
    "   a  b  c  d  e  f  g  h" [ prefix ] keep suffix
    "\n" join print flush ;
: pair-at ( assoc pos -- pair/f )
    dup swapd ?of [ 2array ] [ 2drop f ] if ;
: extract-keys* ( assoc keys -- assoc' )
    [ pair-at ] with map harvest ;
: swap-squares ( f t -- move )
    [ first2 ] bi@ drop f -rot swap [ 2array ] 2bi@ 2array ;
: capture-text ( f t -- msg )
    [ second ] bi@ 2dup and [ " x " glue ] [ 2drop "" ] if ;
: move ( assoc fromto -- assoc' msg )
    dupd extract-keys* dup [ length 2 = ] [ first last ] bi and [
        first2 [ swap-squares assoc-union ] [ capture-text ] 2bi
    ] [ drop "Invalid move" ] if ;
: game ( -- ? )
    initialize [
        dup display "Move" print readln " " split move print flush
    ] follow ;
