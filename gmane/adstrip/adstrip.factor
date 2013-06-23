USING:
    accessors
    assocs
    db.tuples
    formatting
    fry
    gmane.db gmane.statistics
    io
    kernel
    math
    sequences
    splitting ;
IN: gmane.adstrip

: clean-mail ( mail adlines -- mail )
    '[ string-lines [ _ member? not ] filter "\n" join ] change-body ;

: clean-group ( group -- )
    '[
        T{ mail } _ >>group select-tuples dup
        line-freqs [ 0.001 > swap length 10 > and ] assoc-filter keys
        '[
            dup subject>> "At mail \"%s\".\n" printf flush
            _ clean-mail update-tuple
        ] each
    ] with-mydb ;
