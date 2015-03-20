#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)
# Initial code sourced from Stack Overflow, and heavily modified.
# http://stackoverflow.com/questions/2464760/modify-config-file-using-bash-script/26035652#26035652

# INITIALIZE CONFIG IF IT'S MISSING
if [ ! -e "${CONFIG_FILE}" ] ; then
    {
	    # Set default variable value
	    touch $CONFIG_FILE
    	echo "CONFIG_FILE=$CONFIG_FILE" | tee -a $CONFIG_FILE
    } &> /dev/null
fi


function set_config(){
    # echo "Set Config for $1 == $2 >> $CONFIG_FILE" >&2 # Debugging
    {
		sed -i "" "s/^\($1\s*=\s*\).*\$/\1\"$2\"/" $CONFIG_FILE
    } &> /dev/null
}

function add_config() {
    # echo "Set Config for $1 == $2 >> $CONFIG_FILE" >&2 # Debugging
    {
		local Value
		if [[ $2 != "" ]]; then
			Value=$2
		else
			Value=""
		fi
		echo "$1=\"$Value\"" | tee -a $CONFIG_FILE
    } &> /dev/null
}

function reset_config() {
    {
		rm -rf $CONFIG_FILE
	    # Set default variable value
	    touch $CONFIG_FILE
    	echo "CONFIG_FILE=$CONFIG_FILE" | tee -a $CONFIG_FILE
    } &> /dev/null
}


function load_config() {
	{
		source $CONFIG_FILE
    } &> /dev/null
}
