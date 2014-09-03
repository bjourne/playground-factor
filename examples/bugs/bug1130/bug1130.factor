USING: alien alien.accessors alien.c-types combinators compiler.units kernel
math sequences windows.com windows.com.syntax windows.com.wrapper
windows.com.wrapper.private windows.ole32 windows.types ;
IN: examples.bugs.bug1130

COM-INTERFACE: ISimple IUnknown {216fb341-0eb2-44b1-8edb-60b76e353abc}
    HRESULT returnOK ( )
    HRESULT returnError ( ) ;

: simple-wrapper ( -- )
    ISimple
    {
        [
            swap {
                { GUID: {00000000-0000-0000-c000-000000000046} [ 0 ] }
                { GUID: {216fb341-0eb2-44b1-8edb-60b76e353abc} [ 0 ] }
                [ drop f ]
            } case
            [
                void* heap-size * rot <displaced-alien> com-add-ref
                swap 0 set-alien-cell S_OK
            ] [ nip f swap 0 set-alien-cell E_NOINTERFACE ] if*
        ]
    }
    { } 1 (make-interface-callbacks)
    [ execute( -- callback ) drop ] each ;

: small-ex ( -- )
    1200 [ [ simple-wrapper ] with-compilation-unit ] times ;
