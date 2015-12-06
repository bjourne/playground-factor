USING: examples.deploy.mini.features kernel math system ;
IN: examples.deploy.mini.tests.test03

! 64-bit size: 18 688, 17 664, 15 024
! Purpose    : Requiring the quotation compiler for generics

: features ( -- assoc )
    { { quotation-compiler? t } } ;

GENERIC: b-length ( obj -- n ) flushable

M: fixnum b-length drop 3 ;

: the-length ( n -- len )
    b-length ;

: main-word ( -- )
    3 the-length (exit) ;

MAIN: main-word
