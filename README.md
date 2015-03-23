Repository Contents:
======================
- [Oh-My-ZSH Themes](#oh-my-zsh-themes)
  - [GitMod.zsh-theme](#gitmodzsh-theme)
- [Standalone Modules](#standalone-modules)
  - [BSRebuild.sh](#bsrebuildsh)
  - [ConfigWriter.sh](#configwritersh)
  - [TerminalVariables.sh](#terminalvariablessh)
  - [VirtualEnvHandler.sh](#virtualenvhandlersh)
- [Random Aliases/Functions](#random-aliasesfunctions)
  - [GitFunctions.sh](#gitfunctionssh)
  - [GeneralFunctions.sh](#generalfunctionssh)
  - [HyperTextStockShellAliases.sh](#hypertextstockshellaliasessh)
  
**Note:** Some of the documentation for these scripts is still spotty, but i've tried to design them to be as easy to integrate as possible.  Ping me on HipChat for help setting up any of these scripts.

Oh-My-ZSH Themes:
======================
#### GitMod.zsh-theme

**Note:** This script depends on ConfigWriter.sh in order to run effectively


Standalone Modules:
======================
#### BSRebuild.sh

#### ConfigWriter.sh
The purpose of this Script is to make management of one or more configuration files as simple, clean and performant as possible while providing a simple interface for interacting with them.

Configuration files can have many uses, including but not limited to:
  - Providing an interface for programmatically changing variables which can persist beyond closing and re-opening a terminal
  - Providing external channels for cross-thread communication

##### Functions:
- **config [commands|options]**
  - Commands:
    - help
      - Shows this help dialog.
    - add
      - Add a key to the config file.  Requires -k option, -v optional.
    - set
      - Set a key to a specified value.  Requires -k and -v options.
    - load
      - Load keys/values into the current environment. Optionally, the -k flag can be used to specify a specific key to load, else all values are loaded
    - reset
      - Remove and re-create the Config file.
  - Options:
    - --help, -h
      - Shows this help dialog.
    - -c
      - Specify a target config file.
    - -k
      - Specify a key in the config file.
    - -v
      - Specify a value in the config file.
      - NOTE: The empty string "" is considered a legal value for this option. Because of this, the -v option should be specified LAST in any 'config' command, to avoid the script accidently parsing other parameters as values in the case where an expression resolves to the empty string.


#### TerminalVariables.sh
Define and save commands unique to individual terminal IDs, to be run when called at the appropriate time.  Allows for a single command to cause different behavior in each window.

Terminal variables can have many uses, including but not limited to:
  - The ability to define certain values with distinct to each terminal
  - Programmatically set up different configuration settings for each terminal
  - Create a list of commands to be executed that is unique to each terminal

**Note:** This script depends on ConfigWriter.sh in order to run effectively

##### Functions:
- **setTerminalVariable \<Keyname\> \<Value\>**
  - Set a variable for the current Terminal ID with the specified key/value
- **getTerminalVariable \<Keyname\>**
  - Retrieve the specified variable for the current Terminal ID with the specified key

##### Getting Started with iTerm command bindings
1. Create an iTerm Window arrangement


#### VirtualEnvHandler.sh
This module gives you several useful functions as well as improved usability around Virtual Environment handling, including automatic VEnv detection in any directory (even nested subdirectories), *without* restrictions such as the need for a hidden `.venv` file or the VEnv to be named after the directory. (However, these popular optimizations are also incorporated to improve detection performance.)  It also features automatic activation/deactivation of these environments via the cd command.

**Note:** This script optionally uses functions from 'GeneralFunctions.sh' to improve performance and interoperability with other scripts.  However, if the desired functions are not available, alternatives are used instead to preserve functionality and supress errors.

##### Functions:
- **check_virtualenv \<directory\>** 
  - This function returns the name of the VEnv for the specified directory, or for the current PWD if none specified.
- **activate_virtualenv** 
  - This function will detect and activate the Virtual Environment for the current PWD, or deactivate if there is none associated with the current directory.
- **make_venv_file \<name_of_virtual_environment\>** 
  - Create a `.venv` file in the PWD with specified virtualenvironment.  This allows you to temporarily override the virtual environment for a directory if needed, as well as provide a faster mechanism for VEnv lookup in a directory.

##### Configurables:
- *VENVAR__Override_CD_Alias* 
  - Enables automatic VirtualEnv switching mode.  Extremely useful if you primarily navigate via `cd`, otherwise it could be inconsistent and unhelpful.  Can also integrate with addons like 'Autojump' if set up properly to do so.
- *VENVAR__Activate_Venv_In_Git_Dirs_Only* 
  - Only activate VenVs in git repos.  Recommended true, as any project using a Venv should be using Git!  Also, the git check happens first, and will short-circuit the more expensive venv detection checks if allowed to do so.  Especially if CD override is enabled.
- *VENVAR__Use_Workon* 
  - Use the workon command to activate the Virtual Environment.  This ensures that venv hooks are called, however, this also can have some unintended side-effects when auto-activating the Venv.  For instance, when activating a venv with a workon directory set, this may cause the pwd to jump to that directory, even if that's not the current pwd.
- *VENVAR__Recursively_Check_For_VirtualEnv*
  - Recursively check ascending directories looking for a virtual environment.  Recomended true, as this helps find the correct environment when jumping into a subdirectory prior to activation, but can also lead to increased lookup time.
- *VENVAR__Deactivate_Venv_When_None_Detected*
  - Deactivate the current virtual environment if none can be identified for the current directory. Recommended true



Random Aliases/Functions:
======================
#### GitFunctions.sh

#### GeneralFunctions.sh

#### HyperTextStockShellAliases.sh

