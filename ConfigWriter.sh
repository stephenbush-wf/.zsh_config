#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)
# Initial code sourced from Stack Overflow, and heavily modified/expanded.
# http://stackoverflow.com/questions/2464760/modify-config-file-using-bash-script/26035652#26035652

function config() {

  # echo "-- " ${@} # Debugging

  # Helper function for removing instances of text $2 from original text $1 
  function stripString() {
    echo $1 | sed -e "s/${2}//g"
  }


  # Dependency Checks

  # Help output  
  if [[ $1 == "help" ]]; then
    echo "$fg[cyan]================================================================================"
    echo "Configuration-File Manager"
    echo "   written by Stephen Bush (Workiva)"
    echo ""
    echo ""
    echo "  The purpose of this Script is to make management of one or more configuration"
    echo "files as simple, clean and performant as possible while providing a simple"
    echo "interface for interacting with them."
    echo "  Configuration files can have many uses, including but not limited to:"
    echo "    -- Providing an interface for programmatically changing variables which can"
    echo "         persist beyond closing and re-opening a terminal"
    echo "    -- Providing external channels for cross-thread communication"
    echo "================================================================================"
    echo ""
    echo "  $fg[cyan] Usage:"
    echo ""
    echo "     $reset_color config [commands|options]"
    echo ""
    echo ""
    echo "  $fg[cyan] Commands:"
    echo ""
    echo "     $fg[cyan] help"
    echo "        $reset_color Shows this help dialog."
    echo ""
    echo "     $fg[cyan] add"
    echo "        $reset_color Add a key to the config file.  Requires -k option, -v optional."
    echo ""
    echo "     $fg[cyan] set"
    echo "        $reset_color Set a key to a specified value.  Requires -k and -v options."
    echo ""
    echo "     $fg[cyan] load"
    echo "        $reset_color Load keys/values into the current environment. Optionally, the -k flag"
    echo "       can be used to specify a specific key to load, else all values are loaded"
    echo ""
    echo "     $fg[cyan] reset"
    echo "        $reset_color Remove and re-create the Config file."
    echo ""
    echo ""
    echo "  $fg[cyan] Options:"
    echo ""
    echo "     $fg[cyan] --help, -h"
    echo "        $reset_color Shows this help dialog."
    echo ""
    echo "     $fg[cyan] -c"
    echo "        $reset_color Specify a target config file."
    echo ""
    echo "     $fg[cyan] -k"
    echo "        $reset_color Specify a key in the config file."
    echo ""
    echo "     $fg[cyan] -v"
    echo "        $reset_color Specify a value in the config file."
    echo "       NOTE: The empty string \"\" is considered a legal value for this option."
    echo "       Because of this, the -v option should be specified LAST in any 'config'"
    echo "       command, to avoid the script accidently parsing other parameters as values"
    echo "       in the case where an expression resolves to the empty string."
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
      # Disable the validity check, because string could be legally empty
      # if [[ ! ( -n $VarConfigValue ) || $VarConfigValue =~ '^-.*' ]] then
      #  echo "$fg[red]ERROR: This command requires at least one argument following the -v parameter!  See 'config --help' for more details.$reset_color"
      #  return 11
      #fi
    fi

    if [[ $CurParam =~ '^-.*h.*' || $CurParam =~ '^-.*help.*' || $CurParam =~ '^help' ]]; then
      config help
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
		rm -rf $VarConfigFile
	  # Set default variable value
	  touch $VarConfigFile
    echo "# CONFIG_FILE=$VarConfigFile" | tee -a $VarConfigFile &> /dev/null
  fi

  if [[ $CommandAdd == true ]]; then
    if [[ $VarConfigKey == "" ]]; then
        echo "$fg[red]ERROR: The 'add' command requires at least one argument set, -k!  See 'config --help' for more details.$reset_color"      
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
    if [[ $VarConfigKey == "" ]]; then
        echo "$fg[red]ERROR: The 'set' command requires at least two arguments set, -k -v!  See 'config --help' for more details.$reset_color"      
        return 11
    fi
    {
		  sed -i "" "s:^\($VarConfigKey\s*=\s*\).*\$:\1\"$VarConfigValue\":" $VarConfigFile
    } &> /dev/null
  fi

  if [[ $CommandLoad == true ]]; then
	{
		if [[ $VarConfigKey != "" ]]; then
  			cat $VarConfigFile | grep "${VarConfigKey}=" | while read -r line ; do
  				eval $line
  			done
  		else
  			source $VarConfigFile
		fi
    } &> /dev/null
  fi
}