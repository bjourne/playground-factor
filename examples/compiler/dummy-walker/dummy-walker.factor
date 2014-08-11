USING: accessors arrays byte-arrays classes compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.linearization compiler.cfg.registers
formatting fry io kernel math math.order sequences sets ;
IN: examples.compiler.dummy-walker
QUALIFIED: sets

! Domain utility
: register-write ( ds-loc state -- state' )
    first2 rot suffix 2array ;

: adjust-stack ( inc-d state -- state' )
    first2 pick '[ _ + ] map [ + ] dip 2array ;

: read-ok? ( ds-loc state -- ? )
    [ first >= ] [ second in? ] 2bi or ;

! After a gc, negative writes have been erased.
: register-gc ( state -- state' )
    first2 [ 0 >= ] filter 2array ;

! Stack bottom is 0 and no replaces.
: initial-state ( -- state )
    { 0 { } } ;

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
    2dup = not [ "%u: expected %u has %u\n" printf ] [ 3drop ] if ;

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

M: gc-map-insn visit-insn ( state insn -- state' )
    2dup log-gc-map-insn drop register-gc ;

M: insn visit-insn ( state insn -- state' )
    drop ;

FORWARD-ANALYSIS: dummy-walker

: analyze-block ( state bb -- state' )
    instructions>> swap [ visit-insn ] reduce
    first2 sets:members 2array ;

! Always picking the first means that a block will only be analyzed
! once.
: join-states ( states -- state )
    [ initial-state ] [ first ] if-empty ;

M: dummy-walker-analysis transfer-set ( in-set bb dfa -- out-set )
    drop analyze-block ;

M: dummy-walker-analysis ignore-block? ( bb dfa -- ? )
    2drop f ;

M: dummy-walker-analysis join-sets ( sets bb dfa -- set )
    2drop join-states ;
