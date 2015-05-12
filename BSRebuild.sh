#!/bin/sh
# Written by Stephen Bush, Workiva (HyperText)

# ======================================================
#   Bigsky Builder System Config
# ======================================================
# Directory of the workspace where all your Workiva repositories live
BSVAR__Root_Workspace_Directory='/Users/stephenbush/workspaces/wf/'
BSVAR__Temp_Bigsky_Workspace_Directory="$BSVAR__Root_Workspace_Directory""bigsky"
# Directory into which to store backup files (Settings,data,etc)
BSVAR__BKDIR='/Users/stephenbush/Documents/Programming Environment Stuff/bigsky Backup Files/'
# Github URL for the main Bigsky development fork used by you or your team
BSVAR__Bigsky_Fork='git@github.com:timmccall-wf/bigsky.git'
# Username of the Dev Account on the local machine
BSVAR__User_Name='StephenBush'
# These are the login credentials used to authenticate the SuperAdmin in the Erase-reset script
BSVAR__EraseResetAdmin="stephen.bush@webfilings.com"
BSVAR__EraseResetPassword="w3b"
# Flag to allow/disallow the Rebuild script from running while BigSky is running
# Recommended false, as changes to the Bigsky repo while the server is running could
#   cause problems with the running server AND/OR important pieces of the rebuild process 
#   could be caused to fail.
BSVAR__Allow_Rebuild_When_Server_Running=false
# Flag to allow 'git gc' to run during build process.  Adds about 5 minutes to build time.
#    Effects may be negligible for most users who dont actually perform dev work on Bigsky.
BSVAR__Run_Git_Garbage_Collection=false



# ======================================================
#   Datastore Management Config
# ======================================================
# Flag to allow/disallow the Datastore scripts from running while BigSky is running
# Recommended false, because the datastore files are somewhat volatile and some elements 
#   may not be saved until after the server is properly shut down.
BSVAR__Allow_Datastore_Imaging_When_Server_Running=false



bsRebuild () {

  # Helper function for printing a timestamp in status messages
  function bstimestamp() {
    echo $(date -j "+[%H:%M:%S]")
  }

  # Helper function for removing instances of text $2 from original text $1 
  function stripString() {
    echo $1 | sed -e "s/${2}//g"
  }

  # Dependency Checks
  which -s dsBackup &> /dev/null && local useDataStoreBackup=true
  which -s dsRestore &> /dev/null && local useDataStoreRestore=true

  
  if [[ $1 == "help" ]]; then
    echo "$fg[cyan]================================================================================"
    echo "Workiva BigSky Project-Builder Script,"
    echo "   written by Stephen Bush (Hypertext)"
    echo ""
    echo ""
    echo "  This script is designed to be comprehensive, and yield a successful (but not"
    echo "necessarily fast) BigSky build.  It contains many extra steps, including a full"
    echo "rebuilding of dependencies and wiping of the VirtualEnv for bigsky.  The reason"
    echo "for this is that these steps typically fix common build problems, and can lead"
    echo "to build failures if they need to be run and aren't.  So every single step is"
    echo "run pre-emptively."
    echo "  The goal is, you can start a rebuild and go grab a snack and a cup of coffee"
    echo "and come back knowing your build will be successful.  Chances are that a failed"
    echo "quick build (or multiple failures), a fix and a quick rebuild will still eat up"
    echo "more time than a long build that completes successfully."
    echo "  This build also includes many link steps designed to hook other development"
    echo "repositories into BigSky, making development easier.  Individual link steps"
    echo "should be commented out of the script in order to skip them when rebuilding, "
    echo "else these repos should be kept up-to-date to ensure that BigSky still runs as"
    echo "expected."
    echo ""
    echo ""
    echo "================================================================================"
    echo ""
    echo "  $fg[cyan] Usage:"
    echo ""
    echo "     $reset_color bsRebuild [options]"
    echo ""
    echo ""
    echo "  $fg[cyan] Options:"
    echo ""
    echo "     $fg[cyan] help, --help, -h"
    echo "        $reset_color Shows this help dialog"
    echo ""
    echo "     $fg[cyan] -f"
    echo "        $reset_color Runs in full rebuild mode.  When this flag is set, in addition to all"
    echo "       of the other build steps, the script will also completely remove and"
    echo "       re-clone BigSky from the remote repository, and perform additional steps."
    echo "       This can usually fix rare problems related to a corrupted or extremely"
    echo "       outdated file structure."
    echo ""
    echo "     $fg[cyan] -b <origin> <branch>"
    echo "        $reset_color When this flag is set, the specified remote branch is checked out and"
    echo "       used instead of master prior to running the rebuild steps."
    echo ""
    echo "     $fg[cyan] -s"
    echo "        $reset_color Skips many of the hefty rebuild steps (including ant full) and only"
    echo "       performs update/link steps.  This can often fix minor dependency and/or "
    echo "       linking issues that dont require a full rebuild."
    echo ""
    echo "     $fg[cyan] -l"
    echo "        $reset_color Skips almost all of the build steps and only links in external repos."
    echo ""
    echo "     $fg[cyan] -L"
    echo "        $reset_color Skips the link step."
    echo ""
    echo "     $fg[cyan] -r"
    echo "        $reset_color When the build completes, run bigsky (bsRunServer)."
    echo ""
    echo "     $fg[cyan] -u"
    echo "        $reset_color Update the local branch with remote updates (git pull)."
    echo ""
    if [[ $useDataStoreBackup == true ]]; then    
      echo "     $fg[cyan] -d <name>"
      echo "        $reset_color Backs up the datastore prior to build with the specified name."
      echo ""
    fi
    if [[ $useDataStoreRestore == true ]]; then    
      echo "     $fg[cyan] -D <name>"
      echo "        $reset_color Restores the datastore during build with the specified name."
      echo ""
    fi
    return 0
  fi

  echo "$fg[magenta]==============================\n    === BigSky Builder ===\n==============================$reset_color"

  # Dynamic argument parsing
  FlagFull=false
  FlagSkip=false
  FlagLinkOnly=false
  FlagSkipLink=false
  FlagBranch=false
  FlagDatastoreBackup=false
  FlagDatastoreRestore=false
  FlagRunBigSky=false
  FlagUpdate=false
  CurParamNum=1
  while true; do
    eval "CurParam=\$$CurParamNum"
    if [[ $CurParam == "" ]]; then
      break
    fi

    if [[ $CurParam =~ '^-.*f.*' ]]; then
      CurParam=$(stripString $CurParam f)
      FlagFull=true
      echo "$fg[cyan] $(bstimestamp) [bs build] -- Enabling full build (Repo nuke + full re-build)$reset_color"
    fi

    if [[ $CurParam =~ '^-.*s.*' ]]; then
      CurParam=$(stripString $CurParam s)
      FlagSkip=true
      echo "$fg[cyan] $(bstimestamp) [bs build] -- Skipping main build-steps$reset_color"
    fi

    if [[ $CurParam =~ '^-.*l.*' ]]; then
      CurParam=$(stripString $CurParam l)
      FlagLinkOnly=true
      echo "$fg[cyan] $(bstimestamp) [bs build] -- Only build repo links$reset_color"
    fi

    if [[ $CurParam =~ '^-.*L.*' ]]; then
      CurParam=$(stripString $CurParam L)
      FlagSkipLink=true
      echo "$fg[cyan] $(bstimestamp) [bs build] -- Skip building repo links$reset_color"
    fi

    if [[ $CurParam =~ '^-.*r.*' ]]; then
      CurParam=$(stripString $CurParam r)
      FlagRunBigSky=true
      echo "$fg[cyan] $(bstimestamp) [bs build] -- Running BigSky after build$reset_color"
    fi

    if [[ $CurParam =~ '^-.*u.*' ]]; then
      CurParam=$(stripString $CurParam u)
      FlagUpdate=true
      echo "$fg[cyan] $(bstimestamp) [bs build] -- Updating branch with remote server$reset_color"
    fi

    if [[ $CurParam =~ '^-.*b.*' ]]; then
      CurParam=$(stripString $CurParam b)
      FlagBranch=true

      # Parse extra param for the Branch Origin
      CurParamNum=$(($CurParamNum+1))
      eval "BranchOrigin=\$$CurParamNum"
      if [[ $BranchOrigin == "" || $BranchOrigin =~ '^-.*' ]] then
        echo "$fg[red] $(bstimestamp) [bs build] ERROR: This command requires at least two arguments following the -b parameter!  See 'bsRebuild --help' for more details.$reset_color"
        return 11
      fi

      # Parse extra param for the Branch Name
      CurParamNum=$(($CurParamNum+1))
      eval "BranchName=\$$CurParamNum"
      if [[ $BranchName == "" || $BranchName =~ '^-.*' ]] then
        echo "$fg[red] $(bstimestamp) [bs build] ERROR: This command requires at least two arguments following the -b parameter!  See 'bsRebuild --help' for more details.$reset_color"
        return 11
      fi

      echo "$fg[cyan] $(bstimestamp) [bs build] -- Building remote branch { $BranchOrigin $BranchName }$reset_color"
    fi

    if [[ $useDataStoreBackup == true && $CurParam =~ '^-.*d.*' ]]; then
      CurParam=$(stripString $CurParam d)
      FlagDatastoreBackup=true

      # Parse extra param
      CurParamNum=$(($CurParamNum+1))
      eval "DSBackup=\$$CurParamNum"
      if [[ $DSBackup == "" || $DSBackup =~ '^-.*' ]] then
        echo "$fg[red] $(bstimestamp) [bs build] ERROR: This command requires at least one argument following the -d parameter! (Backup name)  See 'bsRebuild --help' for more details.$reset_color"
        return 11
      fi

      echo "$fg[cyan] $(bstimestamp) [bs build] -- Backing up Datastore directory { $DSBackup }$reset_color"
    fi

    if [[ $useDataStoreRestore == true && $CurParam =~ '^-.*D.*' ]]; then
      CurParam=$(stripString $CurParam D)
      FlagDatastoreRestore=true

      # Parse extra param
      CurParamNum=$(($CurParamNum+1))
      eval "DSRestore=\$$CurParamNum"
      if [[ $DSRestore == "" || $DSRestore =~ '^-.*' ]] then
        echo "$fg[red] $(bstimestamp) [bs build] ERROR: This command requires at least one argument following the -D parameter! (Backup name)  See 'bsRebuild --help' for more details.$reset_color"
        return 11
      fi

      echo "$fg[cyan] $(bstimestamp) [bs build] -- Restoring Datastore directory { $DSRestore }$reset_color"
    fi    

    if [[ $CurParam =~ '^-.*h.*' || $CurParam =~ '^-.*help.*' || $CurParam =~ '^help' ]]; then
      bsRebuild help
      return 0
    fi

    if [[ ! $CurParam == "-" && ! $CurParam == "--" ]]; then
      echo "$fg[yellow] $(bstimestamp) [bs build] WARNING: Unrecognized command or parameters, $CurParam $reset_color"
    fi

    CurParamNum=$(($CurParamNum+1))
  done

  # Check to see whether Bigsky is currently running
  if [[ $BSVAR__Allow_Rebuild_When_Server_Running == false && $(isBigskyRunning) == true ]]; then
    echo "${CRED}Error, cannot execute this function while BigSky server is running.$reset_color"
    return 10
  fi

  cd "$BSVAR__Root_Workspace_Directory"
  gtsky

  if [[ $FlagLinkOnly == false ]]; then
  
    if [[ $FlagSkip == false ]]; then
      deactivate
      echo "$fg[cyan] $(bstimestamp) [bs build] Removing Sky Virtual Environment$reset_color"
      # TODO: Refactor 'sky' to use a less static target, such as a configurable (or check_virtualenv)
      rmvirtualenv sky
      rm -rf "$WORKON_HOME/sky/"
      echo "$fg[cyan] $(bstimestamp) [bs build] Backing up the untracked user-created files before git clean $reset_color"
      echo "$fg[cyan] $(bstimestamp) [bs build]   -- Backing up settingslocal.py...$reset_color"
      echo "$fg[cyan] $(bstimestamp) [bs build]   -- Backing up build-user.properties...$reset_color"
      echo "$fg[cyan] $(bstimestamp) [bs build]   -- Backing up tools/bulkdata/accounts.csv...$reset_color"
      copyStaticBigSkyFiles
    fi

    if [[ $FlagDatastoreBackup == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] Backing up the Local Datastore to $DSBackup $reset_color"
      dsBackup $DSBackup
    fi

    if [[ $FlagFull == true && $FlagSkip == false ]]; then

      cd ..
      if [[ -d bigsky ]]; then
        echo "$fg[cyan] $(bstimestamp) [bs build] Wiping the working BigSky directory...$reset_color"
        rm -rf bigsky
      else
        echo "$fg[cyan] $(bstimestamp) [bs build] No BigSky directory detected, creating one...$reset_color"
        cd -
      fi

      echo "$fg[cyan] $(bstimestamp) [bs build] Cloning new Repository...$reset_color"
      git clone $BSVAR__Bigsky_Fork

      cd bigsky

      echo "$fg[cyan] $(bstimestamp) [bs build] Building new Virtual Environment $reset_color"
      mkvirtualenv sky -a $PWD
      gtsky

      git remote -v
      echo "$fg[cyan] $(bstimestamp) [bs build] Updating Remote repository settings $reset_color"
      git remote remove origin
      git remote add origin $BSVAR__Bigsky_Fork
      git remote add trentgrover git@github.com:trentgrover-wf/bigsky.git
      git remote add robbielamb git@github.com:robbielamb-wf/bigsky.git
      git remote add mikethiesen git@github.com:mikethiesen-wf/bigsky.git
      git remote add timmccall git@github.com:timmccall-wf/bigsky.git
      git remote add jasonzerbe git@github.com:jasonzerbe-wf/bigsky.git
      git remote add upstream git@github.com:Workiva/bigsky.git
      git remote add CI git@github.com:codebuilders-wf/bigsky.git
      git remote -v

      if [[ $FlagBranch == true ]]; then
        echo "$fg[cyan] $(bstimestamp) [bs build] Fetching/Pruning remote $BranchOrigin $reset_color"
        git remote update --prune $BranchOrigin
        echo "$fg[cyan] $(bstimestamp) [bs build] Switching branches $reset_color"
        git checkout $BranchName
        git checkout -b $BranchName
        if [[ $FlagUpdate == true ]]; then
          git pull $BranchOrigin $BranchName
        fi
      fi

      # echo "$fg[cyan] $(bstimestamp) [bs build] Building libraries $reset_color"
      # brew install python --framework
      # sudo chown -R $BSVAR__User_Name /Library/Python/2.7/site-packages
      # wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python

      # ========= Temporary Issue workaround =========
      echo "$fg[cyan] $(bstimestamp) [bs build] Downgrading pip to v1.5.6 (Temporary issue workaround) $reset_color"
      pip install pip==1.5.6
      # ========= Temporary Issue workaround =========
  
      echo "$fg[cyan] $(bstimestamp) [bs build] Installing/Updating dependencies $reset_color"
      pip install gae_link_libs
      env CFLAGS="-Qunused-arguments" CPPFLAGS="-Qunused-arguments" pip install -Ur requirements_dev.txt
      pip install -r requirements.txt
      pip install -e .
      ant link-libs
      npm install -g n
      npm update
      bower update

      # ========= Temporary Issue workaround =========
      echo "$fg[cyan] $(bstimestamp) [bs build] Downgrading pip to v1.5.6 (Temporary issue workaround) $reset_color"
      pip install pip==1.5.6
      # ========= Temporary Issue workaround =========

    else

      if [[ $FlagSkip == false ]]; then
        echo "$fg[cyan] $(bstimestamp) [bs build] Building new Virtual Environment $reset_color"
        mkvirtualenv sky -a $PWD
        sky

        echo "$fg[cyan] $(bstimestamp) [bs build] Cleaning up Repository directory $reset_color"
        git reset --hard HEAD
        git clean -xfd
        yes | pycleaner
        if [[ $BSVAR__Run_Git_Garbage_Collection == true ]]; then        
          echo "$fg[cyan] $(bstimestamp) [bs build] Running git gc $reset_color"
          git gc --aggressive
        fi
      fi

      if [[ $FlagBranch == true ]]; then
        echo "$fg[cyan] $(bstimestamp) [bs build] Fetching/Pruning remote $BranchOrigin $reset_color"
        git remote update --prune $BranchOrigin
        echo "$fg[cyan] $(bstimestamp) [bs build] Switching branches $reset_color"
        git checkout $BranchName
        git checkout -b $BranchName
        if [[ $FlagUpdate == true ]]; then
          git pull $BranchOrigin $BranchName
        fi
      else
        echo "$fg[cyan] $(bstimestamp) [bs build] Fetching/Pruning origin branches $reset_color"
        git remote update --prune origin
        git checkout master
        if [[ $FlagUpdate == true ]]; then
          git pull origin master
        fi
      fi

    fi  

    gtsky

    if [[ $FlagSkip == false ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] Replacing untracked files backed up earlier $reset_color"
      replaceStaticBigSkyFiles
      echo "$fg[cyan] $(bstimestamp) [bs build] Creating and permissioning the /datastore/ directory $reset_color"
      mkdir ./datastore
      chmod og+w ./datastore
    fi

    # ========= Temporary Issue workaround =========
    echo "$fg[cyan] $(bstimestamp) [bs build] Downgrading pip to v1.5.6 (Temporary issue workaround) $reset_color"
    pip install pip==1.5.6
    # ========= Temporary Issue workaround =========
  
    echo "$fg[cyan] $(bstimestamp) [bs build] Installing/Updating dependencies $reset_color"
    git submodule update --init
    env CFLAGS="-Qunused-arguments" CPPFLAGS="-Qunused-arguments" pip install -Ur requirements_dev.txt

    # ========= Temporary Issue workaround =========
    echo "$fg[cyan] $(bstimestamp) [bs build] Downgrading pip to v1.5.6 (Temporary issue workaround) $reset_color"
    pip install pip==1.5.6
    # ========= Temporary Issue workaround =========

    npm update
    bower update
    if [[ $FlagSkip == false ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] Running BigSky build (ant full)... $reset_color"
      ant full
    fi

    echo "$fg[cyan] $(bstimestamp) [bs build] Running erase/reset script $reset_color"
    echo "$fg[cyan] $(bstimestamp) [bs build] ** Make sure the Python erase_reset_data.py script arguments match your user login credentials in ./tools/bulkdata/accounts.csv, or you may have problems running BigSky! $reset_color"

    if [[ $FlagDatastoreRestore == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] Restoring Datastore image to $DSRestore $reset_color"
      dsRestore $DSRestore
      if [[ $? == 11 ]]; then
        bsEraseReset      
      fi
    else
      bsEraseReset      
    fi

  else 
    if [[ $FlagBranch == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] Fetching/Pruning remote $BranchOrigin $reset_color"
      git remote update --prune $BranchOrigin
      echo "$fg[cyan] $(bstimestamp) [bs build] Switching branches $reset_color"
        git checkout $BranchName
        git checkout -b $BranchName
        if [[ $FlagUpdate == true ]]; then
          git pull $BranchOrigin $BranchName
        fi
    fi
  fi

  if [[ $FlagSkipLink == false ]]; then
    # =======================================================
    # Throw in some commands here to build bower/symlinks for development repos.
    # Pre-existing ones can also be toggled on/off by default by changing the install flag from false -> true
    # =======================================================
    
    echo "$fg[cyan] $(bstimestamp) [bs build] ===$fg[red] :: WARNING ::$fg[cyan] ===\n $(bstimestamp) [bs build] ** Linking in external development modules:$reset_color"

    # Link Reference Viewer
    installMe=false
    if [[ $installMe == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] -- 'wf-js-reference-viewer' via rv.sh$reset_color"
      cd apps
      ./rv.sh link
      cd ..
    fi

    # Link Doc-viewer
    installMe=false
    if [[ $installMe == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] -- 'sky-docviewer/wf-js-document-viewer' via pip install -e (liDocViewer())$reset_color"
      bsviewerize
    fi

    # Viewerize
    installMe=false
    if [[ $installMe == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] -- 'server_composition', 'wf-viewer-services', 'sky-docviewer/wf-js-document-viewer' via pip install -e (bsviewerize())$reset_color"
      bsviewerize
    fi

    # Link in w-annotation via SymLink
    installMe=false
    if [[ $installMe == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] -- 'w-annotation' via ln -s$reset_color"
      ln -s "$BSVAR__Root_Workspace_Directory"w-annotation/annotation annotation
    fi

    # Link in w-annotation via pip install
    installMe=false
    if [[ $installMe == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] -- 'w-annotation' via pip install -e$reset_color"
      pip uninstall -y w-annotation
      pip install -e ../w-annotation
    fi

    # Link in wf-sdk via pip install
    installMe=false
    if [[ $installMe == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] -- 'wf-sdk' via pip install -e$reset_color"
      yes | pip uninstall wf-sdk
      pip install -e ../wf-sdk
    fi

    # Copy Static w-annotation-js file into BigSky
    installMe=false
    if [[ $installMe == true ]]; then
      echo "$fg[cyan] $(bstimestamp) [bs build] -- 'w-annotation-js' via static file copy (copyStaticAnnotationFile())$reset_color"
      copyStaticAnnotationFile
      gtsky
    fi
  fi

  echo "$fg[green]====================================="
  echo "    === BigSky Build Complete ==="
  echo "=====================================$reset_color"

  if [[ $FlagRunBigSky == true ]]; then
    bsRunServer
  fi
}

rebuildSubRepo () {
  local MYDIR="$(getBaseDir)"
  echo "Running general Rebuild steps for Dev Repo '$MYDIR'"
  # Dependency Check
  which -s check_virtualenv &> /dev/null &&
  which -s activate_virtualenv &> /dev/null || {
    echo "$fg[red]Unable to rebuild; Missing dependency 'check_virtualenv'"
    return
  }
  local VENV=$(check_virtualenv)
  if [[ $VENV != "" ]]; then
    deactivate
    rmvirtualenv $VENV
  else
    echo "$fg[red]""Error, No VirtualEnvironment found for this repo.$reset_color"
    return 11
  fi
  mkvirtualenv $VENV -a $PWD
  activate_virtualenv

  # ========= Temporary Issue workaround =========
  echo "$fg[cyan] $(bstimestamp) [bs build] Downgrading pip to v1.5.6 (Temporary issue workaround) $reset_color"
  pip install pip==1.5.6
  # ========= Temporary Issue workaround =========
  pip install -e .
  npm install
  bower install

  git submodule sync && git submodule update --init --recursive

  if [[ -d bigsky ]]; then
    cd bigsky

    git remote remove origin
    git remote add origin git@github.com:robbielamb-wf/bigsky.git
    git remote remove upstream
    git remote add upstream git@github.com:Workiva/bigsky.git

    rm -rf datastore
    mkdir datastore
    replaceStaticBigSkyFiles

    # git checkout master
    # git pull upstream master
    # git push origin master

    # ========= Temporary Issue workaround =========
    echo "$fg[cyan] $(bstimestamp) [bs build] Downgrading pip to v1.5.6 (Temporary issue workaround) $reset_color"
    pip install pip==1.5.6
    # ========= Temporary Issue workaround =========    
    env CFLAGS="-Qunused-arguments" CPPFLAGS="-Qunused-arguments" 
    pip install -Ur requirements_dev.txt
    rm -rf external_libs
    ant link-libs

    echo -n "$fg[cyan]""Running specialized Rebuild steps for Dev Repo $reset_color"
    if [[ $MYDIR == "wf-js-document-viewer" ]]; then
      echo "wf-js-document-viewer"
      ./tools/link_assets.py sky.docviewer assets
      cd ..
      pip uninstall -y sky-docviewer
    elif [[ $MYDIR == "wf-viewer-services" ]]; then
      echo "wf-viewer-services"
      ./tools/link_assets.py wf.apps.books assets
      cd ..
      pip uninstall -y wf-viewer-services
    elif [[ $MYDIR == "wf-annotation-services" ]]; then
      echo "wf-annotation-services"
      cd ..
      pip uninstall -y wf-annotation-services
    else
      echo "Unrecognized repo, $MYDIR"
      cd ..
    fi

    # ========= Temporary Issue workaround =========
    echo "$fg[cyan] $(bstimestamp) [bs build] Downgrading pip to v1.5.6 (Temporary issue workaround) $reset_color"
    pip install pip==1.5.6
    # ========= Temporary Issue workaround =========
    pip install -e .

    cd bigsky
    #ant full
    cd ..
  else
    # ========= Temporary Issue workaround =========
    echo "$fg[cyan] $(bstimestamp) [bs build] Downgrading pip to v1.5.6 (Temporary issue workaround) $reset_color"
    pip install pip==1.5.6
    # ========= Temporary Issue workaround =========
    pip install -e .
  fi

  gulp
  grunt
}

# Big Sky Quick-Build and Run
alias bsqbar="bsRebuild -sLr -ub upstream master"

# This helper function determines whether a bigsky server is currently running
isBigskyRunning () {
  curl -s http://localhost:8001/home/
  if [[ $? == 0 ]]; then
    echo true
  else
    echo false
  fi
}

copyStaticBigSkyFiles() {
  cp settingslocal.py $BSVAR__BKDIR
  cp build-user.properties $BSVAR__BKDIR
  cp tools/bulkdata/accounts.csv $BSVAR__BKDIR
}


replaceStaticBigSkyFiles() {
  cp $BSVAR__BKDIR"settingslocal.py" $PWD
  cp $BSVAR__BKDIR"build-user.properties" $PWD
  cp $BSVAR__BKDIR"accounts.csv" $PWD"/tools/bulkdata/"
}

bsResetData () {
  gtsky
  rm -rf datastore
  mkdir datastore
  echo "
Stephen,Bush,stephen.bush@webfilings.com,w3b,,WebFilings,stephen.bush@webfilings.com,666-666-6667,555-555-5556,444-444-4445,333-333-3334,2131 North Loop Drive,,,Ames,IA,50011
Leroy,Jenkins,leroy@jenkins.com,m0r3pyl0ns!,,WebFilings,leroy@jenkins.com,666-666-6667,555-555-5556,444-444-4445,333-333-3334,2131 North Loop Drive,,,Ames,IA,50011
" > ./tools/bulkdata/accounts.csv
  bsEraseReset
}

bsEraseReset() {
  python tools/erase_reset_data.py \
    --admin="$BSVAR__EraseResetAdmin" \
    --password="$BSVAR__EraseResetPassword" \
    --enabled_settings= \
        enable_presentations, \
        enable_doc_viewer, \
        enable_charts, \
        enable_two_column, \
        enable_risk,enable_csr, \
        enable_books_viewer_comments, \
        enable_books_viewer_shared_comments, \
        enable_table_bullets, \
        enable_annotation_attachments, \
}

gtsky () {
  if [[ $VIRTUAL_ENV != "" ]]; then
    deactivate
  fi
  builtin cd ~/workspaces/wf/bigsky
  activate_virtualenv
}

function bsRunServer() {
  gtsky
  ./manage.py runserver 0.0.0.0:8001
}




# ==============================================================================
# Repo link aliases/scripts

copyStaticAnnotationFile () {
  cd "$BSVAR__Root_Workspace_Directory"w-annotation-js
  gulp build dist
  cp dist/w-annotation.js ../bigsky/static/js/annotation/w-annotation_1.js
}

# (From Tim McCall) Link in the viewers and stuff
alias bsviewerize=" 
  pip uninstall -y server_composition &&
  pip install -e ../server_composition &&
  pip uninstall -y wf-viewer-services &&
  pip install -e ../wf-viewer-services &&
  liDocViewer
  ant link-libs
"
# (From Tim McCall) Bower link in external modules
alias bla="bower link wf-js-annotations"
alias blc="bower link wf-common"
alias blrv="bower link wf-js-reference-viewer"
alias blui="bower link wf-uicomponents"
alias blv="bower link wf-js-viewer"


# (From Pat Kujawa) Link in the viewers and stuff
alias bspipssc="
  pip freeze | grep wd-sdk | read wfsdk &&
  bsrepip server-composition server-composition &&
  pip install $wfsdk
"

# (From Pat Kujawa) Link in pip modules and stuff
function bsrepip() {
  pipName=${1?"First arg needs to be the pip name of the lib"}
  # if none supplied, default to $1
  folderName=${2:-$pipName}
  workon sky &&
  pip uninstall -y $pipName &&
  pip install -e "../$folderName" &&
  ant link-libs
}

alias liDocViewer="
  pip uninstall -y sky-docviewer &&
  pip install -e ../wf-js-document-viewer &&
  ant link-libs &&
  ant link-doc-viewer &&
  ./tools/link_assets.py sky.docviewer assets
"

alias liBooks="
  bsrepip wf-books books &&
  ant generate-media &&
  ant link-libs &&
  ant link-books
"






# ==============================================================================
# Datastore Management, allows backing up and restoring of the local 
# Datastore directory in order to save settings, documents used for testing, 
# etc.  These functions should not be used while the BigSky server is running, 
# because the files are considered volatile and some elements may not be saved 
# until after the server is properly shut down.

dsBackup () {

  # Helper function for printing a timestamp in status messages
  function dstimestamp() {
    echo $(date -j "+%Y-%m-%d %H.%M.%S")
  }

  # Check to see whether Bigsky is currently running
  if [[ $BSVAR__Allow_Datastore_Imaging_When_Server_Running == false && $(isBigskyRunning) == true ]]; then
    echo "${CRED}Error, cannot execute this function while BigSky server is running.$reset_color"
    return 10
  fi

  # Create the main directory if it doesnt already exist
  if [[ ! -d $BSVAR__BKDIR"Datastore Images/" ]]; then
    mkdir $BSVAR__BKDIR"Datastore Images/"
  fi

  if [[ ${1} == "" ]]; then
    ImageName=$(dstimestamp)
  else
    ImageName=${1}
  fi

  if [[ -d $BSVAR__BKDIR"Datastore Images/$ImageName/" ]]; then
    # If the directory already exists, remove it so it can be replaced
    rm -rf $BSVAR__BKDIR"Datastore Images/$ImageName/"
  fi
  mkdir $BSVAR__BKDIR"Datastore Images/$ImageName/"

  if [[ -d datastore ]]; then
    cp -R datastore $BSVAR__BKDIR"/Datastore Images/$ImageName/datastore"
  fi
}

dsRestore () {

  if [[ ${1} == "" ]]; then
    echo "Select an available image:"

    for dir in $BSVAR__BKDIR"Datastore Images/"*; do
      echo " $fg[green] >$reset_color "$(getBaseDir $dir)
    done
    return 0
  fi

  # Check to see whether Bigsky is currently running
  if [[ $BSVAR__Allow_Datastore_Imaging_When_Server_Running == false && $(isBigskyRunning) == true ]]; then
    echo "${CRED}Error, cannot execute this function while BigSky server is running.$reset_color"
    return 10
  fi

  ImageName=${1}

  if [[ ! -d $BSVAR__BKDIR"Datastore Images/$ImageName/" ]]; then
    echo "Error, specified Backup image does not exist."
    return 11
  fi

  if [[ -d datastore ]]; then
    rm -rf datastore
  fi
  cp -R $BSVAR__BKDIR"Datastore Images/$ImageName/datastore/" datastore
}
# ==============================================================================

