! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays examples.deploy.mini.features kernel math sequences
sequences.private slots.private system ;
IN: examples.deploy.mini.tests.test04

! Purpose    : Requiring additional classes for generics
! 64-bit size: 10 472
: features ( -- assoc )
    {
        { quotation-compiler? t }
        { required-classes {
            bignum byte-array copy-state fixnum object sequence tuple
        } }
        { word-names? f }
    } ;

: main-word ( -- )
    "Hello, world!\n" >byte-array 1 slot (exit) ;

MAIN: main-word
