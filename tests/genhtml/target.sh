#!/usr/bin/env bash
#
# Create HTML output for info files containing target coverage rates as
# specified in mkinfo profile.
#

KEEP_GOING=0
while [ $# -gt 0 ] ; do

    OPT=$1
    case $OPT in

        --coverage )
            shift
            COVER_DB=$1
            shift

            COVER="perl -MDevel::Cover=-db,$COVER_DB,-coverage,statement,branch,condition,subroutine "
            KEEP_GOING=1

            ;;

        * )
            break
            ;;
    esac
done

OUTDIR="out_target"
STDOUT="target_stdout.log"
STDERR="target_stderr.log"

rm -rf "${OUTDIR}"

# Run genhtml
$GENHTML $TARGETINFO -o ${OUTDIR} >${STDOUT} 2>${STDERR}
RC=$?

echo "STDOUT_START"
cat ${STDOUT}
echo "STDOUT_STOP"

echo "STDERR_START"
cat ${STDERR}
echo "STDERR_STOP"

# Check exit code
if [[ $RC -ne 0 && $KEEP_GOING != 1 ]] ; then
        echo "Error: Non-zero genhtml exit code $RC"
        exit 1
fi

# Output must not contain warnings
if [[ -s ${STDERR} && $COVER == '' ]] ; then
        echo "Error: Output on stderr.log:"
        cat ${STDERR}
        exit 1
fi

# Output must indicate correct coverage rates
echo "Checking coverage rates in stdout"
check_counts "${TARGETCOUNTS}" "${STDOUT}" || exit 1

# Check output directory
if [[ ! -d "$OUTDIR" ]] ; then
        echo "Error: Output directory was not created"
        exit 1
fi

# Check output files
NUM_HTML_FILES=$(find ${OUTDIR} -name \*.html | wc -l)

if [[ "$NUM_HTML_FILES" -eq 0 ]] ; then
        echo "Error: No HTML file was generated"
        exit 1
fi

# Success
exit 0
