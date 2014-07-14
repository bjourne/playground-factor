USING: accessors arrays combinators effects kernel make math sequences
sequences.rotated shuffle stack-checker ;
IN: examples.transforms

: make-shuffle-effect ( n dir -- effect )
    swap 1 + iota swap dupd <rotated> [ >array ] bi@ <effect> ;

: emit-dip ( quot -- )
    dup infer
    [ nip in>> length -1 make-shuffle-effect , \ shuffle-effect , ]
    [ swap , , \ call-effect , ]
    [ nip out>> length 1 make-shuffle-effect , \ shuffle-effect , ] 2tri ;

: rewrite-dip ( quot -- quot' )
    first2 drop [ emit-dip ] [ ] make ;
