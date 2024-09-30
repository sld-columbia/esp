#!/bin/bash
is_github_actions=false

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
BOLD='\033[1m'
RESET='\033[0m'

header() {
    echo ""
    echo "    ______    _____    _____  "
    echo "   |  ____| /  ___ |  |  __  \ "
    echo "   | |__    | (___    | |__) |"
    echo "   |  __|   \ ___  \  |  ___/ "
    echo "   | |____   ____) |  | |     "
    echo "   |______| |_____/   |_|     "
    echo ""
    echo "   C O D E  F O R M A T T E R"
	echo "   ___________________________"
	echo ""
	echo ""

}

usage() {
    echo -e "Usage: $0 [OPTIONS]"
    echo -e "  -h           Display this help message"
    echo ""
    echo -e "  -f <file>    Fix formatting for file <file>"
    echo -e "  -c <file>    Check formatting for file <file>"
    echo -e "  -a           Apply to all"
    echo -e "  -g           Run as GitHub Actions workflow or pre-push hook"  
    echo ""
    echo -e "Examples:"
    echo -e "  $0 -fa                    # Fix all modified files in-place"
    echo -e "  $0 -f myfile.py           # Fix myfile.py in-place"
    echo -e "  $0 -ca                    # Report violations for all modified files"
    echo -e "  $0 -c myfile.py           # Report violations for myfile.py"
    echo -e "  $0 -g -ca                 # Report violations as part of a workflow or hook"
    echo ""
	echo "---"
	echo ""
}


check_tools() {
    local tools=("clang-format-10" "verible-verilog-format" "vsg")
    local missing_tools=()

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done

    if ! python3 -m autopep8 --version >/dev/null 2>&1; then
        missing_tools+=("autopep8")
    fi

    if [ "${#missing_tools[@]}" -gt 0 ]; then
        echo -e "${RED}ERROR:${RESET} The following required tools are not installed or not defined in PATH:"
        for tool in "${missing_tools[@]}" ; do
            echo -e "  - $tool${RESET}"
        done
        echo ""
        echo -e "${BOLD}Please install the missing tools before proceeding.${RESET}"
        exit 1
    fi
}


assign_flags() {
    local action="$1"
    local type="$2"
    
    case "$action" in
        format)
            case "$type" in
                c | h | cpp | hpp)
                    flags="-i"
                    ;;
                py)
                    flags="-iaaa"
                    ;;
                sv | v)
                    flags="--inplace --port_declarations_alignment=preserve \
                           --assignment_statement_alignment=align --indentation_spaces=4"
                    ;;
                vhd)
                    flags="--fix -c ~/esp/vhdl-style-guide.yaml"
                    ;;
                *)
                    echo "Unknown type: $type" >&2
                    usage
                    return 1
                    ;;
            esac
            ;;
        check)
            case "$type" in
                c | h | cpp | hpp)
                    flags="--dry-run"
                    ;;
                py)
                    flags="--list-fixes -a -a"
                    ;;
                sv | v)
                    flags="--verify --port_declarations_alignment=preserve \
                           --assignment_statement_alignment=align --indentation_spaces=4"
                    ;;
                vhd)
                    flags="~/esp/vhdl-style-guide.yaml"
                    ;;
                *)
                    echo "Unknown type: $type" >&2
                    usage
					echo -e "${RED}ERROR:${RESET} Type '$type' is unknown." >&2
                    return 1
                    ;;
            esac
            ;;
        *)
            echo "Unknown action: $action" >&2
            usage
			echo -e "${RED}ERROR:${RESET} Action '$action' is unknown." >&2
            return 1
            ;;
    esac
}

run_formatter() {
    local file_to_format="$1"
    local type="$2"
    local flags="$3"
    local mode="$4"
    local output

    case "$type" in
        c | h | cpp | hpp)
            output=$(clang-format-10 $flags "$file_to_format" 2>&1)
            ;;
        py)
            output=$(python3 -m autopep8 $flags "$file_to_format" 2>&1)
            ;;
        sv | v)
            output=$(verible-verilog-format $flags "$file_to_format" 2>&1)
            ;;
        vhd)
            output=$(vsg -f "$file_to_format" $flags 2>&1)
            ;;
    esac

    if [[ $mode == "format" ]]; then
        if [[ $? -ne 0 ]] || echo "$output" | grep -qE "warning|error"; then
            echo -e "$(basename "$file_to_format"): ${RED}${BOLD}Formatting failed!${RESET}"
            echo "$output"
            return 1
        else
            echo -e "$(basename "$file_to_format"): ${GREEN}${BOLD}Formatting successful!${RESET}"
            return 0
        fi
    else
        echo "$output"
        if [[ $? -ne 0 ]] || echo "$output" | grep -qE "warning|error"; then
            echo -e "$(basename "$file_to_format") check result: ${RED}${BOLD}Formatting issues found!${RESET}"
            return 1
        else
            echo -e "[$(basename "$file_to_format")] check result: ${GREEN}${BOLD}No formatting issues detected!${RESET}"
            return 0
        fi
    fi
}


parse_args() {
    action=""
    file_to_format=""
    all=false
    is_github_actions=false

    while [[ $# -gt 0 ]]; do
        local arg="$1"
        case $arg in
            -f)
                if [[ -z $2 || $2 == -* ]]; then
                    echo "Option -f requires an argument <file>." >&2
                    usage
                    return 1
                fi
                action="format"
                file_to_format="$2"
                shift
                ;;
            -fa)
                action="format"
                all=true
                ;;
            -c)
                if [[ -z $2 || $2 == -* ]]; then
                    echo "Option -c requires an argument <file>." >&2
                    usage
                    return 1
                fi
                action="check"
                file_to_format="$2"
                shift
                ;;
            -ca)
                action="check"
                all=true
                ;;
            -g)
                is_github_actions=true
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage
                return 1
                ;;
        esac
        shift
    done

    if [ "$all" = true ]; then
        format_all "$action"
    elif [ -n "$file_to_format" ]; then
        format_file "$action" "$file_to_format"
    else
        usage
        return 1
    fi
}

format_file() {
    local action="$1"
    local file_to_format="$2"
    local type="${file_to_format##*.}"

    if [ ! -f "$file_to_format" ]; then
        echo "$0: Error: file '$file_to_format' not found." >&2
        return 1
    fi

    assign_flags "$action" "$type"
    
    if [ -z "$flags" ]; then
        echo "Unknown type: $type" >&2
        usage
        return 1
    fi

    case $action in
        format)
            echo "Start formatting:"
            ;;
        check)
            echo "Start checking:"
            ;;
    esac

    if run_formatter "$file_to_format" "$type" "$flags" "$action"; then
        return 0
    else
        return 1
    fi
}


format_all() {
    local action="$1"

    if [ "$is_github_actions" = true ]; then
        modified_files=$(git diff --name-only HEAD^..HEAD \
            | grep -E '\.(c|h|cpp|hpp|py|v|sv|vhd)$')
    else
        modified_files=$(git status --porcelain \
            | grep -E '^ M|^??' \
            | awk '$2 ~ /\.(c|h|cpp|hpp|py|v|sv|vhd)$/ {print $2}')
    fi

    if [ -z "$modified_files" ]; then
        echo -e "${RED}${BOLD}Error:${RESET} No modified files found. Please check your changes."
        return 1
    fi

    modified_count=$(echo "$modified_files" | wc -l)
    echo -e "${BOLD}Found $modified_count modified file(s):${RESET}"
    for file in $modified_files; do
        echo -e " - ${YELLOW}$file${RESET}"
    done
    echo ""

    case $action in
        format)
            echo -e "${BLUE}${BOLD}Starting formatting process for modified files...${RESET}"
            ;;
        check)
            echo -e "${BLUE}${BOLD}Starting formatting check for modified files...${RESET}"
            ;;
    esac

    error_files=""
    for file in $modified_files; do
        local type="${file##*.}"
        assign_flags "$action" "$type"
        if ! run_formatter "$file" "$type" "$flags" "$action"; then
            error_files="$error_files $file"
        fi
    done

    echo ""
    if [ -n "$error_files" ]; then
        echo -e "${RED}${BOLD}Error:${RESET} One or more actions failed. Please review the errors above."
        return 1
    else
        echo -e "${GREEN}${BOLD}Success:${RESET} All actions completed without issues!"
        return 0
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    header
    check_tools
    parse_args "$@"
fi
