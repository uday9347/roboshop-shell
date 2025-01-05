#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "$LOGFILE"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongo repo "


dnf install mongodb-org -y  &>> $LOGFILE 
VALIDATE $? "installong the mongodb"

systemctl enable mongod  &>> $LOGFILE 
VALIDATE $? "enabling the mongodb"

systemctl start mongod  &>> $LOGFILE 
VALIDATE $? "starting the mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Remote server access"

systemctl restart mongod &>> $LOGFILE 
VALIDATE $? "starting the mongodb"

