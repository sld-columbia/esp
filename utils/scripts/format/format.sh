#!/bin/bash
is_github_actions=false

header() {
    echo ""
    echo "* * * * * * * * * * * * * * * * * * * * * * * * *"
    echo "*                                               *"
    echo "*  🚀✨ Welcome to the ESP code formatter 🛠️🧙   *"
    echo "*                                               *"
    echo "* * * * * * * * * * * * * * * * * * * * * * * * *"
    echo ""
}


usage() {
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
        echo "Error: The following required tools are not installed or not defined in PATH:"
        for tool in "${missing_tools[@]}" ; do
            echo "  - $tool"
        done
        echo ""
        echo "Please install the missing tools before proceeding."
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
                    return 1
                    ;;
            esac
            ;;
        *)
            echo "Unknown action: $action" >&2
            usage
            return 1
            ;;
    esac
}

run_formatter() {
    local file_to_format="$1"
    local type="$2"
    local flags="$3"

    echo -n " - $(basename "$file_to_format"): "
    case "$type" in
        c | h | cpp | hpp)
            clang-format-10 $flags "$file_to_format" 2>&1
            ;;
        py)
            python3 -m autopep8 $flags "$file_to_format" 2>&1
            ;;
        sv | v) 
            verible-verilog-format $flags "$file_to_format" 2>&1
            ;;
        vhd)
            vsg -f "$file_to_format" $flags 2>&1
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo -e "\033[32msuccess\033[0m"
        return 0
    else
        echo -e "\033[31mfailure\033[0m"
        return 1
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

    if run_formatter "$file_to_format" "$type" "$flags"; then
        echo ""
        echo "Success: action completed."
        return 0
    else
        echo ""
        echo "Error: action failed."
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
        echo "Error: No modified files found."
        return 1
    fi

    modified_count=$(echo "$modified_files" | wc -l)
    echo -e "Found $modified_count modified file(s):"
    for file in $modified_files; do
        echo " - $file"
    done
    echo ""

    root_dir=$(git rev-parse --show-toplevel)
    modified_files=$(echo "$modified_files" | sed "s|^|$root_dir/|")
    error_files=""

    case $action in
        format)
            echo "Start formatting:"
            ;;
        check)
            echo "Start checking:"
            ;;
    esac
    
    for file in $modified_files; do
        local type="${file##*.}"
        assign_flags "$action" "$type"
        if ! run_formatter "$file" "$type" "$flags"; then
            error_files="$error_files $file"
        fi
    done

    echo ""
    if [ -n "$error_files" ]; then
        echo "Error: action failed."
        return 1
    else
        echo "Success: action completed."
        return 0
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    header
    check_tools
    parse_args "$@"
fi
