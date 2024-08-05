#!/bin/bash
# This script is to install the catalogue application with nodejs18 version

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
