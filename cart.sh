#!/bin/bash
# This script is to install the cart application with nodejs18 version

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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGSFILE # Downloading cart applicaiton
CHECK $? "Downloading cart application"

cd /app &>> $LOGSFILE
CHECK $? "Moving to directroy"

unzip -o /tmp/cart.zip &>> $LOGSFILE
CHECK $? "Unzipping the cart application to the /app path"

npm install &>> $LOGSFILE 
CHECK $? "Download & Installing card dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGSFILE
CHECK $? "Created a cart service to start as systemctl service"

systemctl daemon-reload &>> $LOGSFILE
CHECK $? "Enabling Daemon"

systemctl enable cart &>> $LOGSFILE
CHECK $? "Enabling cart service"

systemctl start cart &>> $LOGSFILE
CHECK $? "Starting cart service"
