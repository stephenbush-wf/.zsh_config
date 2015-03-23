#!/bin/sh
# ==============================================================================
# Terminal Variable
#   Written by Stephen Bush, Workiva (HyperText)
#
# Define and save commands unique to individual terminal IDs, to be run when 
#   called at the appropriate time.  Allows for a single command to cause
#   different

TVAR_CONFIG_FILE=$PWD"/.TERM_VARS.cfg"

which -s prependAlias &> /dev/null
if [[ $? != 0 ]]; then
  echo "$fg[red]Error, this Script requires Stephen Bush's ConfigWriter.sh in order to function properly.  Please ensure that it is sourced in your .zshrc file prior to loading this script."
  return
fi


if [[ ! ( -e $TVAR_CONFIG_FILE ) ]]; then
	config -c $TVAR_CONFIG_FILE reset
	local itemToLoad=$(echo "$TTY""_onLoad" | sed -e 's:/::g')
	config -c $TVAR_CONFIG_FILE add -k $itemToLoad
fi

function setTerminalVariable() {
	local itemToLoad=$(echo "$TTY" | sed -e 's:/::g')"_""$1"
	eval "$itemToLoad""=""Empty"
	config -c $TVAR_CONFIG_FILE load -k $itemToLoad
	if [[ $(eval echo \$$itemToLoad) == "Empty" ]]; then
		config -c $TVAR_CONFIG_FILE add -kv $itemToLoad $2
	else 
		config -c $TVAR_CONFIG_FILE set -kv $itemToLoad $2
	fi
}

function getTerminalVariable() {
	local itemToLoad=$(echo "$TTY" | sed -e 's:/::g')"_""$1"
	# echo "Loading $itemToLoad"
	config -c $TVAR_CONFIG_FILE load -k $itemToLoad
	eval echo \$$itemToLoad
}
