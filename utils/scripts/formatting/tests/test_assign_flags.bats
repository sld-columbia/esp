#!/usr/bin/env bats

. ../format_modified.sh

@test "assign_flags format c" {
    # Call the function directly
    assign_flags format c
    [ "$flags" = "-i" ]
}

@test "assign_flags format py" {
    assign_flags format py
    [ "$flags" = "-i -a -a" ]
}

@test "assign_flags format sv" {
    expected_flags="--inplace --port_declarations_alignment=preserve \
                           --assignment_statement_alignment=align --indentation_spaces=4"
    assign_flags format sv
    [ "$flags" = "$expected_flags" ]
}

@test "assign_flags format vhd" {
    assign_flags format vhd
    [ "$flags" = "--fix -c ~/esp/vhdl-style-guide.yaml" ]
}

@test "assign_flags check c" {
    assign_flags check c
    [ "$flags" = "--dry-run" ]
}

@test "assign_flags check py" {
    assign_flags check py
    [ "$flags" = "--list-fixes -a -a" ]
}

@test "assign_flags check sv" {
    expected_flags="--verify --port_declarations_alignment=preserve \
                           --assignment_statement_alignment=align --indentation_spaces=4"
    assign_flags check sv
    [ "$flags" = "$expected_flags" ]
}

@test "assign_flags check vhd" {
    assign_flags check vhd
    [ "$flags" = "~/esp/vhdl-style-guide.yaml" ]
}

@test "assign_flags format unknown" {
    run assign_flags format unknown
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Unknown type: unknown" ]]
}

@test "assign_flags invalid_action py" {
    run assign_flags invalid_action py
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Unknown action: invalid_action" ]]
}