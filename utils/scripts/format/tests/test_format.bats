#!/usr/bin/env bats

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

setup() {
    cat <<EOF > test.c
int main() {int x=5;  printf("Hello, World! %d", x);return 0;}
EOF

	cat <<EOF > test.py
def main():print("Hello");x=5
EOF

	cat <<EOF > test.sv
module main;reg a; initial begin a = 1; end endmodule
EOF

	cat <<EOF > test.vhd
entity main is port (a: in std_logic); end entity main;
EOF
}

teardown() {
	rm -f test.c
	rm -f test.py
	rm -f test.sv
	rm -f test.vhd
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
    run ../format.sh -f missing_file.c
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: file 'missing_file.c' not found."* ]]
}

@test "-c <file> gracefully handles missing file" {
    run ../format.sh -c missing_file.c
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: file 'missing_file.c' not found."* ]]
}
@test "-h shows help" {
    run ../format.sh -h
    [ "$status" -eq 0 ]
	echo "${output}"
    [ "${output}" != "" ]
}

@test "invalid argument -x returns an error" {
    run ../format.sh -x
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option: -x"* ]]
}

@test "C file is formatted properly" {
    run ../format.sh -f test.c
    [ "$status" -eq 0 ]

    run cat test.c
    [ "${lines[0]}" = "int main()" ]
    [ "${lines[1]}" = "{" ]
    [ "${lines[2]}" = "    int x = 5;" ]
    [ "${lines[3]}" = '    printf("Hello, World! %d", x);' ]
    [ "${lines[4]}" = "    return 0;" ]
    [ "${lines[5]}" = "}" ]
}

@test "Python file is formatted properly" {
    run ../format.sh -f test.py
    [ "$status" -eq 0 ]
    run cat test.py
    [ "${lines[0]}" = "def main():" ]
    [ "${lines[1]}" = '    print("Hello")' ]
    [ "${lines[2]}" = "    x = 5" ]
}

@test "Verilog file is formatted properly" {
    run ../format.sh -f test.sv
    [ "$status" -eq 0 ]

    run cat test.sv
    [ "${lines[0]}" = "module main;" ]
    [ "${lines[1]}" = "    reg a;" ]
    [ "${lines[2]}" = "    initial begin" ]
    [ "${lines[3]}" = "        a = 1;" ]
    [ "${lines[4]}" = "    end" ]
    [ "${lines[5]}" = "endmodule" ]
}

@test "VHDL file is formatted properly" {
    run ../format.sh -f test.vhd
    [ "$status" -eq 0 ]

    run cat test.vhd
    [ "${lines[0]}" = "entity main is" ]
    [ "${lines[1]}" = "  port (" ]
    [ "${lines[2]}" = "    a : in    std_logic" ]
    [ "${lines[3]}" = "  );" ]
    [ "${lines[4]}" = "end entity main;" ]
}

@test "-fa formats all modified files" {
    # Run format.sh with -fa option
    run ../format.sh -fa
    [ "$status" -eq 0 ]

    # Check C file formatting
    run cat test.c
    [ "${lines[0]}" = "int main()" ]
    [ "${lines[1]}" = "{" ]
    [ "${lines[2]}" = "    int x = 5;" ]
    [ "${lines[3]}" = '    printf("Hello, World! %d", x);' ]
    [ "${lines[4]}" = "    return 0;" ]
    [ "${lines[5]}" = "}" ]

    # Check Python file formatting
    run cat test.py
    [ "${lines[0]}" = "def main():" ]
    [ "${lines[1]}" = '    print("Hello")' ]
    [ "${lines[2]}" = "    x = 5" ]

    # Check Verilog file formatting
    run cat test.sv
    [ "${lines[0]}" = "module main;" ]
    [ "${lines[1]}" = "    reg a;" ]
    [ "${lines[2]}" = "    initial begin" ]
    [ "${lines[3]}" = "        a = 1;" ]
    [ "${lines[4]}" = "    end" ]
    [ "${lines[5]}" = "endmodule" ]

    # Check VHDL file formatting
    run cat test.vhd
    [ "${lines[0]}" = "entity main is" ]
    [ "${lines[1]}" = "  port (" ]
    [ "${lines[2]}" = "    a : in    std_logic" ]
    [ "${lines[3]}" = "  );" ]
    [ "${lines[4]}" = "end entity main;" ]
}

# Test the -ca (check all) option
@test "-ca checks all modified files without making changes" {
    # Run format.sh with -ca option
    run ../format.sh -ca
    [ "$status" -eq 1 ]

    # Check that no files were modified
    # The original unformatted content should remain
    run cat test.c
    [ "${lines[0]}" = "int main() {int x=5;  printf(\"Hello, World! %d\", x);return 0;}" ]

    run cat test.py
    [ "${lines[0]}" = "def main():print(\"Hello\");x=5" ]

    run cat test.sv
    [ "${lines[0]}" = "module main;reg a; initial begin a = 1; end endmodule" ]

    run cat test.vhd
    [ "${lines[0]}" = "entity main is port (a: in std_logic); end entity main;" ]
}