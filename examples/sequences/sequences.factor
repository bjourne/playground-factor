USING: accessors alien.strings classes.struct combinators
continuations io.backend io.directories.unix io.files.info kernel math
sequences unix.ffi ;
FROM: io.directories.unix.linux => next-dirent ;
IN: examples.sequences

DEFER: directory-size

: entry-size-file ( name -- size )
    file-info size>> ;

: entry-size-dir ( name -- size )
    dup { "." ".." } member? [ drop 0 ] [
        normalize-path directory-size
    ] if ;

: entry-size ( dirent* -- size )
    [ d_name>> alien>native-string ] [ d_type>> ] bi {
        { DT_REG [ entry-size-file ] }
        { DT_DIR [ entry-size-dir ] }
        [ 2drop 0 ]
    } case ;

: dirent-size ( unix-dir dirent -- size/f )
    next-dirent [ entry-size ] [ drop f ] if ;

: (directory-size) ( unix-dir dirent -- total )
    2dup dirent-size [ -rot (directory-size) + ] [ 2drop 0 ] if* ;

: directory-size ( path -- total )
    [
        [ dirent <struct> (directory-size) ] with-unix-directory
    ] [ 2drop 0 ] recover ;
