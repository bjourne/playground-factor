USING:
    accessors
    arrays
    combinators
    fry
    html.parser html.parser.analyzer
    io
    kernel
    math
    present
    sequences
    sets
    shuffle
    splitting
    xml xml.entities.html ;
IN: gmane.html2text

TUPLE: state lines indent in-pre? ;

CONSTANT: max-empty-line-count 2

CONSTANT: quote-string " > "

: new-line-ok? ( lines -- ? )
    max-empty-line-count dup swapd short tail* [ second "" = ] count > ;

: add-new-line ( lines indent -- lines' )
    '[ _ "" 2array suffix ] over new-line-ok? swap when ;

: remove-all ( seq subseqs -- seq )
    swap [ { } replace ] reduce ;

: replace-entities ( html-str -- str )
    '[ _ string>xml-chunk ] with-html-entities first ;

: process-text ( state tag -- state' )
    text>> replace-entities over in-pre?>> [ "\n" "" replace ] unless
    '[ unclip-last first2 _ append 2array suffix ] change-lines ;

: process-block ( state tagpair -- state' )
    [ '[ _ { "blockquote" f } = 1 0 ? + ] change-indent ] keep
    [
        { "pre" "p" "div" "br" "blockquote" } [ f 2array ] map in?
        [ dup indent>> '[ _ add-new-line ] change-lines ] when
    ] keep
    [
        ! Block tags may not end with an empty string.
        { { "div" t } { "blockquote" t } } in?
        [
            [ unclip-last dup second "" = [ drop ] [ suffix ] if ] change-lines
        ] when
    ] keep
    [ '[ _ { "blockquote" t } = 1 0 ? - ] change-indent ] keep
    first2 swap "pre" = [ not >>in-pre? ] [ drop ] if ;

: process-tag ( state tag -- state' )
    dup name>> text =
    [ process-text ] [ [ name>> ] keep closing?>> 2array process-block ] if ;

: lines>string ( seq -- str )
    [ first2 [ [ quote-string ] replicate concat ] dip append ] map "\n" join ;

: tags>string ( tags -- string )
    ! Stray empty text tags are not interesting
    remove-blank-text
    ! Skip content within script tags
    dup [ name>> "script" = ] find-between-all remove-all
    ! Run it through the parsing process
    { } 0 f state boa [ process-tag ] reduce lines>>
    ! Convert the lines to a plain text string
    lines>string ;
