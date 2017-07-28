#!/bin/sh

# Change me to wherever this project was cloned
ADOC_TOOLS_HOME=/u01/projects/adoc_tools

# Change me to wherever you'd prefer the final output of the adoc build to be
OUTDIR=/tmp/generated



for var in $@
do
    case $var in
        -maxWidth=*)
            maxWidth=`echo $var | cut -f2 -d\=`
            ;;
        -html5)
            html5=html5
            ;;
        -singleFile=*)
           singleFile=`echo $var | cut -f2 -d\=`
            ;;
    esac
done

if [ "x$maxWidth" = "x" ]; then
        maxWidth=1024px
fi

ASCIIDOC_LMS="asciidoc -f $ADOC_TOOLS_HOME/conf/html5.conf -b html5 -a max-width=$maxWidth -a icons -a encoding=ISO-8859-1"
ASCIIDOC_ILT="asciidoc -f $ADOC_TOOLS_HOME/conf/slidy.conf -b html5 -a max-width=$maxWidth -a icons"

TEMP_OUTDIR=target

function process_module {
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
            process_module `ls $INPUT/*`
        fi
    done
}

# Useful for transforming a single *.adoc file
# adoc_build.sh -singleFile=OPEN_Course_Developer_Guide.adoc
function process_single {
    mkdir -p $OUTDIR/$DIRNAME
    FILENAME=`basename $singleFile .adoc`
    echo "single file = $singleFile ; FILENAME = $FILENAME"
    $ASCIIDOC_LMS --out-file $OUTDIR/$DIRNAME/$FILENAME.html $singleFile;
    echo "	BUILD COMPLETE:  The output of this build can be found at:  $OUTDIR/$DIRNAME/$FILENAME.html" 
}


if [ "x$singleFile" = "x" ]; then
    echo "############################################################################################################################### "
    echo "  Allslides per module are put into a single slide show styled page."	
    DIRNAME=`basename $@`
    process_module $@
    echo "	BUILD COMPLETE:  The output of this build can be found in the $OUTDIR/$DIRNAME/$TEMP_OUTDIR directory."
    echo "############################################################################################################################### "
else
    process_single
fi


