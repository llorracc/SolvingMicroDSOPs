#!/bin/bash

cd "$source_repo"

# create empty shell script to contain commands for recompiling
echo '#!/bin/bash' > reproduce_html.sh
chmod +x reproduce_html.sh

# add econ-ark css theme
ditto "$econark_css" .
# SOME yaml file needed for gh-pages to work
[[ ! -e _config.yml ]] && echo "theme: jekyll-theme-minimal" > _config.yml 

# compile each file in texfile_lst
for texfile in "${texfile_lst[@]}"; do
    echo "Processing $texfile"
    
    # index.html will be set to the first html file processed
    if [ ! -z "$index_made" ]; then # no index.html yet made for this run
	[[ -e index.html ]] && rm index.html 
	index_made=true && ln -s $texfile.html index.html
    fi
    
    # create .cfg and .mk4 files
    $scripts_abs/make4ht/tex4htMakeCFG.sh $texfile

    export LIBGS=/usr/local/lib/libgs.dylib
    
    # make4ht does not reliably make the aux other biblio files
    # since make4ht runs in dvi mode, they can be made using that
    cmd="pdflatex -interaction=nonstopmode -shell-escape -output-format dvi $texfile"
    echo "$cmd" ; eval "$cmd"
    bibtex -terse $texfile
    cmd="pdflatex -shell-escape -output-format dvi $texfile" ; echo "$cmd"
    eval "$cmd" ; eval "$cmd"
    
    cmd="make4ht  --utf8 --config $texfile.cfg --format html5 $texfile "'"svg            "'"   "'"-cunihtf -utf8"'""
    echo "$cmd" | tee -a reproduce_html.sh
    eval "$cmd"
done

# remove timestamps from svgs (to prevent spurious diffs with git)
$this_dir/svg-clean.sh .

# clean up, leaving files necessary to recompile html using reproduce_web.sh
latexmk -c -r .latexmkrc-for-html
