USING: accessors arrays assocs combinators.short-circuit compiler compiler.cfg
compiler.cfg.dataflow-analysis.private compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.linearization compiler.cfg.registers
examples.compiler.dummy-walker continuations formatting generic kernel macros
math sequences sorting stack-checker.errors tools.test vectors vocabs words ;
IN: examples.compiler.dummy-walker.tests

! : log-analyze-word ( word -- )
!     "analyze-word: %u\n" printf ;

: log-analyze-word ( word -- )
    drop ;

: analyze-word ( word -- )
    dup log-analyze-word
    test-regs first dup linearization-order number-blocks
    compute-dummy-walker-sets ;

: word>blocks ( word -- bbs )
    test-regs first linearization-order ;

: word-size ( word -- size )
    word>blocks length ;

: regular-word? ( word -- ? )
    { generic? inline? macro? no-compile? primitive? }
    [ execute( x -- x ) ] with any? not ;

: short-word? ( word -- ? )
    [ word-size 30 < ] [
        nip dup do-not-compile? [ drop f ] [ throw ] if
    ] recover ;

: testing-words ( -- words )
    all-words [ regular-word? ] filter [ short-word? ] filter ;

: failing-words ( words -- words' )
    [ [ analyze-word f ] [ 2drop t ] recover ] filter ;

: scrub-d-insn? ( insn -- ? )
    { [ gc-map-insn? ] [ gc-map>> scrub-d>> length 3 >= ] } 1&& ;

: has-gc-map? ( insns -- ? )
    [ scrub-d-insn? ] any? ;

! Utils
: create-block ( insns n -- bb )
    <basic-block> swap >>number swap >>instructions ;

: block>cfg ( bb -- cfg )
    cfg new swap >>entry ;

: create-cfg ( insns -- cfg )
    0 create-block block>cfg ;

: output-stack-map ( cfg -- map )
    dummy-walker-analysis run-dataflow-analysis
    nip [ [ number>> ] dip ] assoc-map >alist natural-sort last second ;

: connect-bbs ( from to -- )
    [ [ successors>> ] dip suffix! drop ]
    [ predecessors>> swap suffix! drop ] 2bi ;

: make-edges ( block-map edgelist -- )
    [ [ of ] with map first2 connect-bbs ] with each ;

! Uninitialized peek
[
    V{
        T{ ##inc-d f 1 }
        T{ ##peek { dst 0 } { loc D 0 } }
    } create-cfg
    compute-dummy-walker-sets
] [ vacant-peek? ] must-fail-with

! Here the peek refers to a parameter of the word.
[ ] [
    V{
        T{ ##peek { dst 0 } { loc D 0 } }
    } create-cfg
    compute-dummy-walker-sets
] unit-test

! Replace -1 then peek is ok.
[ ] [
    V{
        T{ ##replace { src 10 } { loc D -1 } }
        T{ ##peek { dst 0 } { loc D -1 } }
    } create-cfg
    compute-dummy-walker-sets
] unit-test

! Replace -1, then gc, then peek is not ok.
[
    V{
        T{ ##replace { src 10 } { loc D -1 } }
        T{ ##alien-invoke }
        T{ ##peek { dst 0 } { loc D -1 } }
    } create-cfg
    compute-dummy-walker-sets
] [ vacant-peek? ] must-fail-with

! Should be ok because the value was at 0 when the gc ran.
{ { -1 { -1 } } } [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##alien-invoke }
        T{ ##inc-d f -1 }
        T{ ##peek { dst 0 } { loc D -1 } }
    } create-cfg output-stack-map
] unit-test

! Should not be ok because the value wasn't initialized when gc ran.
[
    V{
        T{ ##inc-d f 1 }
        T{ ##alien-invoke }
        T{ ##peek { dst 0 } { loc D 0 } }
    } create-cfg
    compute-dummy-walker-sets
] [ vacant-peek? ] must-fail-with


{ { 0 { } } } [
    V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } }
    create-cfg output-stack-map
] unit-test

{
    { 0 { 0 1 2 } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##replace { src 10 } { loc D 1 } }
        T{ ##replace { src 10 } { loc D 2 } }
    } create-cfg output-stack-map
] unit-test

{
    { 1 { 1 0 } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    } create-cfg output-stack-map
] unit-test

{
    { 0 { 0 -1 } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } create-cfg output-stack-map
] unit-test

{ { 0 { -1 } } }
[
    V{
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } create-cfg output-stack-map
] unit-test

: cfg1 ( -- cfg )
    V{
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    } 0 create-block
    V{
        T{ ##peek { dst 37 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } 1 create-block
    1vector >>successors block>cfg ;

{ { 0 { -1 } } } [ cfg1 output-stack-map ] unit-test

! Same cfg structure as the bug1021:run-test word but with
! non-datastack instructions mostly omitted.
: bug1021-cfg ( -- cfg )
    {
        { 0 V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } } }
        {
            1 V{
                T{ ##inc-d f 2 }
                T{ ##replace { src 0 } { loc D 1 } }
                T{ ##replace { src 0 } { loc D 0 } }
            }
        }
        {
            2 V{
                T{ ##call { word <array> } }
            }
        }
        {
            3 V{
                T{ ##inc-d f 2 }
                T{ ##peek { dst 0 } { loc D 2 } }
                T{ ##peek { dst 0 } { loc D 3 } }
                T{ ##replace { src 0 } { loc D 2 } }
                T{ ##replace { src 0 } { loc D 3 } }
                T{ ##replace { src 0 } { loc D 1 } }
            }
        }
        {
            8 V{
                T{ ##inc-d f 3 }
                T{ ##peek { dst 0 } { loc D 5 } }
                T{ ##replace { src 0 } { loc D 0 } }
                T{ ##replace { src 0 } { loc D 3 } }
                T{ ##peek { dst 0 } { loc D 4 } }
                T{ ##replace { src 0 } { loc D 1 } }
                T{ ##replace { src 0 } { loc D 2 } }
            }
        }
        {
            10 V{

                T{ ##inc-d f -3 }
                T{ ##peek { dst 0 } { loc D -3 } }
                T{ ##alien-invoke }
            }
        }
    } [ over create-block ] assoc-map dup
    { { 0 1 } { 1 2 } { 2 3 } { 3 8 } { 8 10 } } make-edges 0 of block>cfg ;

{ { 4 { 3 2 1 0 } } } [ bug1021-cfg output-stack-map ] unit-test
