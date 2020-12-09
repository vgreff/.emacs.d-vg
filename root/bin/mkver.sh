#!/usr/bin/bash

MV="mv -f"

if test $# = "0"
then
     echo "usage: $0 file ..."
     exit 1
fi

for i in "$@"
do
   # keep 999 versions of pervious files
   

   if test -e $i
   then
       LAST=`ls -C1 -d ${i}.* |& fgrep -v "cannot access"|tail -1`
       LASTLEN=`echo $LAST |wc -m`
       LASTST=`expr  $LASTLEN - 3`
       if ((LASTLEN > 1));
       then
                   NB=`echo $LAST |cut -c${LASTST}-`
       else
                   NB=0
       fi
       NEXTNBVAL=`expr  $NB + 1`
       NEXTNB=`printf "%03d" ${NEXTNBVAL}`
       #echo $i ${i}.$NEXTNB
       ${MV} $i ${i}.$NEXTNB
   else
        printf  "warning: $i - no such file or directory\n"
   fi

done

#for i in `seq 1 10`; do VAR=`printf "%03d" $i`; echo $VAR;mkdir chi-ldbd211dir.foo.${VAR};  done


