#!/bin/bash
# Compile with Address Sanitizer
g++ -std=c++17 -fsanitize=address -g *.cpp -o program_asan

# Run the program with Address Sanitizer (without leak detection on macOS)
./program_asan