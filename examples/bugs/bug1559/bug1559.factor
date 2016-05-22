USING: arrays hints kernel kernel.private math sequences
sequences.private strings ;
IN: examples.bugs.bug1559

: my-subseq-unsafe ( from to seq -- subseq )
    [ { array-capacity array-capacity } declare ] dip
    [ subseq>copy (copy) ] keep like ;

: my-subseq ( from to seq -- subseq )
    [ check-slice subseq>copy (copy) ] keep like ;

{ my-subseq my-subseq-unsafe } [
    { { fixnum fixnum string } { fixnum fixnum array } }
    set-specializer
] each

: my-subseq-unsafe-fixnum ( from to seq -- subseq )
    { array-capacity array-capacity array } declare
    [ subseq>copy (copy) ] keep like ;

: my-subseq-fixnum ( from to seq -- subseq )
    { fixnum fixnum array } declare
    [ check-slice subseq>copy (copy) ] keep like ;





GENERIC: gen-string-lines ( str -- lines )
M: string gen-string-lines
      [ V{ } clone 0 ] dip [ 2dup bounds-check? ] [
        2dup [ "\r\n" member? ] find-from swapd [
            over [ [ nip length ] keep ] unless
            [ my-subseq-unsafe suffix! ] 2keep [ 1 + ] dip
        ] dip CHAR: \r eq? [
            2dup ?nth CHAR: \n eq? [ [ 1 + ] dip ] when
        ] when
    ] while 2drop { } like ;
