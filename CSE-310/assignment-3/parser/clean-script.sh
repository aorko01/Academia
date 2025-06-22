#!/bin/bash

# Enable extended globbing for pattern matching
shopt -s extglob

# Loop through all files that do NOT match *.sh, *.g4, Ctester.cpp, Hash.hpp, ScopeTable.hpp, SymbolInfo.hpp, SymbolTable.hpp, or SymbolTable.cpp
for file in !(*.sh|*.g4|Ctester.cpp|Hash.hpp|ScopeTable.hpp|SymbolInfo.hpp|SymbolTable.hpp|SymbolTable.cpp); do
    # Only delete if it's a regular file
    if [[ -f "$file" ]]; then
        rm -f "$file"
    fi
done

# Remove the 'output' directory if it exists
rm -rf output
