USING: examples.deploy.mini.features kernel math system ;
IN: examples.deploy.mini.tests.test03

! 64-bit size: 18 688, 17 664
! Purpose    : Requiring the quotation compiler for generics

: features ( -- assoc )
    H{ { quotation-compiler? t } } ;

GENERIC: b-length ( obj -- n ) flushable

M: fixnum b-length drop 3 ;

: the-length ( n -- len )
    b-length ;

: main-word ( -- )
    3 the-length (exit) ;
    ! 3 the-length (exit) ;
    ! 3 the-length 9 the-length fixnum+fast (exit) ;
    ! B{ 3 4 } the-length (exit) ;

    ! "Hello, world!\n"
    ! >byte-array dup the-length stdout-handle fwrite
    ! stdout-handle fflush ;

MAIN: main-word
