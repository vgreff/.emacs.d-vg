#!/bin/bash
BUILD=~/BUILD
DEPLOY=DEPLOY

source $BUILD/jvt/PROD/BLDINFO.sh
echo $BUILD/jvt/PROD/BLDINFO.sh

cd $BUILD/jvt/PROD/rules; source thirdparty.sh; cd -


echo pushing build $JVT_DATE

if [ -z $JVT_DATE ]
then
echo "Can't identify right PROD"
return
fi

cd $BUILD/jet/PROD
/bin/tar cvfh ~/TAR/jvtbld.$JVT_DATE.tar jet-$JETPKGVERSION.jump1.00
cd $BUILD/jetstream/PROD
/bin/tar rvf ~/TAR/jvtbld.$JVT_DATE.tar jetstream/build
cd $BUILD/jvt/PROD
/bin/tar rvf ~/TAR/jvtbld.$JVT_DATE.tar jvt-1.0.0.jump1.00 rules/thirdparty.txt rules/thirdparty.sh package
/bin/gzip -f --fast ~/TAR/jvtbld.$JVT_DATE.tar

for i in oak-jvtworkl5 oak-jvtworkl4 oak-jvtworkl3 oak-jvtworkl2 oak-jvtworkl1
do
echo "scp to $i"
echo "/bin/mkdir -p $DEPLOY/$JVT_DATE; cd $DEPLOY/$JVT_DATE; /bin/tar xzf /tmp/jvtbld.$JVT_DATE.tar.gz"

scp ~/TAR/jvtbld.$JVT_DATE.tar.gz jvtapp@$i:/tmp/
ssh jvtapp@$i "cd ; /bin/mkdir -p $DEPLOY/$JVT_DATE; /bin/rm -rf $DEPLOY/$JVT_DATE/*; cd $DEPLOY/$JVT_DATE; /bin/tar xzf /tmp/jvtbld.$JVT_DATE.tar.gz; /bin/cp package/.bash_aliases ~/. ; /bin/cp package/envrun.sh .; cd ..; /bin/rm -f PROD; /bin/ln -s $JVT_DATE PROD"
done

cd $BUILD
return


