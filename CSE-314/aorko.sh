#!/bin/bash

# Check if required arguments are provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <submissions_dir> <targets_dir> <tests_dir> <answers_dir>"
    exit 1
fi

submissions_dir="$1"
targets_dir="$2"
tests_dir="$3"
answers_dir="$4"

# Check if directories exist
if [ ! -d "$submissions_dir" ]; then
    echo "Error: Submissions directory does not exist."
    exit 1
fi

if [ ! -d "$tests_dir" ]; then
    echo "Error: Tests directory does not exist."
    exit 1
fi

if [ ! -d "$answers_dir" ]; then
    echo "Error: Answers directory does not exist."
    exit 1
fi

# Create targets directory if it doesn't exist
mkdir -p "$targets_dir"

# Create language subdirectories in targets directory
mkdir -p "$targets_dir/C"
mkdir -p "$targets_dir/C++"
mkdir -p "$targets_dir/Python"
mkdir -p "$targets_dir/Java"

# Create arrays to store metrics and results
declare -A line_counts
declare -A comment_counts
declare -A function_counts
declare -A student_names
declare -A languages
declare -A match_counts
declare -A no_match_counts

# Count test files
test_file_count=$(ls "$tests_dir"/test*.txt | wc -l)
echo "Found $test_file_count test files"

# Create a temporary directory for extraction
temp_dir=$(mktemp -d)

# Process each submission zip file
for zip_file in "$submissions_dir"/*.zip; do
    if [ -f "$zip_file" ]; then
        # Extract student ID and name from filename
        filename=$(basename "$zip_file")
        student_id=$(echo "$filename" | grep -o 'submission_[0-9]\+' | grep -o '[0-9]\+')
        student_name=$(echo "$filename" | grep -o '^[^_]*' | sed 's/_/ /g')
        
        if [ -z "$student_id" ]; then
            echo "Warning: Could not extract student ID from $filename. Skipping."
            continue
        fi
        
        # Store student name
        student_names["$student_id"]="$student_name"
        
        echo "Processing submission for student $student_id ($student_name)"
        
        # Clean temp directory for this submission
        rm -rf "$temp_dir"/*
        
        # Extract the zip file
        unzip -q "$zip_file" -d "$temp_dir"
        
        # Find and process files by language
        # C files
        c_file=$(find "$temp_dir" -name "*.c" -type f | head -1)
        if [ -n "$c_file" ]; then
            mkdir -p "$targets_dir/C/$student_id"
            cp "$c_file" "$targets_dir/C/$student_id/main.c"
            echo "C file found for student $student_id and copied to target directory"
            
            # Store language info
            languages["$student_id"]="C"
            
            # Perform code analysis
            main_file="$targets_dir/C/$student_id/main.c"
            
            # Line count
            line_counts["$student_id"]=$(wc -l < "$main_file")
            
            # Comment count (single-line comments starting with //)
            comment_counts["$student_id"]=$(grep -c '//' "$main_file")
            
            # Function count (lines that match function definition patterns)
            function_counts["$student_id"]=$(grep -c "^[a-zA-Z0-9_]*\s*[a-zA-Z0-9_]\+\s*(.*).*{" "$main_file")
            
            echo "  Analysis - Lines: ${line_counts["$student_id"]}, Comments: ${comment_counts["$student_id"]}, Functions: ${function_counts["$student_id"]}"
            
            # Compile C code
            echo "  Compiling C file for student $student_id"
            gcc -o "$targets_dir/C/$student_id/main.out" "$main_file"
            if [ $? -ne 0 ]; then
                echo "  Compilation failed for student $student_id"
                match_counts["$student_id"]=0
                no_match_counts["$student_id"]=$test_file_count
                continue
            fi
            
            # Run tests and compare with answers
            matched=0
            not_matched=0
            
            for i in $(seq 1 "$test_file_count"); do
                test_file="$tests_dir/test$i.txt"
                answer_file="$answers_dir/ans$i.txt"
                output_file="$targets_dir/C/$student_id/out$i.txt"
                
                if [ -f "$test_file" ] && [ -f "$answer_file" ]; then
                    # Run the compiled program with test input
                    "$targets_dir/C/$student_id/main.out" < "$test_file" > "$output_file"
                    
                    # Compare output with answer
                    if diff -Z -B "$output_file" "$answer_file" > /dev/null; then
                        matched=$((matched+1))
                    else
                        not_matched=$((not_matched+1))
                    fi
                fi
            done
            
            # Store match results
            match_counts["$student_id"]=$matched
            no_match_counts["$student_id"]=$not_matched
            
            echo "  Test Results - Matched: $matched, Not matched: $not_matched"
        fi
        
        # C++ files
        cpp_file=$(find "$temp_dir" -name "*.cpp" -type f | head -1)
        if [ -n "$cpp_file" ]; then
            mkdir -p "$targets_dir/C++/$student_id"
            cp "$cpp_file" "$targets_dir/C++/$student_id/main.cpp"
            echo "C++ file found for student $student_id and copied to target directory"
            
            # Store language info
            languages["$student_id"]="C++"
            
            # Perform code analysis
            main_file="$targets_dir/C++/$student_id/main.cpp"
            
            # Line count
            line_counts["$student_id"]=$(wc -l < "$main_file")
            
            # Comment count (single-line comments starting with //)
            comment_counts["$student_id"]=$(grep -c '//' "$main_file")
            
            # Function count (lines that match function definition patterns)
            function_counts["$student_id"]=$(grep -c "^[a-zA-Z0-9_:]*\s*[a-zA-Z0-9_:]\+\s*(.*).*{" "$main_file")
            
            echo "  Analysis - Lines: ${line_counts["$student_id"]}, Comments: ${comment_counts["$student_id"]}, Functions: ${function_counts["$student_id"]}"
            
            # Compile C++ code
            echo "  Compiling C++ file for student $student_id"
            g++ -o "$targets_dir/C++/$student_id/main.out" "$main_file"
            if [ $? -ne 0 ]; then
                echo "  Compilation failed for student $student_id"
                match_counts["$student_id"]=0
                no_match_counts["$student_id"]=$test_file_count
                continue
            fi
            
            # Run tests and compare with answers
            matched=0
            not_matched=0
            
            for i in $(seq 1 "$test_file_count"); do
                test_file="$tests_dir/test$i.txt"
                answer_file="$answers_dir/ans$i.txt"
                output_file="$targets_dir/C++/$student_id/out$i.txt"
                
                if [ -f "$test_file" ] && [ -f "$answer_file" ]; then
                    # Run the compiled program with test input
                    "$targets_dir/C++/$student_id/main.out" < "$test_file" > "$output_file"
                    
                    # Compare output with answer
                    if diff -Z -B "$output_file" "$answer_file" > /dev/null; then
                        matched=$((matched+1))
                    else
                        not_matched=$((not_matched+1))
                    fi
                fi
            done
            
            # Store match results
            match_counts["$student_id"]=$matched
            no_match_counts["$student_id"]=$not_matched
            
            echo "  Test Results - Matched: $matched, Not matched: $not_matched"
        fi
        
        # Java files
        java_file=$(find "$temp_dir" -name "*.java" -type f | head -1)
        if [ -n "$java_file" ]; then
            mkdir -p "$targets_dir/Java/$student_id"
            cp "$java_file" "$targets_dir/Java/$student_id/Main.java"
            echo "Java file found for student $student_id and copied to target directory"
            
            # Store language info
            languages["$student_id"]="Java"
            
            # Perform code analysis
            main_file="$targets_dir/Java/$student_id/Main.java"
            
            # Line count
            line_counts["$student_id"]=$(wc -l < "$main_file")
            
            # Comment count (single-line comments starting with //)
            comment_counts["$student_id"]=$(grep -c '//' "$main_file")
            
            # Method count (lines that match method definition patterns)
            function_counts["$student_id"]=$(grep -c "^\s*\(public\|private\|protected\)\s.*(.*).*{" "$main_file")
            
            echo "  Analysis - Lines: ${line_counts["$student_id"]}, Comments: ${comment_counts["$student_id"]}, Functions: ${function_counts["$student_id"]}"
            
            # Compile Java code
            echo "  Compiling Java file for student $student_id"
            (cd "$targets_dir/Java/$student_id" && javac Main.java)
            if [ $? -ne 0 ]; then
                echo "  Compilation failed for student $student_id"
                match_counts["$student_id"]=0
                no_match_counts["$student_id"]=$test_file_count
                continue
            fi
            
            # Run tests and compare with answers
            matched=0
            not_matched=0
            
            for i in $(seq 1 "$test_file_count"); do
                test_file="$tests_dir/test$i.txt"
                answer_file="$answers_dir/ans$i.txt"
                output_file="$targets_dir/Java/$student_id/out$i.txt"
                
                if [ -f "$test_file" ] && [ -f "$answer_file" ]; then
                    # Run the compiled program with test input
                    (cd "$targets_dir/Java/$student_id" && java Main < "$test_file" > "out$i.txt")
                    
                    # Compare output with answer
                    if diff -Z -B "$output_file" "$answer_file" > /dev/null; then
                        matched=$((matched+1))
                    else
                        not_matched=$((not_matched+1))
                    fi
                fi
            done
            
            # Store match results
            match_counts["$student_id"]=$matched
            no_match_counts["$student_id"]=$not_matched
            
            echo "  Test Results - Matched: $matched, Not matched: $not_matched"
        fi
        
        # Python files
        py_file=$(find "$temp_dir" -name "*.py" -type f | head -1)
        if [ -n "$py_file" ]; then
            mkdir -p "$targets_dir/Python/$student_id"
            cp "$py_file" "$targets_dir/Python/$student_id/main.py"
            echo "Python file found for student $student_id and copied to target directory"
            
            # Store language info
            languages["$student_id"]="Python"
            
            # Perform code analysis
            main_file="$targets_dir/Python/$student_id/main.py"
            
            # Line count
            line_counts["$student_id"]=$(wc -l < "$main_file")
            
            # Comment count (single-line comments starting with #)
            comment_counts["$student_id"]=$(grep -c '#' "$main_file")
            
            # Function count (lines that start with 'def ')
            function_counts["$student_id"]=$(grep -c "^\s*def\s" "$main_file")
            
            echo "  Analysis - Lines: ${line_counts["$student_id"]}, Comments: ${comment_counts["$student_id"]}, Functions: ${function_counts["$student_id"]}"
            
            # Run tests and compare with answers
            matched=0
            not_matched=0
            
            for i in $(seq 1 "$test_file_count"); do
                test_file="$tests_dir/test$i.txt"
                answer_file="$answers_dir/ans$i.txt"
                output_file="$targets_dir/Python/$student_id/out$i.txt"
                
                if [ -f "$test_file" ] && [ -f "$answer_file" ]; then
                    # Run the Python program with test input
                    python3 "$main_file" < "$test_file" > "$output_file"
                    
                    # Compare output with answer
                    if diff -Z -B "$output_file" "$answer_file" > /dev/null; then
                        matched=$((matched+1))
                    else
                        not_matched=$((not_matched+1))
                    fi
                fi
            done
            
            # Store match results
            match_counts["$student_id"]=$matched
            no_match_counts["$student_id"]=$not_matched
            
            echo "  Test Results - Matched: $matched, Not matched: $not_matched"
        fi
    fi
done

# Clean up temp directory
rm -rf "$temp_dir"

# Generate CSV file
csv_file="$targets_dir/result.csv"
echo "Generating CSV file: $csv_file"
echo "student id,student name,language,matched,not matched,line count,comment count,function count" > "$csv_file"

# Write data for each student to CSV
for student_id in "${!languages[@]}"; do
    name="${student_names[$student_id]:-Unknown}"
    language="${languages[$student_id]}"
    matched="${match_counts[$student_id]:-0}"
    not_matched="${no_match_counts[$student_id]:-0}"
    lines="${line_counts[$student_id]:-0}"
    comments="${comment_counts[$student_id]:-0}"
    functions="${function_counts[$student_id]:-0}"
    
    echo "$student_id,$name,$language,$matched,$not_matched,$lines,$comments,$functions" >> "$csv_file"
done

echo "Processing completed. Files organized in $targets_dir directory."
echo "Results saved to $csv_file"


