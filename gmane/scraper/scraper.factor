USING:
    accessors
    arrays
    assocs
    calendar.format
    combinators
    continuations
    formatting
    gmane.db
    kernel
    html.parser html.parser.analyzer
    http.client
    math math.parser math.ranges
    regexp
    sequences
    splitting
    strings
    unicode.case unicode.categories
    xml.entities
    ;
IN: gmane.scraper

! Generates urls to gmane
! -----------------------
: group-url ( str -- str )
    "http://article.gmane.org/gmane.%s/" sprintf ;

: mail-url ( n str -- str )
    group-url swap number>string append ;

! Generic multi replace and remove
! --------------------------------
: multi-replace ( seq pairs -- seq )
    swap [ first2 replace ] reduce ;

! Takes a list of subsequences and a sequence and removes all
! matches of the subsequences from the sequence
: multi-remove ( seq subseqs -- seq )
    [ { } 2array ] map multi-replace ;

! HTML massaging
! --------------
! xml.entities.entities appear to miss some useful entities.
: fixed-entities ( -- alist )
    entities >alist { "nbsp" 32 } suffix ;

! Takes a string with entities like &lt; and &amp; and replaces them
! with their character equivalents.
: replace-entities ( html-str -- str )
    fixed-entities [
        first2 [ "&%s;" sprintf ] [ 1string ] bi* 2array 
    ] map multi-replace >string ;

: tag-vector>string ( vector -- string )
    ! Br tags should be turned into newlines.
    [ dup name>> "br" = [ text >>name "\n" >>text ] when ] map
    ! Make a big string.
    [ text>> ] map concat
    ! Fix entities &lt; is replaced with < and so on.
    replace-entities
    ! Replace consecutive repetitions of \n so that there is at most
    ! two after each other. This is done because html formatted mails
    ! contains redundant new lines that does not look good when
    ! rendered as plain text.
    R/ \n\n+/ "\n\n" re-replace
    [ blank? ] trim ;

! Specialized parsing functions
! -----------------------------
! Takes the content within the bodytd class, subtracts the header
! and script tag content and then converts it to plain text.
: parse-mail-body ( html -- text )
    "bodytd" find-by-class-between dup
    [
        [ name>> "script" = ] [ "headers" html-class? ] bi or
    ] find-between-all
    multi-remove tag-vector>string ;

: parse-mail-header ( html header -- text )
    [ tag-vector>string ] dip
    ": " append dup "[^\n]+" append <regexp> swapd first-match
    swap "" replace ;

: parse-mail ( n str -- mail )
    ! Db id is fale
    f
    ! Mid and group
    -rot 2dup
    mail-url scrape-html nip
    {
        ! Parse date
        [ "Date" parse-mail-header ymdhms>timestamp ]
        [ "From" parse-mail-header ]
        [ "Subject" parse-mail-header ]
        [ parse-mail-body ]
    } cleave mail boa ;

: safe-parse-mail ( n str -- mail/f )
    2array [ first2 parse-mail ] [ 2drop f ] recover ;
        




