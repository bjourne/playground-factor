! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: examples.deploy.mini.utils kernel memory quotations sequences
slots.private words ;
IN: examples.deploy.mini.word-stripping

CONSTANT: SLOT-NAME 2
CONSTANT: SLOT-VOCABULARY 3
CONSTANT: SLOT-DEF 4
CONSTANT: SLOT-PROPS 5
CONSTANT: SLOT-PIC-DEF 6
CONSTANT: SLOT-PIC-TAIL-DEF 6

: clear-slot ( word n -- )
    f -rot set-slot ;

: strip-word ( word-names? word -- )
    swap [
        dup SLOT-NAME clear-slot
        dup SLOT-VOCABULARY clear-slot
    ] unless
    dup SLOT-PROPS clear-slot
    dup SLOT-PIC-DEF slot [ jit-compile ] when*
    dup SLOT-PIC-TAIL-DEF slot [ jit-compile ] when*
    SLOT-DEF clear-slot ;

: strip-words ( word-names? -- )
    "Compiling identity quotation..." safe-show
    [ ] dup jit-compile f swap 1 set-slot

    "Stripping word instances..." safe-show
    all-instances [
        dup word? [ strip-word ] [ 2drop ] if
    ] with each ;
