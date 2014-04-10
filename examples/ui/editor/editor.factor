USING: accessors fry io.encodings.utf8 io.files kernel ui ui.gadgets.editors
ui.gadgets.scrollers ;
IN: examples.ui.editor

: show-file ( file -- )
    <multiline-editor> { 300 400 } >>pref-dim f >>editable?
    over utf8 file-contents over set-editor-string <scroller>
    swap '[ _ _ open-window ] with-ui ;
