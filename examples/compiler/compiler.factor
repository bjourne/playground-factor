USING: accessors arrays assocs combinators compiler.cfg compiler.cfg.def-use
compiler.cfg.dependence compiler.cfg.finalization compiler.cfg.instructions
compiler.cfg.scheduling grouping kernel
math sequences stack-checker.values ;
QUALIFIED: compiler
IN: examples.compiler

! Utils
: split-indices ( seq indices -- parts )
    over length suffix 0 prefix 2 clump [ first2 rot subseq ] with map ;

: 2with ( p1 p2 obj quot -- obj curry )
    with with ; inline

: enumerate-insns ( insns -- insns' )
    clone [ >>insn# ] map-index ;

: instructions>nodes ( insns -- nodes )
    enumerate-insns [ <node> ] map ;

: split-insns ( insns -- pre/body/post )
    dup [ initial-insn-end ] [ final-insn-start ] bi 2array split-indices ;

! Mutations
: vreg-introductors ( node -- assoc )
    [ dup insn>> defs-vregs [ swap 2array ] with map ] map concat ;

: make-edge ( node-to node-from type -- )
    -rot precedes>> set-at ;

: make-data-edge ( introductors successor vreg -- )
    swapd of +data+ make-edge ;

: my-add-data-edges ( nodes -- )
    [ vreg-introductors ] keep [
        dup insn>> uses-vregs [ make-data-edge ] 2with each
    ] with each ;

: (make-control-edge) ( stack-locs successor loc -- )
    swapd 2dup of [
        [ pick ] dip +control+ make-edge
    ] when* swap set-at ;

GENERIC: make-control-edge ( stack-locs successor insn -- )

M: stack-insn make-control-edge loc>> (make-control-edge) ;
M: memory-insn make-control-edge drop memory-insn (make-control-edge) ;
M: object make-control-edge 3drop ;

: my-add-control-edges ( nodes -- )
    H{ } swap [ dup insn>> make-control-edge ] with each ;

: set-parents ( nodes -- )
    [ choose-parent ] each ;

: my-build-dep-trees ( insns -- trees )
    instructions>nodes dup {
        [ my-add-data-edges ]
        [ my-add-control-edges ]
        [ set-follows ]
        [ set-parents ]
    } cleave [ parent>> not ] filter ;
