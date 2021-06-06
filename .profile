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
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export DVDCSS_CACHE="$XDG_CACHE_HOME/dvdcss/"
export GETIPLAYERUSERPREFS="$XDG_CONFIG_HOME/get-iplayer"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export HISTFILE="$XDG_CACHE_HOME/bash_history"
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export SSB_HOME="$XDG_DATA_HOME/zoom"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"

# The hook writes the REPL history to XDG-compliant directory instead of home
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/history_hook.py"

# === GAMING ===
# Any settings related to gaming setup should be put in this section.

# This environment variable allows Gallium Nine games to delay swapping the buffer until
# it finishes rendering, reducing micro-stuttering and screen tearing
# https://www.phoronix.com/scan.php?page=news_item&px=Gallium-Nine-Thread-Submit
export thread_submit=true

# Default setup for DXVK HUD - shows base driver information (useful for verifying ACO vs LLVM),
# FPS for measure, and frametimes graph to spot stuttering.
export DXVK_HUD="devinfo,fps,frametimes"

# Proton debugging goes into directory under cache
export PROTON_DEBUG_DIR="$XDG_CACHE_HOME/steam"

# This forces the Steam client to unmap the window when close button is clicked
# (default behaviour is to minimise it, keeping it in the windows bar).
export STEAM_FRAME_FORCE_CLOSE=1

# === OTHER CUSTOMISATION ===

# Set up the direction for notes application, used primarily for cool commands,
# tech notes, and the like.
export NOTES_DIRECTORY="$(xdg-user-dir DOCUMENTS)/Notes"
mkdir -p "$NOTES_DIRECTORY"

# This env var is used by Firefox along with some of its own internal settings
# to enable hardware-accelerated video decoding. The config props in question:
# * gfx.webrender.all                       -> true
# * gfx.webrender.compositor                -> true
# * media.ffvpx.enabled                     -> false
# * media.ffvpx.mp3.enabled                 -> false
# * media.ffmpeg.vaapi.enabled              -> true
# * media.ffmpeg.vaapi-drm-display.enabled  -> true
export MOZ_X11_EGL=1

# Setup to ensure that all the applications have address of the SSH key agent
# (but only if there's no previously set socket - it could be if SSH is run with
#  agent forwarding).
if [[ ! -v SSH_AUTH_SOCK ]]; then
	export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.sock"
fi

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
	wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh" | bash
fi

# Execute per-shell setup as well
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# === REMOTE SESSION ===
# If logging in remotely via SSH, start our default remote session.
# By having this option on by default, we won't be running into issues with accidentally
# starting long-running commands that will need connection kept to see the output of
# (it uses defaults provided by custom tmux wrapper to connect to the same session
#  across different logins).

[ ! -z "$SSH_TTY" ] && tmux
