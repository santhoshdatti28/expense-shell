#/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0n"

userid=$(id -u)

logs_folder="/var/log/expense-shell"
log_file=$(echo $0 | cut -d "." -f1)
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file_name="$logs_folder/$log_file-$timestamp.log"

CHECK_ROOT(){
    if [ $userid -ne 0 ]
    then
        echo "ERROR: you do not have access"
        exit 1
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

dnf module disable nodejs -y &>>log_file_name
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>log_file_name
VALIDATE $? "enabling nodejs"

dnf install nodejs -y  &>>log_file_name
VALIDATE $? "installing nodejs"

id expense &>>log_file_name

if [ $? -ne 0 ]
then
    useradd expense &>>log_file_name
    VALIDATE $? "adding user"
else
    echo -e "user expense is already...$Y existed $N"
fi


mkdir -p /app &>>log_file_name
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>log_file_name
VALIDATE $? "downloading the code"

cd /app
VALIDATE $? "going inside app dir"

rm -rf * &>>log_file_name

unzip /tmp/backend.zip &>>log_file_name
VALIDATE $? "unzipping the code"

npm install &>>log_file_name
VALIDATE $? "installing dependncies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>log_file_name
VALIDATE $? "coping backend.service"

dnf install mysql -y &>>log_file_name
VALIDATE $? "installing mysql"

mysql -h mysql.santhoshdatti.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>log_file_name
VALIDATE $? "setting up transaction schema and tables"

systemctl daemon-reload &>>log_file_name
VALIDATE $? "reload daemon"

systemctl enable backend &>>log_file_name
VALIDATE $? "enable backend"

systemctl start backend &>>log_file_name
VALIDATE $? "satrting backend"

