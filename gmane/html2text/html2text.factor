USING:
    accessors
    arrays
    assocs
    continuations
    fry
    gmane.html2text.paragraphs gmane.html2text.tagpath
    html.parser
    kernel
    math
    sequences sequences.extras
    sets
    splitting
    xml xml.entities.html ;
IN: gmane.html2text

: replace-entities ( html-str -- str )
    [ replace-entities ]  with-html-entities ;
    ! [ [ replace-entities ] with-html-entities ] [ drop ] recover ;

: continue-line ( lines str -- lines' )
    [ unclip-last first2 ] dip append 2array suffix ;

: extra-lines ( lines new-lines -- lines' )
    over last first '[ _ swap 2array ] map append ;

: add-lines ( lines new-lines -- lines' )
    unclip swap [ continue-line ] [ extra-lines ] bi* ;

: process-text ( lines path tag -- lines' )
    text>> replace-entities swap dup { "script" "head" } intersects?
    [ 2drop ]
    [ "pre" swap in? [ "\n" split ] [ "\n" "" replace 1array ] if add-lines ]
    if ;

: line-breaks ( -- tagdescs )
    { "pre" "p" "div" "br" "blockquote" } [ f 2array ] map { "p" t } suffix ;

: process-block ( lines path tag -- lines' )
    [ name>> ] [ closing?>> ] bi 2array
    [
        line-breaks in?
        [ [ "blockquote" = ] count "" 2array suffix ] [ drop ] if
    ]
    [
        nip { { "div" t } { "blockquote" t } } in?
        [ dup last "" last= [ but-last ] when ] when
    ] 2bi ;

: process-tag ( lines path tag -- lines' )
    dup name>> text = [ process-text ] [ process-block ] if ;

CONSTANT: max-empty-line-count  1

: empty-line-ok? ( lines -- ? )
    max-empty-line-count dup swapd short tail* [ "" last= ] count > ;

: filter-empty-lines ( lines line -- lines' )
    2dup [ empty-line-ok? ] [ "" last= not ] bi* or [ suffix ] [ drop ] if ;

: tags>string ( tags -- string )
    dup tag-paths swap zip { { 0 "" } } [ first2 process-tag ] reduce
    { } [ filter-empty-lines ] reduce
    [ first2 line>string ] map "\n" join ;
