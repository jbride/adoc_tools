#!/bin/sh

# Change me to wherever this project was cloned
ADOC_TOOLS_HOME=/u01/projects/adoc_tools

# Change me to wherever you'd prefer the final output of the adoc build to be
OUTDIR=/tmp/generated


echo "############################################################################################################################### "
echo "  Allslides per module are put into a single slide show styled page."	
echo "############################################################################################################################### "

for var in $@
do
    case $var in
        -maxWidth=*)
            -maxWidth=`echo $var | cut -f2 -d\=`
            ;;
        -html5)
            html5=html5
            ;;
    esac
done

if [ "x$maxWidth" = "x" ]; then
        maxWidth=1024px
fi


ASCIIDOC_LMS="asciidoc -f $ADOC_TOOLS_HOME/conf/html5.conf -b html5 -a max-width=$maxWidth -a icons -a encoding=ISO-8859-1"
ASCIIDOC_ILT="asciidoc -f $ADOC_TOOLS_HOME/conf/slidy.conf -b html5 -a max-width=$maxWidth -a icons"

DIRNAME=`basename $@`
TEMP_OUTDIR=target

function process_asciidoc {
    rm -rf "$OUTDIR/$DIRNAME/$TEMP_OUTDIR"
    mkdir -p "$OUTDIR/$DIRNAME/$TEMP_OUTDIR"
    for INPUT in  $@ ; do
        # If a file ending in "AllSlides.txt" then process with AsciiDoc.
        if [ -f $INPUT ] && [ `echo $INPUT | grep -c -e "AllSlides.txt$"` == 1 ]; then
            echo "Processing All from:  $INPUT"
            OUTPUT=`basename $INPUT .txt`
            if [ "x$slidy" = "x" ]; then
                $ASCIIDOC_ILT --out-file $OUTDIR/$DIRNAME/$TEMP_OUTDIR/$OUTPUT.html $INPUT;
            else
                $ASCIIDOC_LMS --out-file $OUTDIR/$DIRNAME/$TEMP_OUTDIR/$OUTPUT.html $INPUT;
            fi

	# Else if a directory, process its contents.
        elif [ -d $INPUT ] ; then
            echo "\n################## Processing directory $INPUT #####################"
	    DIRNAME=$INPUT
    	    DIRNAME=`echo "$DIRNAME" | tr -d ' '`
            process_asciidoc `ls $INPUT/*`
        fi
    done
}

process_asciidoc $@

echo "############################################################################################################################### "
echo "	BUILD COMPLETE:  The output of this build can be found in the $OUTDIR/$DIRNAME/$TEMP_OUTDIR directory."
echo "############################################################################################################################### "

