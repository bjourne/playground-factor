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
!     <product-sequence>
!     fork-process
!     models.range:<range>
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
USING: accessors arrays byte-arrays classes compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.registers formatting fry io io.streams.string kernel
math math.order sequences sets ;
IN: examples.compiler.dummy-walker
QUALIFIED: sets

! Domain utility
: register-write ( ds-loc state -- state' )
    first2 rot suffix 2array ;

: adjust-stack ( inc-d state -- state' )
    first2 pick '[ _ + ] map [ + ] dip 2array ;

: read-ok? ( ds-loc state -- ? )
    [ first >= ] [ second in? ] 2bi or ;

! Logging
: log-(transfer-set) ( in-set bb -- )
    2drop ;
: log-(join-sets) ( sets bb -- )
    2drop ;

! : log-(transfer-set) ( in-set bb -- )
!     [ ] [ block-number ] bi* swap
!     "(transfer-set): #%s %u\n" printf ;

! : log-(join-sets) ( sets bb -- )
!     block-number swap "(join-sets): #%s %u\n" printf ;

: state>uninitialized ( state -- seq )
    first2 [ 0 max iota ] dip diff ;

: uninitialized>bitmap ( seq -- ba )
    [ B{ } ] [
        dup supremum 1 + 1 <array>
        [ '[ _ 0 -rot set-nth ] each ] keep >byte-array
    ] if-empty ;

: log-gc-map-insn ( state insn -- )
    [ class-of ] [ gc-map>> scrub-d>> ] bi rot
    state>uninitialized uninitialized>bitmap
    "%u: expected %u has %u\n" printf ;

! visit-insn
GENERIC: visit-insn ( state insn -- state' )

M: ##inc-d visit-insn ( state insn -- state' )
    n>> swap adjust-stack ;

: visit-replace ( state insn -- state' )
    loc>> dup ds-loc? [ n>> swap register-write ] [ drop ] if ;

M: ##replace-imm visit-insn visit-replace ;
M: ##replace visit-insn visit-replace ;

ERROR: vacant-peek insn ;

: visit-peek ( state insn -- )
    dup loc>> dup ds-loc? [
        n>> rot read-ok? [ drop ] [ vacant-peek ] if
    ] [ 3drop ] if ;

M: ##peek visit-insn ( state insn -- state' )
    dupd visit-peek ;

! After a gc, negative writes have been erased.
M: gc-map-insn visit-insn ( state insn -- state' )
    2dup log-gc-map-insn
    drop first2 [ 0 >= ] filter 2array ;

M: insn visit-insn ( state insn -- state' )
    drop ;

FORWARD-ANALYSIS: dummy-walker

: (transfer-set) ( in-set bb -- out-set )
    2dup log-(transfer-set)
    instructions>> swap [ visit-insn ] reduce ;

! Stack bottom is 0 and no replaces.
: initial-state ( -- state )
    { 0 { } } ;

! Always picking the first means that a block will only be analyzed
! once.
: join-states ( states -- state )
    [ initial-state ] [ first ] if-empty ;

: (join-sets) ( sets bb -- set )
    dupd log-(join-sets) join-states ;

M: dummy-walker-analysis transfer-set ( in-set bb dfa -- out-set )
    drop (transfer-set) first2 sets:members 2array ;

M: dummy-walker-analysis ignore-block? ( bb dfa -- ? )
    2drop f ;

M: dummy-walker-analysis join-sets ( sets bb dfa -- set )
    drop (join-sets) ;
