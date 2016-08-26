USING: kernel python python.syntax sequences ;
IN: examples.python.mutagen

PY-QUALIFIED-FROM: mutagen.easyid3 => EasyID3 ( name -- obj ) ;
PY-METHODS: mutagen:easyid3:EasyID3 =>
    __setitem__ ( self key value -- )
    save ( self -- ) ;

: <EasyID3> ( str -- easyid3 )
    >py mutagen.easyid3:EasyID3 ;

: setitem ( obj key val -- )
    [ >py ] bi@ __setitem__ ;

: update-tags ( easyid3 assoc -- )
    dupd [ first2 setitem ] with each save ;
