#!/usr/bin/env bats

. ../format_modified.sh

setup() {
    echo "int main() {}" > test.c
}

teardown() {
    rm -f test.c
}

@test "format_file successfully formats C file" {
    run format_file format test.c
    [ "$status" -eq 0 ]
    [[ "$output" == *"Success: action completed."* ]]
}

@test "format_file fails on non-existent file" {
    run format_file format nonexistent_file.c
    [ "$status" -ne 0 ]
    [[ "$output" == *"Error: file 'nonexistent_file.c' not found."* ]]
}

@test "format_file checks formatting of C file" {
    run format_file check test.c
    [ "$status" -eq 0 ]
    [[ "$output" == *"Success: action completed."* ]]
}

@test "format_file fails to format unsupported file type" {
    echo "Unsupported content" > test.txt
    run format_file format test.txt
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown type: txt"* ]]
	rm test.txt
}

@test "format_file handles unexpected action gracefully" {
    run format_file unknown_action test.c
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown action: unknown_action"* ]]
}
