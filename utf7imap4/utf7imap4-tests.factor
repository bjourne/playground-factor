USING: tools.test utf7imap4 ;
IN: utf7imap4.tests

[ "Skräppost" ] [ "Skr&AOQ-ppost" decode-utf7imap4 ] unit-test

[ "~/Følder/mailbåx & stuff + more" ] [
    "~/F&APg-lder/mailb&AOU-x &- stuff + more" decode-utf7imap4
] unit-test

[ "~/bågø" ] [ "~/b&AOU-g&APg-" decode-utf7imap4 ] unit-test

[ "bøx" ] [ "b&APg-x" decode-utf7imap4 ] unit-test

[ "Ting & Såger" ] [ "Ting &- S&AOU-ger" decode-utf7imap4 ] unit-test

[ "~peter/mail/日本語" ] [ "~peter/mail/&ZeVnLIqe-" decode-utf7imap4 ] unit-test

[ "~peter/mail/日本語/台北" ] [
    "~peter/mail/&ZeVnLIqe-/&U,BTFw-" decode-utf7imap4
] unit-test
