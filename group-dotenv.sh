#!/bin/bash

DEFAULT_CONFIG_FILE="group-dotenv.yaml"

usage() {
    echo "Centrally manage multiple .env files"
    echo ""
    echo "Usage:"
    echo "  group-dotenv [-q]"
    echo "  group-dotenv <config-file> [-q]"
    echo ""
    echo "Options:"
    echo "  -q: Quiet mode (suppress output except for errors)"
    echo ""
    echo "Applies the given environment variables to the .env files specified in the config file."
    echo "By default, the script looks for '$DEFAULT_CONFIG_FILE' in the current directory."
}

QUIET_MODE=0

if [[ "$#" -gt 1 && "${!#}" == "-q" ]]; then
    QUIET_MODE=1
    set -- "${@:1:$#-1}"
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
            current_file=$(echo "$line" | sed 's/.*-//' | sed 's/^[[:space:]]*//;s/:.*//' | sed 's/"//g')
            current_value=$(echo "$line" | sed 's/.*: //')

            var_statement=$current_var=$current_value
            old_statement=$(grep -m 1 "^$current_var=" $current_file)

            if [[ $var_statement != $old_statement ]]; then
                if [[ -z $old_statement ]]; then
                    if [[ $QUIET_MODE -eq 0 ]]; then
                        echo $current_file: $var_statement
                    fi
                    echo $'\n'$var_statement >> $current_file
                else
                    if [[ $QUIET_MODE -eq 0 ]]; then
                        echo $current_file: $old_statement '->' $var_statement
                    fi
                    echo $ZSH_VERSION

                    if sed --version 2>&1 | grep -q GNU; then
                        sed -i "s/$current_var=.*/$var_statement/g" $current_file
                    else
                        sed -i '' "s/$current_var=.*/$var_statement/g" $current_file
                    fi
                fi
            fi
        fi
    done < "$CONFIG_FILE"
}

process_variables
