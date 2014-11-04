USING: arrays assocs html.forms html.templates html.templates.chloe
io.streams.string kernel furnace.utilities ;
IN: examples.web.chloe-tostring

: template-abs-path ( namebase -- path )
    \ template-abs-path swap 2array resolve-template-path ;

: chloe>string ( template vars -- str )
    begin-form [ swap set-value ] assoc-each <chloe>
    [ call-template ] with-string-writer ;

USING: furnace.actions http.client http.server ;


! : test-validation ( -- )
!     "http://localhost?id=1234" <get-request> init-request begin-form
!     [ validate-integer-id ] with-exit-continuation ;
