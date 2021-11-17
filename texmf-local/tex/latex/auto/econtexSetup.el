(TeX-add-style-hook
 "econtexSetup"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "twoside" "marginparwidth=0in" "left=0.5in" "right=0.5in" "top=0.5in" "bottom=0.5in")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "tex4ht"
    "graphicx"
    "hyperref"
    "geometry"
    "layouts")
   (TeX-add-symbols
    '("CDCFigSideways" 1)
    '("CDCFig" 1)
    '("together" 1)
    "textSizeDefault"
    "abstractSizeDefault"
    "Koppa"
    "sampi"
    "cigma"
    "Cigma"
    "wideMargins"
    "koppa")
   (LaTeX-add-environments
    "CDCPrivate"))
 :latex)

