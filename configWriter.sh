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

function config() {

  # Helper function for removing instances of text $2 from original text $1 
  function stripString() {
    echo $1 | sed -e "s/${2}//g"
  }


  # Dependency Checks

  # Help output  
  if [[ $1 == "help" ]]; then
    echo "$fg[cyan]================================================================================"
    echo "Config-Manager"
    echo "   written by Stephen Bush (Workiva)"
    echo "================================================================================"
    echo ""
    echo "  $fg[cyan] Usage:"
    echo ""
    echo "     $reset_color bsRebuild [options]"
    echo ""
    echo ""
    echo "  $fg[cyan] Options:"
    echo ""
    echo "     $fg[cyan] help, --help, -h"
    echo "        $reset_color Shows this help dialog"
    echo ""
    echo "     $fg[cyan] -f"
    echo "        $reset_color Runs in full rebuild mode.  When this flag is set, in addition to all"
    echo "       of the other build steps, the script will also completely remove and"
    echo "       re-clone BigSky from the remote repository, and perform additional steps."
    echo "       This can usually fix rare problems related to a corrupted or extremely"
    echo "       outdated file structure."
    echo ""
    echo "     $fg[cyan] -b <origin> <branch>"
    echo "        $reset_color When this flag is set, the specified remote branch is checked out and"
    echo "       used instead of master prior to running the rebuild steps."
    echo ""
    echo "     $fg[cyan] -s"
    echo "        $reset_color Skips many of the hefty rebuild steps (including ant full) and only"
    echo "       performs update/link steps.  This can often fix minor dependency and/or "
    echo "       linking issues that dont require a full rebuild."
    echo ""
    echo "     $fg[cyan] -l"
    echo "        $reset_color Skips almost all of the build steps and only links in external repos."
    echo ""
    echo "     $fg[cyan] -L"
    echo "        $reset_color Skips the link step."
    echo ""
    return 0
  fi

  # Dynamic argument parsing
  local CurParamNum=0
  local CommandSet=false
  local CommandAdd=false
  local CommandReset=false
  local CommandLoad=false
  local VarConfigFile=$CONFIG_FILE
  local VarConfigKey=""
  local VarConfigValue=""
  while true; do
    CurParamNum=$(($CurParamNum+1))
    eval "CurParam=\$$CurParamNum"
    # echo "-- [$CurParamNum] $CurParam" # Debugging
    if [[ $CurParam == "" ]]; then
      break
    fi

    if [[ $CurParam == 'add' ]]; then
      CommandAdd=true
      continue
    fi
    
    if [[ $CurParam == 'set' ]]; then
      CommandSet=true
      continue
    fi
    
    if [[ $CurParam == 'load' ]]; then
      CommandLoad=true
      continue
    fi
    
    if [[ $CurParam == 'reset' ]]; then
      CommandReset=true
      continue
    fi

    if [[ $CurParam =~ '^-.*c.*' ]]; then
      CurParam=$(stripString $CurParam c)

      # Parse extra param for config file
      CurParamNum=$(($CurParamNum+1))
      eval "VarConfigFile=\$$CurParamNum"
      if [[ $VarConfigFile == "" || $VarConfigFile =~ '^-.*' ]] then
        echo "$fg[red]ERROR: This command requires at least one argument following the -c parameter!  See 'config --help' for more details.$reset_color"
        return 11
      fi
    fi

    if [[ $CurParam =~ '^-.*k.*' ]]; then
      CurParam=$(stripString $CurParam k)

      # Parse extra param for config key
      CurParamNum=$(($CurParamNum+1))
      eval "VarConfigKey=\$$CurParamNum"
      if [[ $VarConfigKey == "" || $VarConfigKey =~ '^-.*' ]] then
        echo "$fg[red]ERROR: This command requires at least one argument following the -k parameter!  See 'config --help' for more details.$reset_color"
        return 11
      fi
    fi

    if [[ $CurParam =~ '^-.*v.*' ]]; then
      CurParam=$(stripString $CurParam v)

      # Parse extra param for config file
      CurParamNum=$(($CurParamNum+1))
      eval "VarConfigValue=\$$CurParamNum"
      if [[ $VarConfigValue == "" || $VarConfigValue =~ '^-.*' ]] then
        echo "$fg[red]ERROR: This command requires at least one argument following the -v parameter!  See 'config --help' for more details.$reset_color"
        return 11
      fi
    fi

    if [[ $CurParam =~ '^-.*h.*' || $CurParam =~ '^-.*help.*' || $CurParam =~ '^help' ]]; then
      bsRebuild help
      return 0
    fi

    if [[ ! $CurParam == "-" && ! $CurParam == "--" ]]; then
      echo "$fg[yellow]WARNING: Unrecognized command or parameters, $CurParam $reset_color"
    fi
  done

  if [[ $VarConfigFile == "" ]]; then
  	echo "$fg[red]ERROR: This command requires a valid Config file, either passed in with '-c <Filepath>' or set via the CONFIG_FILE variable!$reset_color"
  	return 12
  fi

  if [[ $CommandReset == true ]]; then
    {
		rm -rf $VarConfigFile
	    # Set default variable value
	    touch $VarConfigFile
    	echo "# CONFIG_FILE=$VarConfigFile" | tee -a $VarConfigFile
    } &> /dev/null
  fi

  if [[ $CommandAdd == true ]]; then
    if [[ $VarConfigKey == "" || $VarConfigValue == "" ]]; then
        echo "$fg[red]ERROR: The 'add' command requires at least two arguments set, -k -v!  See 'config --help' for more details.$reset_color"      
        return 11
    fi
    {
		local Value
		if [[ $VarConfigValue != "" ]]; then
			Value=$VarConfigValue
		else
			Value=""
		fi
		echo "$VarConfigKey=\"$Value\"" | tee -a $VarConfigFile
    } &> /dev/null
  fi

  if [[ $CommandSet == true ]]; then
    # echo "Set Config for $VarConfigKey == $VarConfigValue >> $VarConfigFile" >&2 # Debugging
    if [[ $VarConfigKey == "" || $VarConfigValue == "" ]]; then
        echo "$fg[red]ERROR: The 'add' command requires at least two arguments set, -k -v!  See 'config --help' for more details.$reset_color"      
        return 11
    fi
    {
		sed -i "" "s/^\($VarConfigKey\s*=\s*\).*\$/\1\"$VarConfigValue\"/" $VarConfigFile
    } &> /dev/null
  fi

  if [[ $CommandLoad == true ]]; then
	{
		source $VarConfigFile
    } &> /dev/null
  fi


}