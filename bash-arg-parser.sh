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
			bap_key=$(cut -f1 -d= <<< "$1")
			bap_value="${1:$[${#bap_key}+1]}"
			bap_args[$bap_key]="$bap_value"
			shift
		else
			bap_key="$1"
			if grep -q '^[^-]' <<< "$2"; then
				bap_args[$bap_key]="$2"
				shift
				shift
			else
				if grep -q '^-[^-]' <<< "$bap_key"; then
					bap_keyLen=${#bap_key}
					if [ $bap_keyLen -gt 2 ]; then
						bap_value=${bap_key:2}
					else
						bap_value='true'
					fi
					bap_key=${bap_key:0:2}
					bap_args[$bap_key]="$bap_value"
				else
					bap_args[$bap_key]='true'
				fi
				shift
			fi
		fi
	done
}

# getSwitches(): returns a space-delimited list of switches that were used
getSwitches() {
	# cannot use echo because it will fail in some cases
	tee /dev/null <<< ${!bap_args[*]}
}

# hasSwitch(): expects one or more space-delimited switches. Outputs a space-delimited list of all
#	matching switches that were used. If at least one switch as found, this function returns
#	with a status that evaluates to true. If none were found, this function returns with a
#	status that evaluates to false.
hasSwitches() {
	unset bap_switchFound
	bap_testSwitches="$@"
	bap_includedSwitches="$(getSwitches)"
	if bap_foundSwitches="$(grep -oP "(${bap_includedSwitches// /|})( |$)" <<< "$bap_testSwitches")"; then
		# print out a space-delimited list of switches found; we can't use echo for this because
		# it will lie if only a single switches is returned and is one of the following: -e -E -n
		cat <<< "$bap_foundSwitches" | sed 's/ $//' | tr '\n' ' ' | sed 's/ $//' && echo
		return
	else
		return 1
	fi
}

# getArg(): accepts one or more switches and returns the associated value for the
#	first-occuring switch that was passed to getArg. So long as the switch was
#	found, the function returns with a status that evaluates to true, otherwise
#	it returns with a status that evaluates to false.
getArg() {
	unset bap_value
	if bap_switches=$(hasSwitches $@); then
		bap_firstMatchingSwitch=$(cut -f1 -d' ' <<< "$bap_switches")
		echo "${bap_args[$bap_firstMatchingSwitch]}"
		return
	fi
	return 1
}

# isValidVarName(): helper function for setArgVars(); not intended to be called otherwise
isValidVarName() {
    echo "$1" | grep -q '^[_[:alpha:]][_[:alpha:][:digit:]]*$' && return || return 1
}

# setArgVars(): iterates through args and creates variables named according to the switches with
#	values that correspond to the values of the switches
setArgVars() {
	for bap_key in ${!bap_args[*]}
	do
		bap_varName=$(grep -oP '[^-].*' <<< "$bap_key")
		bap_value="${bap_args[$bap_key]}"
		if isValidVarName $bap_varName; then
			eval "$bap_varName=\"$bap_value\""
		else
			echo -e "Could not set $bap_varName=$bap_value\n$bap_varName is not a valid variable name" >&2
		fi
	done
}

# when sourced, be sure to set up the assoc array and run the main function
unset bap_args
declare -A bap_args
main "$@"
