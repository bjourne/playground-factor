USING: arrays kernel kernel.private math math.private sequences
sequences.private slots.private ;
IN: examples.bugs.bug1507

: my-new-key4 ( a i j -- i/j )
    2over
    slot
    swap over
    ! a i el j el
    [
        ! a i el j
        swap
        ! a i j el
        77 eq?
        [
            rot drop and
        ]
        [
            ! a i j
            over or my-new-key4
        ] if
    ]
    [
        ! a i el j
        2drop t
        ! a i t
        my-new-key4
    ] if ; inline recursive

: badword ( y -- )
    0 swap dup
    { integer object } declare
    [
        { array-capacity object } declare nip
        1234 1234 pick
        f
        my-new-key4
        set-slot
    ]
    curry (each-integer) ;
