#!/bin/bash
set -e

USAGE="Usage: $0 [filename] {... filename}"
if [ "$#" -eq "0" ]; then
    echo "$USAGE"
    exit 1
fi

SELFDIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
LINTOPTS="--ietf --lint-ensure-hyphenated-names"
OUTOPTS="-f yang --yang-canonical"
NORMALIZE="ace_adm --path=${SELFDIR} ${LINTOPTS} ${OUTOPTS}"

# Normalize a single YANG file
# Arguments:
#  1: The file path to normalize
#
function normalize {
    FILEPATH=$1
    shift

    if [ ! -f "${FILEPATH}" ]; then
        echo "File is missing: ${FILEPATH}"
        exit 1
    fi

    # Canonicalize and normalize into ".out" file
    EXT="${FILEPATH##*.}"
    if [ "${EXT}" == "yang" ]; then
        ${NORMALIZE} "${FILEPATH}" >"${FILEPATH}.out"
    else
        echo "Cannot handle file with extension: ${EXT}"
        exit 1
    fi

    if ! diff -q "${FILEPATH}.out" "${FILEPATH}" >/dev/null; then
        mv "${FILEPATH}.out" "${FILEPATH}"
        echo "Normalized ${FILEPATH}"
    else
        rm "${FILEPATH}.out"
    fi
}

ERRCOUNT=0
for FILEPATH in "$@"
do
    if ! normalize "${FILEPATH}"
    then
        ERRCOUNT=$(($ERRCOUNT + 1))
    fi
done
exit ${ERRCOUNT}
