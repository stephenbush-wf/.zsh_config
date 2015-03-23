#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

ONLOAD_CONFIG_FILE=$PWD"/.ONLOAD_CONFIG_FILE.cfg"

which -s prependAlias &> /dev/null
if [[ $? != 0 ]]; then
  echo "$fg[red]Error, this Script requires Stephen Bush's ConfigWriter.sh in order to function properly.  Please ensure that it is sourced in your .zshrc file prior to loading this script."
  return
fi


if [[ ! ( -e $ONLOAD_CONFIG_FILE ) ]]; then
	config -c $ONLOAD_CONFIG_FILE reset
	local itemToLoad=$(echo "$TTY""_onLoad" | sed -e 's:/::g')
	config -c $ONLOAD_CONFIG_FILE add -k $itemToLoad
fi

function setLoadCommand() {
	local itemToLoad=$(echo "$TTY" | sed -e 's:/::g')"_""$1"
	eval "$itemToLoad""=""Empty"
	config -c $ONLOAD_CONFIG_FILE load -k $itemToLoad
	if [[ $(eval echo \$$itemToLoad) == "Empty" ]]; then
		config -c $ONLOAD_CONFIG_FILE add -kv $itemToLoad $2
	else 
		config -c $ONLOAD_CONFIG_FILE set -kv $itemToLoad $2
	fi
}

function onLoad() {
	local itemToLoad=$(echo "$TTY" | sed -e 's:/::g')"_""$1"
	# echo "Loading $itemToLoad"
	config -c $ONLOAD_CONFIG_FILE load -k $itemToLoad
	eval $(eval echo \$$itemToLoad)
}
