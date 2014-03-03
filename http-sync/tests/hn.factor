! Demonstrates how to scrape /newcomments and store the result in a
! csv. Due to hn's cdn, you won't get *all* comments but it doesn't
! matter.
USING: accessors arrays html.parser html.parser.analyzer http-sync
http-sync.syncitem http-sync.utils http-sync.tests.csvstorage kernel logging
sequences threads ;
IN: http-sync.tests.hn

: parse-headers ( vector -- name link )
    "comhead" find-between-has-class first
    [ name>> "a" = ] find-between-all first2
    [ second text>> ] [ first "href" attribute ] bi* ;

: parse-body ( vector -- body )
    "comment" find-between-has-class first
    "font" find-between-first
    [ text>> ] map sift " " join replace-entities ;

: parse-comment ( vector -- name link body )
    [ parse-headers ] [ parse-body ] bi ;

: parse-comments ( content -- comments )
    parse-html "default" find-between-has-class [
        parse-comment swapd 2array 2array
    ] map ;

: new-content-cb ( syncitem -- vars )
    content>> parse-comments "/tmp/hn.csv" merge-items { } ;

: hn-items ( -- syncitems )
    "https://news.ycombinator.com/newcomments" 5 [ new-content-cb ]
    <syncitem> 1array ;

: run-hn-scraper ( -- thread )
    [ hn-items "hn" [ 100 main ] with-logging ] "hn-scraper" spawn ;
