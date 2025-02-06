#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0n"

logs_folder="/var/log/expense-shell"
log_file=$(echo $0 | cut -d "." -f1)
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file_name="$logs_folder/$log_file-$timestamp.log"

userid=$(id -u)

CHECK_ROOT(){
    if [ $userid -ne 0 ]
    then
        echo "ERROR: you do not have access"
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R failure $N"
        exit 1
    else
        echo -e "$2...$G success $N"
    fi
}

CHECK_ROOT

mkdir -p $logs_folder

echo "script started and executing at : $timestamp" &>>log_file_name

dnf install nginx -y &>>log_file_name
VALIDATE $? "installing nginx"

systemctl enable nginx 
VALIDATE $? "enabling nginx"

systemctl start nginx
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "downloading the code"

cd /usr/share/nginx/html
VALIDATE $? "going inside html"

unzip /tmp/frontend.zip
VALIDATE $? "unzipping code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "coping expense.conf file"

systemctl restart nginx
VALIDATE $? "starting nginx"

