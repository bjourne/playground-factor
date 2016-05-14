! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.strings byte-arrays examples.deploy.mini.features
growable io.encodings io.encodings.utf8 io.streams.c io.streams.memory
kernel kernel.private math quotations sbufs sequences
sequences.private vectors ;
IN: examples.deploy.mini.tests.test07

! Purpose    : Reading special objects
! 64-bit size: 124 536 (136 376)
CONSTANT: features {
    { quotation-compiler? t }
    { required-classes {
        bignum byte-array
        c-ptr compose copy-state curry
        decoder
        fixnum
        growable
        memory-stream
        object
        quotation
        sequence
        sbuf
        tuple
        utf8
    } }
    { word-names? t }
}

: main-word ( -- )
    OBJ-VM-COMPILER special-object>string show
    OBJ-VM-COMPILE-TIME special-object>string show ;

MAIN: main-word
