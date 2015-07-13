! How to construct a linked list in malloc:ed memory.
USING: accessors alien.c-types classes.struct kernel libc sequences
sequences.shifted ;
IN: examples.alien.structs

STRUCT: node
    { value int }
    { next node* } ;

: make-list ( seq -- nodes )
    [ node malloc-struct &free swap >>value ] map
    dup 1 f <shifted> [ >>next ] 2map last ;
