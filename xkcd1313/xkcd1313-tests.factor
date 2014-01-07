USING: kernel sequences sets tools.test xkcd1313 ;
IN: xkcd1313.tests

[ t ] [
    {
        { "t" "h" "e" "he" "th" "the" }
        { "t" "h" "i" "s" "th" "hi" "is" "thi" "his" "this" }
    } { "the" "this" } [ subparts set= ] 2all?
] unit-test

[ t ] [
    {
        { "it" "i." ".t" ".." }
        {
            "this" "thi." "th.s" "th.." "t.is" "t.i." "t..s" "t..."
            ".his" ".hi." ".h.s" ".h.." "..is" "..i." "...s" "...."
        }
    } { "it" "this" } [ dotify set= ] 2all?
] unit-test

[ { "a" "b" "c" } { "any" "bee" "succeed" } ] [
    "a|b|c" { "a" "b" "c" "d" "e" } matches
    "a|b|c" { "any" "bee" "succeed" "dee" "eee!" } matches
] unit-test

[ t ] [
    { "this" } { "losers" "something" "history" } candidate-components
    { "th.s" "^this$" "..is" "this" "t.is" "t..s" ".his" ".h.s" } set=
] unit-test
