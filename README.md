[link text](#VirtualEnvHandler.sh)

Oh-My-ZSH Themes:
======================
#### GitMod.zsh-theme



Standalone Modules:
======================
#### BSRebuild.sh

#### ConfigWriter.sh

#### <a name="VirtualEnvHandler.sh"></a>VirtualEnvHandler.sh
This module gives you several useful functions as well as improved usability around Virtual Environment handling, including automatic VEnv detection in any directory (even nested subdirectories), *without* restrictions such as the need for a hidden `.venv` file or the VEnv to named after the directory. (However, these popular optimizations are also incorporated to improve detection performance.)  It also features automatic activation/deactivation of these environments via the cd command

**check_virtualenv <directory>** -- This function returns the name of the VEnv for the specified directory, or for the current PWD if none specified.

**activate_virtualenv** --

**make_venv_file <name_of_virtual_environment>** -- Create a `.venv` file in the PWD with specified virtualenvironment.  This allows you to temporarily override the virtual environment for a directory if needed, as well as provide a faster mechanism for VEnv lookup in a directory.

##### Configurables:
*VENVAR__Override_CD_Alias* -- Enables automatic VirtualEnv switching mode.  Extremely useful if you primarily navigate via `cd`, otherwise it could be inconsistent and unhelpful.  Can also integrate with addons like 'Autojump' if set up properly to do so.

*VENVAR__Activate_Venv_In_Git_Dirs_Only* -- Only activate VenVs in git repos.  Recommended true, as any project using a Venv should be using Git!  Also, the git check happens first, and will short-circuit the more expensive venv detection checks if allowed to do so.  Especially if CD override is enabled.

*VENVAR__Use_Workon* -- Use the workon command to activate the Virtual Environment.  This ensures that venv hooks are called, however, this also can have some unintended side-effects when auto-activating the Venv.  For instance, when activating a venv with a workon directory set, this may cause the pwd to jump to that directory, even if that's not the current pwd.

*VENVAR__Recursively_Check_For_VirtualEnv* -- Recursively check ascending directories looking for a virtual environment.  Recomended true, as this helps find the correct environment when jumping into a subdirectory prior to activation, but can also lead to increased lookup time.

*VENVAR__Deactivate_Venv_When_None_Detected* -- Deactivate the current virtual environment if none can be identified for the current directory. Recommended true



Random Aliases/Functions:
======================
#### GitFunctions.sh

#### GeneralFunctions.sh

#### HyperTextStockShellAliases.sh

