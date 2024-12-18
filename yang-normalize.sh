#!/bin/bash
##
## Copyright (c) 2011-2024 The Johns Hopkins University Applied Physics
## Laboratory LLC.
##
## This file is part of the Delay-Tolerant Networking Management
## Architecture (DTNMA) Tools package.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##     http://www.apache.org/licenses/LICENSE-2.0
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
set -e

USAGE="Usage: $0 [filename] {... filename}"
if [ "$#" -eq "0" ]; then
    echo "$USAGE"
    exit 1
fi

SELFDIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
LINTOPTS="--ietf --lint-ensure-hyphenated-names"
OUTOPTS="-t adm-add-enum -f yang --yang-canonical"
NORMALIZE="ace_adm --path=${SELFDIR} ${LINTOPTS} ${OUTOPTS}"

# Normalize a single YANG file
# Arguments:
#  1: The file path to normalize
#
function normalize {
    FILEPATH=$1
    shift

    if [ ! -f "${FILEPATH}" ]; then
        echo "File is missing: ${FILEPATH}" >/dev/stderr
        return 1
    fi

    # Canonicalize and normalize into ".out" file
    EXT="${FILEPATH##*.}"
    if [ "${EXT}" == "yang" ]; then
        ${NORMALIZE} "${FILEPATH}" >"${FILEPATH}.out"
    else
        echo "Cannot handle file with extension: ${EXT}" >/dev/stderr
        return 2
    fi
    if [ ! -s "${FILEPATH}.out" ]; then
        echo "Failed to format file ${FILEPATH}" >/dev/stderr
        rm "${FILEPATH}.out"
        return 3;
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
