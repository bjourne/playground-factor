! The idea is to be able to produce complete information about which
! stack locations are live at any given time.
USING: accessors assocs compiler.cfg.dataflow-analysis compiler.cfg.instructions
formatting fry io io.streams.string kernel math prettyprint prettyprint.config
sequences ;
IN: examples.compiler.stack-recorder

ERROR: uninitialized-peek insn ;

GENERIC: visit-insn ( map insn -- )

: assoc-map! ( assoc quot -- )
    dupd assoc-map over clear-assoc assoc-union! drop ; inline

: >short ( obj -- str )
    [ [ pprint ] with-short-limits ] with-string-writer ;

M: ##inc-d visit-insn ( map insn -- )
    n>> '[ [ _ + ] dip ] assoc-map! ;

M: ##peek visit-insn ( map insn -- )
    dup swapd loc>> n>> of [ drop ] [ uninitialized-peek ] if ;

: visit-replace ( map insn -- )
    loc>> n>> t -rot swap set-at ;

M: ##replace visit-insn ( map insn -- )
    visit-replace ;

M: ##replace-imm visit-insn ( map insn -- )
    visit-replace ;

M: insn visit-insn 2drop ;

: join-stacks ( stacks -- stack )
    [ H{ } clone ] [ unclip [ assoc-intersect ] reduce ] if-empty ;

FORWARD-ANALYSIS: stack-recorder

: visit-block ( in-set bb -- )
    instructions>> [ visit-insn ] with each ;

M: stack-recorder-analysis transfer-set ( in-set bb dfa -- out-set )
    drop [ H{ } or ] dip dupd visit-block clone ;

M: stack-recorder-analysis join-sets ( sets bb dfa -- set )
    2drop join-stacks ;
