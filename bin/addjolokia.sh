LIBDIR=~/.lib
mkdir -p $LIBDIR
wget http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/1.3.3/jolokia-jvm-1.3.3-agent.jar -O $LIBDIR/jolokia-jvm-1.3.3-agent.jar
# using hostname -i will allow to contact jolokia on the node via IP or node0 alias
AGENT="-javaagent:$LIBDIR/jolokia-jvm-1.3.3-agent.jar=host=`hostname -i`"
if [ -f ${DSE_CASS_CONFIG_HOME}/jvm.options ]
then
    echo "using jvm.options"
    echo $AGENT >> ${DSE_CASS_CONFIG_HOME}/jvm.options
else
    echo "using cassandra-env.sh"
    echo 'JVM_OPTS="$JVM_OPTS' $AGENT '"' >> ${DSE_CASS_CONFIG_HOME}/cassandra-env.sh
fi
