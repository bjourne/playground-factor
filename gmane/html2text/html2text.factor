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
    unicode.categories
    wrap.strings
    xml xml.entities.html ;
IN: gmane.html2text

TUPLE: state lines indent in-pre? ;

CONSTANT: max-empty-line-count 2

CONSTANT: quote-string " > "

CONSTANT: fill-column 78

: new-line-ok? ( lines -- ? )
    max-empty-line-count dup swapd short tail* [ second "" = ] count > ;

: add-new-line ( lines indent -- lines' )
    '[ _ "" 2array suffix ] over new-line-ok? swap when ;

: replace-entities ( html-str -- str )
    '[ _ string>xml-chunk ] with-html-entities first ;

: continue-line ( lines str -- lines' )
    [ unclip-last first2 ] dip append 2array suffix ;

: extra-lines ( lines new-lines -- lines' )
    [ dup first first ] dip [ 2array ] with map append ;

: add-lines ( lines new-lines -- lines' )
    unclip swap [ continue-line ] [ extra-lines ] bi* ;

! The rules for what tags causes new lines are somewhat arbitrary and
! choosen based on what makes the rendered emails look the best.
: line-breaking-tags ( -- tagpairs )
    { "pre" "p" "div" "br" "blockquote" } [ f 2array ] map { "p" t } suffix ;

: process-text ( state tag -- state' )
    text>> replace-entities over
    in-pre?>> [ "\n" split ] [ "\n" "" replace 1array ] if
    '[ _ add-lines ] change-lines ;

: process-block ( state tagpair -- state' )
    [ '[ _ { "blockquote" f } = 1 0 ? + ] change-indent ] keep
    [
        line-breaking-tags in?
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

: fill-paragraph ( indent str -- lines )
    swap dup quote-string length * fill-column swap - swapd wrap-string
    "\n" split [ 2array ] with map ;

: lines>string ( lines -- str )
    [ first2 fill-paragraph ] map concat
    [ first2 [ [ quote-string ] replicate concat ] dip append ] map
    ! Merge the lines and ensure the string doesn't start or end with
    ! whitespace.
    "\n" join [ blank? ] trim ;

: tags>string ( tags -- string )
    ! Stray empty text tags are not interesting
    remove-blank-text
    ! Run it through the parsing process
    { } 0 f state boa [ process-tag ] reduce lines>>
    ! Convert the lines to a plain text string
    lines>string ;
