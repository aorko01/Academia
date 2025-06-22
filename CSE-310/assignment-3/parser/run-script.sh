#!/bin/bash

# Generate ANTLR files
antlr4 -v 4.13.2 -Dlanguage=Cpp C8086Lexer.g4
antlr4 -v 4.13.2 -Dlanguage=Cpp C8086Parser.g4

# Compile all source files (including the new SymbolTable.cpp)
g++ -std=c++17 -w -I/usr/local/include/antlr4-runtime -c C8086Lexer.cpp C8086Parser.cpp SymbolTable.cpp Ctester.cpp

# Link all object files
g++ -std=c++17 -w C8086Lexer.o C8086Parser.o SymbolTable.o Ctester.o -L/usr/local/lib/ -lantlr4-runtime -o Ctester.out -pthread

# Run the program
DYLD_LIBRARY_PATH=/usr/local/lib ./Ctester.out "$1"