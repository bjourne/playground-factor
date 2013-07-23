USING:
    accessors
    arrays
    fry
    html.parser html.parser.analyzer
    kernel
    math
    sequences
    splitting
    xml xml.entities.html
    ;
IN: gmane.html2text

TUPLE: state lines indent closing? ;

CONSTANT: max-empty-line-count 2

: new-line-ok? ( lines -- ? )
    max-empty-line-count dup swapd short tail* [ second empty? ] count > ;

: add-new-line ( lines -- lines' )
    dup new-line-ok? [ { 0 "" } suffix ] when ;

: remove-all ( seq subseqs -- seq )
    swap [ { } replace ] reduce ;

: replace-entities ( html-str -- str )
    '[ _ string>xml-chunk ] with-html-entities first ;

: process-text ( state tag -- state' )
    text>> replace-entities
    '[ unclip-last first2 _ append 2array suffix ] change-lines ;

: process-block ( state closing? name -- state' )
    nip { "p" "div" "br" "blockquote" } member?
    [ [ add-new-line ] change-lines ] when ;

: process-tag ( state tag -- state' )
    dup name>> text =
    [ process-text ]
    [ [ closing?>> ] keep name>> process-block ] if ;

: tags>string ( tags -- string )
    ! Stray empty text tags are not interesting
    remove-blank-text
    ! Skip content within script tags
    dup [ name>> "script" = ] find-between-all remove-all
    ! Run it through the paring process
    { } 0 f state boa [ process-tag ] reduce lines>>
    ! Convert the lines to a plain text string
    [ second ] map "\n" join ;
