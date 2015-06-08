#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

# ==============================================================================

export GOROOT=/usr/local/go
export GOPATH=$HOME/dev/go
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:~/dev/go_appengine
export PATH=$PATH:$GOPATH/bin


alias lux="cd ~/dev/go/src/github.com/Workiva/wLuxEditor"
alias luxbuild="
    lux &&
    ./init.sh &&
    cd server &&
    go build &&
    cd ../editor &&
    gulp build &&
    cd ..
"
alias luxserver="lux && cd server && ./server"
alias luxclient="lux && cd appHost && goapp serve -host localhost -port 6060 -admin_port 6061"

function lb () {
	lux
	cd server
	go build
	if [[ $? == 0 ]]; then
		luxserver
	fi
}