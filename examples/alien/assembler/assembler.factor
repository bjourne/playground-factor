USING: alien alien.c-types alien.data alien.syntax
compiler.codegen.labels compiler.codegen.relocation
cpu.x86.64 cpu.x86.assembler cpu.x86.assembler.operands
kernel namespaces random sequences specialized-arrays ;
IN: examples.alien.callbacks

LIBRARY: libc

FUNCTION: void qsort ( void* base,
                       size_t num,
                       size_t width,
                       void* func ) ;

SPECIALIZED-ARRAY: uint

CALLBACK: int comparer ( void* arg1, void* arg2 ) ;

: assembly-compare ( uint1* uint2* -- -1/0/1 )
    init-relocation
    int { void* void* } cdecl [
        "gt" "lt" "end" [ define-label ] tri@
        RBP 0xffff0000 MOV
        ! Remember that these are 32 bit numbers.
        EBX param-reg-0 [] MOV
        ECX param-reg-1 [] MOV
        EBX ECX CMP
        "gt" get JG
        "lt" get JL
        RAX 0 MOV
        "end" get JMP
        "gt" resolve-label
        RAX 1 MOV
        "end" get JMP
        "lt" resolve-label
        RAX -1 MOV
        "end" resolve-label
    ] alien-assembly ;

: <comparer> ( -- alien )
    int { pointer: void pointer: void } cdecl
    [ assembly-compare ] alien-callback ;

: random-array ( length -- seq )
    [ 100 random ] replicate ;

: qsort-seq ( seq type -- seq' )
    2dup >c-array [
        -rot [ length ] [ heap-size ] bi* <comparer> qsort
    ] keep ;
