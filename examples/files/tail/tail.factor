USING: accessors io io.encodings.utf8 io.files io.monitors kernel namespaces ;
IN: examples.files.tail

: emit-changes ( monitor -- )
    dup next-change drop
    input-stream get output-stream get stream-copy* flush
    emit-changes ;

: seek-input-end ( -- )
    0 seek-end input-stream get stream>> stream-seek ;

: tail-file ( fname -- )
    [
        dup f [
            swap utf8 [
                seek-input-end emit-changes
            ] with-file-reader
        ] with-monitor
    ] with-monitors ;
