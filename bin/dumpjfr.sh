set -u
FILENAME=$1
DELAY=$2
DURATION=$3
JCMD=`which jcmd`
DSE_PID=`$JCMD | grep DseModule | cut -c1,2,3,4,5`
$JCMD $DSE_PID VM.unlock_commercial_features
$JCMD $DSE_PID JFR.start name=dse settings=profile filename=$FILENAME duration=$DURATION delay=$DELAY

