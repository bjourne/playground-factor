! Note 1: The walk is as expected, but the stupid block numbers have
! to be reinitialized for regs. to match.
!
! Note 2: It appears that a basic blocks initial stack height might
! *differ* depending on what path trough the cfg execution took. No
! idea if that's bad.
!
! Note 3: Should dataflow-analysis really visit the same basic block
! more than once? Sure if the in-set changes it should.
!
! Note 4: compilation of windows-time is not deterministic.
!
! All these words appear to suffer from the "references above the
! stack not traced" bug:
!     (gamma-random-float<1)/777
!     (use-digit)/133
!     barrett-mu/218
!     create-window
!     decimal>ratio/98
!     golden-rainbow/62
!     n-digits-primes/181
!     pareto-random-float/128
!     power-random-float/201
!     read-rfc3339-seconds/144
!     weibull-random-float/215
!     pareto-random-float
!     power-random-float
!     run-test
!     weibull-random-float
!     euler056
!     estimate-cardinality
!     (storage>n)
!     find-unit-suffix
!     reduce-magnitude
!     d^
!     decimalize
!     p-norm
!     parse-decimal
!     minkowski-distance
!     stirling-fact
!     bits-to-satisfy-error-rate
!     exponential-index
!     logspace[a,b)
!     ramanujan
!     logspace[a,b]
!     svg-string>number
!     digit-groups
!     (euler255)
!     exponential-factorial
!     (mult-order)
!
! This is a list of words in which uninitialized.factor wrongly claims
! initialized stack locations are uninitialized.
!
!     <effect>                  17
!     <product-sequence>
!     fork-process
!     make-bitmap               15
!     models.range:<range>      16
!     visit-derived-root
!     ...
!
! The bug appears to be caused by instruction sequences like this:
!
!     ##inc-d -3
!     ... do stuff
!     ##inc-d 3
!
! Unitialized.factor will think 3 locations are unallocated, but they
! are not.
USING: accessors combinators.short-circuit compiler compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.linearization continuations
examples.compiler.dummy-walker formatting generic io io.streams.string kernel
macros math sequences stack-checker.errors vocabs words ;
IN: examples.compiler.dummy-walker.debugger

! logging
: log-analyze-word ( word -- )
    "analyze-word: %u\n" printf ;

! insn methods
: scrub-d-insn? ( insn -- ? )
    { [ gc-map-insn? ] [ gc-map>> scrub-d>> length 2 >= ] } 1&& ;

! word methods
: word>blocks ( word -- bbs )
    test-regs first linearization-order ;

: word-length ( word -- length )
    word>blocks length ;

: word>numbered-cfg ( word -- cfg )
    test-regs first dup linearization-order number-blocks ;

! word predicates
: regular-word? ( word -- ? )
    { generic? inline? macro? no-compile? primitive? }
    [ execute( x -- x ) ] with any? not ;

: short-word? ( word -- ? )
    [ word-length 2000 < ] [
        nip dup do-not-compile? [ drop f ] [ throw ] if
    ] recover ;

: word-has-gc-map? ( word -- ? )
    word>blocks [ instructions>> ] map concat [ scrub-d-insn? ] any? ;

! main
: analyze-word ( word -- )
    dup word>numbered-cfg [ compute-dummy-walker-sets ] with-string-writer
    [ drop ] [ swap log-analyze-word print ] if-empty ;

! word selection
: testing-words ( -- words )
    all-words [ regular-word? ] filter [ short-word? ] filter ;

: failing-words ( words -- words' )
    [ [ analyze-word f ] [ 2drop t ] recover ] filter ;
