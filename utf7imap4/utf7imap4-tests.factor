USING: kernel sequences tools.test utf7imap4 ;
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

[ "test" ] [ "test" encode-utf7imap4 ] unit-test

[ "Skr&AOQ-ppost" ] [ "Skräppost" encode-utf7imap4 ] unit-test

[ "b&APg-x" ] [ "bøx" encode-utf7imap4 ] unit-test

[ "b&AOU-x" ] [ "båx" encode-utf7imap4 ] unit-test

[ "~/b&AOU-g&APg-" ] [ "~/bågø" encode-utf7imap4 ] unit-test

[ "Ting &- S&AOU-ger" ] [ "Ting & Såger" encode-utf7imap4 ] unit-test

[ "~/F&APg-lder/mailb&AOU-x &- stuff + more" ] [
    "~/Følder/mailbåx & stuff + more" encode-utf7imap4
] unit-test

! Roundtripping Chinese chars
[ t ] [
    { "日" "本" "日本語" } [ dup encode-utf7imap4 decode-utf7imap4 = ] all?
] unit-test

[ "~peter/mail/&ZeVnLIqe-/&U,BTFw-" ] [
    "~peter/mail/日本語/台北" encode-utf7imap4
] unit-test
