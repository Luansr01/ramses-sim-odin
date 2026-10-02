#!/bin/bash
PATH_TO_FILE="$PWD/mem/ramses.mem"
OUT="bin"

if [ ! -d "$OUT" ]; then
	mkdir -p "$OUT"
fi

odin run . -out:"$OUT/out" -- "$PATH_TO_FILE" 
