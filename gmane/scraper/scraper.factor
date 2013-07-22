USING:
    accessors
    calendar.format
    combinators
    formatting
    fry
    gmane.db
    html.parser html.parser.analyzer
    kernel
    regexp
    sequences
    splitting
    strings
    unicode.categories
    xml xml.entities.html
    ;
IN: gmane.scraper

: mail-url ( n str -- str )
    swap "http://article.gmane.org/gmane.%s/%d" sprintf ;

: replace-entities ( html-str -- str )
    '[ _ string>xml-chunk ] with-html-entities first ;

: tag-vector>string ( vector -- string )
    ! Special quoting used in html mails. TODO: different parser for
    ! html and plain text.
    dup [ name>> "blockquote" = ] find-between-all swap
    [
      dup
      [
        [ dup empty? not [ " " prepend ] when ] change-text
      ] map replace
    ] reduce
    ! Translate br tags to newlines.
    [ dup name>> "br" = [ text >>name "\n" >>text ] when ] map
    ! Filter away comments and non-text nodes
    [ [ text>> ] [ name>> comment = not ] bi and ] filter

    [ text>> ] map concat
    ! Fix entities &lt; is replaced with < and so on.
    replace-entities
    ! Replace consecutive repetitions of \n so that there is at most
    ! two after each other. This is done because html formatted mails
    ! contains redundant new lines that does not look good when
    ! rendered as plain text.
    R/ \n\n+/ "\n\n" re-replace
    [ blank? ] trim ;

: remove-all ( seq subseqs -- seq )
    swap [ { } replace ] reduce ;

: parse-mail-body ( html -- text )
    "bodytd" find-by-class-between dup
    [
        [ name>> "script" = ] [ "headers" html-class? ] bi or
    ] find-between-all remove-all tag-vector>string ;

: parse-mail-header ( html header -- text )
    [ tag-vector>string ] dip
    ": " append dup "[^\n]+" append <regexp> swapd first-match
    swap "" replace "\t" "" replace ;

: parse-mail ( n str -- mail/f )
    2dup mail-url scrape-html nip dup length 1 =
    [ 3drop f ]
    [
        [ f -rot ] dip
        {
            [ "Date" parse-mail-header ymdhms>timestamp ]
            [ "From" parse-mail-header ]
            [ "Subject" parse-mail-header ]
            [ parse-mail-body ]
        } cleave mail boa
    ] if ;
