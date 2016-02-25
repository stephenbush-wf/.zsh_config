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
  git push $REMOTE $1
  gTrack $1 $REMOTE
  git pull $REMOTE $1
  git pull $REMOTE $BASE
}
alias gbr="gBranch"

function gCom() {
  local ref=""
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
  ref=$(echo ${ref#refs/heads/} | cut -d"_" -f1)
  local comMsg=$ref" "
  if [[ $1 != "" ]]; then
    comMsg+="${@:1}"
    # TODO: Dont have -a here, or make it an option.
    git commit -a -m "$comMsg"
  else
    echo -n $comMsg | pbcopy
    git commit
  fi
}
alias gcom="gCom"

function gTrack() {
  # Check the status of the Input variables
  if [[ $1 == "" ]] then
    echo This command requires at least one argument!
    return
  fi
  local BRANCH=$1

  # Check to see if a branch has been specified to base from
  local REMOTE=""
  if [[ $2 == "" ]] then
    REMOTE='origin'
  else
    REMOTE=$2
  fi

  git branch -u $REMOTE/$BRANCH
}

which -s git-guilt &> /dev/null
if [[ $? == 0 ]]; then
  function gGuilt() {
    local Branch=""
    local Base="master"
    if [[ $1 == "" ]] then
      local ref=""
      ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
      ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
      Branch="${ref#refs/heads/}"
    else
      Branch="$1"
    fi
    if [[ $2 != "" ]] then
      Base="$2"
    fi
    echo "--$Base--/--$Branch--"
    git guilt `git merge-base $Base $Branch` $Branch
  }
fi