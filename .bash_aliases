# Collection of aliases for personal use and improved bash experience. :P

# Convenient ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# === DOTFILES & SYSTEM CONFIGURATION ===
# These two allow for easy tracking of changes to both user-specific and system-wide configuration,
# with help of detached git repo directory; likely used to save this very file (the actual repos
# are initialised in .bash_profile).

alias config-user='/usr/bin/git --git-dir=$HOME/Development/dotfiles/ --work-tree=$HOME'
alias config-system='/usr/bin/git --git-dir=$HOME/Development/system-tweaks/ --work-tree=/'

# === XDG DIRECTORY SPECIFICATION ===
# These aliases force various commands to be XDG directory-compliant where it can only be done with
# CLI arguments/options; we use aliases to "bake in" these options into their regular call signatures.

alias get-iplayer='get-iplayer --profile-dir "$XDG_CONFIG_HOME/get-iplayer"'