USING: accessors fry ui ui.gadgets.editors ui.gadgets.labels
ui.gadgets.worlds ;
IN: examples.ui.modal-dialog

: run-ui ( gadget title -- )
    '[ _ _ open-window ] with-ui ;

: dialog-controls ( -- controls )
    { normal-title-bar close-button dialog-window } ;

: setup-ui ( -- gadget attrs )
    "This is an informative text in the dialog." <label>
    <world-attributes>
        "This window is modal" >>title
        dialog-controls >>window-controls ;

: modal-dialog ( -- )
    setup-ui run-ui ;
