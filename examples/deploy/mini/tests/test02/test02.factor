USING: byte-arrays examples.deploy.mini.features io.streams.c kernel
sequences ;
IN: examples.deploy.mini.tests.test02

! 64-bit size: 3 024

: features ( -- assoc )
    H{ { quotation-compiler? f } } ;

! We are lucky that the generics are inlined.
: main-word ( -- )
    "Hello, world!\n"
    >byte-array dup length stdout-handle fwrite
    stdout-handle fflush ;

MAIN: main-word
