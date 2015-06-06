USING: accessors base64 bit-arrays bloom-filters fry io.encodings.utf8
io.files kernel sequences strings ;
IN: examples.golf.wordcheck

: dictionary-words ( file -- seq )
    utf8 file-lines "I" swap remove ;

: setup-bloom-filter ( words err cap -- filter )
    <bloom-filter> [ '[ _ bloom-filter-insert ] each ] keep ;

: serialization-values ( filter -- #hashes len str count )
    [ #hashes>> ]
    [ bits>> [ length ] [ underlying>> >base64 >string ] bi ]
    [ count>> ] tri ;
