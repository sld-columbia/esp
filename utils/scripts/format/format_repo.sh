#!/bin/bash

RED='\033[31m'
GREEN='\033[32m'
BOLD='\033[1m'
RESET='\033[0m'
BLUE='\033[34m'
YELLOW='\033[33m'

header() {
    echo ""
    echo "    ______    _____    _____  "
    echo "   |  ____| /  ___ |  |  __  \ "
    echo "   | |__    | (___    | |__) |"
    echo "   |  __|   \ ___  \  |  ___/ "
    echo "   | |____   ____) |  | |     "
    echo "   |______| |_____/   |_|     "
    echo ""
    echo "   R E P O  F O R M A T T E R"
    echo "   ___________________________"
    echo ""
}

usage() {
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                 Display this help message"
    echo "  -t, --type <file type>     Specify the type of files to format."
    echo ""
    echo "Supported file types:"
    echo "  c      - C source files"
    echo "  cpp    - C++ source files"
    echo "  vhdl   - VHDL source files"
    echo "  v      - Verilog source files"
    echo "  py     - Python source files"
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
        echo -e "${RED}${BOLD}ERROR:${RESET} The following required tools are not installed or not defined in PATH:"
        for tool in "${missing_tools[@]}" ; do
            echo -e "  - $tool${RESET}"
        done
        echo ""
        echo -e "${BOLD}Please install the missing tools before proceeding.${RESET}"
        exit 1
    fi
}

is_submodule() {
    local dir="$1"
    local submodule_paths
    local resolved_path

	dir=$(realpath "$dir")
    submodule_paths=$(git config --file "$cwd"/.gitmodules --get-regexp path | awk '{print $2}')

    if [[ -L "$dir" ]]; then
        resolved_path=$(readlink -f "$dir")
        for submodule in $submodule_paths; do
            if [[ "$resolved_path" == *"$submodule"* ]]; then
                return 1
            fi
        done
    fi

    if [[ "$dir" == *"rtl/caches/esp-caches"* || 
          "$dir" == *"rtl/caches/spandex-caches"* || 
          "$dir" == *"accelerators/stratus_hls/common/inc"* ]]; then
        return 0
    fi

    for submodule in $submodule_paths; do
        if [[ "$dir" == *"$submodule"* ]]; then
            return 1
        fi
    done

    return 0
}


cwd="$(git rev-parse --show-toplevel)"

format_all() {
    local dir="$1"
    local flags="$2"
    local extension="$3"
    local formatter="$4"

    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            if ! is_submodule "$item"; then
                echo ""
                echo -e "${BOLD}${YELLOW}WARNING:${RESET} Submodule skipped - $item"
            else
                format_all "$item" "$flags" "$extension" "$formatter"
            fi
        else
            format_file "$item" "$flags" "$extension" "$formatter"
        fi
    done
}

format_file() {
    local file="$1"
    local flags="$2"
    local extension="$3"
    local formatter="$4"

    local output
    if [[ -f "$file" ]]; then
        file_extension="${file##*.}"

        if [[ " ${extension[*]} " == *" $file_extension "* ]]; then
            echo ""
            echo -e "${BOLD}${BLUE}INFO:${RESET} Formatting file - $file"
            output=$($formatter $flags "$file" 2>&1)
            local status=$?
            if [[ $status -ne 0 ]] || echo "$output" | grep -qE "warning|error"; then
                echo -n -e "${RED}${BOLD}ERROR${RESET}:"
                echo "$output"
                return 1
            else
                echo -e " - $(basename "$file"): ${GREEN}${BOLD}SUCCESS${RESET}"
            fi
        fi
    fi
}

assign_formatter() {
    local type="$1"
    
    case "$type" in
        c | h | cpp | hpp)
            flags="-i"
            extension=("c" "h" "cpp" "hpp")
            formatter="clang-format-10"
            ;;
        py)
            flags="-iaaa"
            extension=("py")
            formatter="python3 -m autopep8"
            ;;
        sv | v)
            flags="--inplace --port_declarations_alignment=preserve \
                    --assignment_statement_alignment=align --indentation_spaces=4"
            extension=("sv" "v" "svh" "vh")
            formatter="verible-verilog-format"
            ;;
        vhd)
            flags="--fix -c ~/esp/vhdl-style-guide.yaml"
            extension=("vhd")
            formatter="vsg"
            ;;
        *)
            usage
            echo ""
            echo -e "${RED}ERROR:${RESET} Type '$type' is unknown." >&2
            return 1
            ;;
    esac
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        local arg="$1"
        case $arg in
            -t | --type )
                type="$2"
                if [[ -z $type || $type == -* ]]; then
                    usage
                    echo ""
                    echo -e "${RED}${BOLD}ERROR:${RESET} Option '-t', '--type' requires an argument <file type>." >&2
                    return 1
                fi
                assign_formatter "$type"
                shift
                ;;
            -h | --help )
                usage
                return 0
                ;;
            * )
                usage
                echo ""
                echo -e "${RED}${BOLD}ERROR:${RESET} Option '$1' is unknown." >&2
                return 1
                ;;
        esac
        shift
    done

    if [[ -z "$flags" || -z "$extension" || -z "$formatter" ]]; then
      usage
      return 1
    else
      echo -e "${BOLD}${BLUE}INFO:${RESET} Starting formatting process for ${extension[*]} files..."
      format_all "$cwd" "$flags" "${extension[*]}" "$formatter"
      echo -e "${BOLD}${GREEN}INFO:${RESET} Formatting process completed."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    header
    check_tools
    parse_args "$@"
fi
