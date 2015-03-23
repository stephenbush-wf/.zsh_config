#!/bin/sh
# ==============================================================================
# Terminal Variable
#   Written by Stephen Bush, Workiva (HyperText)
#
# Define and save commands unique to individual terminal IDs, to be run when 
#   called at the appropriate time.  Allows for a single command to cause
#   different behavior in each window.
# Terminal variables can have many uses, including but not limited to:
#   -- The ability to define certain values with distinct to each terminal
#   -- Programmatically set up different configuration settings for each terminal
#   -- Create a list of commands to be executed that is unique to each terminal


TVAR_CONFIG_FILE=$PWD"/.TERM_VARS.cfg"

# Dependency Check
which -s config &> /dev/null
if [[ $? != 0 ]]; then
  echo "$fg[red]Error, this Script requires Stephen Bush's ConfigWriter.sh in order to function properly.  Please ensure that it is sourced in your .zshrc file prior to loading this script."
  return
fi

# Initialize config file if it doesnt exist
if [[ ! ( -e $TVAR_CONFIG_FILE ) ]]; then
	config -c $TVAR_CONFIG_FILE reset
	local itemToLoad=$(echo "$TTY""_onLoad" | sed -e 's:/::g')
	config -c $TVAR_CONFIG_FILE add -k $itemToLoad
fi

# setTerminalVariable <Keyname> <Value>
# Set a variable for the current Terminal ID with the specified key/value
function setTerminalVariable() {
	if [[ $1 == "" ]]; then
		echo "$fg[red]Error, setTerminalVariable requires at least one parameter, which is a variable keyname!"
		return 11
	fi
	local itemToLoad=$(echo "$TTY" | sed -e 's:/::g')"_""$1"
	eval "$itemToLoad""=""Empty"
	config -c $TVAR_CONFIG_FILE load -k $itemToLoad
	if [[ $(eval echo \$$itemToLoad) == "Empty" ]]; then
		config -c $TVAR_CONFIG_FILE add -kv $itemToLoad $2
	else 
		config -c $TVAR_CONFIG_FILE set -kv $itemToLoad $2
	fi
	return 0
}

# getTerminalVariable <Keyname>
# Retrieve the specified variable for the current Terminal ID with the specified key
function getTerminalVariable() {
	if [[ $1 == "" ]]; then
		echo "$fg[red]Error, setTerminalVariable requires at least one parameter, which is a variable keyname!"
		return 11
	fi

	local itemToLoad=$(echo "$TTY" | sed -e 's:/::g')"_""$1"
	# echo "Loading $itemToLoad"
	config -c $TVAR_CONFIG_FILE load -k $itemToLoad
	eval echo \$$itemToLoad
	return 0
}

function runTerminalFunction() {
	eval $(getTerminalVariable $1)
}