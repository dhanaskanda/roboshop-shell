#!/bin/bash
# This script is to install the user application with nodejs18 version

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGSFILE="/tmp/$0-$TIMESTAMP.log"
MONGODB_HOST=mongodb.dhanaskanda.online

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

dnf module disable nodejs -y &>> $LOGSFILE # Disabling the nodejs to use required version.
CHECK $? "Disabling nodejs"

dnf module enable nodejs:18 -y &>> $LOGSFILE # Enabling the nodejs 18 version
CHECK $? "Enabling nodejs"

yum list installed nodejs &>> $LOGSFILE
    if [ $? -ne 0 ]
    then
        dnf install nodejs -y  &>> $LOGSFILE # Install the nodejs if value is not zero
        CHECK $? "Installing nodejs 18"
    else
        echo -e "NodeJS already installed.. $Y SKIPPING $N"
    fi

id roboshop &>> $LOGSFILE
    if [ $? -ne 0 ]
    then
        useradd roboshop &>> $LOGSFILE # Creating a roboshot if doesn't exits on the server
        CHECK $? "roboshop user creation"
    else
        echo -e "user already exists.. $Y SKIPPING $N"
    fi

mkdir -p /app &>> $LOGSFILE # Creating /app directory
CHECK $? "/app directory creation"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGSFILE # Downloading the user appplication

CHECK $? "Downloading user application"

cd /app

unzip -o /tmp/user.zip &>> $LOGSFILE 
CHECK $? "Unzipping the app content to /app directory" 

npm install &>> $LOGSFILE # Installing the dependencies
CHECK $? "Installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGSFILE
CHECK $? "Created a user service to start as systemctl service"

systemctl daemon-reload &>> $LOGSFILE
CHECK $? "Enabling Daemon"

systemctl start user &>> $LOGSFILE
CHECK $? "Starting user service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGSFILE
CHECK $? "Preparing to install mongodb shell"

dnf install mongodb-org-shell -y &>> $LOGSFILE # Installing mongodb client to connect and load the schemas into mongo DB.
CHECK $? "Installing mongoDB shell client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGSFILE
CHECK $? "Loading user data into mongoDB"