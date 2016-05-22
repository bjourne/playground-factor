USING: accessors html.parser.analyzer io kernel math namespaces
present regexp sequences ;

IN: examples.golf.all-roads

SYMBOL: G

: match-good-pages ( a -- ?/f )
    R/ \/wiki\/[^:]*$/ first-match ;

: filter-urls ( tags -- urls )
    find-hrefs [ present ]     map
    [ match-good-pages ]       filter
    [ match-good-pages seq>> ] map ;

    : page-title ( seq -- title )
        dup "title" find-by-name drop 1 + swap nth
        text>> R/ - Wikipedia,/ re-split first ;

    : page-links ( seq -- links )
        "bodyContent" find-by-id-between filter-urls ;

    : scrape-en-wiki-url ( wiki-url -- seq )
        "https://en.wikipedia.org" prepend
        dup print flush scrape-html nip ;

    : found-url? ( wiki-url -- ? )
        G get [ = ] [ drop t ] if* ;

    : findpath ( wiki-url -- seq/f )
        dup found-url?
        [ drop f G set f ] [
            scrape-en-wiki-url
            [ page-title print flush ] [
                page-links [ findpath ] map
            ] bi
        ] if ; inline recursive
