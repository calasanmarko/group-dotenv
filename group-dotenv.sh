#!/bin/bash

DEFAULT_CONFIG_FILE="group-dotenv.yaml"

usage() {
    echo "Centrally manage multiple .env files"
    echo ""
    echo "Usage:"
    echo "  group-dotenv [-q]"
    echo "  group-dotenv <config-file> [-q]"
    echo "  group-dotenv pull <file1> <file2> ... [-q] [-o output-file]"
    echo ""
    echo "Options:"
    echo "  -q: Quiet mode (suppress output except for errors)"
    echo "  -o: Specify output file for the 'pull' command. Default is '$DEFAULT_CONFIG_FILE'."
    echo ""
    echo "Applies the given environment variables to the .env files specified in the config file."
    echo "By default, the script looks for '$DEFAULT_CONFIG_FILE' in the current directory."
}

QUIET_MODE=0
OUTPUT_FILE="$DEFAULT_CONFIG_FILE"

# Parsing -o flag
while getopts ":o:" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG";;
        \?) echo "Invalid option -$OPTARG" >&2; usage; exit 1;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage; exit 1;;
    esac
done
shift $((OPTIND -1))

if [[ "$#" -gt 1 && "${!#}" == "-q" ]]; then
    QUIET_MODE=1
    set -- "${@:1:$#-1}"
fi

if [[ "$1" == "pull" ]]; then
    shift
    files=("$@")
    declare -a variables
    declare -a mappings

    for file in "${files[@]}"; do
        while IFS= read -r line; do
            if [[ "$line" =~ ^[^#].*=.* ]]; then
                var="${line%=*}"
                val="${line#*=}"

                if [[ ! " ${variables[@]} " =~ " $var " ]]; then
                    variables+=("$var")
                fi

                mappings+=("$var $file:$val")
            fi
        done < "$file"
    done

    echo "variables:" > $OUTPUT_FILE
    for var in "${variables[@]}"; do
        echo "- name: $var" >> $OUTPUT_FILE
        echo "  values:" >> $OUTPUT_FILE
        for mapping in "${mappings[@]}"; do
            if [[ "$mapping" == "$var "* ]]; then
                file_val="${mapping#* }"
                file="${file_val%:*}"
                val="${file_val#*:}"
                echo "  - \"$file\": $val" >> $OUTPUT_FILE
            fi
        done
    done

    exit 0
fi

if [[ -z "$1" ]]; then
    CONFIG_FILE="$DEFAULT_CONFIG_FILE"
else
    CONFIG_FILE="$1"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file '$CONFIG_FILE' does not exist."
    echo ""
    usage
    exit 1
fi

process_variables() {
    local state="none"
    local current_var=""
    local current_file=""
    local current_value=""

    while read -r line; do
        if [[ $line =~ ^-.*name: ]]; then
            current_var=$(echo "$line" | sed 's/^- name: //')
            state="none"
        elif [[ $line =~ ^.*values: ]]; then
            state="var"
        elif [[ $state == "var" ]]; then
            current_file=$(echo "$line" | sed 's/[:space]*-//' | sed 's/^[[:space:]]*//;s/:.*//' | sed 's/"//g')
            current_value=$(echo "$line" | sed 's/.*: //')

            var_statement=$current_var=$current_value

            if [[ $1 == "CLEAR" ]]; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' '/^[^#]/d' "$current_file"
                else
                    sed -i '/^[^#]/d' "$current_file"
                fi
            else
                if [[ -z $old_statement ]]; then
                    if [[ $QUIET_MODE -eq 0 ]]; then
                        echo $current_file: $var_statement
                    fi
                    echo $var_statement >> $current_file
                fi
            fi
        fi
    done < "$CONFIG_FILE"
}

process_variables "CLEAR"
process_variables
