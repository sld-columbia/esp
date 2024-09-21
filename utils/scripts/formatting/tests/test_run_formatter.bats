#!/usr/bin/env bats

. ../format_modified.sh

setup() {
    function clang-format-10() {
        echo "clang-format mock"
        return 0
    }

    function python3() {
        echo "autopep8 mock"
        return 0
    }

    function verible-verilog-format() {
        echo "verible-verilog-format mock"
        return 0
    }

    function vsg() {
        echo "vsg mock"
        return 0
    }
}

@test "run_formatter formats C file" {
    file="test.c"
    type="c"
    flags="-i"
    run run_formatter "$file" "$type" "$flags"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = " - test.c: clang-format mock" ]
	[[ "${output}" == *"success"* ]]
}

@test "run_formatter formats Python file" {
    file="test.py"
    type="py"
    flags="-i -a -a"
    run run_formatter "$file" "$type" "$flags"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = " - test.py: autopep8 mock" ]
	[[ "${output}" == *"success"* ]]
}

@test "run_formatter formats Verilog file" {
    file="test.sv"
    type="sv"
    flags="--inplace --port_declarations_alignment=preserve --assignment_statement_alignment=align --indentation_spaces=4"
    run run_formatter "$file" "$type" "$flags"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = " - test.sv: verible-verilog-format mock" ]
	[[ "${output}" == *"success"* ]]
}

@test "run_formatter formats VHDL file" {
    file="test.vhd"
    type="vhd"
    flags="--fix -c ~/esp/vhdl-style-guide.yaml"
    run run_formatter "$file" "$type" "$flags"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = " - test.vhd: vsg mock" ]
	[[ "${output}" == *"success"* ]]
}

@test "run_formatter fails when tool fails" {
    file="test.c"
    type="c"
    flags="-i"

    function clang-format-10() {
        echo "failed clang-format mock"
        return 1
    }

    run run_formatter "$file" "$type" "$flags"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = " - test.c: failed clang-format mock" ]
	[[ "${output}" == *"failure"* ]]
}
