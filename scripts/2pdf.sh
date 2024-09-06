#!/bin/sh

#
# Build latex document and convert to pdf
#

set +eux

# Check all commands exist
for cmd in lualatex inkscape date biber
do
    if ! command -v ${cmd} >/dev/null 2>&1
    then
        echo "Requires $cmd command!"
        exit 1
    fi
done

help()
{
    echo "Usage of $(basename $0) [-h] [-n]"
    echo "\t" "-h" "\t" "prints usage"
    echo "\t" "-n" "\t" "do not delete artifacts after building document"
    echo "\t" "no arguments builds project and deletes artifacts after build"
}

build_pdf()
{
    lualatex --shell-escape Presentation.tex
    if [ -f $PWD/Presentation.bcf ]; then
        biber $PWD/Presentation.bcf
    else
        echo "Could not run biber, did not create Presentation.bcf file!"
        exit 1
    fi
    lualatex Presentation.tex
}

rename_pdf()
{
    TOC=$(date +"%Y_%m_%d")
    NAME=Jonas_Schulze_Presentation_BA_$TOC
    # Rename pdf
    if [ -f Presentation.pdf ]; then
        mv Presentation.pdf $NAME.pdf
    else
        echo "Could not find output pdf, exiting"
        exit 1
    fi
}

while getopts ":hnc" opt; do
    case $opt in
        h) # display usage
            help
            exit;;
        n) # dont delete artifacts
            build_pdf
            rename_pdf
            exit;;
        c) # if script runs in CI, do not rename pdf to enable stable link
            build_pdf
            $PWD/scripts/clean.sh
            exit;;
        ?) # invalid arguments
            echo "Invalid argument: ${opt}"
            help
            exit;;
    esac
done

build_pdf
rename_pdf
# Cleanup afterwards on success
$PWD/scripts/clean.sh
