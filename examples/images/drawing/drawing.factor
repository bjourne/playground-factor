USING: cairo cairo.ffi combinators images.loader io.files.temp ;
IN: examples.images.drawing

! : test-image ( -- image )
!     "C:/Users/bjli.BRUGGEMANN/Desktop/adbilder/norm/about.png" load-image ;

: image>cairo-surface ( image -- surface )
    {
        [ bitmap>> ]
        [ drop CAIRO_FORMAT_ARGB32 ]
        [ dim>> first2 ]
        [ rowstride ]
    } cleave cairo_image_surface_create_for_data ;

: draw-stuff ( cr -- )
    {
        [ 5 cairo_set_line_width ]
        [ 1.0 0.0 0.0 cairo_set_source_rgb ]
        [ 10 10 220 100 cairo_rectangle ]
        [ cairo_stroke ]
        [
            "serif"
            CAIRO_FONT_SLANT_NORMAL
            CAIRO_FONT_WEIGHT_NORMAL
            cairo_select_font_face
        ]
        [ 32.0 cairo_set_font_size ]
        [ 0.0 0.0 1.0 cairo_set_source_rgb ]
        [ 20.0 50.0 cairo_move_to ]
        [ "Hello, Cairo!" cairo_show_text ]
    } cleave ;

: save-cairo-image ( -- )
    { 240 120 } [ draw-stuff ] make-bitmap-image
    "cairo-image.png" temp-file save-graphic-image ;
