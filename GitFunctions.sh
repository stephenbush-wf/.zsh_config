#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

# ==============================================================================
# Useful Git Extensions/Aliases

gBranch () {
  # Check the status of the Input variables
  if [[ $1 == "" ]] then
    echo This command requires at least one argument!
    return
  fi

  # Check to see if a branch has been specified to base from
  local BASE=""
  if [[ $2 == "" ]] then
    BASE='master'
  else
    BASE=$2
  fi

  # Check to see if a branch has been specified to base from
  local REMOTE=""
  if [[ $3 == "" ]] then
    REMOTE='origin'
  else
    REMOTE=$3
  fi


  git fetch
  git checkout $BASE
  git pull $REMOTE $BASE
  git branch $1
  git checkout $1
  git branch -u $REMOTE/$BASE
  git pull $REMOTE $1
  git pull $REMOTE $BASE
}
alias gb="gBranch"

function gcom() {
  local ref=""
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
  if [[ $1 != "" ]]; then
    local comMsg=""
    comMsg+="${ref#refs/heads/}"" - ""${@:1}"
    # TODO: Dont have -a here, or make it an option.
    git commit -a -m "$comMsg"
  else
    echo -n ${ref#refs/heads/}" - " | pbcopy
    git commit
  fi
}

