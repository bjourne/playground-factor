USING: assocs help.markup help.syntax words ;
IN: examples.introspection

ARTICLE: "examples.introspection" "GC maps decoder"
"A vocab that disassembles words gc maps. It's useful to have when debugging garbage collection issues." ;

HELP: gc-info
{ $class-description "A struct that defines the sizes of the garbage collection maps for a word. It has the following slots:"
  { $table
    { { $slot "scrub-d-count" } "Number of datastack scrub bits per callsite." }
    { { $slot "scrub-r-count" } "Number of retainstack scrub bits per callsite." }
    { { $slot "gc-root-count" } "Number of gc root bits per callsite." }
    { { $slot "derived-root-count" } "Number of derived roots per callsite." }
    { { $slot "return-address-count" } "Number of gc callsites." }
  }
} ;

HELP: word>gc-info
{ $values { "word" word } { "gc-info" gc-info } }
{ $description "Gets the gc-info struct for a word." } ;

HELP: decode-gc-maps
{ $values { "word" word } { "assoc" assoc } }
{ $description "Main word of the vocab. Decodes the gc maps for a word into an assoc with the following format:"
  { $list
    "Each key is the return addess of a gc callsite (delta relative to the start of the code block)."
    {
        "Each value is a two-tuple where:"
        { $list
          "The first element is a three-tuple containing the scrub patterns for the datastack, retainstack and gc roots."
          "The second element is a sequence of derived roots for the callsite."
        }
    }
  }
}
{ $examples
  { $unchecked-example
    "USING: effects prettyprint ;"
    "\\ <effect> decode-gc-maps ."
    "{ { 151 { { ?{ t } ?{ t t t } ?{ f t t t t } } { } } } }"
  }
} ;

ABOUT: "examples.introspection"
