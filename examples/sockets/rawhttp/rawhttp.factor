USING: alien.strings byte-arrays combinators io.sockets
io.sockets.private kernel sequences system vocabs.parser words ;
IN: examples.sockets.rawhttp

<< os windows? [ "windows.winsock" ] [ "unix.ffi" ] if use-vocab >>

: do-send ( s buf len flags -- n )
    os {
        { windows [
            "send" "windows.winsock" lookup-word
            execute( a b c d -- n )
        ] }
        [
            drop [ native-string>alien ] 2dip f 0
            "sendto" "unix.ffi" lookup-word
            execute( a b c d e f -- n )
        ]
    } case ;

: do-http ( host -- arr )
    ! Step 1. Resolve the host.
    80 <inet> resolve-host first
    ! Step 2. Create a socket.
    AF_INET SOCK_STREAM IPPROTO_TCP socket
    ! Step 3. Connect to the host.
    [
        swap make-sockaddr/size connect 0 assert=
    ]
    ! Step 4. Send a GET request
    [
        "GET / HTTP/1.1\r\n\r\n" dup length [ 0 do-send ] keep
        assert=
    ]
    ! Step 5. Recv data into a byte buffer.
    [
        100 dup <byte-array> swap [ 0 recv ] 2keep swapd
        assert=
    ] tri ;
