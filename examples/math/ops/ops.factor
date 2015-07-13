USING: fry kernel math prettyprint sequences sequences.generalizations ;
IN: examples.math.ops

! If you know about array-based languages, then you know that most of
! their words are polymorphic over their data types
! dimensionality. So, the same word can be used for 0 dimensional
! (scalar), 1-dimensional (sequences), 2-dimensional,
! ... N-dimensional data structures.

! You can define words in Factor to work in the same way, but usually
! that's not how it is done. Instead, it is interesting to realize
! that map is a word that takes a unary word operating on scalar and
! making it work with sequences.

! Consider

IN: scratchpad -9 abs .

! And the sequence variant

IN: scratchpad { -9 3 0 -1 } [ abs ] map .

! The pattern is clear, let's make a word for it

: raise-un ( quot: ( a -- b ) -- quot': ( a b -- c ) )
    [ map ] curry ;

! Now you can write

IN: scratchpad { -9 3 0 -1 } [ abs ] raise-un call( x -- x ) .

! Cool!

! We can do the same with binary words:

: raise-bin ( quot: ( a b -- c ) -- quot': ( a b -- c ) )
    [ 2map ] curry ;

IN: scratchpad { 3 4 } { 5 6 } [ * ] raise-bin call( a b -- c ) .

! If we call denote * as *[0:0] because it works on scalars, then the
! above would be denoted as *[1:1] and *[2:2] would be:

IN: scratchpad { { 3 4 } } { { 5 6 } } [ * ] raise-bin raise-bin
call( a b -- c ) .

! 3map does the same thing for tertiary words. How about words with
! arbitrary arity? nmap can be used:

: raise-arity ( n quot: ( * -- x ) -- quot': ( * -- x ) )
    [ nmap ] swapd 2curry ;

IN: scratchpad { 1 32 } { 3 3 } { 3 3 } 3 [ + * ] raise-arity
call( x y z -- w ) .

! Neat! So we took a quotation operating on three numbers and made it
! operate on three sequences instead. It could have been called
! +*[1:1:1].


! Now here comes the interesting part. How do we construct *[1:0]?

: raise-bin-left ( b quot: ( a b -- c ) -- quot': ( a -- c ) )
    curry [ map ] curry ;

IN: scratchpad { 3 4 } 3 [ * ] raise-bin-left call( x -- x ) .

! It's not as symmetrical, and the result would be denoted: *[1]

! 2:0 works too:

IN: scratchpad { { 3 4 } { 8 } } 3 [ * ] raise-bin-left raise-un
call( x -- y ) .

! 3:0

IN: scratchpad { { { 3 4 } { 8 } } } 3 [ * ] raise-bin-left
raise-un raise-un call( x -- x ) .

! 2:1, 3:1, 0:1, 0:2 and other similar dimension matchings has no good
! mathematical interpretation.
