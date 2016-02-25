#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

# ==============================================================================
# Useful Smithy Extensions/Aliases using the Workiva Smithy Client:
#     https://github.com/Workiva/smithy-client


# Smithy helpers by Pat Kujawa, updated 2015-Oct-6
# Uses https://github.com/Workiva/smithy-client
# http://tldp.org/LDP/abs/html/parameter-substitution.html
smithywatch () {
  which smithy 2>&1 1>/dev/null
  if [[ "$?" != "0" ]]; then
    echo "Please pip install smithy-client and make sure 'smithy' is in your path"
    return 1
  fi
  local ignored=${SMITHY_API_TOKEN?"You need an API token in the SMITHY_API_TOKEN env variable"}
  local buildid=${1:?"need one arg, which is the build number (from the url in smithy). You can also just give me the url."}
  # Ok, start background job
  (
    buildid=${buildid##*/}  # remove all but the id from the url, if it's a url
    mktemp /tmp/smithy_watch_XXXXXXXX | read outfile
    set -x
    nohup smithy watch builds $buildid 2>&1 1> $outfile
    set +x
    local customMsg=${2:-"$buildid"}
    local msg="smithy watch $customMsg $(tail -1 $outfile)"
    osascript -e "display notification \"$msg\" sound name \"Ping.aiff\""  # Mac notification system
    echo $msg
    case "$msg" in
      *succe*)
        say "smithy build succeeded"
        ;;
      *fail*)
        say "smithy build failed"
        ;;
      *kill*)
        say "smithy build killed"
        ;;
    esac
    rm -f $outfile
  ) &
}
alias sw=smithywatch