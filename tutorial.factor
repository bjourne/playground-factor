! tutorial
! ========
! This module contains examples on how to use some words in the Factor
! language.
USING:
    accessors
    arrays
    assocs
    calendar
    combinators combinators.short-circuit
    formatting
    fry
    kernel
    math math.ranges
    mirrors
    prettyprint
    random
    sequences
    splitting
    strings
    unicode.case
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

! kernel: when
! ------------
! A slightly silly way of implementing the abs function.
: when-abs ( x -- x )
    dup 0 < [ -1 * ] when ;

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
! : multi-replace ( repls str -- str )
!     [ first2 replace ] reduce ;

! mirrors:<mirror>
! ----------------
! Gets an ordered list of slot values from the tuple whose names match
! those in the input sequence. This function can be pretty useful in
! cases when you want to iterate over all attributes of some tuple.
: slot-values ( slots tuple -- values )
    <mirror> >alist extract-keys values ;

! prettyprint: simple-table.
! --------------------------
! Demonstrates how to use slot-values to output a table of
! tuples. Called like this:
!
!     tuples { "attr1" "attr2" ... } simple-tuple-table
!
! and the result is a pretty table with headers being printed.
: simple-tuple-table ( tuples slots -- )
    [ '[ _ swap slot-values ] map ] keep prefix simple-table. ;

! calendar: time+
! ---------------
! Generate a random timestamp 500 days wihin current date. This
! function could be improved so that the timestamps aren't always
! full days apart.
: random-timestamp ( -- timestamp )
    now 1000 random 500 - days time+ ;

! sequences: pad-tail
! -------------------
! If you have an alist and want to output the key values nicely,
! pad-tail and longest comes in handy:
! : pad-strings ( strings -- strings )
!     dup longest '[ _ CHAR: \\s  pad-tail ] map ;

! : print-alist ( alist -- )
!     [ keys pad-strings ] [ values ] bi zip
!     [ " : " join ] map "\n" join print ;
