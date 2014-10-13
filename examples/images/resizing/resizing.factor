USING: accessors cairo cairo.ffi combinators images kernel math
math.functions math.vectors sequences ;
IN: examples.images.resizing

: image>cairo-surface ( image -- surface )
    [ bitmap>> CAIRO_FORMAT_ARGB32 ]
    [ dim>> first2 ]
    [ rowstride ] tri
    cairo_image_surface_create_for_data ;

: scale-size ( size scale -- size' )
    v* [ round >integer ] map ;

: (resize-image) ( image scale cr -- )
    {
        [ swap first2 cairo_scale ]
        [ swap image>cairo-surface 0 0 cairo_set_source_surface ]
        [
            cairo_get_source CAIRO_FILTER_BEST
            cairo_pattern_set_filter
        ]
        [ cairo_paint ]
    } cleave ;

: resize-image ( image scale -- image' )
    2dup [ dim>> ] dip scale-size
    [ (resize-image) ] make-bitmap-image ;
