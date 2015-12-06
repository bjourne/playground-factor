! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays examples.deploy.mini.features hashtables kernel
math namespaces namespaces.private quotations sequences
sequences.private system ;
IN: examples.deploy.mini.tests.test06

! Purpose    : Global variables
! 64-bit size: 25 248
: features ( -- assoc )
    {
        { quotation-compiler? t }
        { required-classes {
            bignum byte-array
            compose curry
            copy-state fixnum
            global-hashtable global-box
            hashtable
            object
            quotation
            sequence tuple
        } }
        { global-hash? t }
    } ;

: do-it ( -- )
    33 44 set-global ;

: main-word ( -- )
    do-it 44 get-global (exit) ;

MAIN: main-word
