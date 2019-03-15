# bash-arg-parser
An argument parser for other bash scripts

Purpose and Incorporation
-----
This script facilitates the parsing of bash arguments and can handle arguments presented in a number of formats:
 * `-k value`
 * `--key value`
 * `-kVALUE` *<sub>(in this case, the switch is `-k` and the value is `VALUE`)</sub>*
 * `key=value`
 * `-k` *<sub>(a switch with no assigned value)</sub>*
 
*<sub>WARNING: do not mix -k, -kVALUE, or --key formatting with key=value formatting</sub>*
 
To utilize this script, simply place a copy of it in a path that can be accessed by your script. Then at the beginning of your bash script, include a line that reads `source /path/to/bash-arg-parser.sh`, filling in the actual path to the `bash-arg-parser.sh` script.

Functions of Note
-----------------
Once sourced by your bash script, this script exposes four functions of interest to your script:
 1. `getSwitches`: this function takes no arguments and simply returns a space-delimited list of switches that were used when you called your script.
 2. `getArg`: this function takes one or more switch names as arguments and outputs the value of the switch that was provided when the script was run. If more than one switch is provided to `getArg`, they are processed in alphabetical order, and the first one returning a value is outputted. If none of the provided switches were found, the function returns with a status that evaluates to false.
 3. `setArgVars`: this function takes no arguments and creates one variable for each switch. The names of the variables correspond to the names of the switches used not including any leading dashes. The value assigned to any given variable is the value associated with the switch of the same name. If the switch name is not also a valid variable name, then this is noted in stderr, and variable assignment is skipped.
 4. `hasSwitch`: this function accepts one or more arguments, the names of a switches. As soon as one is found to exist, it is outputted by the function and the function returns with a status that evaluates to true. If none of the switches were found, the function returns with a status that evaluates to false.
 
Examples
--------
<sub>`getSwitches` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source bash-arg-parser.sh
    echo "Switches: $(getSwitches)"
    
Output of Sample Code:

    $ ./script.sh -x 10 -y 20 -z 3
    Switches: x y z
&nbsp;  
&nbsp;  
<sub>`getArg` function</sub>
-----
Say you expect a switch that accepts text, `-t` or `--text` or `text=...`, the `getArg` function can be called with a single switch or a list of space-delimited switches to fetch the value for that switch. In the case of a switch that accepts no value, `getArg` outputs "true"

Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source bash-arg-parser.sh
    
    # define switches to look for
    stringSwitches="-s --string"
    asciiSwitches="-a --ascii"
    numberSwitches="-n --number"
    
    # use getArg to get values of switches
    argString="$(getArg $stringSwitches)"   # equivalent to getArg -s --string
    argAscii="$(getArg $asciiSwitches)"     # equivalent to getArg -a --ascii
    
    if [ ! -z "$argString" ]; then
        # a string was provided; print it to the terminal
        echo "String arg: $argString"
    else
        # no string was provided; report this to terminal
        echo "No string argument was provided; you can specify a string with -s, --string"
    fi
    
    if [ ! -z $argAscii ]; then
        # the ascii switch was included as an argument
        echo "ascii option enabled"
    else
        # the ascii switch was not included as an argument
        echo "ascii option disabled"
    fi
    
    # demo the identification of missing switches
    if num=$(getArg -n --number); then      # could have used $numberSwitches here
        echo "You chose the number $num"
    else
        echo "The -n and --number switches were omitted"
    fi
    
    
Output of Sample Code:

    $ ./script.sh -s "hello world" -n 10
    String arg: hello world
    ascii option disabled
    You chose the number 10
    
    $ ./script.sh -a --string "hello world"
    String arg: hello world
    ascii option enabled
    The -n and --number switches were omitted
    
    $ ./script.sh string="hello world"
    String arg: hello world
    ascii option disabled
    The -n and --number switches were omitted
    
    $ ./script.sh --ascii -n 4
    No string argument was provided; you can specify a string with -s, --string
    ascii option enabled
    You chose the number 4
&nbsp;  
&nbsp;  
<sub>`setArgVars` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source bash-arg-parser.sh
    
    # make two passes, printing the values of the variables that match the switch names.
    # Run setVarArgs on the second iteration
    for i in 0 1
    do
        if [ $i -eq 0 ]; then
            # first pass; don't run setArgVars yet
            echo -e "\nAs you can see, no switch variables have yet been set"
            echo "-----------------------------------------------------"
        else
            # second pass; run setArgVars
            setArgVars
            echo -e "\nNow the switch variables have been set"
            echo "--------------------------------------"
        fi
        for key in $(getSwitches)
        do
            echo "$key is equal to \"${!key}\""
        done
    done
    
    
Output of Sample Code:

    $ ./script.sh --string "hello world"
    
    As you can see, no switch variables have yet been set
    -----------------------------------------------------
    string is equal to ""

    Now the switch variables have been set
    --------------------------------------
    string is equal to "hello world"
    
    
    $ ./script.sh -x 5 -y 10 -n

    As you can see, no switch variables have yet been set
    -----------------------------------------------------
    n is equal to ""
    x is equal to ""
    y is equal to ""

    Now the switch variables have been set
    --------------------------------------
    n is equal to "true"
    x is equal to "5"
    y is equal to "10"


    $ ./script.sh greeting=hello name=tux
    
    As you can see, no switch variables have yet been set
    -----------------------------------------------------
    greeting is equal to ""
    name is equal to ""
    
    Now the switch variables have been set
    --------------------------------------
    greeting is equal to "hello"
    name is equal to "tux"
&nbsp;  
&nbsp;  
<sub>`hasSwitch` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh

    source bash-arg-parser.sh

    if switch=$(hasSwitch -n --number); then
        echo "I was looking for the -n or --number switch and found \"$switch\""
    else
        echo "I was looking for the -n or --number switch and could find neither"
    fi    
Output of Sample Code:

    $ ./script.sh -x 10
    I was looking for the -n or --number switch and could find neither
    
    $ ./script.sh -n 10
    I was looking for the -n or --number switch and found "n"
