# Alias all the repos - These minimize the typing you need to do to get to your dev enivronments
alias ws='cd ~/workspace'
alias dv='cd ~/workspace/wf/wf-js-document-viewer'
alias docviewer='cd ~/workspace/wf/wf-js-document-viewer'
alias devtools='cd ~/workspace/wf/dev-tools'
alias bs='cd ~/workspace/wf/bigsky'
alias ss='cd ~/workspace/wf/smallsky'
alias ssc='cd ~/workspace/wf/server_composition'
alias smallsky='ss'
alias ui='cd ~/workspace/wf/wf-uicomponents'
alias anno='cd ~/workspace/wf/wf-js-annotations'
alias bsrv='cd ~/workspace/wf/bigsky/apps/rv'
alias books='cd ~/workspace/wf/books'
alias rv='cd ~/workspace/wf/wf-js-reference-viewer'
alias vw='cd ~/workspace/wf/wf-js-viewer'
alias viewer='cd ~/workspace/wf/wf-js-viewer'
alias common='cd ~/workspace/wf/wf-common'
alias vs='cd ~/workspace/wf/wf-viewer-services'
alias viewers='vs'
alias annos='cd ~/workspace/wf/wf-annotation-services'
alias paw='cd ~/workspace/wf/wf-js-paw'
alias pitcher='cd ~/workspace/wf/wf-pitcher'
alias catcher='cd ~/workspace/wf/wf-catcher'
 
## Misc
alias bower='noglob bower' # Prevent the shell from expanding things like * for bower commands
alias reload=". ~/.zshrc" # If you change your zshrc, run this to make the changes apply to your current shell.
alias loc='find . -name $1 2>/dev/null'  # Use like find, but filter out that pesky STDERR.
 
## Bigsky helpers
alias bstestvs='workon sky && ./manage.py test apps.viewer'
alias bsvspip='workon sky && { pip uninstall -y wf-viewer-services; pip install -e ../wf-viewer-services; } && ant link-libs' # Links your local copy of viewer-services into BigSky
alias bssscpip='workon sky && { pip uninstall -y server-composition; pip install -e ../server_composition; } && ant link-libs' # Links your local copy of server_composition into BigSky
alias bslinkdocviewerassets='workon sky && ./tools/link_assets.py sky.docviewer assets' # Sets up the doc viewer dependencies inside of BigSky
alias bsdocviewerpip='workon sky && pip uninstall -y sky-docviewer; pip install -e ../wf-js-document-viewer; } && ant link-libs && bslinkdocviewerassets' # Links your local copy of doc viewer into BigSky
alias bslinkbooksassets='workon sky && ./tools/link_assets.py wf.apps.books assets' # Sets up books dependencies inside of BigSky
alias bsbookspip='workon sky && { pip uninstall -y wf-books; pip install -e ../books; } && ant link-libs && bslinkbooksassets'  # links your local copy of books into BigSky
# https://wiki.webfilings.com/display/DEV/How+to+Upload+and+Enable+Fonts
alias bsfonts='workon sky && python tools/remote_api/upload_font.py ../font/fonts/general --wf-enable; bell'
 
#alias sky="workon sky"
alias skyup="workon sky && git checkout master && git pull && git pull wf-origin master && git submodule update --init && pip install -Ur requirements_dev.txt" # Updates bigsky and all the dev requirements.  Production would just use requrements.txt.
alias bigsky='workon sky && python manage.py runserver 0.0.0.0:8001'
 
alias bsunpip='workon sky && pip uninstall -y server-composition wf-viewer-services sky-docviewer wf-books' # Remove all locally linked environments from BigSky
alias pipr='pip install -Ur requirements_dev.txt || pip install -r requirements.txt' # Install all python requirements for BigSky
 
#alias resetdata="workon sky && python tools/erase_reset_data.py --admin='stephen.bush@webfilings.com' --password='w3b'"
 
alias repip='bs && workon sky && pip install -Ur requirements_dev.txt'
alias loadbsfonts='bs && workon sky && python tools/remote_api/upload_font.py ../font/fonts/general && python tools/remote_api/upload_font.py ../font/fonts/restricted --wf-enable'
 
alias bsdoc='bs && workon sky && python tools/Doctor/bin/doctor.py' # I don't know what this does
 
 
## Bower and npm aliases
alias lsbowerlinks='ls -al ~/.local/share/bower/links'
alias cdbowerlinks='cd ~/.local/share/bower/links'
 
# Link local packages into the pwd.  So, if you were in  ~/workspace/wf/wf-js-viewer, the package would be linked in bower_components/
alias bowerlinkall="bower link wf-js-viewer && bower link wf-js-annotations && bower link wf-common && bower link wf-js-reference-viewer && bower link wf-uicomponents && bower link wf-js-paw && ls -l bower_components"
alias blrv="bower link wf-js-reference-viewer"
alias blvw="bower link wf-js-viewer"
alias blui="bower link wf-uicomponents"
alias blcommon="bower link wf-common"
alias blanno="bower link wf-js-annotations"
 
alias init="rm -rf bower_components node_modules; npm install && bower install" # Reset your pwd's npm and bower modules, without blowing away working directory changes, like ./init.sh
alias rebower="rm -rf bower_components && bower install"
alias lsbc="ls bower_components"
alias llbc="ll bower_components"
alias lsbcr='ls `find . -name bower_components | xargs`' # recursive, useful in bigsky
alias llbcr='ll `find . -name bower_components | xargs`' # recursive, useful in bigsky
alias rebower='rm -rf bower_components/$* && bower install'
alias renpm='rm -rf node_modules/$* && npm install'
 
## Git shortcuts
# http://superuser.com/questions/44787/looping-through-subdirectories-and-running-a-command-in-each
alias glwf='for dir in wf-*; do (echo "> inside $dir" && cd "$dir" && git status && git pull); done' # Git pulls all of pwds wf-* directories.
alias glwfmaster='for dir in wf-*; do (echo "> inside $dir" && cd "$dir" && git status && git checkout master && git pull); done' # Git pulls all of pwd's wf-* directories after checking out master.
alias gsu='git submodule update --init'
alias glom='git pull origin master'
alias loadfonts="workon bigsky && bigsky && python tools/remote_api/upload_font.py ../font/fonts/general"
alias lasttag="git describe --tags --abbrev=0"


## Other shortcuts


alias gpa='cd ~/workspaces/wf/ && for dir in *; do (echo "> inside $dir" && cd "$dir" && git status && git checkout master && git pull origin master); done' # Git pulls all of pwd's wf-* directories after checking out master.


# From Lance
alias pldv="
  sky
  pip uninstall -y sky-docviewer
  pip install -e ../wf-js-document-viewer
  ant link-doc-viewer
  ./tools/link_assets.py sky.docviewer assets
"