# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# ==== DOTFILES & SYSTEM CONFIGURATION ====
# Following code sets up aliases for saving any changes either to user-specific dotfiles, or system configuration,
# into detached git repository. These are used to preserve any other system customisation.

for name in dotfiles system-tweaks; do
	repo_dir="$HOME/Development/$name"
	if [ ! -d "$repo_dir" ]; then
		mkdir -p "$repo_dir"
	fi
	if [ "$( cd "$repo_dir" && git rev-parse --is-bare-repository )" != "true" ]; then
		git init --bare "$repo_dir" || exit 1
		(cd "$repo_dir" && git config status.showUntrackedFiles no)
	fi
done

alias config-user='/usr/bin/git --git-dir=$HOME/Development/dotfiles/ --work-tree=$HOME'
alias config-system='/usr/bin/git --git-dir=$HOME/Development/system-tweaks/ --work-tree=/'

# ==== XDG DIRECTORY SPECIFICATION ====
# Following bits attempt to make as much software behave in XDG-compliant way as possible,
# explicitly moving their configuration, cache, and other local data into XDG-defined directories,
# and keeping the home directory bit tidier.

# Defining XDG base dir variables, so that they can be consistently used with software
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"

# Configuring XDG-compliant paths to various configuration files
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME/android"
export DVDCSS_CACHE="$XDG_CACHE_HOME/dvdcss/"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export HISTFILE="$XDG_CACHE_HOME/bash_history"
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"

# The hook writes the REPL history to XDG-compliant directory instead of home
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/history_hook.py"

alias get-iplayer='get-iplayer --profile-dir "$XDG_CONFIG_HOME/get-iplayer"'

# ====== GAMING ======
# Any settings related to gaming setup should be put in this section.

# Vulkan setup:
# With both mesa and amdvlk installed, one of the drivers should be set up as default
# (otherwise the Vulkan layer selected at runtime is undefined). We go with mesa as
# default Vulkan implementation, and should be able to use amdvlk by providing
# alternative ICD paths.
# https://wiki.archlinux.org/index.php/Vulkan#Nvidia_-_vulkan_is_not_working_and_can_not_initialize
export VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/radeon_icd.x86_64.json"
#export VK_ICD_FILENAMES="/etc/vulkan/icd.d/amd_icd64.json"

# This environment variable allows Gallium Nine games to delay swapping the buffer until
# it finishes rendering, reducing micro-stuttering and screen tearing
# https://www.phoronix.com/scan.php?page=news_item&px=Gallium-Nine-Thread-Submit
export thread_submit=true

# Proton debugging goes into directory under cache
export PROTON_DEBUG_DIR="$XDG_CACHE_HOME/steam"

# ====== OTHER CUSTOMISATION ======

# Defining preferred text editor; Sublime Text when working locally within X session,
# nano otherwise (either remotely, or on non-X session)
if [[ -v DISPLAY ]] && [[ ! -v SSH_CLIENT ]] && [[ ! -v SSH_TTY ]]; then
	export VISUAL="subl --wait"
else
	export VISUAL="nano"
fi
export EDITOR=$VISUAL

# Git configuration
export GIT_EDITOR=$EDITOR

# Disabling history for less
export LESSHISTFILE=-

# Adding support for nvm, the version manager for nodejs
if [ ! -d "$NVM_DIR" ]; then
	wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Adding git bash prompt, to list repo status when in terminal
GIT_PROMPT_ONLY_IN_REPO=1
[ -s "$XDG_DATA_HOME/bash-git-prompt/gitprompt.sh" ] && source $XDG_DATA_HOME/bash-git-prompt/gitprompt.sh
