USING: fry kernel sequences splitting unicode wrap.strings ;
IN: gmane.html2text.paragraphs

CONSTANT: line-width   78
CONSTANT: quote-string " > "

: string-prefix ( quote-level str -- prefix )
    [ blank? not ] split1-when drop
    [ [ quote-string ] replicate concat ] dip append ;

! "Fixed" variant of wrap-indented-string that evaluates to indent if
! the input string is empty.
: wrap-string2 ( string width indent -- newstring )
    [ wrap-indented-string ] [ '[ _ ] ] bi when-empty ;

: line>string ( quote-level str -- str' )
    [ string-prefix ] keep line-width rot wrap-string2 ;
