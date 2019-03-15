#!/bin/bash
# process command line arguments
# Usage: This script is intended to be imported by other scripts using the "source" command
#        Once sourced by another script, the getArg function can be called to retrieve arguments by name
#        or the setArgVars function can be called to create varibles named in accordance with the argument
#        identifiers and assigned the values associated with those identifiers so long as the identifier 
#        represents a valid variable name. 


# main(): parses provided command line arguments and saves in an assoc array
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
			if grep -q '^[^-]' <<< "$2"; then
				args[$key]="$2"
				shift
				shift
			else
				args[$key]='true'
				shift
			fi
		fi
	done
}

# getSwitches(): returns a space-delimited list of provided switches
getSwitches() {
	echo ${!args[*]}
}

# getArg(): accepts one or more switches and returns the associated value for that switch
getArg() {
	unset value
	unset switchExists
	for switch in $@
	do
		key="$(grep -oP "[^-].*" <<< "$switch")"
		[[ "$(getSwitches)" =~ (^|[[:space:]])$key([[:space:]]|$) ]] && switchExists=1
		[ -z "$value" ] && value="${args[$key]}"
	done
	[ ! -z $switchExists ] && echo "$value" || return 1
}

# isValidVarName(): helper function for setArgVars(); not intended to be called otherwise
isValidVarName() {
    echo "$1" | grep -q '[_[:alpha:]][_[:alpha:][:digit:]]*' && return || return 1
}

# setArgVars(): iterates through args and creates variables named according to the switches with
#	values that correspond to the values of the switches
setArgVars() {
	for key in ${!args[*]}
	do
		if isValidVarName $key; then
			eval "$key=\"${args[$key]}\""
		else
			echo -e "Could not set $key=$value\n$key is not a valid variable name" >&2
		fi
	done
}

unset args
declare -A args
main "$@"
