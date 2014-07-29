! The idea is to be able to produce complete information about which
! stack locations are live at any given time.
USING: accessors assocs compiler.cfg.dataflow-analysis compiler.cfg.instructions
formatting fry io kernel math sequences ;
IN: examples.compiler.stack-recorder

ERROR: uninitialized-peek insn ;

GENERIC: visit-insn ( map insn -- )

: assoc-map! ( assoc quot -- )
    dupd assoc-map over clear-assoc assoc-union! drop ; inline

M: ##inc-d visit-insn ( map insn -- )
    n>> '[ [ _ + ] dip ] assoc-map! ;

M: ##peek visit-insn ( map insn -- )
    dup swapd loc>> n>> of [ drop ] [ uninitialized-peek ] if ;

M: ##replace visit-insn ( map insn -- )
    loc>> n>> t -rot swap set-at ;

FORWARD-ANALYSIS: stack-recorder

: visit-block ( in-set bb -- )
    instructions>> [ visit-insn ] with each ;

M: stack-recorder-analysis transfer-set ( in-set bb dfa -- out-set )
    drop [ H{ } clone or ] dip dupd visit-block ;
