#!/bin/bash
is_github_actions=false

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
                    flags="-i -a -a"
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
	return "$flags"
}

run_formatter() {
	local file_to_format="$1"
	local type="$2"
	local flags="$3"
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

	if [ $? -eq 0 ]; then
		echo -e " \033[32mSUCCESS\033[0m"
        return 0
    else
		echo -e " \033[31mFAILED\033[0m"
        echo "$output" | sed 's/^/  /'
		echo ""
        return 1
    fi
}

parse_args() {
	while [[ $# -gt 0 ]]; do
		local arg="$1"
		case $arg in
			-f)
				if [[ -z $2 || $2 == -* ]]; then
					echo "Option -f requires an argument." >&2
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
					echo "Option -c requires an argument." >&2
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
				return 1
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
		format_all
	elif [ -n "$file_to_format" ]; then
		format_file $action $file_to_format
	else
		usage
		return 1
	fi
}

format_file() {
	local action="$1"
	local file_to_format="$2"

	if [ ! -f "$file_to_format" ]; then
		echo "$0: Error: File '$file_to_format' not found." >&2
		return 1
	fi

	local type="${file_to_format##*.}"
	flags=$(assign_flags $action $type)

	case $action in
		format)
			echo -n "Formatting $file_to_format..."
			;;
		check)
			echo -n "Checking $file_to_format..."
			;;
	esac

	if run_formatter "$file_to_format" "$type" "$flags"; then
		echo -e "\U00002728 $action""ing done!"
		return 0
	else
		echo -e "\u274C $action""ing failed!"
		return 1
	fi	
}

format_all() {
	if [ "$is_github_actions" = true ]; then
		modified_files=$(git diff --name-only HEAD^..HEAD \
			| grep -E '\.(c|h|cpp|hpp|py|v|sv|vhd)$')
	else
		modified_files=$(git status --porcelain \
			| grep -E '^ M|^??' \
			| awk '$2 ~ /\.(c|h|cpp|hpp|py|v|sv|vhd)$/ {print $2}')
	fi

	if [ -z "$modified_files" ]; then
		echo -e "No modified files found."
		return 0
	fi

	modified_count=$(echo "$modified_files" | wc -l)
	echo -e "\U0001F50E Found $modified_count modified files:"
	echo ""
	for file in $modified_files; do
		echo "   - $file"
	done
	echo ""
	root_dir=$(git rev-parse --show-toplevel)
	modified_files=$(echo "$modified_files" | sed "s|^|$root_dir/|")

	error_files=""
	success_files=""

	for file in $modified_files; do
		case $action in
			format)
				echo -n "Formatting $(basename "$file")..."
				;;
			check)
				echo -n "Checking $(basename "$file")..."
				;;
		esac
		
		if ! format_file "$file" "$action"; then
			error_files="$error_files $file"
		fi
	done

	echo ""
	if [ -n "$error_files" ]; then
		echo -e "\u274C $action""ing failed!"
		exit 1
	else
		echo -e "\U00002728 $action""ing done!"
		exit 0
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_args "$@"
fi