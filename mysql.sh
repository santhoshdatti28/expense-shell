#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

userid=$(id -u)

logs_folder="/var/log/expenseshell-log"
log_file=$(echo $0 | cut -d "." -f1)
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file_name="$logs_folder/$log_file-$timestamp.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R failure $N"
        exit 1
    else
        echo -e "$2...$G success $N"
    fi

}

CHECK_ROOT(){
    if [ $userid -ne 0 ]
    then 
        echo "ERROR: you do not have access"
        exit1
    fi
}

mkdir -p $logs_folder

echo "script started and executed at: $timestamp" &>>$log_file_name

CHECK_ROOT

dnf install mysql-server -y &>>$log_file_name
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>>$log_file_name
VALIDATE $? "enabling mysql"

systemctl start mysqld &>>$log_file_name
VALIDATE $? "starting mysql"

mysql -h mysql.santhoshdatti.online -u root -pExpenseApp@1 -e 'show databases; &>>$log_file_name
VALIDATE $? "setting up root password"
