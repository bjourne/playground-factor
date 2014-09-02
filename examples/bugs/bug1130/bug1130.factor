USING: compiler.units destructors kernel math
windows.com windows.com.syntax windows.com.wrapper windows.com.wrapper.private
windows.ole32 windows.types ;
IN: examples.bugs.bug1130

COM-INTERFACE: ISimple IUnknown {216fb341-0eb2-44b1-8edb-60b76e353abc}
    HRESULT returnOK ( )
    HRESULT returnError ( ) ;

: simple-wrapper ( -- wrapper )
    { { ISimple { [ drop S_OK ] [ drop E_FAIL ] } } } <com-wrapper> ;

: small-ex ( -- )
    300 [ [ simple-wrapper dispose ] with-compilation-unit ] times ;
