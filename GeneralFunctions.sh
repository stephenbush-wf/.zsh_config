#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

function scriptPath () {
    local DIR="`dirname \"$1\"`"              # relative
    local DIR2="`( builtin cd \"$DIR\" && pwd )`"  # absolutized and normalized
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


# ==============================================================================
# ZSH Extensions
# Developped by Stephen Bush, Workiva LLC (HyperText)

function changeTheme() {
  ZSH_THEME=${1?"robbyrussell"}
  loadZSH
}

function loadZSH() {
  source $ZSH/oh-my-zsh.sh  
}



# ==============================================================================
# Alias Management -- Provides a framework for safely "Hooking" into aliases, for makeshift event handling
# Developped by Stephen Bush, Workiva LLC (HyperText)

function _createBaseAliasNew () {
  # {
    local AliasToTest=$1"_BaseAliasContent"
    if [[ $(eval echo \$$AliasToTest) == "" ]]; then

      if [[ false == true ]]; then
        local Text=""
        alias $1
        if [[ $? -gt 0 ]]; then
          echo "CREATING BASE" >&2
          # No alias exists
          Text='\'"$1"' $@'
        else
          echo "USING EXISTING ALIAS" >&2
          local TEMP_PREV_CONTENTS=$(eval echo \$$1)""
          eval $(alias $1 | sed -e 's:\\:\\\\:g')
          Text="$(eval echo \$$1)"
          eval "$1""=""$TEMP_PREV_CONTENTS"
        fi
        eval "$AliasToTest""="'$Text'
        eval echo "3-- \$cd_BaseAliasContent ""-!-" >&2
      fi

      if [[ false == true ]]; then
        local Text=""
        # Text='\'"$1"' $@'
        Text="'\\\\$1 $""@'"
        # eval "$AliasToTest""="'$Text'
        eval $AliasToTest=$Text
      fi
    fi
  # } &> /dev/null
}


function _createBaseAlias () {
  {
    local AliasToTest=$1"_BaseAliasContent"
    if [[ $(eval echo \$$AliasToTest) == "" ]]; then
      local Text="'\\\\$1 $""@'"
      eval $AliasToTest=$Text
    fi
  } &> /dev/null
}

function _wrapAlias () {
  alias $1="function Alias_Function_Wrapper () { ""$(eval echo \$$1"_BaseAliasContent")"" }; Alias_Function_Wrapper"
}


# -- Deprecated
function prependAliasSimple () {
  {
    alias $1
    if [[ $? -gt 0 ]]; then
      # No alias exists
      alias $1="$2""; ""\\$1"
    else
      local TEMP_PREPEND=$(eval echo \$$1)""
      eval $(alias $1 | sed -e 's:\\:\\\\:g')
      alias $1="$2""; ""$(eval echo \$$1)"
      eval "$1""=""$TEMP_PREPEND"
    fi
  } &> /dev/null
}


# -- Deprecated
function appendAliasSimple () {
  {
    alias $1
    if [[ $? -gt 0 ]]; then
      # No alias exists
      alias $1="$2""; ""\\$1"
    else
      local TEMP_PREPEND=$(eval echo \$$1)""
      eval $(alias $1 | sed -e 's:\\:\\\\:g')
      alias $1="$(eval echo \$$1)""; ""$2"
      eval "$1""=""$TEMP_PREPEND"
    fi
  } &> /dev/null
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
