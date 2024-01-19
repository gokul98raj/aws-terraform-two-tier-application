#!/bin/bash

# Update the instance
sudo yum update -y

#Install GIT
sudo yum install git -y

# Install Python3 and pip3
sudo yum install python3 -y
sudo yum install python3-pip -y

# Install Flask and pymysql
sudo pip3 install flask pymysql boto3 requests

# Install AWS CLI
sudo pip3 install awscli --upgrade

# Change Directory
cd /home/ec2-user/

# Clone your Flask application repository from GitHub
git clone https://github.com/gokul98raj/Login-with-python.git

# Navigate to the cloned repository directory
cd Login-with-python

# Run the Flask application in the background
sudo nohup python3 myapp.py > app.log 2>&1 &
