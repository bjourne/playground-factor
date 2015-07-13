USING: io kernel kernel.private math prettyprint sequences sequences.private ;
IN: examples.bugs.bug839

: foo ( seq -- ? )
    [ 42 < ] all? ;

: foo2 ( seq -- ? )
    [ 42 < ] (each) all-integers? ;

: foo3 ( seq -- ? )
    dup length swap [ nth-unsafe 42 < ] curry all-integers? ;

: foo4 ( seq -- ? )
    0 over length rot [ nth-unsafe 42 < ] curry (all-integers?) ;

: each-to10 ( ... quot: ( ... i -- ... ) i -- ... )
    dup 10 < [
        2dup swap call 1 + each-to10
    ] [ 2drop ] if ; inline recursive

: foo5 ( seq -- )
    [ nth-unsafe unparse print ] curry 0 each-to10 ;
