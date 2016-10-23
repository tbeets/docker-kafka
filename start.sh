#!/bin/bash

docker run -p 2181:2181 -p 9092:9092 \
--env ADVERTISED_KAFKA_LISTENER=`ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2`:9092 \
--env ADVERTISED_ZOOKEEPER_LISTENER=`ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2`:2181 \
--env ZK_CHROOT=kafka \
tbeets/docker-kafka
