USING:
    formatting fry
    grouping
    kernel
    math math.combinatorics math.ranges
    pcre
    sequences sets ;
IN: xkcd1313

! ------------------------------------------------------------------------------
: name-set ( str -- set )
    "\\s" split members ;

: winners ( -- set )
    "washington adams jefferson jefferson madison madison monroe
monroe adams jackson jackson vanburen harrison polk taylor pierce buchanan
lincoln lincoln grant grant hayes garfield cleveland harrison cleveland mckinley
 mckinley roosevelt taft wilson wilson harding coolidge hoover roosevelt
roosevelt roosevelt roosevelt truman eisenhower eisenhower kennedy johnson nixon
nixon carter reagan reagan bush clinton clinton bush bush obama obama" name-set ;

: losers ( -- set )
    "clinton jefferson adams pinckney pinckney clinton king adams
jackson adams clay vanburen vanburen clay cass scott fremont breckinridge
mcclellan seymour greeley tilden hancock blaine cleveland harrison bryan bryan
parker bryan roosevelt hughes cox davis smith hoover landon wilkie dewey dewey
stevenson stevenson nixon goldwater humphrey mcgovern ford carter mondale
dukakis bush dole gore kerry mccain romney" name-set winners diff
    { "fremont" } diff "fillmore" suffix ;

: drugs ( -- set )
    "lipitor nexium plavix advair ablify seroquel singulair crestor actos epogen"
    name-set ;

: cities ( -- set )
    "paris trinidad capetown riga zurich shanghai vancouver chicago adelaide auckland"
    name-set ;

! ------------------------------------------------------------------------------
: matches ( seq regex -- seq' )
    '[ _ findall empty? not ] filter ;

: mconcat ( seq quot -- set )
    map concat members ; inline

: dotify ( str -- seq )
    { t f } over length selections [ [ CHAR: . rot ? ] "" 2map-as ] with map ;

: subparts ( str -- seq )
    1 4 [a,b] [ clump ] with mconcat ;

: candidate-components ( winners losers -- seq )
    [
        [ [ "^%s$" sprintf ] map ]
        [ [ subparts ] mconcat [ dotify ] mconcat ] bi append
    ] dip swap [ matches empty? ] with filter ;

: find-cover ( winners candidates -- cover )
    swap [ drop { } ] [
        2dup '[ _ over matches length 3 * swap length - ] supremum-by [
            [ dupd matches diff ] [ rot remove ] bi find-cover
        ] keep prefix
    ] if-empty ;

: find-regex ( winners losers -- regex )
    dupd candidate-components find-cover "|" join ;

: verify ( winners losers regex -- ? )
    swap over [
        dupd matches diff "Error: should match but did not: %s\n"
    ] [
        matches "Error: should not match but did: %s\n"
    ] 2bi* [
        dupd '[ ", " join _ printf ] unless-empty empty?
    ] 2bi@ and ;

: print-stats ( legend winners regex -- )
    dup length rot "|" join length over /
    "separating %s: '%s' (%d chars %.1f ratio)\n" printf ;

: (find-both) ( winners losers legend -- )
    -rot 2dup find-regex [ verify t assert= ] 3keep nip print-stats ;

: find-both ( winners losers -- )
    [ "1 from 2" (find-both) ] [ swap "2 from 1" (find-both) ] 2bi ;
