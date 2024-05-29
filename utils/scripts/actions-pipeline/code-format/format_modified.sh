#!/bin/bash

root_dir=$(git rev-parse --show-toplevel)
is_github_actions=false

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
GREEN='\033[32m'
RED='\033[31m'

# Display usage instructions
usage() {
    echo "ESP format checker ✨🛠️"
	echo "Report violations or format files in-place."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo "  -h            Display this help message"
	echo ""
    echo "  -f <file>     Fix formatting for file <file>"
	echo "  -c <file>     Check formatting for file <file>"
    echo "  -a            Apply to all"  
	echo "  -g            Run as Github Actions workflow or pre-push hook"  
    echo ""
    echo "Examples:"
    echo "  $0 -fa                    # Fix all modified files in-place"
    echo "  $0 -f myfile.py           # Fix myfile.py in-place"
	echo "  $0 -ca                    # Report violations for all modified files"
    echo "  $0 -c myfile.py           # Report violations for myfile.py"
	echo "  $0 -g -ca                 # Report violations as part of a workflow or hook"
    exit 1
}

format_file() {
    local file_to_format="$1"
	local action="$2"
    local type="${file_to_format##*.}"

	# Parse file extension type and decide which formatting tool to use
	# Add the corresponding flags based on whether we are formatting or checking
	case "$action" in
    Formatt)
        case "$type" in
            c | h | cpp | hpp)
                clang_format_edit="-i" ;;
            py)
                autopep8_edit="-i" ;;
            sv | v) 
                verible_edit="--inplace" ;;
            vhd)
                vsg_edit="--fix" ;;
        esac
        ;;
    Check)
		case "$type" in
            c | h | cpp | hpp)
                clang_format_edit="--dry-run" ;;
            py)
                autopep8_edit="--list-fixes" ;;
            sv | v) 
                verible_edit="--verify";;
            vhd)
                ;;
        esac
		;;
    *)
        echo "Unknown action: $action" >&2
        usage
        ;;
esac

	# Apply formatting tool based on file extension type
    local output
    case "$type" in
        c | h | cpp | hpp)
		# Format with clang-format-10
            output=$(clang-format-10 $clang_format_edit "$file_to_format" 2>&1);;
        py)
		# Format with autopep8
            output=$(python3 -m autopep8 $autopep8_edit -a -a "$file_to_format" 2>&1);;
        sv | v) 
		# Format with verible
            output=$(verible-verilog-format $verible_edit --port_declarations_alignment=preserve -assignment_statement_alignment=align --indentation_spaces=4 "$file_to_format" 2>&1) ;;
        vhd)
		# Format with vhdl-style-guide
            output=$(vsg -f "$file_to_format" $vsg_edit -c ~/esp/vhdl-style-guide.yaml 2>&1) ;;
    esac

	# If no errors were encountered while formatting, return SUCCESS
	# Else return FAILED
	if [ $? -eq 0 ] && ! echo "$output" | grep -qi "warning"; then
    	echo -e "${GREEN}SUCCESS${NC}"
    	return 0
	else
		echo -e "${RED}FAILED${NC}"
		echo "$output" | sed 's/^/  /'
		echo ""
		return 1
	fi
}

# Based on the command-line flags, determine whether to format in-place or check
# Call the appropriate action
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -f)
            if [[ -z $2 || $2 == -* ]]; then
                echo "Option -f requires an argument." >&2
                usage
            fi
            action="Formatt"
            file_to_format="$2"
            shift
            ;;
        -fa)
            action="Formatt"
            all_files=true
            ;;
        -c)
            if [[ -z $2 || $2 == -* ]]; then
                echo "Option -c requires an argument." >&2
                usage
            fi
            action="Check"
            file_to_format="$2"
            shift
            ;;
        -ca)
            action="Check"
            all_files=true
            ;;
		-g)
            is_github_actions=true
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
    shift
done

# User must specify a file to format if the -f flag is called
if [ -n "$file_to_format" ]; then
	if [ ! -f "$file_to_format" ]; then
        echo "$0: Error: File '$file_to_format' not found." >&2
        exit 1
    fi

	echo -n "$action""ing $file_to_format..."
    if format_file "$file_to_format" "$action"; then
		echo -e "✨ $action""ing done!"
		exit 0
	else
		echo -e "❌ $action""ing failed!"
		exit 1
	fi

	exit 0
fi


# Check all modified files of the file types: C/C++, Python, Verilog/SystemVerilog, VHDL
if [ "$all_files" = true ]; then
    modified_files=$(git status --porcelain | grep -E '^ M|^??' | awk '$2 ~ /\.(c|h|cpp|hpp|py|v|sv|vhd)$/ {print $2}')

	if [ "$is_github_actions" = true ]; then
		modified_files=$(git diff --name-only HEAD^..HEAD | grep -E '\.(c|h|cpp|hpp|py|v|sv|vhd)$')
	fi

    if [ -z "$modified_files" ]; then
        echo -e "🔍 No modified files found."
        exit 0
    fi

	# List the number of modified files found
    modified_count=$(echo "$modified_files" | wc -l)
    echo -e "🔍 Found $modified_count modified files:"
    echo ""
    for file in $modified_files; do
        echo "   - $file"
    done
    echo ""
    modified_files=$(echo "$modified_files" | sed "s|^|$root_dir/|")

    error_files=""
    success_files=""

	# Format/check each file in place with the appropriate tool
    for file in $modified_files; do
		echo -n "$action""ing $(basename "$file")..."
		if ! format_file "$file" "$action"; then
			error_files="$error_files $file"
		fi
	done

	# Final pass/fail directive
	echo ""
	if [ -n "$error_files" ]; then
		echo -e "❌ $action""ing failed!"
		exit 1
	else
		echo -e "✨ $action""ing done!"
		exit 0
	fi
else
    usage
fi