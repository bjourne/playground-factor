USING: accessors assocs compiler.cfg compiler.cfg.dataflow-analysis.private
compiler.cfg.instructions compiler.cfg.registers
examples.compiler.stack-recorder kernel sequences tools.test vectors ;
IN: examples.compiler.stack-recorder.tests

: create-cfg ( insns -- cfg )
    <basic-block> swap >>instructions cfg new swap >>entry ;

[
    V{ T{ ##peek { dst 37 } { loc D 0 } } } create-cfg
    compute-stack-recorder-sets
] [ uninitialized-peek? ] must-fail-with

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
    } create-cfg
    stack-recorder-analysis run-dataflow-analysis nip values first
] unit-test

{
    H{ { 0 t } { 1 t } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    } create-cfg
    stack-recorder-analysis run-dataflow-analysis nip values first
] unit-test
