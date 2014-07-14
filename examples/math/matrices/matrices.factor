USING:
    arrays.shaped
    kernel literals locals
    math.affine-transforms math.vectors math.matrices random sequences ;
IN: examples.math.matrices

: nrand ( shape -- out )
    [ product [ 0 1 normal-random-float ] replicate ]
    [ <shaped-array> ] bi shaped-array>array ;

: <normal-random-matrix> ( w h -- mat )
    f <matrix> [ drop 0 1 normal-random-float ] matrix-map ;

: H ( -- m )
    {
        { 1 2 3 4 5 -20 7 8 9 10 }
        { 10 9 8 7 6 5 4 3 2 9 }
    } ;

: V ( -- m )
    {
        { 1 2 3 4 5 6 7 8 9 10 }
        { 10 9 8 7 6 5 4 3 2 1 }
        { 1 2 3 4 5 6 7 8 9 10 }
        { 10 9 8 7 6 5 4 3 2 1 }
        { 1 2 3 4 5 6 7 8 9 10 }
        { 10 9 8 7 6 5 4 3 2 1 }
        { 1 2 3 4 5 6 7 8 9 10 }
        { 10 9 8 7 6 5 4 3 2 1 }
        { 1 2 3 4 5 6 7 8 9 10 }
        { 10 9 8 7 6 5 4 3 2 1 }
    } ;


: beta ( -- v )
    {
        { 20 30 40 50 60 70 80 90 100 3 }
        { 3 9 3 9 3 3 9 3 9 3 }
    } ;

: r ( -- m )
    { { 5 -5 } { 2 3 } } ;

:: calc ( H V beta r -- S )
    H beta m. r m- ;
