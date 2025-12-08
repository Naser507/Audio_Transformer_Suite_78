#!/bin/bash

# Recursively show the file structure and mark empty files or show size

print_tree() {
    local prefix="$1"
    local dir="$2"

    for f in "$dir"/*; do
        if [ -d "$f" ]; then
            echo "${prefix}$(basename "$f")/"
            print_tree "  $prefix" "$f"
        elif [ -f "$f" ]; then
            if [ ! -s "$f" ]; then
                echo "${prefix}$(basename "$f") → EMPTY"
            else
                size=$(stat -c%s "$f")
                echo "${prefix}$(basename "$f") → $size bytes"
            fi
        fi
    done
}

print_tree "" "."

