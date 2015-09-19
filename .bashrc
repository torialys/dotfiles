#
#                        __ ____    _____        _    __ _ _
#                       /_ |___ \  |  __ \      | |  / _(_) |
#                ___ __ _| | __) | | |  | | ___ | |_| |_ _| | ___  ___
#               / __/ _` | ||__ <  | |  | |/ _ \| __|  _| | |/ _ \/ __|
#              | (_| (_| | |___) | | |__| | (_) | |_| | | | |  __/\__ \
#               \___\__,_|_|____/  |_____/ \___/ \__|_| |_|_|\___||___/
#
#################################################################################
# ENVIRONMENT
#################################################################################

# System OS
# ---------
export PLATFORM=$(uname -s)
[ -f /etc/bashrc ] && . /etc/bashrc

BASE=$(dirname $(readlink $BASH_SOURCE))

# do not continue if we are not in a bash shell
[ -z "$BASH_VERSION" ] && return

# do not continue if we are not running interactively
[ -z "$PS1" ] && return

# Better-looking less for binary files
[ -x /usr/bin/lesspipe    ] && eval "$(SHELL=/bin/sh lesspipe)"

# Bash completion
if [ -f /usr/local/etc/bash_completion ]; then
  source /usr/local/etc/bash_completion
elif [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# Set PATH so it includes user bin if it exists.
[ -d "$HOME/bin" ] && PATH=$HOME/bin:$PATH

if [ -d "$HOME/.rbenv/bin" ]; then
  PATH=$HOME/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
fi

[ -d "$HOME/.pear/bin" ] && PATH=$HOME/.pear/bin:$PATH

[ -d "$HOME/.composer/vendor/bin" ] && PATH=$HOME/.composer/vendor/bin:$PATH

if [ "$PLATFORM" = Darwin ]; then
  PATH="$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin"
  PATH="$PATH:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
fi

export PATH

# Enable some Bash 4 features when possible
# checkwinsize : Update $LINES and $COLUMNS after each command
# histappend : Append to the history file
# autocd : e.g $(**/dir) will enter $(./foo/bar/baz/dir)
# globstart : recursive globbing, eg $(echo **/*.txt)
for option in checkwinsize histappend autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

# History
export HISTCONTROL=erasedups:ignoreboth
export HISTSIZE=
export HISTFILESIZE=
export HISTTIMEFORMAT="%d/%m/%Y %H:%M:%S:   "
export HISTIGNORE='cd:ls:l:ll:la:lk:lh:lr:lo:q:s:c:history:h:hgrep:alg:v:o:st:a:sb'

[ -z "$TMPDIR" ] && TMPDIR=/tmp
export EDITOR=vim
export LANG=fr_FR.UTF-8
[ "$PLATFORM" = 'Darwin' ] || export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.:/usr/local/lib

command -v docker-machine > /dev/null 2>&1 && eval "$(docker-machine env default)"

# Load Homebrew GitHub API key
[ -s ~/.brew_github_api ] && export HOMEBREW_GITHUB_API_TOKEN=$(cat ~/.brew_github_api)

# Init z https://github.com/rupa/z
[ -f ~/z/z.sh ] && . ~/z/z.sh

#################################################################################
# ALIASES
#################################################################################

# Sudo
# ----
# The space following sudo tells tells bash to check if the command that follow the space is also an alias
alias sudo='sudo '

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

# ls
# --
if [ "$PLATFORM" = Darwin ]; then
  export LSCOLORS=GxFxCxDxBxegedabagaced
  alias ls="command ls -G"
elif [ "$PLATFORM" = MINGW32 ]; then
  export LS_COLORS='di=01;36'
  alias pt='pt --nocolor'
else
  alias ls="command ls -F --color=auto"
  export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
fi

alias l='ls -al'
alias ll='ls -l'
alias la='ls -a'
alias lk='ls -lah  | grep "\->" 2> /dev/null || echo "no symlinked files here..."'
alias lh='ls .???* 2> /dev/null || echo "no hidden files here..."'
alias li='ls -lai'
alias lr="ls -l | grep '^d'"
# List ALL files (colorized() in long format, show permissions in octal
alias lo="ls -laF | awk '
{
  k=0;
  for (i=0;i<=8;i++)
    k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));
  if (k)
    printf(\"%0o \",k);
  print
}'"

# Misc
# ----
alias vi='vim'
alias h='history'
alias c='clear'
alias s='cd .. && ls -ltr'
alias q='exit'
alias sb='source ~/.bashrc'
alias rmf='rm -rf'
alias grep='grep --color=auto'
alias hgrep='history | grep'
alias alg='alias | grep'
alias ip="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias hosts='sudo $EDITOR /etc/hosts'
# View HTTP traffic
alias sniff="sudo ngrep -d 'en3' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en3 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Veewee
# ------
command -v bundle > /dev/null 2>&1 && alias veewee='bundle exec veewee'

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null 2>&1 || alias hd="hexdump -C"

# Make Grunt print stack traces by default
command -v grunt > /dev/null 2>&1 && alias grunt="grunt --stack"

# Use always htop if installed
command -v htop > /dev/null 2>&1 && alias top='htop'

if [ "$PLATFORM" = Darwin ]; then

  command -v md5sum > /dev/null || alias md5sum="md5"

  command -v sha1sum > /dev/null || alias sha1sum="shasum"

  alias pb="tr -d '\n' | pbcopy"

  # Recursively delete `.DS_Store` files
  alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

  # Show/hide hidden files in Finder
  alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

  # Hide/show all desktop icons (useful when presenting)
  alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

fi

# Git
# ---
# command -v hub > /dev/null 2>&1 || alias git="hub"
alias gitl='git log --graph --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

# Bookmarks
# ---------
# show pour voir la liste des bookmarks existants
# save foo sauvergarde le dossier courant dans le bookmark foo
# cd foo pour y revenir
[ ! -f ~/.dirs ] && touch ~/.dirs

alias show='cat -n ~/.dirs | sed "s/^\([^.]*\)\=\(.*\)/-\1 --> \2/g"'
save (){ command sed "/!$/d" ~/.dirs > ~/.dirs1; \mv ~/.dirs1 ~/.dirs; echo "$@"=\"`pwd`\" >> ~/.dirs; source ~/.dirs ;}
source ~/.dirs  # initialisation de la fonction 'save': source le fichier .sdirs

if [ "$PLATFORM" = Darwin ]; then
  alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install -g npm@latest; sudo gem update --system; sudo gem update'
fi

#################################################################################
# PROMPT
#################################################################################

# Max prompt
# ----------
if [ "$PLATFORM" != Linux ]; then
  PS1="\[\e[1;38m\]\u\[\e[1;34m\]@\[\e[1;31m\]\h\[\e[1;30m\]:"
  PS1="$PS1\[\e[0;38m\]\w\[\e[1;35m\]> \[\e[0m\]"
else
  # git-prompt
  __git_ps1() { :;}
  if [ -e ~/.git-prompt.sh ]; then
    source ~/.git-prompt.sh
  fi
  PROMPT_COMMAND='history -a; history -c; history -r; printf "\[\e[38;5;59m\]%$(($COLUMNS - 4))s\r" "$(__git_ps1) ($(date +%d/%m\ %H:%M:%S))"'
  # PROMPT_COMMAND='history -a; printf "\[\e[38;5;59m\]%$(($COLUMNS - 4))s\r" "$(__git_ps1) ($(date +%d/%m\ %H:%M:%S))"'
  PS1="\[\e[34m\]\u\[\e[1;32m\]@\[\e[0;33m\]\h\[\e[35m\]:"
  PS1="$PS1\[\e[m\]\w\[\e[1;31m\]> \[\e[0m\]"
fi

# Mini prompt
# -----------
miniprompt() {
  unset PROMPT_COMMAND
  PS1="\[\e[38;5;168m\]> \[\e[0m\]"
}

#################################################################################
# FUNCTIONS
#################################################################################

# Create a new directory and enter it
mkd() {
  mkdir -p "$@" && cd "$_";
}

# change to parent directory matching partial string, eg:
# in directory /home/foo/bar/baz, 'bd f' changes to /home/foo
bd () {
  local old_dir=`pwd`
  local new_dir=`echo $old_dir | sed 's|\(.*/'$1'[^/]*/\).*|\1|'`
  index=`echo $new_dir | awk '{ print index($1,"/'$1'"); }'`
  if [ $index -eq 0 ] ; then
    echo "No such occurrence."
  else
    echo $new_dir
    cd "$new_dir"
  fi
}

# `st` with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
st() {
  if [ $# -eq 0 ]; then
    command -v subl > /dev/null 2>&1 || subl .;
  else
    command -v subl > /dev/null 2>&1 || subl "$@";
  fi;
}

# `a` with no arguments opens the current directory in Atom Editor, otherwise
# opens the given location
a() {
  if [ $# -eq 0 ]; then
    command -v subl > /dev/null 2>&1 || atom .;
  else
    command -v subl > /dev/null 2>&1 || atom "$@";
  fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
v() {
  if [ $# -eq 0 ]; then
    command -v subl > /dev/null 2>&1 || vim .;
  else
    command -v subl > /dev/null 2>&1 || vim "$@";
  fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
o() {
  if [ $# -eq 0 ]; then
    command -v subl > /dev/null 2>&1 || open .;
  else
    command -v subl > /dev/null 2>&1 || open "$@";
  fi;
}

# Setup paths
remove_from_path() {
  [ -d $1 ] || return
  # Doesn't work for first item in the PATH but don't care.
  export PATH=$(echo $PATH | sed -e "s|:$1||") 2>/dev/null
}

add_to_path_start() {
  [ -d $1 ] || return
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

add_to_path_end() {
  [ -d "$1" ] || return
  remove_from_path "$1"
  export PATH="$PATH:$1"
}

force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

quiet_which() {
  which $1 1>/dev/null 2>/dev/null
}

rvm() {
  # Load RVM into a shell session *as a function*
  if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    unset -f rvm

    [ ! -e "$HOME/.rvmrc" ] && echo "rvm_autoupdate_flag=2" >> "$HOME/.rvmrc"

    source "$HOME/.rvm/scripts/rvm"
    # Add RVM to PATH for scripting
    PATH=$PATH:$HOME/.rvm/bin
    rvm $@
  fi
}

# Start an HTTP server from a directory, optionally specifying the port
server() {
  local port="${1:-8000}";
  sleep 1 && open "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Create a git.io short URL
gitio() {
  if [ -z "${1}" -o -z "${2}" ]; then
    echo "Usage: \`gitio slug url\`";
    return 1;
  fi;
  curl -i http://git.io/ -F "url=${2}" -F "code=${1}";
}

# Determine size of a file or total size of a directory
fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* *;
  fi;
}

#################################################################################
# LOCAL
#################################################################################

LOCAL=$BASE/.bashrc.local
[ -f "$LOCAL" ] && source "$LOCAL"
