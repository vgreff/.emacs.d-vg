PS1='[%!]{%?} %n@%m:%~ : '

PATHORG=~/bin:$PATH
LD_LIBRARY_PATHORG=$LD_LIBRARY_PATH

source ~/.mykshrc

bindkey -e 
bindkey -s "^?" "\C-d"

bindkey  "\e[3~" delete-char-or-list
bindkey  "^?" backward-delete-char  

HISTSIZE=600
DIRSTACKSIZE=50

setopt autoPushd pushdMinus pushdSilent pushdToHome pushdIgnoreDups
setopt autoList autoMenu noListBeep listAmbiguous
setopt autoCd 
setopt mailWarning correct 
setopt longlistjobs nohup
setopt rmstarsilent

#setopt completeInWord alwaysToEnd
#setopt histIgnoreDups interactiveComments
#setopt globComplete noNoMatch
#setopt shWordSplit
#setopt appendHistory
#setopt NULL_GLOB

unsetopt bgnice

alias dh="dirs -v"

REPORTTIME=5


#  function incfiles 
#  {
#      reply=( /usr/wfg/include/*/(${1}*.[Hh]|${1}*)(:t) )
#  }
#  function elan 
#  {
#      reply=( `elconfig show -all | perl -nae '$i++; if ($i > 6) {printf("$F[0]\n");}'`)
#  }

#  compctl -K incfiles incp xincp

# Strip, profile, and debug only executables.  The compctls for the
# debuggers could be better, of course.
compctl -g '*(*)' strip gprof adb dbx xdbx ups

#compctl -k '(show add delete)' -x 'c[-1,show]' -k '(-all -configured -lecs -unit)' - 'c[-1,add]'  -K elan   - 'c[-1,delete]'  -K elan  -- elconfig
compctl -k '(optimize=1 cvskey cvs clean)' -g 'Makefile.*' make 

#hosts=($(ypcat hosts | perl -ne '($junk, @names) = split(/[\t ]+/, (split(/#/))[0]); print join(" ", @names), " "'))

#users=($(ypcat passwd | perl -ne '@names = split(/[:\t ]+/, (split(/#/))[0]); print $names[0], " "'))
#programmers=($(ypcat passwd | egrep ":11:|:100:" | perl -ne '@names = split(/[:\t ]+/, (split(/#/))[0]); print $names[0], " "'))
#libs=($(ls `cat /usr/wfg/lib/bld/version.prod`/wfg/lib/lib*.a | fgrep -v _ ))

# Completions
#compctl -K cdmatch -S '/' -x 'S[/][~]' -g '*(-/)' -- cd pushd
compctl -g '*.ps' + -g '*(-/)' gs ghostview
compctl -l '' nohup exec nice eval trap whence type
# If the command is rsh, make the first argument complete to hosts and treat the
# rest of the line as a command on its own.
compctl -k hosts -x 'p[2,-1]' -l '' -- rsh
compctl -k hosts -x 'c[-1,-l]' -u -- rlogin
compctl -k hosts telnet ping ssh
compctl -f -x 'R[-*d,^*]' -g '*.gz *.z *.Z' + -g '*(-/)' -- gzip
compctl -g '*.gz *.z *.Z' + -g '*(-/)' gunzip zcat zless
compctl -u -x 'w[2,-c] p[3,-1]' -l '' -- su
#compctl -k libs rebuild.pl
#compctl -k programmers locksrc

# xsetroot: gets possible colours, cursors and bitmaps from wherever.
# Uses two auxiliary functions.  You might need to change the path names.
#Xcolours() { reply=($(awk '{ print $4 }' < /usr/lib/X11/X11/rgb.txt)) }
#Xcursor() { reply=($(awk '/^#define/ {print $2}' \
#</usr/include/X11/cursorfont.h | sed 's/^XC_//')) }
#compctl -k '(-help -def -display -cursor -cursor_name -bitmap -mod -fg -bg
#  -grey -rv -solid -name)' -x 'c[-1,-display]' -k hosts -S ':0.0' - \
#  'c[-1,-cursor]' -f -  'c[-2,-cursor]' -f - \
#  'c[-1,-bitmap]' -g '/usr/include/X11/bitmaps/*' - \
#  'c[-1,-cursor_name]' -K Xcursor - \
#  'C[-1,-(solid|fg|bg)]' -K Xcolours -- xsetroot

compctl -v unset typeset declare vared readonly export integer








