# ~/.profile: executed by the command interpreter for login shells.
# Contains various environment variables tweaking the behaviour, as well as any
# once-off setup that should be done on login.
# The counterpart containing per-shell settings is .bashrc, whereas any custom
# aliases have been place in .bash_aliases.

# The default umask creates files inaccessible to other users, for increased privacy.
umask 0077

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# === DOTFILES & SYSTEM CONFIGURATION ===
# Following code sets up the git repos for user-specific and system-wide custom configuration tracking;
# the commands for easily commiting to these repos are set up in .bash_aliases instead.

for name in dotfiles system-tweaks; do
	repo_dir="$HOME/Development/$name"
	if [ ! -d "$repo_dir" ]; then
		mkdir -p "$repo_dir"
	fi
	if [ "$( cd "$repo_dir" && git rev-parse --is-bare-repository )" != "true" ]; then
		# We clone using HTTPS URL (which does not require an SSH key), since we might not have
		# the key available yet, but once that's done, we switch to SSH URL; this allows us to
		# easily get the repo set up, but still uses secure SSH for any changes
		git clone --bare "https://github.com/D1SoveR/$name.git" "$repo_dir" || exit 1
		(
			cd "$repo_dir" &&
			git config status.showUntrackedFiles no &&
			git remote set-url origin "git@github.com:D1SoveR/$name.git"
		)
	fi
done

# === XDG DIRECTORY SPECIFICATION ===
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

# === GAMING ===
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

# === OTHER CUSTOMISATION ===

# Setup to ensure that all the applications have address of the SSH key agent.
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.sock"

# Defining preferred software based on current environment; if we're in local X session,
# use Sublime Text as editor and Firefox as browser; but if we're connecting remotely,
# use nano and lynx respectively.
if [[ -v DISPLAY ]] && [[ ! -v SSH_CLIENT ]] && [[ ! -v SSH_TTY ]]; then
	export VISUAL="subl --wait"
	export BROWSER="firefox"
else
	export VISUAL="nano"
	export BROWSER="lynx"
fi
export EDITOR=$VISUAL
export GIT_EDITOR=$EDITOR

# Disabling history for less
export LESSHISTFILE=-

# Adding support for nvm, the version manager for nodejs
# (this bit only installs it if it's not present to begin with; the code for
# loading up all its aliases and bash completion is available in .bashrc)
if [ ! -d "$NVM_DIR" ]; then
	wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
fi

# Execute per-shell setup as well
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
