USING:
    accessors
    arrays
    calendar
    combinators
    formatting
    interpolate
    io.streams.string
    kernel
    math
    namespaces
    sequences ;
IN: http-sync.urlvars

: unix-time-gmt ( timestamp -- unix-time )
    dup gmt-offset>> time- timestamp>unix-time >fixnum ;

: time-variables ( -- assoc )
    gmt {
        { [ year>> ] "yyyy" "%04d" }
        { [ month>> ] "mm" "%02d" }
        { [ day>> ] "dd" "%02d" }
        { [ unix-time-gmt ] "unix-time-gmt" "%d" }
    } [ first3 [ call( x -- x ) 1array ] 2dip swapd vsprintf 2array ] with map ;
