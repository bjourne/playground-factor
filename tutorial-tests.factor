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
