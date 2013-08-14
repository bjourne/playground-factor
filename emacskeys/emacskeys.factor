USING: accessors arrays formatting io kernel random sequences ;
IN: emacskeys

TUPLE: area name shortcuts ;
TUPLE: shortcut key desc ;

CONSTANT: shortcut-areas
{
    T{ area
       { name "emacs-lisp-mode" }
       { shortcuts
         {
             T{ shortcut
                { key "C-x C-e" }
                { desc "evaluate the emacs lisp expression before point" }
             }
         }
       }
    }
    T{ area
       { name "ido-mode" }
       { shortcuts
         {
             T{ shortcut
                { key "C-k" }
                { desc "kill matched buffer" }
             }
         }
       }
    }
    T{ area
       { name "ibuffer" }
       { shortcuts
         {
             T{ shortcut
                { key "D" }
                { desc "kill marked buffer" }
             }
         }
       }
    }
    T{ area
       { name "general" }
       { shortcuts
         {
             T{ shortcut
                { key "C-g" }
                { desc "abort the current operation" }
             }
             T{ shortcut
                { key "C-g" }
                { desc "abort the current operation" }
             }
             T{ shortcut
                { key "C-g" }
                { desc "abort the current operation" }
             }

         }
       }
    }

}

: printff ( -- )
    printf flush ; inline

: ask-shortcut ( name shortcut -- ? )
    [ desc>> "In *%s*, what is the shortcut to \"%s\"?\n> " printff ]
    [ key>> readln = ] bi dup "Correct!" "Wrong!" ? print flush ;

: shortcuts-flat ( -- shortcuts )
    shortcut-areas
    [ [ name>> ] [ shortcuts>> ] bi [ 2array ] with map ] map concat ;

: training-game ( -- )
    shortcuts-flat 5 sample [ first2 ask-shortcut ] map sift
    length "You scored %d points!\n" printf flush ;
