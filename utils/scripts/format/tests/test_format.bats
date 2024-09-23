#!/usr/bin/env bats

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

setup() {
    echo "int main() {int x=5;  printf(\"Hello, World! %d\", x);return 0;}" > test.c
    echo "def main():print(\"Hello\");x=5" > test.py
    echo "module main;reg a; initial begin a=1; end endmodule" > test.sv
    echo "entity main is port (a:in std_logic);end entity main;" > test.vhd
}

teardown() {
	rm -f test.c test.py test.sv test.vhd
}

@test "Check if all required formatters are installed" {
    missing_tools=()
    
    for tool in "clang-format-10" "verible-verilog-format" "vsg"; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    if ! python3 -m autopep8 --version >/dev/null 2>&1; then
        missing_tools+=("autopep8")
    fi

    if [ "${#missing_tools[@]}" -gt 0 ]; then
        skip "Skipping test: Missing tools ${missing_tools[*]}"
    fi
}

@test "-f option gracefully handles missing file" {
    run ../format.sh -f missing_file.c
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: file 'missing_file.c' not found."* ]]
}

@test "-c option gracefully handles missing file" {
    run ../format.sh -c missing_file.c
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: file 'missing_file.c' not found."* ]]
}
@test "-h option displays help" {
    run ../format.sh -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: ../format.sh [OPTIONS]"* ]]
}

@test "Invalid option returns an error" {
    run ../format.sh -x
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option: -x"* ]]
}

@test "C file is formatted correctly with -f option" {
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

@test "Python file is formatted correctly with -f option" {
    run ../format.sh -f test.py
    [ "$status" -eq 0 ]
	
    run cat test.py
    [ "${lines[0]}" = "def main():" ]
    [ "${lines[1]}" = '    print("Hello")' ]
    [ "${lines[2]}" = "    x = 5" ]
}

@test "Verilog file is formatted properly with -f option" {
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

@test "VHDL file is formatted correctly with -f option" {
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
    run ../format.sh -fa
    [ "$status" -eq 0 ]

    run cat test.c
    [ "${lines[0]}" = "int main()" ]
    [ "${lines[1]}" = "{" ]
    [ "${lines[2]}" = "    int x = 5;" ]
    [ "${lines[3]}" = '    printf("Hello, World! %d", x);' ]
    [ "${lines[4]}" = "    return 0;" ]
    [ "${lines[5]}" = "}" ]

    run cat test.py
    [ "${lines[0]}" = "def main():" ]
    [ "${lines[1]}" = '    print("Hello")' ]
    [ "${lines[2]}" = "    x = 5" ]

    run cat test.sv
    [ "${lines[0]}" = "module main;" ]
    [ "${lines[1]}" = "    reg a;" ]
    [ "${lines[2]}" = "    initial begin" ]
    [ "${lines[3]}" = "        a = 1;" ]
    [ "${lines[4]}" = "    end" ]
    [ "${lines[5]}" = "endmodule" ]

    run cat test.vhd
    [ "${lines[0]}" = "entity main is" ]
    [ "${lines[1]}" = "  port (" ]
    [ "${lines[2]}" = "    a : in    std_logic" ]
    [ "${lines[3]}" = "  );" ]
    [ "${lines[4]}" = "end entity main;" ]
}

@test "-ca checks all modified files without making changes" {
    run ../format.sh -ca
    [ "$status" -eq 1 ]

    run cat test.c
    [ "${lines[0]}" = "int main() {int x=5;  printf(\"Hello, World! %d\", x);return 0;}" ]

    run cat test.py
    [ "${lines[0]}" = "def main():print(\"Hello\");x=5" ]

    run cat test.sv
    [ "${lines[0]}" = "module main;reg a; initial begin a=1; end endmodule" ]

    run cat test.vhd
    [ "${lines[0]}" = "entity main is port (a:in std_logic);end entity main;" ]
}