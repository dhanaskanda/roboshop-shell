#!/bin/bash

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGSFILE # Mainting the repo in mongo.repo file
CHECK $? "Copying mongo.repo"

yum list installed mongodb
if [ $? -ne 0 ]
then
    dnf install mongodb-org -y &>> $LOGSFILE # Installing MongoDB
    CHECK $? "Installing mongoDB"
else
    echo -e "mongoDB is already installed.. $Y SKIPPING $N"
fi

systemctl enable mongod &>> $LOGSFILE # Enabling the mongoDB service to auto restart
CHECK $? "Enabling mongoDB"

systemctl start mongod &>> $LOGSFILE # Starting the mongoDB service
CHECK $? "Starting mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGSFILE
CHECK $? "Remote connection to mongoDB" 

systemctl restart mongod &>> $LOGSFILE # Restart the mongoDB service
CHECK $? "Restarting mongoDB" 