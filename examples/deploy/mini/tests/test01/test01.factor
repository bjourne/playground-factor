USING: examples.deploy.mini.features kernel system ;
IN: examples.deploy.mini.tests.test01

! Words      : (exit) main-word t c-to-factor
! Quotations : [ ]
! Code blocks: (exit) main-word/c-to-factor [ ]
! 64-bit size: 1 496

: features ( -- assoc )
    {
        { quotation-compiler? f }
        { required-classes { } }
        { global-hash? f }
    } ;

: main-word ( -- ) 99 (exit) ;

MAIN: main-word
