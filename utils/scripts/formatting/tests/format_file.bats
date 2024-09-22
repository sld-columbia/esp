#!/usr/bin/env bats

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

@test "check_formatters" {
    missing_formatters=()

    for formatter in "clang-format-10" "autopep8" "verible-verilog-format" "vsg"; do
        if ! command_exists "$formatter"; then
            missing_formatters+=("$formatter")
        fi
    done

    if [ "${#missing_formatters[@]}" -gt 0 ]; then
        skip "The following required formatters are not installed: ${missing_formatters[*]}"
    fi
}

@test "-f <file> gracefully handles missing file" {
    run ../format_modified.sh -f missing_file.c
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: file 'missing_file.c' not found."* ]]
}

@test "-c <file> gracefully handles missing file" {
    run ../format_modified.sh -c missing_file.c
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: file 'missing_file.c' not found."* ]]
}
@test "-h shows help" {
    run ../format_modified.sh -h
    [ "$status" -eq 0 ]
	echo "${output}"
    [ "${output}" != "" ]
}

@test "invalid argument -x returns an error" {
    run ../format_modified.sh -x
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option: -x"* ]]
}