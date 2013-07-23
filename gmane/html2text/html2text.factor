USING:
    accessors
    arrays
    fry
    html.parser html.parser.analyzer
    kernel
    math
    sequences
    sets
    splitting
    xml xml.entities.html ;
IN: gmane.html2text

TUPLE: state lines indent closing? ;

CONSTANT: max-empty-line-count 2

: new-line-ok? ( lines -- ? )
    max-empty-line-count dup swapd short tail* [ second "" = ] count > ;

: add-new-line ( lines -- lines' )
    dup new-line-ok? [ { 0 "" } suffix ] when ;

: remove-all ( seq subseqs -- seq )
    swap [ { } replace ] reduce ;

: replace-entities ( html-str -- str )
    '[ _ string>xml-chunk ] with-html-entities first ;

: process-text ( state tag -- state' )
    text>> replace-entities
    '[ unclip-last first2 _ append 2array suffix ] change-lines ;

: process-block ( state name closing? -- state' )
    2array
    '[ _
        [
            { "pre" "p" "div" "br" "blockquote" } [ f 2array ] map in?
            [ add-new-line ] when
        ]
        [
            ! Block tags may not end with an empty string.
            { "div" "blockquote" } [ t 2array ] map in?
            [ unclip-last dup second "" = [ drop ] [ suffix ] if ] when
        ] bi
    ] change-lines ;

: process-tag ( state tag -- state' )
    dup name>> text =
    [ process-text ] [ [ name>> ] keep closing?>> process-block ] if ;

: tags>string ( tags -- string )
    ! Stray empty text tags are not interesting
    remove-blank-text
    ! Skip content within script tags
    dup [ name>> "script" = ] find-between-all remove-all
    ! Run it through the paring process
    { } 0 f state boa [ process-tag ] reduce lines>>
    ! Convert the lines to a plain text string
    [ second ] map "\n" join ;
