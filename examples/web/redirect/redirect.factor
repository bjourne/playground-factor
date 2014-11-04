USING: http.server http.server.dispatchers http.server.redirection namespaces ;
IN: examples.web.redirect

: do-redirect ( -- responder )
    "http://www.google.com" <permanent-redirect>
    <trivial-responder> ;

: run-site ( -- )
    dispatcher new-dispatcher
    do-redirect "" add-responder
    main-responder set-global ;
