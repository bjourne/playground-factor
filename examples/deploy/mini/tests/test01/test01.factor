USING: examples.deploy.mini.features system ;
IN: examples.deploy.mini.tests.test01

! Words      : (exit) main-word t c-to-factor
! Quotations : [ ]
! Code blocks: (exit) main-word/c-to-factor t [ ]
! 64-bit size: 1 888

: features ( -- assoc )
    H{ { quotation-compiler? f } } ;

: main-word ( -- ) 99 (exit) ;

MAIN: main-word
