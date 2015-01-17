! To use this script, you need the following:
!
!  * A directory containing:
!    * a template.html file
!    * a posts/ directory with all your markdown blog posts
!    * a chrome/ directory containing stylesheets and images
!  * The github version of python-markdown installed
!
! If you have all that, then you can run this script:
!
!   "path/to/dir" generate-blog
!
! and hope for the best. :)
USING: accessors assocs arrays combinators continuations
formatting fry html.templates html.templates.fhtml io io.directories
io.directories.hierarchy io.encodings.utf8 io.files io.launcher io.pathnames
io.streams.string kernel math math.statistics namespaces sequences
sequences.generalizations slots.syntax sorting splitting ;
IN: blog-maker

! Configuration
CONSTANT: blog-base "/blog/"
CONSTANT: blog-title "Bjourne's blog"
CONSTANT: scp-path "bjourne@31.192.226.186:/opt/sites/bjornlindqvist.se/www/blog"

! Utilities
: directory-files-w/path ( dir -- abs-paths )
    dup directory-files [ append-path absolute-path ] with map ;

: read-process-contents ( cmd encoding -- str )
    [ contents ] with-process-reader ;

: set-file-contents-safe ( contents path encoding -- )
    over parent-directory make-directories set-file-contents ;

: tag-wrap2 ( body tag attrs -- str )
    [ "%s=\"%s\"" sprintf ] { } assoc>map " " join rot pick
    "<%s %s>%s</%s>" sprintf ;

: tag-wrap ( body tag -- str )
    { } tag-wrap2 ;

: fhtml>string ( template -- str )
    <fhtml> [ call-template ] with-string-writer ;

: link ( url title -- str )
    "<a href=\"%s\">%s</a>" sprintf ;

! Making blog posts
TUPLE: post title date tags html slug ;

CONSTANT: markdown-cmd "python -m markdown -x markdown.extensions.codehilite -x meta %s"

: markdown-render ( file -- str )
    markdown-cmd sprintf utf8 read-process-contents ;

: markdown-metadata ( path -- assoc )
    utf8 file-lines [ "" = ] split1-when drop [ ": " split1 2array ] map ;

: parse-metadata ( metadata -- title date tags )
    [ "title" of ] [ "date" of ] [ "tags" of " " split ] tri ;

: post-month ( post -- seq )
    date>> "-" split but-last ;

: post-year ( post -- seq )
    post-month 1 head ;

: post>path-components ( post -- components )
    [ post-month ] keep slug>> suffix ;

: post-url ( post -- url )
    post>path-components "/" join blog-base prepend ;

: post>a ( post -- str )
    [ post-url ] [ title>> ] bi link ;

: posts>ul ( posts -- str )
    [ post>a "li" tag-wrap ] map concat
    "ul" { { "class" "square" } } tag-wrap2 ;

: post-header ( post -- header )
    [ post>a "h2" tag-wrap ]
    [
        get[ date tags ] " " join 2array { "Posted:" "Tags:" }
        [ [ "dd" tag-wrap ] [ "dt" tag-wrap ] bi* prepend ] 2map
        concat "dl" tag-wrap
    ] bi append ;

: <post> ( path -- post )
    [ markdown-metadata parse-metadata ]
    [ markdown-render ]
    [ file-stem ] tri post boa
    dup [ html>> ] keep post-header prepend >>html ;

: read-posts ( dir -- posts )
    directory-files-w/path [ <post> ] map ;

! Then from posts we make pages
TUPLE: page title html path ;

: post>page ( post -- page )
    [ title>> ]
    [ html>> ]
    [ post>path-components ] tri page boa ;

CONSTANT: month-title "%d post(s) for the month %04s-%02s"

: month-render-title ( year/month posts -- html )
    length swap first2 month-title sprintf ;

: month-render-html ( year/month posts -- html )
    [ month-render-title "h2" tag-wrap ] [ posts>ul ] bi append ;

: month-page ( year/month posts -- page )
    [ month-render-title ]
    [ month-render-html ]
    [ drop "index" suffix ] 2tri page boa ;

: posts>month-pages ( posts -- assoc )
    [ post-month ] collect-by [ month-page ] { } assoc>map ;

CONSTANT: year-title "%d post(s) for the year %04s"

: year-render-title ( year posts -- html )
    length swap first year-title sprintf ;

: year-render-html ( year posts -- page )
    [ year-render-title "h2" tag-wrap ] [ posts>ul ] bi append ;

: year-page ( year posts -- page )
    [ year-render-title ]
    [ year-render-html ]
    [ drop "index" suffix ] 2tri page boa ;

: posts>year-pages ( posts -- pages )
    [ post-year ] collect-by [ year-page ] { } assoc>map ;

! Make index page
: posts>index-page ( posts -- page )
    [ date>> ] sort-with reverse
    [ html>> ] map "<hr/>" join blog-title swap { "index" } page boa ;

! Glueing it all together
: make-pages ( dir -- pages )
    read-posts {
        [ posts>year-pages ]
        [ posts>month-pages ]
        [ [ post>page ] map ]
        [ posts>index-page 1array ]
    } cleave 4 nappend ;

! Then with the page tuples, we generate ready html pages using fhtml
! templates.
SYMBOL: page-var

! Utilities to be called from the template
: stylesheet. ( str -- )
    "<link rel=\"stylesheet\" href=\"%s\">" printf ;

: adjusted-page-path ( page -- path )
    [ title>> ] [
        path>> "home" prefix dup last "index" = [ but-last ] when
    ] bi dup length 4 = [ but-last swap suffix ] [ nip ] if ;

: breadcrumb. ( page -- )
    adjusted-page-path dup length
    {
        { 1 { "" } }
        { 2 { ".." "" } }
        { 3 { "../.." ".." "" } }
        { 4 { "../.." ".." "." "" } }
    } at swap [ link ] 2map " &raquo; " join print ;

: title. ( page -- )
    [ title>> ] [ path>> ] bi length 1 > [ blog-title " - " glue ] when print ;

: write-page ( page dir -- )
    over path>> "/" join append-path
    [ page-var set "template.html" fhtml>string ] dip
    utf8 set-file-contents-safe ;

: write-pages ( pages dir -- )
    '[ _ write-page ] each ;

: generate-blog ( dir -- )
    [
        [ "build" delete-directory ] ignore-errors
        "posts" make-pages "build" write-pages
        "chrome" "build/chrome" copy-tree
        "build" [
            { "sh" "-c" } scp-path "scp -r * %s" sprintf suffix try-process
        ] with-directory
    ] with-directory ;
