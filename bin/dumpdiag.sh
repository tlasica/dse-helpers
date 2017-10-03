# Dumps important DSE diagnostics such as: logs, jfr, conf and threaddump
# into 4 files: conf.tar.gz, logs.tar.gz, threaddump.txt and dse.jfr
# into a directory specified as $1

if [ -z "$1" ]
then
    echo "Usage: dumpdiag.sh dir"
    echo
    exit 1
fi

OUTDIR=$1

mkdir -p $OUTDIR

echo "..dumping configuration dse/resources"
tar czf $OUTDIR/conf.tar.gz `find dse/resources -type f | grep  '/conf/'`

echo "..dumping logs"
tar czf $OUTDIR/logs.tar.gz /var/log/cassandra

DSE_PID=`ps aux | grep dse.server_process | grep -v "grep" | cut -c10,11,12,13,14,15`
if [ "x$DSE_PID" == "x" ] 
then
    DSE_PID=`$JCMD | grep DseModule | cut -c1,2,3,4,5`
fi

if [ "x$DSE_PID" == "x" ] 
then
	echo "..DSE process not found, skipping threadump and jfr"
else
	echo "..DSE process found: $DSE_PID, requesting jfr"
	jcmd $DSE_PID VM.unlock_commercial_features
	jcmd $DSE_PID JFR.start name=dse settings=profile filename=$OUTDIR/dse.jfr duration=60s delay=10s
	echo "..generating thread dump for DSE: $DSE_PID"
	jstack -l $DSE_PID > $OUTDIR/threaddump.txt
	echo "..watiting 70s for JFR to finish"
	sleep 70
fi

ls $OUTDIR
