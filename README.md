# bash-arg-parser
An argument parser for other bash scripts and functions within those scripts

Purpose and Incorporation
-----
These scripts facilitate the parsing of bash arguments presented to scripts and functions within scripts and can handle arguments presented in the following formats:
 * `-k value`
 * `--key value`
 * `-kVALUE` *<sub>(in this case, the switch is `-k` and the value is `VALUE`)</sub>*
 * `key=value`
 * `-k` *<sub>(a switch with no assigned value)</sub>*
 
*<sub>WARNING: do not mix -k, -kVALUE, or --key formatting with key=value formatting</sub>*
 
To utilize these scripts, simply place copies of argParser.h and argParser.class in the same path as your script. Then at the beginning of your bash script, include a line that reads `source argParser.h`. Then you must create an argParser "object" (it's not a true object) by including a line like this `argParser scriptArgs`, where `scriptArgs` could be anything you want it to be.

If you want to use this in your functions, you do *not* need to include `source argParser.h` again. All you need to do is create another argParser "object" inside the function. Something like `argParser funcArgs`, where `funcArgs` could be any name other than that which you have already used would be sufficient.

Functions of Note
-----------------
Once argParser.h has been sourced by your bash script and you've created an argParser, four functions of interest will have been created. These are called like this *object_name*.*function_name* (eg. scriptArgs.getSwitches):
 1. `getSwitches`: this function takes no arguments and simply returns a space-delimited list of switches that were used when you called your script.
 2. `getArg`: this function takes one or more switch names as arguments and outputs the value of the switch that was provided when the script was run. If more than one switch is provided to `getArg`, they are processed in alphabetical order, and the first one returning a value is outputted. If none of the provided switches were found, the function returns with a status that evaluates to false.
 3. `setArgVars`: this function takes no arguments and creates one variable for each switch. The names of the variables correspond to the names of the switches used not including any leading dashes. The value assigned to any given variable is the value associated with the switch of the same name. If the switch name is not also a valid variable name, then this is noted in stderr, and variable assignment is skipped.
 4. `hasSwitches`: this function accepts one or more arguments, the names of a switches. All switches that were found to have been supplied as arguments are outputted by the function and the function returns with a status that evaluates to true. If none of the switches were found, the function returns with a status that evaluates to false.
 
Examples
--------
<sub>`getSwitches` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source argParser.h
    argParser scriptArgs
    echo "Switches: $(scriptArgs.getSwitches)"
    
Output of Sample Code:

    $ ./script.sh -x 10 -y 20 -z 3
    Switches: -z -y -x
&nbsp;  
&nbsp;  
<sub>`getArg` function</sub>
-----
Say you expect a switch that accepts text, `-t` or `--text` or `text=...`, the `getArg` function can be called with a single switch or a list of space-delimited switches to fetch the value for that switch. In the case of a switch that accepts no value, `getArg` outputs "true"

Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source argParser.h
    argParser scriptArgs
    
    # define switches to look for
    stringSwitches="-s --string"
    asciiSwitches="-a --ascii"
    numberSwitches="-n --number"
    
    # use getArg to get values of switches
    argString="$(scriptArgs.getArg $stringSwitches)"   # equivalent to getArg -s --string
    argAscii="$(scriptArgs.getArg $asciiSwitches)"     # equivalent to getArg -a --ascii
    
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
    if num=$(scriptArgs.getArg -n --number); then      # could have used $numberSwitches here
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
<sub>`setArgVars` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh
    
    source argParser.h
    argParser scriptArgs
    
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
            scriptArgs.setArgVars
            echo -e "\nNow the switch variables have been set"
            echo "--------------------------------------"
        fi
        for key in $(scriptArgs.getSwitches)
        do
            varName=$(grep -oP '[^-].*' <<< "$key")
            if scriptArgs.isValidVarName "$varName"; then
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
    string is equal to ""

    Now the switch variables have been set
    --------------------------------------
    string is equal to "hello world"
    
    
    $ ./script.sh -x 5 -y 10 -n --3x three-x-val

    As you can see, no switch variables have yet been set
    -----------------------------------------------------
    -y is equal to ""
    -x is equal to ""
    -n is equal to ""
    Cannot evaluate 3x; the name is invalid
    Could not set 3x=three-x-val
    3x is not a valid variable name
    
    Now the switch variables have been set
    --------------------------------------
    -y is equal to "10"
    -x is equal to "5"
    -n is equal to "true"
    Cannot evaluate 3x; the name is invalid


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
<sub>`hasSwitches` function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh

    source argParser.h
    argParser scriptArgs

    if switch=$(scriptArgs.hasSwitches -n --number); then
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
<sub>Using an argParser within a function</sub>
-----
Sample Code:

    #!/bin/bash
    # filename: script.sh

    source argParser.h
    argParser scriptArgs

    func() {
        argParser funcArgs
        echo "                 ____________________"
        echo "----------------| function arguments |----------------"
        echo "                 --------------------"
        for switch in $(funcArgs.getSwitches)
        do
            echo "switch: $switch => value: $(funcArgs.getArg $switch)"
        done
    }
    
    func --fn1 --fn2 20
    
    echo -e "\n                  __________________ "
    echo "-----------------| script arguments |-----------------"
    echo "                  ------------------"
    for switch in $(scriptArgs.getSwitches)
    do
        echo "switch: $switch => value: $(scriptArgs.getArg $switch)"
    done

Output of Sample Code:

    $ ./script.sh -x10 --string "hello world"
                     ____________________
    ----------------| function arguments |----------------
                     --------------------
    switch: --fn2 => value: 20
    switch: --fn1 => value: true
    
                      __________________ 
    -----------------| script arguments |-----------------
                      ------------------
    switch: --string => value: hello world
    switch: -x => value: 10