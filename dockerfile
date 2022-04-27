
#!/bin/bash
FROM ubuntu


##################     MAINTAINERS     ################################
MAINTAINER sanjay





##################     RUNNING AS ROOT     ################################
USER root






##################     INSTALLING     ################################
RUN apt-get clean  -y
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install ssh -y
RUN apt-get install vim -y
RUN apt-get install --fix-missing -y
RUN apt-get install openjdk-8-jdk -y
RUN apt-get install nano -y
RUN apt-get install curl -y
RUN apt-get install libselinux-dev -y
RUN apt-get install unzip -y
RUN apt-get install net-tools -y
RUN apt-get install iputils-ping -y
RUN apt-get install  mysql-server -y
RUN apt-get install mysql-client -y







##################     SETTING ENVIRONMENT VARIABLES     ################################
ENV HADOOP_HOME /opt/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV PATH $PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_COMMON_LIB_NATIVE_DIR"
ENV HIVE_HOME /opt/hive
ENV PATH $PATH:$HIVE_HOME/bin






##################     COPYING ALL FOLDERS AND FILES     ################################
COPY hive/apache-hive-3.1.2-bin.tar.gz /opt/
COPY hadoop/hadoop-3.3.1.tar.gz /
COPY all_jar.zip /






##################     For Hadoop     ################################
RUN cd / && tar -xzf hadoop-3.3.1.tar.gz
RUN mv hadoop-3.3.1 $HADOOP_HOME
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh 
RUN echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc
ADD hadoop/* $HADOOP_HOME/etc/hadoop/
ADD hadoop/hadoop_site/* $HADOOP_HOME/etc/hadoop/
RUN sed s/HOSTNAME/localhost/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml





##################     For Hive     ################################
#https://dlcdn.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
RUN cd /opt/ &&  tar -xvf apache-hive-3.1.2-bin.tar.gz
RUN cd /opt/ && rm apache-hive-3.1.2-bin.tar.gz && mv apache-hive-3.1.2-bin hive
RUN cd /opt/ && ls -a 
RUN cd /opt/ && ls -a
RUN cd /opt/hive/ &&  ls -a
# ADD hive/* /opt/hive/conf/
ADD hive/hive_site/* /opt/hive/conf/
RUN echo "PATH=$PATH:$HIVE_HOME/bin" >> ~/.bashrc










##################     CREATING HDFS FOLDER      ################################







COPY all_jar.zip /
RUN cd / && unzip all_jar.zip && rm all_jar.zip && cd all_jar && ls -a
RUN cd /all_jar && chmod 755 *.jar
RUN cd /all_jar && cp -r *.jar  /opt/hadoop/share/hadoop/common && cp -r *.jar /opt/hive/lib
RUN cd / && ls -a && rm -r all_jar
# RUN cd $HADOOP_HOME/etc/hadoop/ && chmod -x *-env.sh

# create ssh keys
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys &&  chmod 0600 ~/.ssh/authorized_keys
ADD ssh_config /root/.ssh/config








##################     ADDING THE MYSQL JAR FILE TO HIVE     ################################
COPY mysql-connector-java_8.0.28-1ubuntu18.04_all.deb /
RUN cd / && dpkg -i mysql-connector-java_8.0.28-1ubuntu18.04_all.deb && rm mysql-connector-java_8.0.28-1ubuntu18.04_all.deb
RUN cd /usr/share/java/ && cp mysql-connector-java-8.0.28.jar /opt/hive/lib/






##################     ADDING THE GOOGLE JAR FILES INTO HIVE     ################################
RUN cp /opt/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar /opt/hive/lib/guava-27.0-jre.jar
RUN cd /opt/hive/lib/ && rm guava-19.0.jar




#RUN hdfs dfs -mkdir /opt/warehouse
#RUN hdfs dfs -mkdir /tmp
#RUN $HIVE_HOME/bin/schematool -dbType derby -initSchema






##################     EXPOSING THE PORTS     ################################
EXPOSE 9083 10000 10001 10002 10500 10501 15551 15002 15004
EXPOSE 50010 50020 50070 50075 50090 8020 9000 50470 50475 50030 50060
EXPOSE 8030 8031 8032 8033 8040 8042 8088 8090 8050 8025 8141 45454 10200 8190 8188 
EXPOSE 10020 19888 13562 19890





##################     ADDING THE FINES     ################################
ADD start-hadoop.sh /etc/start-hadoop.sh







##################     WORKING FOR MYSQL DEFAULT PASSWORD TO HIVE-SITE.XML    ################################
RUN cd  && awk 'i++ == 4 {print $3}'  /etc/mysql/debian.cnf > /home/alpha.sh

RUN export val=$(awk 'i++ == 4 {print $3}'  /etc/mysql/debian.cnf) && \
    echo $val && \
    sed -i "s/root/$val/g" /opt/hive/conf/hive-site.xml 

RUN cat /opt/hive/conf/hive-site.xml

RUN cd /home && cat alpha.sh 




##################     FOR sshd_config    ################################
# ADD sshd_config.txt /home && cd /home && mv sshd_config.txt sshd_config && cp -r
ADD sshd_config /etc/ssh


##################    SET PASSWORD FOR SSH    ################################
RUN echo 'root:ab5a46b13f462976' | chpasswd


##################     CMD     ################################
CMD bash /etc/start-hadoop.sh




















#ADD hive/hive-env.sh /opt/apache-hive-3.1.2-bin/conf/hive-env.sh 


#https://techjogging.com/standalone-hive-metastore-presto-docker.html
#wget https://jdbc.postgresql.org/download/postgresql-42.2.16.jar
#yum install mysql-connector-java-8.0.21-1.el7.noarch.rpm
#cp /usr/share/java/mysql-connector-java.jar ./

#copy this to the $HIVE_HOME/lib
#https://repo1.maven.org/maven2/org/postgresql/postgresql/9.4.1212.jre7/postgresql-9.4.1212.jre7.jar


