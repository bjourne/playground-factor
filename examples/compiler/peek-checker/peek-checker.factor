! True positives: run-test
! False positive:
! Unknown       : golden-rainbow

USING: accessors arrays compiler.cfg.dataflow-analysis
compiler.cfg.dataflow-analysis.private compiler.cfg.instructions
compiler.cfg.registers formatting fry io io.streams.string kernel math namespaces
prettyprint prettyprint.config sequences ;
IN: examples.compiler.peek-checker

! Utility
: >short ( obj -- str )
    [ [ pprint ] with-short-limits ] with-string-writer ;

! Stack methods
TUPLE: stack-state lower-bound assigned ;

: <stack-state> ( lower-bound assigned -- state )
    stack-state boa ;

! There needs to be a reasonable amount of clone calls. Probably
! should remake to use immutable data structures.
: clone-stack ( stack -- stack' )
    [ lower-bound>> ] [ assigned>> clone ] bi <stack-state> ;

: adjust-bound ( stack n -- )
    [ '[ _ + ] change-lower-bound drop ]
    [ [ assigned>> ] dip '[ _ + ] map! drop ] 2bi ;

: read-ok? ( stack n -- ? )
    [ swap lower-bound>> >= ] [ swap assigned>> member? ] 2bi or ;

FORWARD-ANALYSIS: peek-checker

GENERIC: visit-insn ( stack insn -- )

M: ##peek visit-insn ( stack insn -- )
    loc>> dup ds-loc? [
        n>> read-ok? [ "nope" throw ] unless
    ] [ 2drop ] if ;

: visit-replace ( stack insn -- )
    loc>> dup ds-loc? [
        n>> swap assigned>> 2dup member? [ 2drop ] [ push ] if
    ] [ 2drop ] if ;

M: ##inc-d visit-insn ( stack insn -- )
    n>> adjust-bound ;

M: ##replace visit-insn ( stack insn -- )
    visit-replace ;

M: ##replace-imm visit-insn ( stack insn -- )
    visit-replace ;

M: gc-map-insn visit-insn ( stack insn -- )
    ! Immediately following a gc, negative peeks are disallowed.
    drop assigned>> [ 0 >= ] filter! drop ;

M: insn visit-insn 2drop ;

: visit-block ( state bb -- )
    instructions>> [
        ! 2dup "%u %u\n" printf
        visit-insn
    ] with each ;

! This is a illogical method.
M: peek-checker-analysis block-order ( cfg dfa -- bbs )
    drop entry>> 1array ;

M: peek-checker-analysis reject-block? ( bb dfa -- ? )
    2drop f ;

M: peek-checker-analysis transfer-set ( in-set bb dfa -- out-set )
    drop
    2dup number>> swap "transfer-set: #%d %u\n" printf
    dupd visit-block clone-stack ;

M: peek-checker-analysis join-sets ( stacks bb dfa -- stack )
    2drop
    dup "join-sets: %u\n" printf

    ! [ length ] dip
    ! ! 2drop
    ! drop number>> "join-sets: %d\n" printf
    sift [ 0 V{ } clone <stack-state> ] [ first clone-stack ] if-empty ;
