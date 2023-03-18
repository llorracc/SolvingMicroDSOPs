# Google 'latexmk' for explanation of this config file
# latexmk at unix command line will compile the paper
$do_cd = 1;
$clean_ext = "bbl nav out snm dvi idv mk4 tmp xref 4tc out aux log fls fdb_latexmk gz toc 4ct ps out.ps upa upb 4ct";
$bibtex_use=2;
$pdf_mode = 1;
$out_dir = '.';
$rc_report = 1;
$pdflatex="pdflatex -interaction=nonstopmode %O %S";
@default_files = ('SolvingMicroDSOPs.tex','cctwMoM.tex','SolvingMicroDSOPs-Slides');
$aux_out_dir_report = 1;
$silent  = 0;
warn "PATH = '$ENV{PATH}'\n";
