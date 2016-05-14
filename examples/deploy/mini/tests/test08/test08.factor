! Copyright (C) 2016 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays destructors examples.deploy.mini.features growable
hash-sets hashtables io.streams.c kernel math namespaces
namespaces.private quotations sequences sequences.private
slots.private system ;
IN: examples.deploy.mini.tests.test08

! Purpose    : Preserving globals
! 64-bit size: (80 120)

CONSTANT: features {
    { quotation-compiler? t }
    { required-classes {
        fixnum
        global-hashtable global-box
        hashtable
        object
        tuple
    } }
    { global-hash? t }
    { required-vars { os } }
    { word-names? t }
}

! To prevent inlining trickery.
: get-the-global ( key -- val )
    get-global ;

: main-word ( -- )
    \ os get-the-global 2 slot 1 slot (exit) ;

MAIN: main-word
