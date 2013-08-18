USING: accessors arrays formatting io kernel random sequences ;
IN: emacskeys

TUPLE: area name shortcuts ;
TUPLE: shortcut key desc ;

CONSTANT: shortcut-areas
{
    T{ area
       { name "dired" }
       { shortcuts
         {
             T{ shortcut
                { key "D" }
                { desc "delete file at point" }
             }
             T{ shortcut
                { key "^" }
                { desc "visit the parent directory" }
             }
         }
       }
    }
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
       { name "fuel-mode" }
       { shortcuts
         {
             T{ shortcut
                { key "C-c C-d d" }
                { desc "open the manual for symbol at point" }
             }
             T{ shortcut
                { key "C-c C-d C-e" }
                { desc "show stack effect for word at point" }
             }
             T{ shortcut
                { key "C-c C-d v" }
                { desc "show all words in vocab" }
             }
             T{ shortcut
                { key "M-." }
                { desc "edit the word at point" }
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
                { key "C-x C-v RET" }
                { desc "reload the buffers file (using find alterate file)" }
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
