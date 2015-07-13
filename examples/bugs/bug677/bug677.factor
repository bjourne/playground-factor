USING: arrays kernel.private math sequences ;
IN: examples.bugs.bug677

: sum-fast ( array -- n )
    { array } declare
    0 [ + ] binary-reduce ; inline
