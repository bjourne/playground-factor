USING: arrays assocs csv io.directories io.encodings.utf8 kernel sequences ;
IN: http-sync.tests.csvstorage

! First item on each row is the unique key
: load-items ( file -- items )
    dup touch-file utf8 file>csv [ unclip swap 2array ] map ;

: save-items ( items file -- )
    [ [ first2 swap prefix ] map ] dip utf8 csv>file ;

: merge-items ( new-items file -- )
    [ load-items assoc-union ] keep save-items ;
