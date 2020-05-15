
export PATH=.:$PATH
cd $JVTROOT/rules
source thirdparty.sh
cd -

ulimit -c unlimited

alias callgrind="valgrind --tool=callgrind "

alias cjr='cd $JETROOT'
alias cjsr='cd $JETSTREAMROOT'
alias cjvr='cd $JVTROOT'

export JVT_DB='dbname=jvtdb port=5432 host=oak-jvtworkl1 user=jvt password=jvt123'
export JVT_SC_PORT=20011

export JETSTREAMRUNTIME=$JETSTREAMROOT/jetstream/build/pic/x86_64
export JETRUNTIME=$JETROOT/jet-$JETPKGVERSION.jump1.00/home/jet/packages/$JETPKGVERSION
export JVTRUNTIME=$JVTROOT/jvt-1.0.0.jump1.00/home/jvt/packages/1.0.0

export JSROOT=$JETSTREAMROOT


export PATH=.:$JVTRUNTIME/bin:$JETRUNTIME/bin:$JETSTREAMRUNTIME/bin:$VALGRINDROOT/bin:$KCACHEGRINDROOT/bin:$DOXYGENROOT/bin:$PATHORG
export LD_LIBRARY_PATH=$JVTRUNTIME/lib:$EXSTREAMSPEED/lib:$JETRUNTIME/bin:$JETSTREAMRUNTIME/lib:$JVTSQLAPI/lib:$JVTSYBASE/lib:$POSTGRESROOT/lib:$BOOST/lib:$EXSTREAMSPEED/lib:$VALGRINDROOT/lib/valgrind:$GSL/lib:$LD_LIBRARY_PATHORG

export RUBYLIB=$JVTROOT/ruby/codegenerator/lib 

