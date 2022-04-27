#!/bin/bash


# start ssh server
/etc/init.d/ssh start


apt list --installed | grep openssh-server
apt-get install openssh-server -y
apt list --installed | grep openssh-server
service ssh status -y
service ssh start -y
service ssh restart -y
netstat -ltnp | grep sshd

ufw allow port /tcp
ufw allow 22/tcp -y
ufw reload -y
ufw status -y



# format namenode
$HADOOP_HOME/bin/hdfs namenode -format  





# start hadoop
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
$HADOOP_HOME/sbin/start-all.sh
mv metastore_db metastore_db.tmp

usermod -d /var/lib/mysql/ mysql
service mysql restart


hdfs dfs -mkdir /tmp
hdfs dfs -chmod g+w /tmp
hdfs dfs -ls /
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /user/hive/warehouse
hdfs dfs -ls /user/hive

#$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver


# hive part also come here
#hive --service metastore
nohup schematool -initSchema -dbType mysql & 
nohup hive --service hiveserver2 &
#hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=INFO,console
#hiveserver2 --hiveconf hive.server2.enable.doAs=false
# keep container running
#org.apache.derby.jdbc.EmbeddedDriver
tail -f /dev/null