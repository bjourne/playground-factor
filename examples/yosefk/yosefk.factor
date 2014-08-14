! Different ways of solving yosefk's problem:
!
!   http://www.mail-archive.com/factor-talk@lists.sourceforge.net/msg06816.html
USING: fry kernel locals math math.functions math.statistics sequences shuffle ;
IN: examples.yosefk

! First the correct way -- using library functions is always better
! than inventing your own logic.
: mean-std-1 ( vector -- mean std )
    [ mean ] [ population-std ] bi ;

: vec>args ( vector -- sum^2 sum inv-len )
    [ sum-of-squares ] [ sum ] [ length 1.0 swap / ] tri ;

! Then using locals.
:: mean-std-2 ( sum^2 sum inv-len -- mean std )
    sum inv-len * dup [ sum^2 inv-len * ] dip sq - sqrt ;

! Without locals and no rot.
: mean-std-3 ( sum^2 sum inv-len -- mean std )
    [ * swap dupd ] keep * swap sq - sqrt ;

! Without locals and with rot.
: mean-std-4 ( sum^2 sum inv-len -- mean std )
    swap over * -rot * over sq - sqrt ;

! With 2bi@
: mean-std-5 ( sum^2 sum inv-len -- mean std )
    swap over [ * ] 2bi@ [ sq - sqrt ] keep swap ;

! With tuck from shuffle.
: mean-std-6 ( sum^2 sum inv-len -- mean std )
    tuck * -rot * over sq - sqrt ;

! With tuck and changed order of arguments
: mean-std-7 ( sum sum^2 inv-len -- mean std )
    tuck [ * ] 2bi@ over sq - sqrt ;

! With parameters arranged for optimal pipelining
: mean-std-8 ( inv-len sum^2 sum -- mean std )
    pick * -rot * over sq - sqrt ;

! With fry
: mean-std-9 ( sum^2 sum inv-len -- std mean )
    '[ _ * ] bi@ [ sq - sqrt ] keep ;

! Fry and tuck
: mean-std-10 ( sum^2 sum inv-len -- std mean )
    '[ _ * ] bi@ tuck sq - sqrt ;
