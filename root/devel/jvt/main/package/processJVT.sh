#!/bin/bash

# without paramters will checkout jvt repository using current time and build
# if parameter PROD specified will rebuilt current jvt/PROD version

export JVTNOW=`date +%Y%m%d-%H%M%S`
export BUILD=~/BUILD
export JVT="https://jvtgit.w2k.jumptrading.com/JVT/jvt.git"

cd $BUILD

if [ -z $1 ]
then
printf "No arguments provided.\n"
printf "USAGE:\n"
printf " CHECKOUT - Checkout latest JVT version. Set jvt/PROD link to point to it\n"
printf " PROD     - Build version that jvt/PROD link pointing to\n"
printf " NEW      - Checkout and build latest JVT version. Set jvt/PROD link to point to it\n"
return
fi

BLDFOLDER=$JVTNOW
MYARG=$1

if [ $MYARG != "CHECKOUT" -a $MYARG != "NEW" -a $MYARG != "PROD" ]
then
printf "ERROR: unknown argument $MYARG\n"
printf "USAGE:\n"
printf " CHECKOUT - Checkout latest JVT version. Set jvt/PROD link to point to it\n"
printf " PROD     - Build version that jvt/PROD link pointing to\n"
printf " NEW      - Checkout and build latest JVT version. Set jvt/PROD link to point to it\n"
return
fi

if [ $MYARG = "CHECKOUT" -o $MYARG = "NEW" ]
then
git clone $JVT jvt/$JVTNOW
printf "JVT_DATE=$JVTNOW\nJVT_VERSION=main" > jvt/$JVTNOW/BLDINFO.sh;

echo "CHECKOUT of jvt ($JVTNOW) completed."
echo "Set PROD -> $JVTNOW"
cd $BUILD/jvt; /bin/rm -f PROD; ln -s $JVTNOW PROD; cd $BUILD;

 if [ $MYARG = "CHECKOUT" ]
 then
     return
 fi
fi

if [ $MYARG = "PROD" ]
then
source jvt/PROD/BLDINFO.sh
echo "No checkout. Building $JVT_DATE"
BLDFOLDER='PROD'
fi

#cd jvt/$BLDFOLDER/rules
#source thirdparty.sh
#cd $BUILD/jvt/$BLDFOLDER/cpp

export JETSTREAMROOT=$BUILD/jetstream/PROD
export JETROOT=$BUILD/jet/PROD
export JVT_PACKAGE=jvt-1.0.0.jump1.00/home/jvt/packages/1.0.0
export JVTROOT=$BUILD/jvt/$BLDFOLDER
export RUBYLIB=$JVTROOT/ruby/codegenerator/lib
#export PATH=.:$JVTROOT/$JVT_PACKAGE/bin:$PATHORG
#export LD_LIBRARY_PATH=$JVTROOT/$JVT_PACKAGE/lib:$LD_LIBRARY_PATHORG

jvt/$BLDFOLDER/
source envdev.sh
cd $BUILD/jvt/$BLDFOLDER/cpp

# do the build
make -j
MYMAKERC=$?
printf "BUILD of jvt PROD ($JVTNOW) completed with rc=$MYMAKERC\n"

# if [ $MYMAKERC -ne 0 ]
# then
#   printf "Don't set the PROD link\n"
#   cd $BUILD
#   return
# fi

# if [ $MYARG = "NEW" ]
# then
# echo "Set PROD -> $JVTNOW"
# cd $BUILD/jvt; /bin/rm -f PROD; ln -s $JVTNOW PROD; cd $BUILD; echo "CHECKOUT of jvt ($JVTNOW) completed."
# fi

cd $BUILD
