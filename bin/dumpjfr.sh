set -u
FILENAME=$1
DELAY=$2
DURATION=$3
JCMD=`which jcmd`
DSE_PID=`ps aux | grep dse.server_process | grep -v "grep" | cut -c10,11,12,13,14,15`
if [ "x$DSE_PID" == "x" ]
then
    DSE_PID=`$JCMD | grep DseModule | cut -c1,2,3,4,5`
fi

$JCMD $DSE_PID VM.unlock_commercial_features
$JCMD $DSE_PID JFR.start name=dse settings=profile filename=$FILENAME duration=$DURATION delay=$DELAY

