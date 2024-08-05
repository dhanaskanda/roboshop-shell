#!/bin/bash

# Installing RedisDB through this shell script

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGSFILE="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Script is started execution at $Y $TIMESTAMP $N" &>> $LOGSFILE

CHECK(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2.. $R Failed $N"
        exit 1
    else
        echo -e "$2.. $G Success $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo "Error: Run the script with the root user"
    exit  1 # if not true
else
    echo -e "You are a $G root $N user"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGSFILE
CHECK $? "Installing redisDB packages"

dnf module enable redis:remi-6.2 -y &>> $LOGSFILE
CHECK $? "Enable Redis 6.2 from package streams"

dnf list installed redis

    if [ $? -ne 0 ]
    then
        dnf install redis -y &>> $LOGSFILE # Installing redis if not installed already
        CHECK $? "Installig redis"
    else
        echo -e "Redis already exists.. $Y Skipping $N"
    fi

sed -i '/s/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGSFILE
CHECK $? "allowing remote connections"

systemctl enable redis &>> $LOGSFILE
CHECK $? "Enabling the redis service"

systemctl start redis &>> $LOGSFILE
CHECK $? "Starting the redis service"