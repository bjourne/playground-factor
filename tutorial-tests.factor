USING:
    kernel
    tools.test
    tutorial
    ;
IN: tutorial-tests

[ "This bar is not so good" ]
[
    { { "foo" "bar" } { "bad" "good" } }
    "This foo is not so bad"
    multi-replace
] unit-test

[ 6 ] [ 7 -1 idx-rel>abs ] unit-test

[ 7 ] [ 7 7 idx-rel>abs ] unit-test

[ 3 ] [ 7 3 idx-rel>abs ] unit-test

[ 7 ] [ 7 20 idx-rel>abs ] unit-test

[ 0 ] [ 7 -20 idx-rel>abs ] unit-test
