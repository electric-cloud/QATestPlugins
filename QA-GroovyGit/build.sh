if [ -"x${COMMANDER_SERVER}" = "x" ]; then
  COMMANDER_SERVER="localhost"
fi;

if [ -"x${PLUGIN_VERSION}" = "x" ]; then
  PLUGIN_VERSION="1.0.0"
fi;

ectool --server ${COMMANDER_SERVER} login admin changeme
ectool installPlugin build/QA-GroovyGit.zip
ectool promotePlugin "QA-GroovyGit-${PLUGIN_VERSION}.0"