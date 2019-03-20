# this script emulates the creation of instances of a class

# turn on extended debugging so that we can get to function arguments outside of the function
shopt -s extdebug

argParser() {
	source <(sed "s/argParser/$1/g" argParser.class)
}
