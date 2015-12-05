! Demonstrates how to write a GTK application in Factor.
!
! See also the samples in extra/gtk-samples/* in the Factor
! distribution.
USING: alien.c-types alien.data alien.strings
gobject-introspection.standard-types gtk.ffi io.encodings.utf8 kernel
ui.backend.gtk ;
IN: examples.ui.gtk.hello

: start-gtk ( -- )
    f f gtk_init ;

: connect-signals ( win -- )
    "destroy" [ 2drop gtk_main_quit ] GtkObject:destroy connect-signal ;

: setup-gtk ( -- )
    GTK_WINDOW_TOPLEVEL gtk_window_new
    [
        "Hello, World!" utf8 string>alien gtk_button_new_with_label
        gtk_container_add
    ]
    [ connect-signals ]
    [ gtk_widget_show_all ] tri ;

: hello-gtk ( -- )
    start-gtk setup-gtk gtk_main ;

MAIN: hello-gtk
