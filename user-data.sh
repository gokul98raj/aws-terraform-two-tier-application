#!/bin/bash

# Update the instance
sudo yum update -y

# Install Python3 and pip3
sudo yum install python3 -y
sudo yum install python3-pip -y

# Install Flask and pymysql
sudo pip3 install flask pymysql

# Export necessary environment variables from Terraform
export DB_HOST=$(terraform output db_endpoint)
export DB_USER=$(terraform variable rds_username)
export DB_PASSWORD=$(terraform variable rds_password)
#export DB_NAME=$(terraform output db_name)

# Create a Python script with your Flask application code (You can copy your Flask code here)

cat <<EOL > app.py
from flask import Flask, request
import pymysql

app = Flask(__name__)

def get_db_connection():
    return pymysql.connect(host="$DB_HOST", user="$DB_USER", password="$DB_PASSWORD")

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    connection = get_db_connection()
    cursor = connection.cursor()

    query = "SELECT * FROM users WHERE username=%s AND password=%s"
    cursor.execute(query, (username, password))

    user = cursor.fetchone()

    if user:
        return "Login Successful!", 200
    else:
        return "Invalid credentials. Please try again.", 401

    cursor.close()
    connection.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOL

# Run the Flask application in the background
nohup python3 app.py > app.log 2>&1 &
