#!/bin/bash

# First, get the required non-option arguments
if [ $# -lt 4 ]; then
    echo "Usage: $0 <submissions_dir> <targets_dir> <tests_dir> <answers_dir> [options]"
    exit 1
fi

submissions_dir="$1"
targets_dir="$2"
tests_dir="$3"
answers_dir="$4"
shift 4  # Remove the first four arguments

# Initialize flags for optional arguments
verbose=false
noexecute=false
nolc=false
nocc=false
nofc=false

# Process optional arguments that come after the four required arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -v)
            verbose=true
            ;;
        -noexecute)
            noexecute=true
            ;;
        -nolc)
            nolc=true
            ;;
        -nocc)
            nocc=true
            ;;
        -nofc)
            nofc=true
            ;;
        *)
            echo "Unknown option: $1"
            echo "Available options: -v, -noexecute, -nolc, -nocc, -nofc"
            exit 1
            ;;
    esac
    shift
done

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
            continue
        fi
        
        # Store student name
        student_names["$student_id"]="$student_name"
        
        # Print info if verbose is enabled
        if $verbose; then
            echo "Organizing files of $student_id"
        fi
        
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
            
            # Store language info
            languages["$student_id"]="C"
            
            # Perform code analysis
            main_file="$targets_dir/C/$student_id/main.c"
            
            # Line count (if not skipped)
            if ! $nolc; then
                line_counts["$student_id"]=$(wc -l < "$main_file")
            else
                line_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Comment count (if not skipped)
            if ! $nocc; then
                comment_counts["$student_id"]=$(grep -c '.*//.*' "$main_file")
            else
                comment_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Function count (if not skipped)
            if ! $nofc; then
                function_counts["$student_id"]=$(grep -cE '^[[:blank:]]*[A-Za-z_][A-Za-z0-9_]*[[:blank:]]+[A-Za-z_][A-Za-z0-9_]*\([^)]*\)[[:blank:]]*\{?' "$main_file")
            else
                function_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Skip execution if noexecute flag is set
            if $noexecute; then
                match_counts["$student_id"]=-1  # Use -1 to indicate skipped
                no_match_counts["$student_id"]=-1  # Use -1 to indicate skipped
                continue
            fi
            
            # Compile C code
            gcc -o "$targets_dir/C/$student_id/main.out" "$main_file" 2>/dev/null
            if [ $? -ne 0 ]; then
                match_counts["$student_id"]=0
                no_match_counts["$student_id"]=$test_file_count
                continue
            fi
            
            # Print info if verbose is enabled
            if $verbose; then
                echo "Executing files of $student_id"
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
                    
                    # Compare output with answer - use -w flag to ignore all whitespace differences
                    if diff -w "$output_file" "$answer_file" > /dev/null; then
                        matched=$((matched+1))
                    else
                        not_matched=$((not_matched+1))
                    fi
                fi
            done
            
            # Store match results
            match_counts["$student_id"]=$matched
            no_match_counts["$student_id"]=$not_matched
        fi
        
        # C++ files
        cpp_file=$(find "$temp_dir" -name "*.cpp" -type f | head -1)
        if [ -n "$cpp_file" ]; then
            mkdir -p "$targets_dir/C++/$student_id"
            cp "$cpp_file" "$targets_dir/C++/$student_id/main.cpp"
            
            # Store language info
            languages["$student_id"]="C++"
            
            # Perform code analysis
            main_file="$targets_dir/C++/$student_id/main.cpp"
            
            # Line count (if not skipped)
            if ! $nolc; then
                line_counts["$student_id"]=$(wc -l < "$main_file")
            else
                line_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Comment count (if not skipped)
            if ! $nocc; then
                comment_counts["$student_id"]=$(grep -c '.*//.*' "$main_file")
            else
                comment_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Function count (if not skipped)
            if ! $nofc; then
                function_counts["$student_id"]=$(grep -cE '^[[:blank:]]*[A-Za-z_][A-Za-z0-9_]*[[:blank:]]+[A-Za-z_][A-Za-z0-9_]*\([^)]*\)[[:blank:]]*\{?' "$main_file")
            else
                function_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Skip execution if noexecute flag is set
            if $noexecute; then
                match_counts["$student_id"]=-1  # Use -1 to indicate skipped
                no_match_counts["$student_id"]=-1  # Use -1 to indicate skipped
                continue
            fi
            
            # Compile C++ code
            g++ -o "$targets_dir/C++/$student_id/main.out" "$main_file" 2>/dev/null
            if [ $? -ne 0 ]; then
                match_counts["$student_id"]=0
                no_match_counts["$student_id"]=$test_file_count
                continue
            fi
            
            # Print info if verbose is enabled
            if $verbose; then
                echo "Executing files of $student_id"
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
                    
                    # Compare output with answer - use -w flag to ignore all whitespace differences
                    if diff -w "$output_file" "$answer_file" > /dev/null; then
                        matched=$((matched+1))
                    else
                        not_matched=$((not_matched+1))
                    fi
                fi
            done
            
            # Store match results
            match_counts["$student_id"]=$matched
            no_match_counts["$student_id"]=$not_matched
        fi
        
        # Java files
        java_file=$(find "$temp_dir" -name "*.java" -type f | head -1)
        if [ -n "$java_file" ]; then
            mkdir -p "$targets_dir/Java/$student_id"
            cp "$java_file" "$targets_dir/Java/$student_id/Main.java"
            
            # Store language info
            languages["$student_id"]="Java"
            
            # Perform code analysis
            main_file="$targets_dir/Java/$student_id/Main.java"
            
            # Line count (if not skipped)
            if ! $nolc; then
                line_counts["$student_id"]=$(wc -l < "$main_file")
            else
                line_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Comment count (if not skipped)
            if ! $nocc; then
                comment_counts["$student_id"]=$(grep -c '.*//.*' "$main_file")
            else
                comment_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Method count (if not skipped)
            if ! $nofc; then
                function_counts["$student_id"]=$(grep -cE '^[[:blank:]]*(public|private|protected)?[[:blank:]]*(static)?[[:blank:]]*[A-Za-z_][A-Za-z0-9_]*[[:blank:]]+[A-Za-z_][A-Za-z0-9_]*\([^)]*\)[[:blank:]]*\{?' "$main_file")
            else
                function_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Skip execution if noexecute flag is set
            if $noexecute; then
                match_counts["$student_id"]=-1  # Use -1 to indicate skipped
                no_match_counts["$student_id"]=-1  # Use -1 to indicate skipped
                continue
            fi
            
            # Compile Java code
            (cd "$targets_dir/Java/$student_id" && javac Main.java 2>/dev/null)
            if [ $? -ne 0 ]; then
                match_counts["$student_id"]=0
                no_match_counts["$student_id"]=$test_file_count
                continue
            fi
            
            # Print info if verbose is enabled
            if $verbose; then
                echo "Executing files of $student_id"
            fi
            
            # Run tests and compare with answers
            matched=0
            not_matched=0
            
            for i in $(seq 1 "$test_file_count"); do
                test_file="$tests_dir/test$i.txt"
                answer_file="$answers_dir/ans$i.txt"
                output_file="$targets_dir/Java/$student_id/out$i.txt"
                
                if [ -f "$test_file" ] && [ -f "$answer_file" ]; then
                    # Run the compiled program with test input - use absolute path for out file
                    (cd "$targets_dir/Java/$student_id" && java Main < "$test_file" > "$output_file")
                    
                    # Compare output with answer - use -w flag to ignore all whitespace differences
                    if diff -w "$output_file" "$answer_file" > /dev/null; then
                        matched=$((matched+1))
                    else
                        not_matched=$((not_matched+1))
                    fi
                fi
            done
            
            # Store match results
            match_counts["$student_id"]=$matched
            no_match_counts["$student_id"]=$not_matched
        fi
        
        # Python files
        py_file=$(find "$temp_dir" -name "*.py" -type f | head -1)
        if [ -n "$py_file" ]; then
            mkdir -p "$targets_dir/Python/$student_id"
            cp "$py_file" "$targets_dir/Python/$student_id/main.py"
            
            # Store language info
            languages["$student_id"]="Python"
            
            # Perform code analysis
            main_file="$targets_dir/Python/$student_id/main.py"
            
            # Line count (if not skipped)
            if ! $nolc; then
                line_counts["$student_id"]=$(wc -l < "$main_file")
            else
                line_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Comment count (if not skipped)
            if ! $nocc; then
                comment_counts["$student_id"]=$(grep -c '.*#.*' "$main_file")
            else
                comment_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Function count (if not skipped)
            if ! $nofc; then
                function_counts["$student_id"]=$(grep -cE '^[[:blank:]]*def[[:blank:]]+[A-Za-z_][A-Za-z0-9_]*\([^)]*\)[[:blank:]]*:' "$main_file")
            else
                function_counts["$student_id"]=-1  # Use -1 to indicate skipped
            fi
            
            # Skip execution if noexecute flag is set
            if $noexecute; then
                match_counts["$student_id"]=-1  # Use -1 to indicate skipped
                no_match_counts["$student_id"]=-1  # Use -1 to indicate skipped
                continue
            fi
            
            # Print info if verbose is enabled
            if $verbose; then
                echo "Executing files of $student_id"
            fi
            
            # Run tests and compare with answers
            matched=0
            not_matched=0
            
            for i in $(seq 1 "$test_file_count"); do
                test_file="$tests_dir/test$i.txt"
                answer_file="$answers_dir/ans$i.txt"
                output_file="$targets_dir/Python/$student_id/out$i.txt"
                
                if [ -f "$test_file" ] && [ -f "$answer_file" ]; then
                    # Run the Python program with test input
                    python3 "$main_file" < "$test_file" > "$output_file" 2>/dev/null
                    
                    # Compare output with answer - use -w flag to ignore all whitespace differences
                    if diff -w "$output_file" "$answer_file" > /dev/null; then
                        matched=$((matched+1))
                    else
                        not_matched=$((not_matched+1))
                    fi
                fi
            done
            
            # Store match results
            match_counts["$student_id"]=$matched
            no_match_counts["$student_id"]=$not_matched
        fi
    fi
done

# Clean up temp directory
rm -rf "$temp_dir"

# Generate CSV file
csv_file="$targets_dir/result.csv"

# Create header based on enabled metrics
header="student id,student name,language"
if ! $noexecute; then
    header="$header,matched,not matched"
fi
if ! $nolc; then
    header="$header,line count"
fi
if ! $nocc; then
    header="$header,comment count"
fi
if ! $nofc; then
    header="$header,function count"
fi

# Write header to CSV file
echo "$header" > "$csv_file"

# Write data for each student to CSV
for student_id in "${!languages[@]}"; do
    name="${student_names[$student_id]:-Unknown}"
    language="${languages[$student_id]}"
    
    # Start with basic data
    line="$student_id,$name,$language"
    
    # Add execution data if not skipped
    if ! $noexecute; then
        matched="${match_counts[$student_id]:-0}"
        not_matched="${no_match_counts[$student_id]:-0}"
        line="$line,$matched,$not_matched"
    fi
    
    # Add line count if not skipped
    if ! $nolc; then
        lines="${line_counts[$student_id]:-0}"
        line="$line,$lines"
    fi
    
    # Add comment count if not skipped
    if ! $nocc; then
        comments="${comment_counts[$student_id]:-0}"
        line="$line,$comments"
    fi
    
    # Add function count if not skipped
    if ! $nofc; then
        functions="${function_counts[$student_id]:-0}"
        line="$line,$functions"
    fi
    
    # Write line to CSV
    echo "$line" >> "$csv_file"
done

echo "all the submissions processed successfully"


