! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays examples.deploy.mini.features io.streams.c kernel
math sequences sequences.private ;
IN: examples.deploy.mini.tests.test05

! Purpose    : Using io.streams.c:show
! 64-bit size: 97 616-
: features ( -- assoc )
    {
        { quotation-compiler? t }
        { required-classes {
            bignum byte-array copy-state fixnum object sequence tuple
        } }
    } ;

: main-word ( -- )
    "Hello, world!" show ;

MAIN: main-word
