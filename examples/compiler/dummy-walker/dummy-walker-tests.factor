USING: combinators.short-circuit compiler compiler.cfg.debugger compiler.cfg.linearization
examples.compiler.dummy-walker formatting generic kernel macros math sequences
vocabs words ;
IN: examples.compiler.dummy-walker.tests

: log-analyze-word ( word -- )
    "analyze-word: %u\n" printf ;

! : log-analyze-word ( word -- )
!     drop ;

: analyze-word ( word -- )
    dup log-analyze-word
    test-regs first dup linearization-order number-blocks
    compute-dummy-walker-sets ;

: word>blocks ( word -- bbs )
    test-regs first linearization-order ;

: regular-word? ( word -- ? )
    { generic? inline? macro? no-compile? primitive? }
    [ execute( x -- x ) ] with any? not ;

: short-word? ( word -- ? )
    word>blocks length 35 < ;

: testing-words ( -- words )
    all-words [ { [ regular-word? ] [ short-word? ] } 1&& ] filter ;
