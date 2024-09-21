#!/usr/bin/env bats

. ../format_modified.sh

setup() {
    # Create test files
    mkdir -p test_repo
    cd test_repo
    echo "void main() {}" > test.c
    echo "print('Hello, World!')" > test.py
}

teardown() {
    # Clean up test repository
    cd ..
    rm -rf test_repo
}

@test "format_all finds modified files in a Git repository" {
    # Modify the files to simulate changes
    echo "int main() {}" > test.c
    echo "print('Goodbye, World!')" > test.py
    
    # Run the format_all function
    run format_all format
    [ "$status" -eq 0 ]
    [[ "$output" == *"Found 2 modified file(s):"* ]]
}

@test "format_all with no modified files" {
    # Ensure no modifications are made
    run format_all format
    [ "$status" -eq 0 ]
    [[ "$output" == *"Info: No modified files found."* ]]
}

@test "format_all fails with unsupported file type" {
    # Create an unsupported file type
    echo "Unsupported content" > test.txt
    git init
    git add test.txt
    git commit -m "Add unsupported file"
    
    # Run format_all
    run format_all format
    [ "$status" -ne 0 ]
    [[ "$output" == *"Error: action failed."* ]]
}

@test "format_all runs as GitHub Actions" {
    git init
    git add test.c
    git commit -m "Initial commit"
    
    # Modify the file to simulate a change
    echo "int main() {}" > test.c
    git add test.c
    git commit -m "Modify test.c"
    
    # Simulate GitHub Actions
    is_github_actions=true
    
    # Run format_all
    run format_all format
    [ "$status" -eq 0 ]
    [[ "$output" == *"Found 1 modified file(s):"* ]]
}