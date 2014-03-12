USING: accessors arrays calendar formatting html.parser html.parser.analyzer
http-sync http-sync.tests.utils http-sync.tests.csvstorage kernel logging math
present sequences urls ;
IN: http-sync.tests.hn2

: parse-headers ( vector -- name/f link/f )
    "comhead" find-between-has-class first
    [ name>> "a" = ] find-between-all dup length 1 > [
        first2 [ html-vector>text ] [ first "href" attribute ] bi*
    ] [ drop f f ] if ;

: parse-body ( vector -- body )
    "comment" find-between-has-class first
    "font" find-between-first
    [ text>> ] map sift " " join replace-entities ;

: parse-comment ( vector -- name link body )
    [ parse-headers ] [ parse-body ] bi ;

: parse-comments ( link vector -- comments )
    ! Xpath would have been nice here. The filter removes poll options
    ! which shares some of the markup of regular comments.
    "default" find-between-has-class [ second name>> "div" = ] filter
    [
        parse-comment [ -rot ] dip 3array 2array
    ] with map [ first ] filter ;

: parse-link ( vector -- link/f )
    "title" find-between-has-class
    [ "no title found" \ parse-link NOTICE log-message f ]
    [ first "a" find-first-name nip "href" attribute ] if-empty ;

: parse-comments-page ( content -- comments )
    parse-html [ parse-link ] keep parse-comments ;

: comments-page ( item content -- children )
    [ url>> ] [ parse-comments-page "/tmp/hn.csv" merge-items ] bi*
    "from %s, extracted %d comments" sprintf
    \ comments-page NOTICE log-message { } ;

: parse-articles ( content -- rel-links )
    parse-html find-hrefs [ path>> "item" = ] filter ;

: top-articles-cb ( item content -- children )
    [ url>> >url ] [ parse-articles ] bi*
    [ derive-url 60 seconds [ comments-page ] <item> ] with map ;

: hn2-items ( -- items )
    "https://news.ycombinator.com/news" 30 seconds [ top-articles-cb ]
    <item> 1array ;
