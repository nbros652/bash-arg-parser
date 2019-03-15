# bash-arg-parser
An argument parser for other bash scripts

This script facilitates the parsing of bash arguments and can handle arguments presented in a number of formats:
 1. `-k value`
 2. `--key value`
 3. `key value`
 4. `key=value`
 
To utilize this script, simply place a copy of it in a path that can be accessed by your script. Then at the beginning of your bash script, include a line that reads `source /path/to/bash-arg-parser.sh`, filling in the actual path to the `bash-arg-parser.sh` script.

Any point after this line in your script, you can call `getArg`*`your-switch-name`* to fetch the value assocated with that switch. Say you called your script with `./myscript --key secret -t "my plaintext" -c aes-xts-plain64`. After having sourced this script, any one of the following assignments would work:
  * `key=$(getVar key)`
  * `key=$(getVar --key)`
  * `text=$(getVar t)`
  * `text=$(getVar -t)`
  * `cipher=$(getVar c)`
  * `cipher=$(getVar -c)`

Furthermore, if `-t` and `--text` are both valid switches for a single item, you can call `getArg t text` or `getArg -t --text`, and if one was supplied but not the other, it will return the value for the one that was supplied. If both were supplied, the first occuring argument will be returned.
  
&nbsp;  
Additionally, if want simply to assign the values to the switch names outright, you can call the `setArgVars` function which will do this for you. So, say you called your script with `./myscript key=unknown text="did you know x=x?" cipher=aes-xts-plain64`. Then in your script you source `bash-arg-parser.sh` and call `setArgVars`. Now, the following variables will have already been set with the corresponding values:
  * key -> unknown
  * text -> "did you know x=x?"
  * cipher -> aes-xts-plain64
  
One point of note here is that it is possible to create switches that can be called with `getArg` but that do not themselves conform to variable naming standards. In this case, the `setArgVars` will assign all the variables it can and notify of the ones it was unable to. For example, given `./myscript -1a "name" -1b "phone" -x 10 -y 5`, running `setArgVars` will create variables x and y with values 10 and 5, respectively and notify that variables named 1a and 1b could not be created since these are invalid variable names. However, since the values for 1a and 1b can still obtained with `getArg`, `getArg 1a` and `getArg 1b` would return "name" and "phone", respectively.
