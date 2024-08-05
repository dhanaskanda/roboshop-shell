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

dnf list installed nginx &>> $LOGSFILE

if [ $? -ne 0 ]
then 
    dnf install nginx -y &>> $LOGSFILE
    CHECK $? "Installing nginx webserver"
else
    echo -e "Nginx already installed.. $Y Skipping $N"
fi

systemctl enable nginx &>> $LOGSFILE
CHECK $? "enabling nginx webserver"

systemctl start nginx &>> $LOGSFILE
CHECK $? "starting nginx webserver"

rm -rf /usr/share/nginx/html/* &>> $LOGSFILE
CHECK $? "Removing the existing to starting content from nginx webserver"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
CHECK $? "Downloading frontend content"

cd /usr/share/nginx/html &>> $LOGSFILE
CHECK $? "Moving to html folder to copy the frontend content"

unzip -o /tmp/web.zip &>> $LOGSFILE
CHECK $? "Unzipping the frontend content to the html directory"

cp /home/centos/roboshop-shell/roboshop.conf /etc/yum.repos.d/roboshop.conf &>> $LOGSFILE
CHECK $? "Preparing the roboshop configuration from webserver"

systemctl restart nginx &>> $LOGSFILE
CHECK $? "Restart Nginx Service to load the changes of the configuration"



