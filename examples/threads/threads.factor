USING: calendar fry kernel math.order threads ;
IN: examples.threads

: make-timeout-check ( duration -- quot )
    now time+ '[ now _ <=> +lt+ = ] ; inline

: repeat-for ( duration quot -- )
    [ make-timeout-check ] dip while ; inline
