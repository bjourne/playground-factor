USING:
    accessors assocs
    calendar
    http-sync.item http-sync.utils
    kernel
    logging
    math
    namespaces
    sequences
    threads ;
IN: http-sync

! SYMBOLS: user-agent ;

! SYMBOL: parse-variables

! : check-syncitem ( syncitem -- syncitem' )
!     parse-variables get
!     [ over url-format>> interpolate-string >>real-url poll-url ] keep
!     assoc-union parse-variables set ;

! : main-recursive ( syncitems times -- )
!     [ [ check-syncitem ] map ] dip 1 -
!     [ drop ] [ tick-seconds seconds sleep main-recursive ] if-zero ;
! \ main-recursive NOTICE add-input-logging

! ! Not a good name
! : main ( syncitems times -- )
!     time-variables parse-variables set main-recursive ;
! \ main NOTICE add-input-logging
