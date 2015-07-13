USING: io kernel sequences ;
IN: examples.bugs.bug1187

: do-test ( x y -- z ) 2dup [ print ] bi@ append ;
