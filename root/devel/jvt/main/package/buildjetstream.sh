#!/bin/bash

export BUILD=~/BUILD
export JETSTREAMVC='https://jumpgit/jetstream/jetstream.git'
export JETSTREAMNOW=`date +%Y%m%d-%H%M%S`

cd $BUILD/jvt/PROD/rules; source thirdparty.sh; cd $BUILD;

if [$JETSTREAMREVISION -eq '']
then
    echo JETSTREAMREVISION not set;
    return 1;
fi;

if [$JETSTREAMPKGVERSION -eq '']
then
    echo JETSTREAMPKGVERSION not set;
    return 1;
fi;

#echo "svn co $JETSTREAM jetstream/$JETSTREAMNOW -r $JETSTREAMREVISION"
cmd="git clone $JETSTREAMVC jetstream/$JETSTREAMNOW "
echo $cmd
`$cmd`

cd $BUILD/jetstream; /bin/rm -f PROD; ln -s $JETSTREAMNOW PROD; cd PROD;
/bin/rm -f jetstream-*-binary; ln -s jetstream jetstream-$JETSTREAMPKGVERSION-binary;

printf "JS_DATE=$JETSTREAMNOW\nJS_VERSION=$JETSTREAMREVISION" > BLDINFO.sh;

cd jetstream
make -j;
export MACHINE=pic_x86_64; make -j;

cd $BUILD
