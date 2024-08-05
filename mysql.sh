#!/bin/bash

# Installing the mysql DataBase using shell script!

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

dnf module disable mysql -y
CHECK $? "Disabling the default mysql package"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGSFILE
CHECK $? "Set MySQL5.7 repo file"

dnf list installed mysql-community-server

if [ $? -ne 0 ]
then
    dnf install mysql-community-server -y &>> $LOGSFILE
    CHECK $? "Installing mysql server"
else
    echo -e "mysql server already installed.. $Y SKIPPING $N"
fi

systemctl enable mysqld &>> $LOGSFILE
CHECK $? "Enabling mysqld service to start from reboot"

systemctl start mysqld 
CHECK $? "Starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1
CHECK $? "Set the Mysql root password"


