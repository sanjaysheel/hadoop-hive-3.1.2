#!/bin/bash

# Run hadoop first of all
#bash /etc/start_hadoop.sh -bash

# start metastore
hive --service metastore
schematool -initSchema -dbType derby
#HIVE_HOME/bin/schematool --dbType mysql --initSchema

# keep container running
tail -f /dev/null