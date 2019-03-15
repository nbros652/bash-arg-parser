#!/bin/bash
# process command line arguments
# Usage: This script is intended to be imported by other scripts using the "source" command
#        Once sourced by another script, the getArg function can be called to retrieve arguments by name
#        or the setArgVars function can be called to create varibles named in accordance with the argument
#        identifiers and assigned the values associated with those identifiers so long as the identifier 
#        represents a valid variable name. 

main() {
	while [ $# -gt 0 ]
	do
		if grep  '='  <<< "$1" | cut -f1 -d= | grep -qvP ' '; then
			key=$(cut -f1 -d= <<< "$1")
			value="${1:$[${#key}+1]}"
			args[$key]="$value"
			shift
		else
			key=$(grep -oP '[^-].*' <<< "$1")
			args[$key]="$2"
			shift
			shift
		fi
	done
}

getArg() {
	unset value
	for switch in $@
	do
		key="$(grep -oP "[^-].*" <<< "$switch")"
		[ -z "$value" ] && value="${args[$key]}"
	done
	echo "$value"
}

isValidVarName() {
    echo "$1" | grep -q '[_[:alpha:]][_[:alpha:][:digit:]]*' && return || return 1
}

setArgVars() {
	for key in ${!args[*]}
	do
		if isValidVarName $key; then
			eval "$key=${args[$key]}"
		else
			echo -e "Could not set $key=$value\n$key is not a valid variable name" >&2
		fi
	done
}

unset args
declare -A args
main "$@"
