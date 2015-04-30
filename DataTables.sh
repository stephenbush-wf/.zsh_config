#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

# ==============================================================================

alias runDataTablesServer="
  export VENV=local &&
  gotable-server
"

alias runDataTablesClient="
  export VENV=local &&
  cd ~/workspaces/wf/wTable/app &&
  pub serve
"

alias updateGotableServer="
  cd $GOPATH/src/github.com/Workiva/gotable-server &&
  git pull &&
  godep go install
"