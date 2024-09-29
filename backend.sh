#!/bin/bash

#genearting logs .
LOG_FOLDER=/var/log/expense
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo "$2  is failure " | tee -a $LOG_FILE
    else
        echo "$2  is success " | tee -a $LOG_FILE
    fi

}
#checking the user is having sudo access or not.
USER_ID=$(id -u) #it should be id=0; zero or else not having access.
if [ $USER_ID -ne 0 ]
then 
    echo "please run this script with sudo privileges" | tee -a $LOG_FILE
    exit 1  # it checks for id=0 if not , the execution stops here.
fi

dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "installing nodejs"

id expense &>>LOG_FILE
if [ $? -ne 0 ]
then 
    echo " creating a user" | tee -a $LOG_FILE
    useradd expense &>>LOG_FILE
else
    echo " user exist no need to create" | tee -a $LOG_FILE
fi

mkdir -p /app &>>LOG_FILE

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE
VALIDATE $? "downloadinf from git"

cd /app
rm -rf /app/* &>>LOG_FILE

unzip /tmp/backend.zip &>>LOG_FILE
VALIDATE $? "unzipping files"

npm install &>>LOG_FILE
VALIDATE $? "installing dependencies"

cp /home/ec2-user/expense-shall/backend.service /etc/systemd/system/backend.service &>>LOG_FILE
VALIDATE $? "copying backend.service file"

dnf install mysql -y &>>LOG_FILE
VALIDATE $? "mysql client"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>LOG_FILE
VALIDATE $? "backend.sql file"

systemctl daemon-reload &>>LOG_FILE
VALIDATE $? "deamon reloading"

systemctl enable backend  &>>LOG_FILE
VALIDATE $? "enabling backend services"

systemctl restart backend  &>>LOG_FILE
VALIDATE $? "restarting backend services"

