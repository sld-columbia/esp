#!/usr/bin/env bats

setup() {
    # Create C file
    cat <<EOF > test.c
int main() {int x=5;  printf("Hello, World! %d", x);return 0;}
EOF

    # Create Python file
    cat <<EOF > test.py
def main():print("Hello");x=5
EOF

    # Create Verilog file
    cat <<EOF > test.sv
module main;reg a; initial begin a = 1; end endmodule
EOF

    # Create VHDL file
    cat <<EOF > test.vhd
entity main is port (a: in std_logic); end entity main;
EOF
}

@test "-fa formats all modified files" {
    # Run format_modified.sh with -fa option
    run ../format_modified.sh -fa
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
    # Run format_modified.sh with -ca option
    run ../format_modified.sh -ca
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