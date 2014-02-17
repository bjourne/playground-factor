! Demonstrates how to scrape /newcomments and store the result in a
! csv.
USING:
    accessors
    arrays
    assocs
    csv
    formatting
    html.parser html.parser.analyzer
    http-sync http-sync.syncitem http-sync.utils
    io.encodings.utf8 io.files
    kernel
    logging
    sequences
    threads ;
IN: http-sync.tests.hn

CONSTANT: csv-file "/tmp/hn.csv"

: save-comments ( comments -- )
    [ first2 first2 3array ] map csv-file utf8 csv>file ;

! Bug in csv doesn't accept empty file
: init-csv ( -- )
    csv-file exists? [
        { { "link" { "name" "text" } } } save-comments
    ] unless ;

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

: load-comments ( -- comments )
    init-csv csv-file utf8 file>csv [ first3 swapd 2array 2array ] map ;

: merge-comments ( comments -- )
    dup length load-comments swapd assoc-union dup length swap save-comments
    "%d incoming comments, %d in total saved" sprintf
    \ merge-comments NOTICE log-message ;

: new-content-cb ( syncitem -- vars )
    content>> parse-comments merge-comments { } ;

CONSTANT: hn-items {
    {
        "https://news.ycombinator.com/newcomments"
        5
        [ new-content-cb ]
    }
}

: run-scraper ( -- thread )
    [
        hn-items [ first3 <syncitem> ] map "hn"
        [ 10 main ] with-logging
    ] "hn-scraper" spawn ;
