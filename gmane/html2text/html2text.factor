USING:
    accessors
    arrays
    combinators
    fry
    gmane.html2text.paragraphs
    html.parser html.parser.analyzer
    kernel
    math
    sequences sequences.extras
    sets
    splitting
    unicode.categories
    xml xml.entities.html ;
IN: gmane.html2text

TUPLE: state lines indent in-pre? ;

CONSTANT: max-empty-line-count  2

: new-line-ok? ( lines -- ? )
    max-empty-line-count dup swapd short tail* [ "" last= ] count > ;

: add-new-line ( lines indent -- lines' )
    over new-line-ok? [ "" ] [ swap unclip-last last swapd ] if 2array suffix ;

: replace-entities ( html-str -- str )
    '[ _ string>xml-chunk ] with-html-entities first ;

: continue-line ( lines str -- lines' )
    [ unclip-last first2 ] dip append 2array suffix ;

: extra-lines ( lines new-lines -- lines' )
    over last first '[ _ swap 2array ] map append ;

: add-lines ( lines new-lines -- lines' )
    unclip swap [ continue-line ] [ extra-lines ] bi* ;

! The rules for what tags causes new lines are somewhat arbitrary and
! choosen based on what makes the rendered emails look the best.
: line-breaking-tags ( -- tagdescs )
    { "pre" "p" "div" "br" "blockquote" } [ f 2array ] map { "p" t } suffix ;

: process-text ( state tag -- state' )
    text>> replace-entities over
    in-pre?>> [ "\n" split ] [ "\n" "" replace 1array ] if
    '[ _ add-lines ] change-lines ;

: process-block ( state tagdesc -- state' )
    {
        [ '[ _ { "blockquote" f } = 1 0 ? + ] change-indent ]
        [
            line-breaking-tags in?
            [ dup indent>> '[ _ add-new-line ] change-lines ] when
        ]
        [ '[ _ { "blockquote" t } = 1 0 ? - ] change-indent ]
        [
            ! Block tags must not end with an empty string.
            { { "div" t } { "blockquote" t } } in?
            [
                [ dup last "" last= [ but-last ] when ] change-lines
            ] when
        ]
        [ first2 swap "pre" = [ not >>in-pre? ] [ drop ] if ]
    } cleave ;

: process-tag ( state tag -- state' )
    dup name>> text =
    [ process-text ] [ [ name>> ] keep closing?>> 2array process-block ] if ;

: tags>string ( tags -- string )
    ! Stray empty text tags are not interesting
    remove-blank-text
    ! Run it through the parsing process
    { { 0 "" } } 0 f state boa [ process-tag ] reduce lines>>
    ! Convert the lines to a plain text string
    [ first2 line>string ] map "\n" join ;
