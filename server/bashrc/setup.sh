#!/bin/bash

set -x

BASE=$( dirname $0 )
TS=$(date +%s)

for src in $BASE/bashrc.d/*.sh ; do
    src_fn=$( basename "$src" )
    tgt="$HOME/.bashrc.d/$src_fn"
    install -vbCD --suffix="$TS" -T -m '0400' "$src" "$tgt"
done

bashrc="$HOME/.bashrc"
grep -q '^# INCLUDE bashrc.d' "$bashrc" || {
    cat "$BASE/bashrc_snippet" >> "$bashrc"
}
