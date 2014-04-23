USING: accessors calendar calendar.format documents fry kernel sequences
timers ui ui.gadgets.editors ui.gadgets.scrollers ui.gadgets.tables ;
IN: examples.ui.update-editor

: doc-append ( doc string -- )
    over doc-string prepend swap set-doc-string ;

: dummy-line ( -- line )
    now timestamp>string CHAR: \n suffix ;

: run-editor ( -- )
    <multiline-editor> [
        model>> '[ _ dummy-line doc-append ] 0.5 seconds every
    ] [
        { 300 150 } >>pref-dim <scroller>
        '[ _ "Editor Text That Grows" open-window ] with-ui
    ] bi stop-timer ;
