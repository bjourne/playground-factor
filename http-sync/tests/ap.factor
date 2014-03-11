USING: accessors arrays calendar http.client http-sync
http-sync.tests.csvstorage kernel logging sequences splitting
xml xml.traversal ;
IN: http-sync.tests.ap

: child-text ( xml tag -- text )
    deep-tags-named first children>string ;

: parse-headline ( xml -- id title summary )
    [ "id" child-text ":" split last ]
    [ "title" child-text ]
    [ "summary" child-text ] tri ;

: parse-ap-feed ( content -- headlines )
    string>xml "entry" deep-tags-named [
        parse-headline 2array 2array
    ] map ;

: new-content-cb ( item content -- children )
    nip parse-ap-feed "/tmp/ap.csv" merge-items drop { } ;

: ap-feeds ( -- syncitems )
    {
        "http://hosted2.ap.org/atom/APDEFAULT/3d281c11a96b4ad082fe88aa0db04305"
        "http://hosted2.ap.org/atom/APDEFAULT/386c25518f464186bf7a2ac026580ce7"
        "http://hosted2.ap.org/atom/APDEFAULT/cae69a7523db45408eeb2b3a98c0c9c5"
    } [ 30 seconds [ new-content-cb ] <item> ] map ;

: run-ap-scraper ( -- )
    "ap" [ ap-feeds 10 spider-loop ] with-logging ;
