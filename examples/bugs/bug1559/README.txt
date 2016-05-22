with subseq:
-----------
[
    >R { } 0
    { vector 2 1 tuple 236985587512 vector 8369605308162 }
    <tuple-boa> 0 R> 2dup 1 slot fixnum< [ \ t ] [ f ] if [
        \ ( gensym ) [
            2dup 2dup 1 slot fixnum< [ \ t ] [ f ] if [
                dup >R dup >R 1 slot R> \ ( gensym ) [
                    pick pick fixnum< [
                        ( 8670945 8670949 8673131 -- 8670945 8673131 8670945 8670949 8673131 )
                        >R >R >R >R R> 2dup string-nth-fast
                        dup 127 fixnum<=
                        [ 2nip ] [
                            >R 2 slot swap 1 fixnum-shift-fast
                            alien-unsigned-2 7 fixnum-shift-fast
                            R> fixnum-bitxor
                        ] if dup 13 eq? [ \ t ] [ f ] if
                        [ drop \ t ] [
                            10 eq? [ \ t ] [ f ] if
                            [ \ t ] [ f ] if
                        ] if R> R> R> >R rot R> swap
                        [ 2drop ] [
                            "COMPLEX SHUFFLE" 1 fixnum+fast
                            "COMPLEX SHUFFLE" ( gensym )
                        ] if
                    ] [ 3drop f ] if
                ] label R> over [
                    dupd >R R> 2dup string-nth-fast
                    dup 127 fixnum<=
                    [ 2nip ] [
                        >R 2 slot swap 1 fixnum-shift-fast
                        alien-unsigned-2 7 fixnum-shift-fast
                        R> fixnum-bitxor
                    ] if
                ] [ drop f ] if
            ] [ 2drop f f ] if swapd >R over
            [ ] [ dup >R nip 1 slot R> ] if 2dup >R >R subseq
            over dup >R 3 slot R> 2dup 3 slot fixnum>= [
                2dup 2 slot 1 slot fixnum>= [
                    over 1 fixnum+fast 2 fixnum*
                    over dup >R 2 slot resize-array
                    R> swap swap >R R> 2 set-slot
                ] [ ] if >R R> over 1 fixnum+fast
                over >R 288230376151711743 fixnum-bitand
                R> 3 set-slot
            ] [ >R R> ] if 2 slot >R R> swap 2 fixnum+fast
            set-slot R> R> >R 1 fixnum+fast R> R> 13 eq? [
                2dup 2dup 1 slot fixnum< [ \ t ] [ f ] if [
                    >R R> 2dup string-nth-fast dup 127 fixnum<=
                    [ 2nip ] [
                        >R 2 slot swap 1 fixnum-shift-fast
                        alien-unsigned-2 7 fixnum-shift-fast
                        R> fixnum-bitxor
                    ] if
                ] [ 2drop f ] if 10 eq?
                [ >R 1 fixnum+fast R> ] [ ] if
            ] [ ] if 2dup 1 slot fixnum< [ \ t ] [ f ] if
            [ ( gensym ) ]
            [ ( 8671129 8671133 8671134 -- 8671129 ) ] if
        ] label
    ] [ ( 8670814 8670829 8670830 -- 8670814 ) ] if
    dup >R 3 slot R> 2 slot 2dup 1 slot eq?
    [ nip ] [ resize-array ] if
]

with subseq-unsafe:
-----------
[
    >R { } 0
    { vector 2 1 tuple 236985587512 vector 8369605308162 }
    <tuple-boa> 0 R> 2dup 1 slot fixnum< [ \ t ] [ f ] if [
        \ ( gensym ) [
            2dup 2dup 1 slot fixnum< [ \ t ] [ f ] if [
                dup >R dup >R 1 slot R> \ ( gensym ) [
                    pick pick fixnum< [
                        ( 8678886 8678890 8681072 -- 8678886 8681072 8678886 8678890 8681072 )
                        >R >R >R >R R> 2dup string-nth-fast
                        dup 127 fixnum<=
                        [ 2nip ] [
                            >R 2 slot swap 1 fixnum-shift-fast
                            alien-unsigned-2 7 fixnum-shift-fast
                            R> fixnum-bitxor
                        ] if dup 13 eq? [ \ t ] [ f ] if
                        [ drop \ t ] [
                            10 eq? [ \ t ] [ f ] if
                            [ \ t ] [ f ] if
                        ] if R> R> R> >R rot R> swap
                        [ 2drop ] [
                            "COMPLEX SHUFFLE" 1 fixnum+fast
                            "COMPLEX SHUFFLE" ( gensym )
                        ] if
                    ] [ 3drop f ] if
                ] label R> over [
                    dupd >R R> 2dup string-nth-fast
                    dup 127 fixnum<=
                    [ 2nip ] [
                        >R 2 slot swap 1 fixnum-shift-fast
                        alien-unsigned-2 7 fixnum-shift-fast
                        R> fixnum-bitxor
                    ] if
                ] [ drop f ] if
            ] [ 2drop f f ] if swapd >R over
            [ ] [ dup >R nip 1 slot R> ] if
            2dup >R >R subseq-unsafe over dup >R 3 slot
            R> 2dup 3 slot fixnum>= [
                2dup 2 slot 1 slot fixnum>= [
                    over 1 fixnum+fast 2 fixnum*
                    over dup >R 2 slot resize-array
                    R> swap swap >R R> 2 set-slot
                ] [ ] if >R R> over 1 fixnum+fast
                over >R 288230376151711743 fixnum-bitand
                R> 3 set-slot
            ] [ >R R> ] if 2 slot >R R> swap 2 fixnum+fast
            set-slot R> R> >R 1 fixnum+fast R> R> 13 eq? [
                2dup 2dup 1 slot fixnum< [ \ t ] [ f ] if [
                    >R R> 2dup string-nth-fast dup 127 fixnum<=
                    [ 2nip ] [
                        >R 2 slot swap 1 fixnum-shift-fast
                        alien-unsigned-2 7 fixnum-shift-fast
                        R> fixnum-bitxor
                    ] if
                ] [ 2drop f ] if 10 eq?
                [ >R 1 fixnum+fast R> ] [ ] if
            ] [ ] if 2dup 1 slot fixnum< [ \ t ] [ f ] if
            [ ( gensym ) ]
            [ ( 8679070 8679074 8679075 -- 8679070 ) ] if
        ] label
    ] [ ( 8678755 8678770 8678771 -- 8678755 ) ] if
    dup >R 3 slot R> 2 slot 2dup 1 slot eq?
    [ nip ] [ resize-array ] if
]
