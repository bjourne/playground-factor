USING: byte-arrays examples.deploy.mini.features io.streams.c kernel
math sequences sequences.private ;
IN: examples.deploy.mini.tests.test02

! 64-bit size: 2 616 (3 128)
! Purpose    : Hello world
CONSTANT: features {
    { global-hash? f }
    { required-classes {
        bignum byte-array copy-state fixnum object sequence tuple
    } }
    { quotation-compiler? f }
    { word-names? f }
}

! We are lucky that the generics are inlined.
: main-word ( -- )
    "Hello, world!\n"
    >byte-array dup length stdout-handle fwrite
    stdout-handle fflush ;

MAIN: main-word
