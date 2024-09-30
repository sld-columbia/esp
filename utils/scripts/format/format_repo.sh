#!/bin/bash

RED='\033[31m'
GREEN='\033[32m'
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
    echo ""
    echo "  -t, --type <file type>     Specify the type of files to format."
	echo ""
    echo "                             Supported file types:"
    echo "                             c      - C source files"
    echo "                             cpp    - C++ source files"
    echo "                             vhdl   - VHDL source files"
    echo "                             v      - Verilog source files"
    echo "                             py     - Python source files"
    echo ""
}


is_submodule() {
  local dir="$1"
  local gitmodules="$2"
  local cwd="$3"
  local rel_dir="${dir#$cwd/}"

  grep -q "\[submodule \"$rel_dir\"\]" "$gitmodules"
}


descend_and_format() {
  local dir="$1"
  local gitmodules="$2"
  local cwd="$3"
  local format_style="$4"

  "$format_style" "$dir"

  # Traverse all directories under /esp
  for item in "$dir"/*; do
    if [[ -d "$item" ]]; then
      # If directory is a submodule, skip unless its sld-owned, then recurse
      if is_submodule "$item" "$gitmodules" "$cwd"; then
		case "$item" in
			*/rtl/caches/esp-caches|*/accelerators/stratus_hls/common/inc|*/rtl/caches/spandex-caches)
				descend_and_format "$item" "$gitmodules" "$cwd" "$format_style"
				;;
			*)
				continue
				;;
			esac
        continue
      fi
      descend_and_format "$item" "$gitmodules" "$cwd" "$format_style"
    fi
  done
}

# Find all .c and .h files in the current directory
find_c_h_files() {
  local dir="$1"
  for file in "$dir"/*.c "$dir"/*.h; do
  	local output
    if [[ -f "$file" ]]; then
	  echo -n "Formatting $(basename "$file")..."
      output=$(clang-format-10 -i "$file" 2>&1)
	  if [ ! $? -eq 0 ]; then
		echo -e " ${RED}FAILED${NC}"
		echo "$output" | sed 's/^/  /'
		echo ""
        return 1
      else
		echo -e " ${GREEN}SUCCESS${NC}"
		echo ""
        return 0
    fi
    fi
  done
}

# Find all .cpp and .hpp files in the current directory
find_cpp_hpp_files() {
  local dir="$1"
  for file in "$dir"/*.cpp "$dir"/*.hpp; do
    if [[ -f "$file" ]]; then
	  echo -n "Formatting $(basename "$file")..."
      output=$(clang-format-10 -i "$file" 2>&1)
	  if [ ! $? -eq 0 ]; then
		echo -e " ${RED}FAILED${NC}"
		echo "$output" | sed 's/^/  /'
		echo ""
        return 1
      else
		echo -e " ${GREEN}SUCCESS${NC}"
		echo ""
        return 0
      fi
    fi
  done
}

# Find all .py files in the current directory
find_py_files() {
  local dir="$1"
  local output
  for file in "$dir"/*.py; do
    if [[ -f "$file" ]]; then
	  echo -n "Formatting $(basename "$file")..."
	  output=$(python3 -m autopep8 -i -a -a "$file" 2>&1)
	  if [ ! $? -eq 0 ]; then
		echo -e " ${RED}FAILED${NC}"
		echo "$output" | sed 's/^/  /'
		echo ""
        return 1
      else
		echo -e " ${GREEN}SUCCESS${NC}"
		echo ""
        return 0
      fi
    fi
  done
}

# Find .v files in the current directory
find_v_files() {
  local dir="$1"
  local output
  for file in "$dir"/*.v "$dir"/*.sv; do
    if [[ -f "$file" ]]; then
	  echo -n "Formatting $(basename "$file")..."
 	  output=$(verible-verilog-format --inplace --port_declarations_alignment=preserve -assignment_statement_alignment=align --indentation_spaces=4 "$file" 2>&1)
	  if [ ! $? -eq 0 ]; then
		echo -e " ${RED}FAILED${NC}"
		echo "$output" | sed 's/^/  /'
		echo ""
        return 1
      else
		echo -e " ${GREEN}SUCCESS${NC}"
		echo ""
        return 0
      fi
	fi
  done
}

# Function to find .vhd files in the current directory
find_vhd_files() {
  local dir="$1"
  local output
  for file in "$dir"/*.vhd; do
    if [[ -f "$file" ]]; then
	  echo -n "Formatting $(basename "$file")..."
	  output=$(vsg -f "$file" --fix -c ~/esp/vhdl-style-guide.yaml -of summary 2>&1)
	  if [ ! $? -eq 0 ]; then
		echo -e " ${RED}FAILED${NC}"
		echo "$output" | sed 's/^/  /'
		echo ""
        return 1
      else
		echo -e " ${GREEN}SUCCESS${NC}"
		echo ""
        return 0
      fi
    fi
  done
}

# Get cwd and gitmodules
cwd="$(git rev-parse --show-toplevel)"
gitmodules="$cwd/.gitmodules"

parse_args() {

    format_style=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t | --type )
                shift
                case "$1" in
                    c )
                        format_style="find_c_h_files"
                        ;;
                    cpp )
                        format_style="find_cpp_hpp_files"
                        echo "Starting formatting for C++ files ..."
                        echo -e "This should be quick! \U0001F680"
                        ;;
                    vhdl )
                        format_style="find_vhd_files"
                        echo "Starting formatting for VHDL files ..."
                        echo -e "This may take a while, be patient! \U0001F691"
                        ;;
                    v )
                        format_style="find_v_files"
                        echo "Starting formatting for Verilog/SystemVerilog files ..."
                        echo -e "This may take a while, be patient. \U0001F691"
                        ;;
                    py )
                        format_style="find_py_files"
                        echo "Starting formatting for Python files ..."
                        echo -e "This should be quick! \U0001F680"
                        ;;
                    * )
                        echo "Invalid formatting option. Valid options include: c, cpp, vhdl, v, py"
                        usage
                        exit 1
                        ;;
                esac
                ;;
            -h | --help )
                usage
                exit 0
                ;;
            * )
                echo "Invalid option: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
    
    echo ""
    
    if [ -z "$format_style" ]; then
        echo "No format type specified. Use -t to define the file type."
        usage
        exit 1
    fi
}

# Check if format_style is set
if [ -z "$format_style" ]; then
  echo "Error: Missing formatting style. Use -t {c, cpp, vhdl, v, py}."
  usage
  exit 1
fi

# descend_and_format "$cwd" "$gitmodules" "$cwd" "$format_style"
# echo ""
# echo ""
# echo -e "✨ Formatting complete!"