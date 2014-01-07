USING:
    arrays
    formatting fry
    grouping
    kernel
    math math.combinatorics math.ranges
    pcre
    sequences sets ;
IN: xkcd1313

CONSTANT: regexp
    "bu|[rn]t|[coy]e|[mtg]a|j|iso|n[hl]|[ae]d|lev|sh|[lnd]i|[po]o|ls"

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

: print-errors ( names fmt -- )
    '[ ", " join _ printf ] unless-empty ; inline

: verify-winners ( winners regex -- misses )
    '[ _ findall empty? ] filter
    dup "Error: should match but did not: %s\n" print-errors ;

: verify-losers ( losers regex -- misses )
    '[ _ findall empty? not ] filter
    dup "Error: should not match but did: %s\n" print-errors ;

: verify ( winners losers regex -- ? )
    [ verify-losers swap ] [ verify-winners ] bi [ empty? ] both? ;

: mconcat ( seq quot -- set )
    map concat members ; inline

: dotify ( str -- seq )
    { t f } over length selections [ [ CHAR: . rot ? ] "" 2map-as ] with map ;

: subparts ( str -- seq )
    1 4 [a,b] [ clump ] with mconcat ;

: matches ( regex seq -- seq )
    [ swap findall empty? not ] with filter ;

: candidate-components ( winners losers -- seq )
    [
        [ [ "^%s$" sprintf ] map ]
        [ [ subparts ] mconcat [ dotify ] mconcat ] bi
    ]
    [ '[ _ matches empty? ] ] bi* filter append ;

: score-candidate ( regex winners -- n )
    dupd matches length 3 * swap length - ;

: find-cover ( cover candidates winners -- cover' )
    [ 2drop { } ] [
        dupd '[ _ score-candidate ] supremum-by swap remove nip
    ] if-empty ;

: find-regex ( winners losers -- ? )
    dupd candidate-components { } -rot swap find-cover ;
