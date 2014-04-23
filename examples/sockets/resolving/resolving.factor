USING: accessors alien.c-types alien.data alien.destructors classes.struct
destructors io.sockets kernel windows.winsock ;
IN: examples.sockets.resolving

DESTRUCTOR: freeaddrinfo

: addrinfo-hints ( -- hints )
    addrinfo <struct>
        IPPROTO_TCP >>protocol
        AF_UNSPEC >>family
        SOCK_STREAM >>socktype ;

: resolve-v1 ( host -- stuff )
    ! host plus three more arguments to getaddrinfo. Note that the
    ! last argument is an output argument to be filled in by the
    ! function.
    f addrinfo-hints { void* } [
        ! Run getaddrinfo and attach a destructor to the allocated
        ! addrinfo.
        [ getaddrinfo 0 assert= ] with-out-parameters &freeaddrinfo
        ! "Cast" it to an addrinfo and follow the path. Kind of like
        ! ptr->ai_addr->sin_addr in C.
        addrinfo memory>struct addr>> sockaddr-in memory>struct addr>>
        inet_ntoa
    ] with-destructors ;
