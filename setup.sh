#!/bin/bash

set -x

BASE=$( dirname $0 )
TS=$(date +%s)

# ASSUME RUNNING FROM TOP LEVEL OF CLONED PUPPERWARE REPO
# Output from 'pwd' will be the directory from which quickstart was invoked
INSTALL_DIR="$(pwd)"


# Install from src to tgt
install_it() {
    set -x
    local _src="$1"
    local _tgt="$2"
    cp \
        --preserve=mode,timestamps \
        --recursive \
        "$_src" \
        "$_tgt"
}


# Copy dirs as-is
DIRLIST=( agent server vagrant )
for dir in "${DIRLIST[@]}"; do
    install_it "$BASE"/"$dir" "$INSTALL_DIR"/
done

# Copy files as-is
FILELIST=( $( ls "$BASE"/docker-compose*.yml ) )
for src in "${FILELIST[@]}"; do
    install_it "$src" "$INSTALL_DIR"/
done

# Copy files with different target name
declare -A FILEMAP
FILEMAP[env]=.env
for src in "${!FILEMAP[@]}"; do
    tgt="${FILEMAP[$src]}"
    install_it "$BASE"/"$src" "$INSTALL_DIR"/"$tgt"
done
