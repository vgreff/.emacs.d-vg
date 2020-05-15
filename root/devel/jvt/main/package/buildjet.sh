#!/bin/bash
export JETVC='https://jumpgit/jet/jet.git'

export JETNOW=`date +%Y%m%d-%H%M%S`

export BUILD=~/BUILD
export JSROOT=$BUILD/jetstream/PROD

cd $BUILD/jvt/PROD/rules; source thirdparty.sh; 
cd $BUILD;

if [$JETREVISION -eq '']
then
    echo JETREVISION not set;
    return;
fi;

if [$JETPKGVERSION -eq '']
then
    echo JETPKGVERSION not set;
    return;
fi;

#svn co $JET/dev/jet_jvt_20110518_151 jet/$JETNOW -r $JETREVISION
cmd="git clone -b $JETREVISION $JETVC jet/$JETNOW "
echo $cmd
`$cmd`

cd $BUILD/jet;
/bin/rm -f PROD;
ln -s $JETNOW PROD;
cd PROD;
#/bin/rm -f JETDIR; ln -s jet-$JETPKGVERSION.jump1.00/home/jet/packages/$JETPKGVERSION JETDIR;
/bin/rm -f JETDIR; ln -s jet-$JETPKGVERSION.jump1.00 JETDIR;
printf "JET_DATE=$JETNOW\nJET_VERSION=$JETREVISION" > BLDINFO.sh;

cd $BUILD/jet/$JETNOW/jet
make -j world; make  install
cd $BUILD
