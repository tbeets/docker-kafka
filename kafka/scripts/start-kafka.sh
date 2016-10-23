#!/bin/sh

# Optional ENV variables:
# * ADVERTISED_KAFKA_LISTENER: the external ip:port for the Kafka listener
# * ADVERTISED_ZOOKEEPER_LISTENER: the external ip:port for the Zookeeper listener
# * ZK_CHROOT: the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic

# Set the external host:port listener (Kafka 10.0+)
if [ "$ADVERTISED_KAFKA_LISTENER" ]; then
    echo "advertised kafka listener: $ADVERTISED_KAFKA_LISTENER"
    sed -r -i "s/^#(advertised.listeners)=(PLAINTEXT:\/\/)(.*)/\1=\2$ADVERTISED_KAFKA_LISTENER/g" $KAFKA_HOME/config/server.properties
fi

# Set the zookeeper chroot
if [ "$ZK_CHROOT" ] && [ "$ADVERTISED_ZOOKEEPER_LISTENER" ]; then
    # wait for zookeeper to start up
    until /usr/share/zookeeper/bin/zkServer.sh status; do
      sleep 0.1
    done

    # create the chroot node
    echo "create /$ZK_CHROOT \"\"" | /usr/share/zookeeper/bin/zkCli.sh || {
        echo "can't create chroot in zookeeper, exit"
        exit 1
    }

    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=$ADVERTISED_ZOOKEEPER_LISTENER\/$ZK_CHROOT/g" $KAFKA_HOME/config/server.properties
fi

# Allow specification of log retention policies
if [ "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

# Enable/disable auto creation of topics
if [ "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
fi

# Run Kafka
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
