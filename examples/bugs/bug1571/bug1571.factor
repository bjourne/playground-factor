USING: math sequences.private ;
IN: examples.bugs.bug1571

TUPLE: foo { a fixnum } ; ! OK
TUPLE: foo3 { a float } ; ! OK
TUPLE: foo1 { a array-capacity } ; ! OK
TUPLE: foo2 { a integer-array-capacity } ;
TUPLE: foo4 { a bignum } ; ! OK
