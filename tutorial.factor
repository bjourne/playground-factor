! tutorial
! ========
! This module contains examples on how to use some words in the Factor
! language.
USING:
    accessors
    arrays
    ascii
    assocs
    combinators
    combinators.short-circuit
    formatting
    kernel
    math
    math.ranges
    random
    sequences
    splitting
    strings
    xml.entities
    ;
IN: tutorial

! combinators: 2bi
! ----------------
! Demonstrates how to use the 2bi combinator by calculating
! z = x * y - x + y
: demo-2bi ( x y -- z )
    [ * ] [ + ] 2bi - ;

! combinators.short-circuit: 1&&
! ------------------------------
! This combinator is useful for implementing complex boolean Here we
! return t if the object on the stack is an array of length two whose
! first element is a number and second element a string.
! Due to it's short-circuiting nature, it will not fail if the object
! is not an array.
: demo-1&& ( obj -- ? )
    { [ array? ] [ length 2 = ] [ first number? ]  [ second string? ] } 1&& ;

! TUPLE
! -----
! A boring tuple with only one slot. If name is not given, it is
! dummy.
TUPLE: person { name initial: "dummy" } ;

! accessors:
: demo-initial ( -- x )
    person new name>> ;

! sequences: rest
! ---------------
! Here is a way to parse a mail header. To make it more interesting
! extraneous spaces are trimmed from the resulting value. Try it with
!    "from:  sender   name  <some.email@domain.com" parse-header .
: parse-header ( header -- value )
    " " split harvest rest " " join ;

! sequences: replicate
! --------------------
! How to use replicate to generate a random "believable name" composed
! of a first and lastname.
: ascii-letters ( -- seq )
    CHAR: a CHAR: z [a,b] ;

: generate-ascii-name ( -- str )
    2 [ 8 [1,b] random [ ascii-letters random ] replicate ] replicate
    " " join >title ;

! sequences: reduce
! -----------------
! Executes multiple string substitutions in one go.
: multi-replace ( repls str -- str )
    [ first2 replace ] reduce ;


    


