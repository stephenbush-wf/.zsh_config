Repository Contents:
======================
- [Oh-My-ZSH Themes](#VirtualEnvHandler.sh)
  - [GitMod.zsh-theme](#GitMod.zsh-theme)
- [Standalone Modules](#Standalone Modules)
  - [BSRebuild.sh](#BSRebuild.sh)
  - [ConfigWriter.sh](#ConfigWriter.sh)
  - [OnLoad.sh](#onloadsh)
  - [VirtualEnvHandler.sh](#VirtualEnvHandler.sh)
- [Random Aliases/Functions](#Random Aliases/Functions)
  - [GitFunctions.sh](#GitFunctions.sh)
  - [GeneralFunctions.sh](#GeneralFunctions.sh)
  - [HyperTextStockShellAliases.sh](#HyperTextStockShellAliases.sh)

<a name="Oh-My-ZSH Themes"></a>Oh-My-ZSH Themes:
======================
#### <a name="GitMod.zsh-theme"></a>GitMod.zsh-theme



<a name="Standalone Modules"></a>Standalone Modules:
======================
#### <a name="BSRebuild.sh"></a>BSRebuild.sh

#### <a name="ConfigWriter.sh"></a>ConfigWriter.sh
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


#### <a name="OnLoad.sh"></a>OnLoad.sh


#### <a name="VirtualEnvHandler.sh"></a>VirtualEnvHandler.sh
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



<a name="Random Aliases/Functions"></a>Random Aliases/Functions:
======================
#### <a name="GitFunctions.sh"></a>GitFunctions.sh

#### <a name="GeneralFunctions.sh"></a>GeneralFunctions.sh

#### <a name="HyperTextStockShellAliases.sh"></a>HyperTextStockShellAliases.sh

