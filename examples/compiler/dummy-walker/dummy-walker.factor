USING: accessors arrays byte-arrays classes compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.registers
formatting fry io kernel math math.order sequences sets ;
IN: examples.compiler.dummy-walker
QUALIFIED: sets

! Operations on the stack info
: register-write ( ds-loc stack -- stack' )
    first2 rot suffix sets:members 2array ;

: adjust-stack ( inc-d stack -- stack' )
    first2 pick '[ _ + ] map [ + ] dip 2array ;

: read-ok? ( ds-loc stack -- ? )
    [ first >= ] [ second in? ] 2bi or ;

! After a gc, negative writes have been erased.
: register-gc ( stack -- stack' )
    first2 [ 0 >= ] filter 2array ;

: stack>uninitialized ( stack -- seq )
    first2 [ 0 max iota ] dip diff ;

: uninitialized>byte-array ( seq -- ba )
    [ B{ } ] [
        dup supremum 1 + 1 <array>
        [ '[ _ 0 -rot set-nth ] each ] keep >byte-array
    ] if-empty ;

! Operations on the analysis state
: state>gc-bitmap ( state -- pair )
    [ stack>uninitialized uninitialized>byte-array ] map ;

! Stack bottom is 0 for d and r and no replaces.
: initial-state ( -- state )
    { { 0 { } } { 0 { } } } ;

: insn>gc-bitmap ( insn -- pair )
    gc-map>> [ scrub-d>> ] [ scrub-r>> ] bi 2array ;

: log-gc-map-insn ( state insn -- )
    [ state>gc-bitmap ] [ [ class-of ] [ insn>gc-bitmap ] bi ] bi* rot
    2dup = not [ "%u: given %u have %u\n" printf ] [ 3drop ] if ;

GENERIC: visit-insn ( state insn -- state' )

M: ##inc-d visit-insn ( state insn -- state' )
    n>> swap first2 [ adjust-stack ] dip 2array ;

M: ##inc-r visit-insn ( state insn -- state' )
    n>> swap first2 swapd adjust-stack 2array ;

: insn>location ( insn -- n ds? )
    loc>> [ n>> ] [ ds-loc? ] bi ;

: visit-replace ( state insn -- state' )
    [ first2 ] dip insn>location
    [ rot register-write swap ] [ swap register-write ] if 2array ;

M: ##replace-imm visit-insn visit-replace ;
M: ##replace visit-insn visit-replace ;

ERROR: vacant-peek insn ;

: peek-loc-ok? ( state insn -- ? )
    insn>location 0 1 ? rot nth read-ok? ;

: visit-peek ( state insn -- )
    swap over peek-loc-ok? [ drop ] [ vacant-peek ] if ;

M: ##peek visit-insn ( state insn -- state' )
    dupd visit-peek ;

M: gc-map-insn visit-insn ( state insn -- state' )
    2dup log-gc-map-insn drop [ register-gc ] map ;

M: insn visit-insn ( state insn -- state' )
    drop ;

FORWARD-ANALYSIS: dummy-walker

M: dummy-walker-analysis transfer-set ( in-set bb dfa -- out-set )
    drop instructions>> swap [ visit-insn ] reduce ;

M: dummy-walker-analysis ignore-block? ( bb dfa -- ? )
    2drop f ;

! Always picking the first means that a block will only be analyzed
! once.
M: dummy-walker-analysis join-sets ( sets bb dfa -- set )
    2drop [ initial-state ] [ first ] if-empty ;
