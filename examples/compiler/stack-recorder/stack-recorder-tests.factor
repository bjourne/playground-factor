USING: accessors arrays assocs compiler.cfg compiler.cfg.dataflow-analysis.private
compiler.cfg.instructions compiler.cfg.registers
examples.compiler.stack-recorder kernel sequences tools.test vectors ;
IN: examples.compiler.stack-recorder.tests

! Utils
: create-block ( insns n -- bb )
    <basic-block> swap >>number swap >>instructions ;

: block>cfg ( bb -- cfg )
    cfg new swap >>entry ;

: create-cfg ( insns -- cfg )
    0 create-block block>cfg ;

: compute-resulting-stack-map ( cfg -- map )
    stack-recorder-analysis run-dataflow-analysis nip values first ;

! Tests for join-stacks
{ H{ { 0 t } } } [
    { H{ { 0 t } } H{ { 0 t } } } join-stacks
] unit-test

{ H{ } } [
    { H{ { 0 t } } H{ { 1 t } } } join-stacks
] unit-test

! In one branch the zeroth stack location has been initialized, in the
! second it has only been allocated using inc-d 1. Peeking it is
! therefore forbidden.
{ H{ { 0 f } } }
[
    { H{ { 0 f } } H{ { 0 t } } } join-stacks
] unit-test

! Tests for add-vacant-locations
{ H{ } } [
    H{ } [ -1 add-vacant-locations ] keep
] unit-test

[ H{ { 0 f } } ] [
    V{ T{ ##inc-d f 1 } } create-cfg compute-resulting-stack-map
] unit-test

[
    V{
        T{ ##inc-d f 1 }
        T{ ##peek { dst 0 } { loc D 0 } }
    } create-cfg
    compute-stack-recorder-sets
] [ vacant-peek? ] must-fail-with

! Here the peek probably refers to a parameter of the word.
[ ] [
    V{
        T{ ##peek { dst 0 } { loc D 0 } }
    } create-cfg
    compute-stack-recorder-sets
] unit-test


{ H{ } } [
    V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } }
    create-cfg compute-resulting-stack-map
] unit-test

{ } [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##peek { dst 37 } { loc D 0 } }
    } create-cfg
    compute-stack-recorder-sets
] unit-test

{
    H{ { 0 t } { 1 t } { 2 t } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##replace { src 10 } { loc D 1 } }
        T{ ##replace { src 10 } { loc D 2 } }
    } create-cfg compute-resulting-stack-map
] unit-test

{
    H{ { 0 t } { 1 t } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    } create-cfg compute-resulting-stack-map
] unit-test

{
    H{ { -1 t } { 0 t } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } create-cfg compute-resulting-stack-map
] unit-test

{ H{ { -1 t } } }
[
    V{
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } create-cfg compute-resulting-stack-map
] unit-test

! Try and cross a basic-block boundary
{ H{ { -1 t } } } [
    V{
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    }
    V{
        T{ ##peek { dst 37 } { loc D 0 } }
        T{ ##inc-d f -1 }
    }
    [ 0 create-block ] bi@ 1vector >>successors block>cfg
    compute-resulting-stack-map
] unit-test

: connect-bbs ( from to -- )
    [ [ successors>> ] dip suffix! drop ]
    [ predecessors>> swap suffix! drop ] 2bi ;

: make-edges ( block-map edgelist -- )
    [ [ of ] with map first2 connect-bbs ] with each ;

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

{ } [
    {
        { 0 V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } } }
        {
            1 V{
                T{ ##inc-d f 2 }
                T{ ##replace-imm { src 0 } { loc D 1 } }
                T{ ##replace-imm { src 0 } { loc D 0 } }
            }
        }
    }
    [ over create-block ] assoc-map
    drop
] unit-test
