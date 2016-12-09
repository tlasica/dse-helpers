LIBDIR=~/.lib
mkdir -p $LIBDIR
wget http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/1.3.3/jolokia-jvm-1.3.3-agent.jar -O $LIBDIR/jolokia-jvm-1.3.3-agent.jar
echo "-javaagent:$LIBDIR/jolokia-jvm-1.3.3-agent.jar" >> ${DSE_CASS_CONFIG_HOME}/jvm.options

