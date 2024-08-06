#!/bin/bash
set -e

USAGE="Usage: $0 [filename] {... filename}"
if [ "$#" -eq "0" ]; then
    echo "$USAGE"
    exit 1
fi

SELFDIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
LINTOPTS="--ietf --lint-ensure-hyphenated-names"
VALIDATE="ace_adm --path=${SELFDIR} ${LINTOPTS}"

# Validate a single ADM module file
# Arguments:
#  1: The file path to normalize
#
function validate {
    FILEPATH=$1
    shift

    if [ ! -f "${FILEPATH}" ]; then
        echo "File is missing: ${FILEPATH}"
        exit 1
    fi

    echo "Validating ${FILEPATH}"
    ${VALIDATE} "${FILEPATH}"
}

ERRCOUNT=0
for FILEPATH in "$@"
do
    if ! validate "${FILEPATH}"
    then
        ERRCOUNT=$(($ERRCOUNT + 1))
    fi
done
exit ${ERRCOUNT}
