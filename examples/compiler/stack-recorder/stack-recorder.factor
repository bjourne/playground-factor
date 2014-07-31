! The idea is to be able to produce complete information about which
! stack locations are live at any given time.
USING: accessors arrays assocs compiler.cfg.dataflow-analysis
compiler.cfg.instructions formatting fry io io.streams.string kernel math
math.order prettyprint prettyprint.config sequences sequences.extras ;
IN: examples.compiler.stack-recorder

! Utility

! Compare with the one in yaml
: assoc-map! ( assoc quot -- )
    dupd assoc-map over clear-assoc assoc-union! drop ; inline

: >short ( obj -- str )
    [ [ pprint ] with-short-limits ] with-string-writer ;

! Domain-specific utility

: vacant-slots ( stack -- stack' )
    [ nip f = ] assoc-filter ;

: occupied-slots ( stack -- stack' )
    [ nip t = ] assoc-filter ;

: vacant-locations ( stack1 stack2 -- stack3 )
    [ vacant-slots ] bi@ assoc-union ;

: occupied-locations ( stack1 stack2 -- stack3 )
    [ occupied-slots ] bi@ assoc-intersect ;

: merge-locations ( stack1 stack2 -- stack3 )
    [ vacant-locations ] [ occupied-locations ] 2bi assoc-union ;

: join-stacks ( stacks -- stack )
    ! [ clone ] map
    ! If a stack location is vacant in one branch, it is vacant in the
    ! merged branch, but it must be occupied in all branches to be
    ! occupied in the merged branch.
    ! [ H{ } clone ] [
    !     [ [ vacant-slots ] map assoc-combine ]
    !     [ [ occupied-slots ] map assoc-refine ] bi
    !     assoc-union
    ! ] if-empty ;
    [ H{ } clone ] [ [ merge-locations ] reduce1 ] if-empty ;

: offset-stack-locations ( stack ofs -- )
    '[ [ _ + ] dip ] assoc-map! ;

: add-vacant-locations ( stack count -- )
    0 max iota [ f 2array ] map assoc-union! drop ;

ERROR: vacant-peek insn ;

GENERIC: visit-insn ( stack insn -- )

M: ##inc-d visit-insn ( stack insn -- )
    n>> 2dup offset-stack-locations add-vacant-locations ;

M: ##peek visit-insn ( stack insn -- )
    dup swapd loc>> n>> ?of 2array
    { f t } = [ vacant-peek ] [ drop ] if ;

: visit-replace ( stack insn -- )
    loc>> n>> t -rot swap set-at ;

M: ##replace visit-insn ( stack insn -- )
    visit-replace ;

M: ##replace-imm visit-insn ( stack insn -- )
    visit-replace ;

M: gc-map-insn visit-insn ( stack insn -- )
    2drop ;
    ! [ short. ] bi@ ;

M: insn visit-insn 2drop ;

FORWARD-ANALYSIS: stack-recorder

: visit-block ( in-set bb -- )
    instructions>> [
        2dup [ >short ] bi@ "%s %s\n" printf
        visit-insn
    ] with each ;

: param-log-transfer-set ( in-set bb dfa -- )
    drop [ ] [ instructions>> ] bi* [ >short ] bi@
    "transfer-set: %s %s\n" printf ;

! transfer-set doesnt appear to transfer state data as i thought it
! would.
M: stack-recorder-analysis transfer-set ( in-set bb dfa -- out-set )
    3dup param-log-transfer-set
    drop [ H{ } clone or ] dip dupd visit-block ;

M: stack-recorder-analysis join-sets ( sets bb dfa -- set )
    2drop join-stacks ;
