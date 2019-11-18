# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Only show two directories in prompt to keep it from getting too long
PROMPT_DIRTRIM=2


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi
PROMPT_DIRTRIM=2
if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1)\n$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi



# Custom additions here
export PATH=${PATH}:${HOME}/Source/Scripts
export PATH=${PATH}:${HOME}/KlocWork/bin
#export PATH=${PATH}:${HOME}/klocwork/desktop/bin
export PATH=${PATH}:/usr/local/x-tools/powerpc-unknown-eabi/bin
export PATH=${PATH}:/usr/local/x-tools/mips-unknown-elf/bin

#export ECLIPSE_HOME=${HOME}/IDEs/eclipse
#alias eclipse='${ECLIPSE_HOME}/eclipse'
#export WORKON_HOME=~/VEs
#export VIRTUALENVWRAPPER_PYTHON=`which python2`

# Handy Git Shortcuts
alias gits='git branch && git status'
alias gitc='git checkout'
alias gita='git add'
alias gitm='git merge'
alias gitu='git fetch && git pull && git submodule update'
alias stfu='eval $(ssh-agent) && ssh-add'
alias lc=${HOME}/Source/Scripts/lastChanges.sh

# start CLion with clion command
alias clion='/opt/clion-2018.3.4/bin/clion.sh'

# "Disk Usage Here"
alias duh='du -b -d 1 | sort -n'

# Formatted Directory listing
alias dir='lsr=`ls -lA --color=always` && \
         echo "$lsr" | grep "^d" | more && \
         echo "$lsr" | grep -v "^d" | more'

# Directory listing, plus git status if it exists
alias d='dir; echo; if [ -e .git ]; then gits; fi'

# Handy grep functions
function grep_common()
{
    ffilter=$1
    shift
    args=( "$@" )
    numargs=${#args[@]}

    path="."
    if [ "$#" -gt 1 ]
    then
        lastarg=${args[@]:(-1)}
        if [ -f "$lastarg" ]
        then
            path="$lastarg"
            unset args[$numargs-1]
            numargs=${#args[@]}
        else
            if [ -d "$lastarg" ]
            then
                path="$lastarg"
                unset args[$numargs-1]
                numargs=${#args[@]}
            else
                find $lastarg 1> /dev/null 2>&1
                ret=$?
                if [ "$ret" -eq 0 ]
                then
                    path="$lastarg"
                    unset args[$numargs-1]
                    numargs=${#args[@]}
                fi
            fi
        fi
    fi

    flags=""
    pattern=""
    if [ "$numargs" -gt 1 ]
    then
        lastarg=${args[@]:(-1)}
        pattern=$lastarg
        unset args[$numargs-1]
        numargs=${#args[@]}

        flags="${args[@]}"
    else
        pattern="${args[0]}"
    fi
    #echo "PATH: $path"
    #echo "FLAG: $flags"
    #echo "PATTERN: $pattern"
    #echo "FILTER: $ffilter"
    eval find $path -type f "\( $ffilter \)" | grep -v *.pb.* | xargs grep --color=auto $flags "$pattern"
}
function pygrep()
{
    if [ "$#" -eq 0 ]
    then
        echo "Usage: pygrep [OPTIONS] PATTERN [FILE]"
        return
    fi

    grep_common ' \( -iname \*.py \) ! -iname "*_pb2.py" ' "$@"
}
function cgrep()
{
    if [ "$#" -eq 0 ]
    then
        echo "Usage: cgrep [OPTIONS] PATTERN [FILE]"
        return
    fi

    grep_common ' \( -iname \*.cpp -o -iname \*.h -o -iname \*.c -o -iname \*.hpp -o -iname \*.str \) ! -iname "*.pb.*"' "$@"

}
function jgrep()
{
    if [ "$#" -eq 0 ]
    then
        echo "Usage: jgrep [OPTIONS] PATTERN [FILE]"
    fi

    grep_common ' \( -iname \*.java -o -iname \*.xml -o -iname \*.str  \) ! -iname "*.pb.*"' "$@"
}

# teh lolz
fortune | cowsay -f $(shuf -n1 -e /usr/share/cowsay/cows/*) | lolcat

export HISTTIMEFORMAT="%d%m%y %T "


alias lock='i3lock -c 000000'

function tarup()
{
    if [ "$#" -ne 1 ]
    then 
	echo "Can't tarup -- accepts only single argument (file or dir)"
    fi
    
    if [[ -d "$1" || -f "$1" ]]
    then
	tar -czvf "$1.tar.gz" "$1"
    else
	echo "Can't tarup '$1' -- argument is not a directory or file"
    fi
}

alias untar='tar -xzvf'
alias cdhere='cd $(pwd)'
alias lh='ls -lh'
alias diff='git diff --no-index'
alias watch='watch '
