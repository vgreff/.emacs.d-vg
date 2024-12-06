
if [ -z "${PATHORG+xxx}"  ]
then
     export PATHORG=$PATH
     export LD_LIBRARY_PATHORG=$LD_LIBRARY_PATH
fi



function setenv
{
    eval "$1='$2' export $1"
}

# setenv EDITOR emacs

#***********************************************************************
# git aliases
#***********************************************************************

alias gitr='git reset --hard ' 
alias gitcl='git clean -fdx ' 
alias gits='git status ' 
alias gitrc='gitr; gitcl; gits ' 
alias gitc='git clone ' 
alias gb='git branch ' 
alias gba='git branch -a' 
alias gco='git checkout ' 
alias gw='git worktree ' 
alias gwl='git worktree list' 
alias gwa='git worktree add' 
alias gr='git remote -v ' 

#*********** aliases  *****************************************************
alias bl="/bin/ls"
# alias l="ls -o"
alias l="ls -l"
alias lh="ls -lh"
alias la="ls -la"
alias ll="ls -Lo"
alias lr="ls -lrt"
#alias ls="ls -F"
alias bc="bc -l"
alias u="cd .."
alias rd="rm -rf "
alias md="mkdir -p "
alias h="history 10000"
alias pe='env|sort'
alias pej='env|sort| egrep "^J|^PATH|^LD_|^REPLAY"'
alias pep='env|sort| egrep "^PATH|^LD_"'
alias ssh='ssh -X '
alias now="date +%Y%m%d-%H%M%S"
alias today="date +%Y%m%d"
alias del=" /bin/rm -f  *~  .*~ *.bak .*.bak *.BAK ;find -L . -name \"*~\" -delete ; find -L . -name \"core\" -delete ;find -L . -name \".#*\" -delete ;"

alias ff='which '
alias trp="tr '\1\2\3' '|' "
alias vgc="g++ --version"


#*********** emacs  *****************************************************

function e
{
	emacs $* &
}

function et
{
	emacs $1 -T $1 &
}

function sm
{
	VGPWD=$PWD
	source ~/.bash_aliases
	cd $VGPWD
}

#***********************************************************************
# smiley & colors

# echo -e "☹ ☻ ✔"
# https://symbl.cc/en/collections/arrow-symbols/
# http://panmental.de/symbols/info.htm

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# if [ "$?" = "0" ]; then 	echo -e "${YELLOW}✔${NC}"; else 	echo -e "${RED}☹${NC} "; fi

#***********************************************************************

export LC_ALL=C

#***********************************************************************
# prompt 

#PS1='[$? \u@\h:\w]\$'
#PS1='$? \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$'
#PS1='$? \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \n \[\033[1;33m\]!\! :\[\033[00m\] '
#PS1='$? \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \n \[\033[1;33m\]!\! \[\033[00m\]➜ '
#PS1='$? $(if [ "$?" = "0" ]; then 	echo -e "\033[0;32m✔\033[0;0m"; else 	echo -e "\033[0;31m☹\033[0;0m "; fi) \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \n \[\033[1;33m\]!\! \[\033[00m\]➜ '

PS1='$? $(if [ "$?" = "0" ]; then 	echo -e "${YELLOW}✔${NC}"; else 	echo -e "${RED}☹${NC} "; fi) \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \n \[\033[1;33m\]!\! \[\033[00m\]➜ '

#***********************************************************************
export VGHOME=~/.emacs.d/
export VGROOT=$VGHOME/root
export VGCONF=$VGHOME/config


export PATH=.:$PATH:$VGROOT/bin/:~/bin/:~/.local/bin:


#unset MANPATH

alias dh='cd --'
shopt -s autocd    
shopt -s cdspell
shopt -s globstar

#***********************************************************************

# allow coredumps
ulimit -c unlimited

# emacs keybinding for the shell
set -o emacs

if [ -e ~/.bash_user ]; then
    . ~/.bash_user
# Source extra setting
elif [ -e ~/.bash_aliases-p72 ]; then
        . ~/.bash_aliases-p72
else
	if [ -e /etc/redhat-release -a -e /usr/bin/scl_source ]; then
		PATH=$PATH:/opt/rh/gcc-toolset-13/root/usr/bin/:/opt/rh/gcc-toolset-12/root/usr/bin/:/opt/rh/gcc-toolset-11/root/usr/bin/:/opt/rh/gcc-toolset-10/root/usr/bin/:/opt/rh/gcc-toolset-9/root/usr/bin/:
		MANPATH=:$MANPATH
		source scl_source enable gcc-toolset-13
		export VCPKG_ROOT="/home/vgreff/gh/oss/vcpkg"
		export PATH=$VCPKG_ROOT:$PATH
	fi
fi

