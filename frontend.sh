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
        echo "$2 installation is failure " | tee -a $LOG_FILE
    else
        echo "$2 installation is success " | tee -a $LOG_FILE
    fi

}
#checking the user is having sudo access or not.
USER_ID=$(id -u) #it should be id=0; zero or else not having access.
if [ $USER_ID -ne 0 ]
then 
    echo "please run this script with sudo privileges" | tee -a $LOG_FILE
    exit 1  # it checks for id=0 if not , the execution stops here.
fi

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "install nginx"

rm -rf /usr/share/nginx/html/* &>>LOG_FILE

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOG_FILE
VALIDATE $? "download from git"

cd /usr/share/nginx/html &>>LOG_FILE

unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "UNZIIPING"

cp /home/ec2-user/expense-shall/expense.conf /etc/systemd/system/expense.conf &>>LOG_FILE
VALIDATE $? "copying expense.conf file"

systemctl enable nginx &>>LOG_FILE
VALIDATE $? "ENABBLING NGINX"

systemctl restart nginx &>>LOG_FILE
VALIDATE $? "ERESTARTING NGINX"