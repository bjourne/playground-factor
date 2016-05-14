USING: examples.deploy.mini.features kernel math system ;
IN: examples.deploy.mini.tests.test03

! 64-bit size: 14 280 (15 240)
! Purpose    : Requiring the quotation compiler for generics
: features ( -- assoc )
    {
        { quotation-compiler? t }
        { required-classes { fixnum } }
        { word-names? t }
    } ;

GENERIC: b-length ( obj -- n )

TUPLE: tool-1 ;

TUPLE: tool-2 ;

M: fixnum b-length drop 3 ;

M: tool-1 b-length drop 999 ;
M: tool-2 b-length drop 998 ;

: the-length ( n -- len )
    b-length ;

: main-word ( -- )
    3 the-length (exit) ;

MAIN: main-word
