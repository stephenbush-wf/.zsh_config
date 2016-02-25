#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

# ==============================================================================
# Functions for archon (https://github.com/bovard/archon) by Bovard Doerschuk-Tiberi

function archonInstall() {
	if [[ "${PWD##*/}" == "archon" ]]; then
		npm install -g .
	else
		npm install -g archon
	fi
}

function archonTest() {
	printWithTimestamp "Archon Started -- $1"
	if [[ $1 == "1" ]]; then
		archon src/team037 src/examplefuncsplayer -m -r 'replays/testing'
	elif [[ $1 == "2" ]]; then
		archon src/team037 src/examplefuncsplayer -m -r 'replays/testing' -p 8
	elif [[ $1 == "3" ]]; then
		archon src/team037 src/examplefuncsplayer -m -r 'replays/testing' -p 2
	fi
	printWithTimestamp "Archon Finished"
}