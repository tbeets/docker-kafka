# docker-kafka 

This repository is based on [spotify/docker-kafka](https://github.com/spotify/docker-kafka) with some updates for
 Kafka 10.0+ and Docker 1.12+ local machine. 


## Pre-requisites

* Mac 10.10+
* Docker 1.12+
* Homebrew formulas:
    * java (1.8+) 
    * kafka (10.0+)

## Container Execution

```bash
docker run -p 2181:2181 -p 9092:9092 \
--env ADVERTISED_KAFKA_LISTENER=`ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2`:9092 \
--env ADVERTISED_ZOOKEEPER_LISTENER=`ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2`:2181 \
--env ZK_CHROOT=kafka \
tbeets/docker-kafka
```

## Verify 

```bash
export KAFKA=`ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2`:9092 
kafka-console-producer --broker-list $KAFKA --topic test
```

```bash
export ZOOKEEPER=`ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2`:2181/kafka 
kafka-console-consumer --zookeeper $ZOOKEEPER --topic test
```

## Container Build

```bash
docker build -t tbeets/docker-kafka kafka/
```




