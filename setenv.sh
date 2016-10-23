export KAFKA=`ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2`:9092
export ZOOKEEPER=`ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2`:2181/kafka
