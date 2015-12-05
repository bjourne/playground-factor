! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays examples.deploy.mini.features io.streams.c kernel
math sequences slots.private ;
IN: examples.deploy.mini.tests.test04

! Purpose    : See if we can strip away the unused methods of the-length
! Goal: 21664

: features ( -- assoc )
    H{ { quotation-compiler? t } } ;

GENERIC: the-length ( obj -- len )

M: byte-array the-length ( obj -- len )
    1 slot ;

M: fixnum the-length ( obj -- len )
    length ;

: oh-length ( obj -- len )
    the-length ;

: main-word ( -- )
    "Hello, world!\n"
    >byte-array dup oh-length stdout-handle fwrite
    stdout-handle fflush ;

MAIN: main-word
