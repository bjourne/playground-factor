USING: accessors html.parser html.parser.analyzer kernel namespaces sequences ;
IN: gmane.html2text.tagpath

SYMBOL: path

CONSTANT: childless-tags { comment text dtd "br" "img" "link" }

: tag-path ( tag -- path )
    path get swap dup name>> childless-tags member?
    [ drop ]
    [
        [ name>> ] [ closing?>> ] [ "/" attribute? ] tri or
        [ over ?last = [ but-last ] when dup ]
        [ dupd suffix ] if path set
    ] if ;

: tag-paths ( tags -- tags' )
    { } path [ [ tag-path ] map ] with-variable ;
