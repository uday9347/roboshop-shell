#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"


VALIDATE ()
{
    if [ $1 -ne 0 ]
    then 
    echo "$2 is failed"
    else 
    echo "$2 is success"
    fi 
}

if [ $ID -ne 0 ]
then 
    echo "switch to root user"
    exit 1
else 
    echo "root user"
fi 

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing nodejs"

id roboshop &>> $LOGFILE
VALIDATE $? "checking if roboshop user is there"

if [ $? -ne 0 ]
    useradd roboshop 
else 
    echo "user already exist"
fi 

mkdir -p /app &>> $LOGFILE
VALIDATE $? "making app directory"


curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "downlaodinf zip files"

cd /app  &>> $LOGFILE
VALIDATE $? "navigating to app"

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unzipping from tmp files"

cd /app &>> $LOGFILE
VALIDATE $? "navigating to app dir"

npm install  &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "copying the catalogue service to remote server"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "enable cat"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "start cat"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "cp mongo repi"

dnf install -y mongodb-mongosh &>> $LOGFILE
VALIDATE $? "install mongodb"
 
mongosh --host 172.31.22.124 </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "connecting to mongodb host"
