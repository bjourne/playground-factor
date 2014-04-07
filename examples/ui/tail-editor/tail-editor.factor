USING: accessors continuations documents formatting fry io io.encodings.utf8
io. io.monitors io.streams.string kernel sequences strings threads ui
ui.gadgets.editors ui.gadgets.scrollers ;
IN: examples.ui.tail-editor

: safe-next-change ( monitor -- change/f )
    [ next-change ] [ 2drop f ] recover ;

: read-all ( stream -- str )
    <string-writer> [ stream-copy* ] keep >string ;

: doc-append ( doc string -- )
    over doc-string prepend swap set-doc-string ;

: monitor-to-doc ( doc stream monitor -- )
    3dup safe-next-change [
        read-all doc-append monitor-to-doc
    ] [ 3drop 2drop ] if ;

: connect-monitor-to-doc ( doc monitor -- )
    [ path>> utf8 <file-reader> ] keep
    '[ _ _ _ monitor-to-doc ] "Tailer" spawn drop ;

: run-gui ( monitor -- )
    <multiline-editor> { 400 500 } >>pref-dim [
        model>> swap connect-monitor-to-doc
    ] [
        <scroller> swap path>> "Tailing '%u'" sprintf
    ] 2bi '[ _ _ open-window ] with-ui ;

: tail-file-in-window ( fname -- )
    [ f [ run-gui ] with-monitor ] with-monitors ;
