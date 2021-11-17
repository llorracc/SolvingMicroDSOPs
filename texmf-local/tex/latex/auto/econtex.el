(TeX-add-style-hook
 "econtex"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("scrartcl" "fontsize=12pt" "english" "numbers=noenddot" "captions=tableheading" "captions=nooneline")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("fontenc" "T1") ("babel" "english") ("eucal" "mathscr") ("ulem" "normalem") ("optional" "econtex") ("endfloat" "noheads" "nolists" "tablesfirst" "nomarkers") ("natbib" "authoryear") ("footmisc" "multiple")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "snapshot"
    "ifthen"
    "changepage"
    "setspace"
    "scrartcl"
    "scrartcl10"
    "fontenc"
    "babel"
    "calc"
    "eucal"
    "ulem"
    "bm"
    "bbm"
    "url"
    "optional"
    "endfloat"
    "geometry"
    "natbib"
    "footmisc"
    "manyfoot"
    "perpage")
   (TeX-add-symbols
    '("aspublished" 1)
    '("jelclass" 1)
    '("keywords" 1)
    '("maketitleWithForcedDate" 1)
    '("forcedate" 1)
    '("Descriptionlabel" 1)
    "bmmax"
    "textSizeDefault"
    "abstractSizeDefault"
    "titlepagefinish"
    "thanksFooter"
    "rm"
    "sf"
    "tt"
    "bf"
    "it"
    "sl"
    "sc"
    "normalsize"
    "makelabel"
    "liminf"
    "var"
    "cov"
    "std"
    "argmax"
    "htline"
    "hdline"
    "UrlFont"
    "footnotesize"
    "num"
    "authNum"
    "name")
   (LaTeX-add-environments
    "authorsinfo"
    "Description")
   (LaTeX-add-counters
    "IncludeTitlePage"
    "authornum"
    "bottomauthor"))
 :latex)

