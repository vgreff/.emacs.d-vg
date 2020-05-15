if [ -z "${PATHORG+xxx}"  ]
then
     export PATHORG=$PATH
     export LD_LIBRARY_PATHORG=$LD_LIBRARY_PATH
fi

function setenv
{
    eval "$1='$2' export $1"
}

setenv EDITOR emacs


alias bl="/bin/ls"
alias l="ls -o"
alias lg="ls -l"
alias la="ls -la"
alias ll="ls -Lo"
alias lr="ls -og"
alias ls="ls -F"
alias bc="bc -l"
alias u="cd .."
alias rd="rm -rf "
alias md="mkdir -p "
alias h="history 10000"
alias pe='env|sort'
alias pej='env|sort| egrep "^J|^PATH|^LD_"'
alias pep='env|sort| egrep "^PATH|^LD_"'
alias ssh='ssh -X '
alias now="date +%Y%m%d-%H%M%S"
alias del=" /bin/rm -f  *~  .*~ *.bak .*.bak *.BAK ;find -L . -name \"*~\" -delete ;find -L . -name \"core\" -delete ; ;find -L . -name \".#*\" -delete ;"

alias ssyb='. /opt/jump/x86_64/sybase-15.0-JUMP1.00/SYBASE.sh'
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

#*********** GIT stuff *************************************************************
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
function gd2 { 
 echo branch \($1\) has these commits and \($2\) does not 
 git log $2..$1 --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local
}
function grin {
git fetch origin master
gd2 FETCH_HEAD $(parse_git_branch)
}
function grout {
git fetch origin master
gd2 $(parse_git_branch) FETCH_HEAD
}
#***********************************************************************

. ~/DEPLOY/PROD/envrun.sh
