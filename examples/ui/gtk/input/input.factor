! Demonstrates simple input event handling in GTK.
!
! See also the samples in extra/gtk-samples/* in the Factor
! distribution.
USING: alien.strings arrays formatting gtk.ffi io.encodings.utf8
kernel locals sequences ui.backend.gtk ;
IN: examples.ui.gtk.input

: string>gtk ( str -- alien )
    utf8 string>alien ;

: gtk>string ( alien -- str )
    utf8 alien>string ;

: start-gtk ( -- )
    f f gtk_init ;

: connect-signals ( win -- )
    "destroy" [ 2drop gtk_main_quit ] GtkObject:destroy connect-signal ;

: show-info-dialog ( text -- )
    f GTK_DIALOG_MODAL GTK_MESSAGE_INFO GTK_BUTTONS_OK f f
    gtk_message_dialog_new
    [ swap string>gtk gtk_message_dialog_set_markup ]
    [ gtk_dialog_run drop ]
    [ gtk_widget_destroy ] tri ;

: button-press ( button user_data -- )
    nip gtk_entry_get_text gtk>string
    "Hello, %s! How are you doing?" sprintf show-info-dialog ;

: <button> ( str -- button )
    string>gtk gtk_button_new_with_label ;

:: setup-click-signal ( data button quot -- )
    button "clicked" quot GtkButton:clicked data
    connect-signal-with-data ; inline

: setup-button ( entry -- button )
    "Press me!" <button> [ [ button-press ] setup-click-signal ] keep ;

: make-hbox ( widgets -- hbox )
    f 0 gtk_hbox_new dup rot [ t t 0 gtk_box_pack_start ] with each ;

: setup-widgets ( -- layout )
    "Enter your name:" string>gtk gtk_label_new
    gtk_entry_new
    dup setup-button
    3array make-hbox ;

: setup-gtk ( -- )
    GTK_WINDOW_TOPLEVEL gtk_window_new
    [ setup-widgets gtk_container_add ]
    [ connect-signals ]
    [ gtk_widget_show_all ] tri ;

: input-gtk ( -- )
    start-gtk setup-gtk gtk_main ;

MAIN: input-gtk
