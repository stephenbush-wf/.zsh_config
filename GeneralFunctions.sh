#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

# ==============================================================================
# Utility functions

# Return the path where the calling script lives.  Requires argument '$0' and
#  only works during initial sourcing of the script, so if this path is needed 
#  later, then it should be grabbed and saved by the calling script.
function scriptPath () {
    local DIR="`dirname \"$1\"`" # relative
    local DIR2="`( builtin cd \"$DIR\" && pwd )`" # absolutized and normalized
    if [ -z "$DIR2" ] ; then
        echo $DIR
        return 0
    fi
    echo $DIR2
    return 0
}

# This helper function gets the base directory name from the PWD
function getBaseDir() {
  if [[ ${@:1} == "" ]]; then
    echo "${PWD##*/}"
  else
    echo "${${@:1}##*/}"
  fi
  return 0
}

# Show/Hide hidden files and folders in the Finder
alias finderShowHiddenFiles="defaults write com.apple.finder AppleShowAllFiles YES"
alias finderHideHiddenFiles="defaults write com.apple.finder AppleShowAllFiles NO"

# Host a local file server available over the wifi for sharing/moving files
alias serveFiles="
  ifconfig | grep netmask &&
  echo 'Running file server on port 5000' &&
  python -m SimpleHTTPServer 5000
"

# Pause the currently running program until the user pushes Enter.
function pause() {
    echo "***************************************************"
    echo "** $*"
    echo "** Press ENTER to continue, Ctrl-C to quit."
    echo "***************************************************"
    read -e ""
}

# Create an easy detailed 'ls' alias
alias l="ls -1 -lah"

alias runPassageway="/Applications/runscope-passageway --bucket=4k0snp2zbost --fixed 8001"

function alert() {
  Title="$1"
  Msg="$2"
  say "$Title"
  osascript -e "display notification \"$Msg\" sound name \"Ping.aiff\" with title \"$Title\" "  # Mac notification system
}

function printWithTimestamp() {
  echo "$(timestamp) ${@:1}"
}

function timestamp() {
  if [[ $1 == '-d' ]]; then
    echo $(date -j "+[%Y-%m-%d %H:%M:%S]")
  else
    echo $(date -j "+[%H:%M:%S]")
  fi
}





# ==============================================================================
# ZSH Extensions

function changeTheme() {
  ZSH_THEME=${1?"robbyrussell"}
  loadZSH
}

function loadZSH() {
  source $ZSH/oh-my-zsh.sh  
}




# ==============================================================================
# Alias Management -- Provides a framework for safely "Hooking" into aliases, 
#   for makeshift event handling

function _createBaseAlias () {
  {
    local AliasToTest=$1"_BaseAliasContent"
    if [[ $(eval echo \$$AliasToTest) == "" ]]; then
      if [[ true == true ]]; then
        local TempText=""
        alias $1
        if [[ $? -gt 0 ]]; then
          # No alias exists
          TempText="\\\\$1 $""@"
        else
          local TEMP_PREV_CONTENTS=$(eval echo \$$1)""
          eval $(alias $1 | sed -e 's:\\:\\\\:g')
          TempText="$(eval echo \$$1) $""@"
          eval "$1""=""$TEMP_PREV_CONTENTS"
        fi
        eval "$AliasToTest""="'$TempText'
      fi
    fi
  } &> /dev/null
}


function _createBaseAliasOLD () {
  {
    local AliasToTest=$1"_BaseAliasContent"
    if [[ $(eval echo \$$AliasToTest) == "" ]]; then
      local TempText="'\\\\$1 $""@'"
      eval $AliasToTest=$TempText
    fi
  } &> /dev/null
}

function _wrapAlias () {
  alias $1="function Alias_Function_Wrapper () { ""$(eval echo \$$1"_BaseAliasContent")"" }; Alias_Function_Wrapper"
}


function appendAlias () {
  {
    _createBaseAlias $1
    eval $1"_BaseAliasContent""="\$"$1""_BaseAliasContent""'; '""'${@:2}'"
    _wrapAlias $1
  } &> /dev/null
}

function prependAlias () {
  {
    _createBaseAlias $1
    eval $1"_BaseAliasContent""=""'${@:2}'""'; '"\$"$1""_BaseAliasContent"
    _wrapAlias $1
  } &> /dev/null
}





# ==============================================================================
# Docker Functions -- 

dockerReboot () {
  # # VBoxManage list
  # # VBoxManage showvminfo boot2docker-vm
  # # boot2docker stop
  # # VBoxManage controlvm boot2docker-vm poweroff
  # # VBoxManage unregistervm boot2docker-vm --delete
  # # rm -rf ~/VirtualBox\ VMs/boot2docker-vm/
  # boot2docker init

  (port=49444;VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port${port},tcp,,${port},,${port}")

  boot2docker up

  export DOCKER_HOST=tcp://192.168.59.103:2376
  export DOCKER_CERT_PATH=/Users/stephenbush/.boot2docker/certs/boot2docker-vm
  export DOCKER_TLS_VERIFY=1

  #docker login docker.webfilings.org --username="stephenbush-wf" --password="d60d1deb7b" --email="stephen.bush@workiva.com"
  # Use --insecure-registry ??

  # dockerUpdate $1 $2
}

dockerUpdate() {
  local imageToLoad="latest" # Default
  if [[ $1 != "" ]]; then
    imageToLoad="$1"
  fi

  local image2ToLoad="latest" # Default
  if [[ $2 != "" ]]; then
    image2ToLoad="$2"
  fi

  # Run the NVS Task Manager
  docker stop nvs-task-manager
  docker rm nvs-task-manager
  docker pull docker.webfilings.org/hydra/nvs-task-manager:"$imageToLoad"
  docker run -t -d -p 49444:49444 --name nvs-task-manager -e "DEMETER_CONF=-l DEBUG" docker.webfilings.org/hydra/nvs-task-manager:"$imageToLoad"

  # Run the NVS Worker
  docker stop nvs-worker
  docker rm nvs-worker
  docker pull docker.webfilings.org/hydra/nvs-worker:"$image2ToLoad"
  docker run -d --name nvs-worker --link nvs-task-manager:nvs-task-manager -e "DEMETER_CONF=-l DEBUG" docker.webfilings.org/hydra/nvs-worker:"$image2ToLoad"
}

function runTests() {
  runTerminalFunction runTests
}