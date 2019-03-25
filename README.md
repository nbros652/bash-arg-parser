# bash-arg-parser
An argument parser for other bash scripts and functions within those scripts

Purpose and Incorporation
-----
This script facilitates the parsing of bash arguments presented to scripts and functions within scripts and can handle arguments that are passed in the following formats:
 * `-k value`
 * `--key value`
 * `-kVALUE` *<sub>(in this case, the switch is `-k` and the value is `VALUE`)</sub>*
 * `key=value`
 * `-k` *<sub>(a switch with no assigned value)</sub>*
 
*<sub>WARNING: do not mix -k, -kVALUE, or --key formatting with key=value formatting</sub>*
 
To utilize this script, simply place a copy of argParser.sh in the same path as your script. Then at the beginning of your bash script, include a line that reads `source argParser.sh`. Once you've done this, you're ready to start interacting with switches that were used to call your script or functions within your script.

Functions of Note
-----------------
With argParser.sh sourced by your bash script, four functions of interest will have been created for querying switches. If they are called by a script from within the main body of the script, they will return information about the switches used when the script was run. If they are called from within a function in that same script, they will return information about the switches used when calling that function. Here are the functions for querying switches:
 1. `argParser.getSwitches`: this function takes no arguments and simply returns a space-delimited list of switches that were used with the calling script or function.
 2. `argParser.getArg`: this function takes one or more switch names as arguments and outputs the value of the switch that was provided when the script/function was run/called. If more than one switch is provided to **argParser.getArg**, they are processed in the order in which they were passed to **argParser.getArg**, and only the value associated with the first one is outputted. If none of the provided switches were found, this function returns with a status that evaluates to false.
 3. `argParser.setArgVars`: this function takes no arguments and creates one variable for each switch that was passed to the calling script/function. The names of the variables correspond to the names of the switches used, not including leading dashes. The value assigned to each variable is the value associated with the switch of the same name. If the switch name is not also a valid variable name, then this is noted in stderr, and variable assignment is skipped.
 4. `argParser.hasSwitches`: this function accepts one or more arguments, names of switches. All switches that are found to have been supplied as arguments to the calling script/function are outputted, and this function returns with a status that evaluates to true. If none of the switches were found, this function returns with a status that evaluates to false.
 5. `argParser.getMissingSwitches`: this function accepts one or more arguments, names of switches. These are the required switches. The list of required switches is compared to the list of switches that were provided to the calling script/function, the caller switches. Any required switches not included in the caller switches are considered to be missing switches. A space-delimited list of only the missing switches is outputted. If there were missing switches, this function evaluates to true. Otherwise, it evaluates to false.
 
Examples
--------
<sub>`argParser.getSwitches` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source argParser.sh
    echo "Switches: $(argParser.getSwitches)"
    
Output of Sample Code:

    $ ./script.sh -x 10 -y 20 -z 3
    Switches: -z -y -x
&nbsp;  
&nbsp;  
<sub>`argParser.getArg` function</sub>
-----
Say you expect a switch that accepts text, `-t` or `--text` or `text=...`, the `getArg` function can be called with a single switch or a list of space-delimited switches to fetch the value for that switch. In the case of a switch that accepts no value, `getArg` outputs "true"

Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source argParser.sh
    
    # define switches to look for
    stringSwitches="-s --string"
    asciiSwitches="-a --ascii"
    numberSwitches="-n --number"
    
    # use getArg to get values of switches
    argString="$(argParser.getArg $stringSwitches)"   # equivalent to getArg -s --string
    argAscii="$(argParser.getArg $asciiSwitches)"     # equivalent to getArg -a --ascii
    
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
    if num=$(argParser.getArg -n --number); then      # could have used $numberSwitches here
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
    
    $ ./script.sh --ascii -n4
    No string argument was provided; you can specify a string with -s, --string
    ascii option enabled
    You chose the number 4
&nbsp;  
&nbsp;  
<sub>`argParser.setArgVars` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source argParser.sh
    
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
            argParser.setArgVars
            echo -e "\nNow the switch variables have been set"
            echo "--------------------------------------"
        fi
        for key in $(argParser.getSwitches)
        do
            varName=$(grep -oP '[^-].*' <<< "$key")
            if argParser.isValidVarName "$varName"; then
                echo "$key is equal to \"${!varName}\""
            else
                echo "Cannot evaluate $varName; the name is invalid"
            fi
        done
    done
    
    
Output of Sample Code:

    $ ./script.sh --string "hello world"
    
    As you can see, no switch variables have yet been set
    -----------------------------------------------------
    --string is equal to ""
    
    Now the switch variables have been set
    --------------------------------------
    --string is equal to "hello world"
    
    
    $ ./script.sh -x 5 -y 10 -n --3x three-x-val
    
    As you can see, no switch variables have yet been set
    -----------------------------------------------------
    Cannot evaluate 3x; the name is invalid
    -n is equal to ""
    -x is equal to ""
    -y is equal to ""
    Could not set 3x=three-x-val
    3x is not a valid variable name
    
    Now the switch variables have been set
    --------------------------------------
    Cannot evaluate 3x; the name is invalid
    -n is equal to "true"
    -x is equal to "5"
    -y is equal to "10"
    

    $ ./script.sh greeting=hello name=tux
    
    As you can see, no switch variables have yet been set
    -----------------------------------------------------
    name is equal to ""
    greeting is equal to ""
    
    Now the switch variables have been set
    --------------------------------------
    name is equal to "tux"
    greeting is equal to "hello"
&nbsp;  
&nbsp;  
<sub>`argParser.hasSwitches` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh

    source argParser.sh

    if switch=$(argParser.hasSwitches -n --number); then
        echo "I was looking for the -n or --number switch and found \"$switch\""
    else
        echo "I was looking for the -n or --number switch and could find neither"
    fi    
Output of Sample Code:

    $ ./script.sh -x 10
    I was looking for the -n or --number switch and could find neither
    
    $ ./script.sh -n 10
    I was looking for the -n or --number switch and found "-n"
&nbsp;  
&nbsp;
<sub>`argParser.getMissingSwitches` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source argParser.sh
    
    echo "The -x -y -z switches are required; looking for missing switches"
    if missing=$(argParser.getMissingSwitches -x -y -z); then
    	# we found missing switches
    	echo "Missing switch(es): $missing"
    	exit
    fi
Output of Sample Code:

    $ ./script.sh .sh -x 10 -n
    The -x -y -z switches are required; looking for missing switches
    Missing switch(es): -y -z
&nbsp;  
&nbsp;  
<sub>Using an argParser within a function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    # pull in the arg parser
    source argParser.sh
    
    # demonstrate the functionality of the argParser functions from the main script
    echo "+----------------------------------------------+"
    echo "|                Script Context                |"
    echo "+----------------------------------------------+"
    
    # load switches used and display
    switches=$(argParser.getSwitches)
    echo "Script switches: $switches"
    
    # set variables by switch name
    argParser.setArgVars
    
    # iterate over switches and make a call to argParser.getArg for each
    # also print the variable assigned when argParser.getArgVars was called
    # to demo that both of these functions work
    for switch in $switches
    do
    	argVal=$(argParser.getArg $switch)
    	var=${switch//-/}
    	echo "$switch --> getArg val: $argVal; setArgVars val: ${!var}"
    done
    
    # print whether or not a -n --number or "n" switch was used
    s=$(argParser.hasSwitches -n --number n) && echo "has number switch: $s" || echo "doesn't have number switch"
    
    # now demonstrate the same functionality of the argParser functions from within a function
    # as we perform the same steps from above, I'm not going to duplicate comments here
    func() {
    	echo
    	echo "+----------------------------------------------+"
    	echo "|               Function Context               |"
    	echo "+----------------------------------------------+"
            switches=$(argParser.getSwitches)
            argParser.setArgVars
    	echo "function switches: $switches"
            argParser.setArgVars
    	for switch in $switches
    	do
    	        argVal=$(argParser.getArg $switch)
    	        var=${switch//-/}
    	        echo "$switch --> getArg val: $argVal; setArgVars val: ${!var}"
    	done
    	s=$(argParser.hasSwitches -n --number n) && echo "has number switch: $s" || echo "doesn't have number switch"
    }
    
    # call func to force the demo of argParser in a function
    func -x10 -y3 -z7
    
    # jump back to the main script and demo that we can still access the switches there
    # after having used them inside a function.
    echo
    echo "+----------------------------------------------+"
    echo "|            Back to Script Context            |"
    echo "+----------------------------------------------+"
    
    # just reprint the switches that were passed to the script when it was first run
    echo "Switches passed to script: $(argParser.getSwitches)"

Output of Sample Code (note the script is called with `n=4 t=0` and the function is called with `-x -y -z`):

    $ ./script.sh n=4 t=0

    +----------------------------------------------+
    |                Script Context                |
    +----------------------------------------------+
    Script switches: t n 
    t --> getArg val: 0; setArgVars val: 0
    n --> getArg val: 4; setArgVars val: 4
    has number switch: n
    
    +----------------------------------------------+
    |               Function Context               |
    +----------------------------------------------+
    function switches: -x -y -z 
    -x --> getArg val: 10; setArgVars val: 10
    -y --> getArg val: 3; setArgVars val: 3
    -z --> getArg val: 7; setArgVars val: 7
    doesn't have number switch
    
    +----------------------------------------------+
    |            Back to Script Context            |
    +----------------------------------------------+
    Switches passed to script: t n
    
How it works
--------
Most scripts that attempt to tackle the task of parsing switches without `getopts` do so using the `$@` variable. I chose a slightly different approach. My script turns on extended debugging which gives access to a calling-function stack and all the arguments passed to each function in the stack. This is useful because it enables me to walk back up through the function stack to the caller and then inspect the switches that pertain only to the caller. This enables me to dynamically access the switches for the scope I am currently in. If I'm in a function, it examines the arguments passed to that function. If I am in the main body of a script, it examines the arguments that were passed to the script itself. Furthermore, if the current shell parses arguments for a given scope (script/function). These get cached so that they do not need to be parsed again later if the existing shell instance wants to refer back to that scope at a later time.

The other functions
----------
The other functions in **argParser.sh** are helper functions that work for the four primary functions. Running some of these functions from your own script may have unintended side affects and is not recommended!

However, there are two functions that could be useful outside of the context of argParser.sh. Running the following functions should not be an issue:
 1. `argParser.cloneArray`: This function clones an associative array. It takes two arguments, *name_of_source_array* and *name_of_destination_array*, in that order.
 2. `argParser.isValidVarName`: This function takes a single argument, a string and determines if that string can be used as a variable name. If it can, the function evaluates to true. If it can't, the function evaluates to false.
