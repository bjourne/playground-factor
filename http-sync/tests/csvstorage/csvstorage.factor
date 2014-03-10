USING: arrays assocs csv io.directories io.encodings.utf8 kernel math
sequences ;
IN: http-sync.tests.csvstorage

! First item on each row is the unique key
: load-items ( file -- items )
    dup touch-file utf8 file>csv [ unclip swap 2array ] map ;

: save-items ( items file -- )
    [ [ first2 swap prefix ] map ] dip utf8 csv>file ;

: merge-items ( new-items file -- count )
    [ load-items dup length -rot assoc-union dup length rot - ] keep
    swapd save-items ;
