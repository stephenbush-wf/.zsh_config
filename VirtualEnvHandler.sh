#!/bin/sh
# ==============================================================================
# Dynamically obtain the virtualenv when CD into a directory
#   Written by Stephen Bush, Workiva (HyperText)
# Based initially on https://gist.github.com/clneagu/7990272 & other places, with many improvements.
# This module gives you several useful functions as well as improved usability around Virtual 
#   Environment handling, including automatic VEnv detection in any directory (even nested 
#   subdirectories), *without* restrictions such as the need for a hidden `.venv` file or the VEnv 
#   to be named after the directory. (However, these popular optimizations are also incorporated to 
#   improve detection performance.)  It also features automatic activation/deactivation of these 
#   environments via the cd command.
# This script optionally uses functions from Stephen Bush's 'GeneralFunctions.sh' to improve 
#   performance and interoperability with other scripts.  However, if the desired functions are not 
#   available, alternatives are used instead to preserve functionality and supress errors.




# ======================================================
#   VirtualEnv Handling System Config
# ======================================================
# Enables automatic VirtualEnv switching mode.  Extremely useful if you primarily 
#   navigate via `cd`, otherwise it could be inconsistent and unhelpful.  Can also 
#   integrate with addons like 'Autojump' if set up properly to do so.
VENVAR__Override_CD_Alias=true
# Only activate VenVs in git repos
# Recommended true, as any project using a Venv should be using Git!  Also, the git
#   check happens first, and will short-circuit the more expensive venv detection checks
#   if allowed to do so.  Especially if CD override is enabled.
VENVAR__Activate_Venv_In_Git_Dirs_Only=true
# Use the workon command to activate the Virtual Environment.  This ensures that venv
#   hooks are called, however, this also can have some unintended side-effects when auto-
#   activating the Venv.  For instance, when activating a venv with a workon directory set,
#   this may cause the pwd to jump to that directory, even if that's not the current pwd.
VENVAR__Use_Workon=true
# Recursively check ascending directories looking for a virtual environment.  
# Recomended true, as this helps find the correct environment when jumping into a 
#   subdirectory prior to activation, but can also lead to increased lookup time.
VENVAR__Recursively_Check_For_VirtualEnv=true
# Deactivate the current virtual environment if none can be identified for the current 
#   directory.  
# Recommended true
VENVAR__Deactivate_Venv_When_None_Detected=true




# ==============================================================================
# Functions

# check_virtualenv <directory>
# This function returns the name of the VEnv for the specified directory, or for the current PWD if 
#   none specified.
function check_virtualenv() {

  local ENV_NAME="0"
  local tempENV_NAME
  local prev_pwd=$PWD

  if [[ $1 != "" ]]; then
    builtin cd $1
  fi

  while [ true ]; do
    # Check to see if a '.venv' file exists
    if [[ $ENV_NAME == "0" ]]; then
      if [ -e .venv ]; then
        tempENV_NAME=$(cat .venv)
        if [[ -e "$WORKON_HOME/$tempENV_NAME/bin/activate" ]]; then
          #echo "FOUND BY .venv!"
          ENV_NAME="$tempENV_NAME"
          break
        fi
      fi
    fi

    # Check to see if a virtualenv with the same name as the current directory exists
    if [[ $ENV_NAME == "0" ]]; then
      tempENV_NAME=$(getBaseDir)
      if [[ -e "$WORKON_HOME/$tempENV_NAME/bin/activate" ]]; then
        #echo "FOUND BY NAME!"
        ENV_NAME="$tempENV_NAME"
        break
      fi
    fi

    # Lookup the venv by rolling through each existing venv and matching one to pwd
    if [[ $ENV_NAME == "0" ]]; then
      tempENV_NAME=$(_lookupEnvForDirectory)
      if [[ $? == 0 ]]; then
        #echo "FOUND BY LOOKUP!"
        ENV_NAME="$tempENV_NAME"
        break
      fi
    fi
    if [[ $VENVAR__Recursively_Check_For_VirtualEnv == false || $PWD == "/" ]]; then
      break
    fi    
    builtin cd ..
  done

  builtin cd $prev_pwd
  # If we didnt find a venv, or we're no longer in a git repository, 
  if [[ $ENV_NAME == "0" ]]; then
    return 12
  fi
  echo "$ENV_NAME"
  return 0
}


# activate_virtualenv
# This function will detect and activate the Virtual Environment for the current PWD, or deactivate 
#   if there is none associated with the current directory.
function activate_virtualenv() {
  # Check to see if we're in a git repository
  # This limits venv activation to ONLY directories inside a git repo.
  if [[ $VENVAR__Activate_Venv_In_Git_Dirs_Only == true ]]; then
    [ -d .git ] || git rev-parse --show-toplevel &> /dev/null
  else
    true
  fi
  if [[ $? == 0 ]]; then
    local myVenv="$(check_virtualenv)"
    if [[ $? == 0 && $myVenv != "" ]]; then
      # Verify that the found exists and/or is not already activated
      if [[ "${VIRTUAL_ENV##*/}" != "$myVenv" ]]; then
        echo "Activating VirtualEnv >> $myVenv"
        if [[ $VENVAR__Use_Workon == true ]]; then
          workon $myVenv && export CD_VIRTUAL_ENV=$myVenv
        else
          source "$WORKON_HOME/$myVenv""/bin/activate" && export CD_VIRTUAL_ENV=$myVenv
        fi
      fi
      return 0
    fi
  fi

  if [[ $VENVAR__Deactivate_Venv_When_None_Detected == true && $CD_VIRTUAL_ENV != "" ]]; then
    echo "Deactivating VirtualEnv"
    deactivate && unset CD_VIRTUAL_ENV
    return 0
  fi
  return 0
}


# make_venv_file <name_of_virtual_environment>
# Create a `.venv` file in the PWD with specified virtualenvironment. This allows you to temporarily
#   override the virtual environment for a directory if needed, as well as provide a faster 
#   mechanism for VEnv lookup in a directory.
function make_venv_file() {
  local File=".venv"
  if [[ -e $File ]]; then
    rm -rf $File
  fi
  touch $File
  echo "$1" | tee -a $File
}


function _lookupEnvForDirectory () {
  local VENVBASE="$WORKON_HOME"
  local FILE
  local FOUNDENVDIR
  # for ENV in $(workon);
  for ENV in $(ls -1 $VENVBASE);
  do
    if [[ -d "$VENVBASE/$ENV" ]]; then
      FILE="$VENVBASE/$ENV/.project"
      if [[ -e $FILE ]]; then
        FOUNDENVDIR=$(cat $FILE)
        if [[ $FOUNDENVDIR == $PWD ]]; then
          echo "${ENV}"
          return 0
        fi
      fi
    fi
  done
  return 1
}

# Call check_virtualenv in case opening directly into a directory (e.g
# when opening a new tab in Terminal.app).
if [[ $VENVAR__Override_CD_Alias == true ]]; then
  if [[ $VIRTUAL_ENV != "" ]]; then
    deactivate
  fi
  unset CD_VIRTUAL_ENV
  activate_virtualenv

  # Override the default CD functionality to provide automatic venv switching
  # Check for appendAlias dependency
  which -s appendAlias &> /dev/null
  if [[ $? -gt 0 ]]; then
  	venv_cd () {
      builtin cd "$@" && activate_virtualenv
	  }
    alias cd="venv_cd"
  else
  	venv_cd () {
  	  activate_virtualenv
    }
  	appendAlias cd "venv_cd"
  fi
fi
