# -*- mode: sh; sh-shell: bash; -*-
# Google 'latexmk' for explanation of this config file
# latexmk at unix command line will compile the paper
$do_cd = 1;
$clean_ext = "bbl nav out snm dvi idv tmp 4tc out aux log fls fdb_latexmk mk4 synctex.gz toc ps out.ps upa upb 4ct";
$bibtex_use=2;
$bibtex = 'bibtex %O %B; sed -i "" "s/error message/benign repeated-entry note/" %B.blg; exit 0';
@default_files = ('SolvingMicroDSOPs');
$pdf_mode = 4;
$out_dir = '.';
$rc_report = 1;
$lualatex="lualatex -interaction=nonstopmode %O %S";
$aux_out_dir_report = 1;
$silent  = 1;
#warn "PATH = '$ENV{PATH}'\n";

# Search paths for econark .bst, .bib, .sty, and .cls files
# in the repo's @resources and @local directories.
# Needed in Docker and any environment without a custom texmf.cnf.
# TEXINPUTS: makes \openin, \IfFileExists, and kpathsea find .bib/.sty/.cls
# BSTINPUTS: makes bibtex find .bst files
# BIBINPUTS: makes bibtex find .bib files
$ENV{'TEXINPUTS'} = './@resources/texlive/texmf-local/tex/latex//'
  . ':./@resources/texlive/texmf-local/bibtex/bib//'
  . ':./@resources/texlive/texmf-local/bibtex/bst//'
  . ':./@resources/texlive/texmf-local/tex/latex//'
  . ':./@local//'
  . ':' . ($ENV{'TEXINPUTS'} || '');
$ENV{'BSTINPUTS'} = './@resources/texlive/texmf-local/bibtex/bst//'
  . ':' . ($ENV{'BSTINPUTS'} || '');
$ENV{'BIBINPUTS'} = './@resources/texlive/texmf-local/bibtex/bib//'
  . ':' . ($ENV{'BIBINPUTS'} || '');
