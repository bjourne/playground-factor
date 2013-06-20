USING:
    accessors
    fry
    math math.statistics
    sequences
    splitting ;
IN: gmane.statistics

! Counts how often a line occurs in a sequence of mails
: line-freqs ( mails -- dict )
    [ body>> string-lines [ length 0 > ] filter ] map concat
    normalized-histogram ;
