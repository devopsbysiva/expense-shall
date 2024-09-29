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

#installing mysql server.and output is redirected to log-file.
dnf install mysql-server -y &>>LOG_FILE  
VALIDATE $? "MYSQL-SERVER"
#enabling  mysql server.and output is redirected to log-file.
systemctl enable mysqld &>>LOG_FILE
VALIDATE $? "enabling mysqld"

#instarting mysql server.and output is redirected to log-file.
systemctl start mysqld &>>LOG_FILE
VALIDATE $? "starting mysqld"

#checking for root user password set or not
mysql -h mysql.devgani.online -u root -pExpenseApp@1 -e 'show databases;' &>>LOG_FILE

if [ $? -ne 0 ]
then 
    echo "the Root Password is not set. setting up now..!" | tee -a $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "root password setup"
else
    echo "password is already set"
fi
