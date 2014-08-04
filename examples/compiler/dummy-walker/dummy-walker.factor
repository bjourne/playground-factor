! Note 1: The walk is as expected, but the stupid block numbers have
! to be reinitialized for regs. to match.
!
! Note 2: It appears that a basic blocks initial stack height might
! *differ* depending on what path trough the cfg execution took. No
! idea if that's bad.
!
! Note 3: Should dataflow-analysis really visit the same basic block
! more than once?
!
! Weird words: (match-all) golden-rainbow
USING: accessors arrays combinators.short-circuit compiler
compiler.cfg.dataflow-analysis compiler.cfg.dataflow-analysis.private
compiler.cfg.debugger compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.registers formatting fry generic io io.streams.string kernel
macros math prettyprint prettyprint.config sequences sets vocabs words ;
IN: examples.compiler.dummy-walker

! Utility
: >short ( obj -- str )
    [ [ pprint ] with-short-limits ] with-string-writer ;

GENERIC: visit-insn ( state insn -- state' )

M: ##inc-d visit-insn ( state insn -- state' )
    n>> + ;

M: insn visit-insn ( state insn -- state' )
    drop ;

! Logging
! : log-(transfer-set) ( in-set bb -- )
!     2drop ;
! : log-(join-sets) ( sets -- )
!     drop ;

: log-analyze-word ( word -- )
    "analyze-word: %u\n" printf ;

: log-(transfer-set) ( in-set bb -- )
    [ ] [ block-number ] bi* swap ! [ >short ] bi@ swap
    "(transfer-set): #%s %u\n" printf ;

: log-(join-sets) ( sets bb -- )
    block-number swap "(join-sets): #%s %u\n" printf ;

FORWARD-ANALYSIS: dummy-walker

: (transfer-set) ( in-set bb -- out-set )
    2dup log-(transfer-set)
    instructions>> swap [ visit-insn ] reduce ;
    ! block-number ;

: (join-sets) ( sets bb -- set )
    dupd log-(join-sets) [ { 0 } ] when-empty
    ! dup log-(join-sets) [ { 0 } ] when-empty
    [ members length 1 assert= ] [ first ] bi ;

M: dummy-walker-analysis transfer-set ( in-set bb dfa -- out-set )
    drop (transfer-set) dup fixnum? t assert= ;

M: dummy-walker-analysis ignore-block? ( bb dfa -- ? )
    2drop f ;

M: dummy-walker-analysis join-sets ( sets bb dfa -- set )
    drop (join-sets) dup fixnum? t assert= ;
    ! 2drop (join-sets) dup fixnum? t assert= ;

: analyze-word ( word -- )
    dup log-analyze-word
    test-regs first dup linearization-order number-blocks
    compute-dummy-walker-sets ;

: word>blocks ( word -- bbs )
    test-regs first linearization-order ;

: regular-word? ( word -- ? )
    { generic? inline? macro? no-compile? primitive? }
    [ execute( x -- x ) ] with any? not ;

: short-word? ( word -- ? )
    word>blocks length 20 < ;

: testing-words ( -- words )
    all-words 500 head [ { [ regular-word? ] [ short-word? ] } 1&& ] filter ;
