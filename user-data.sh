#!/bin/bash

# Update the instance
sudo yum update -y

# Install Python3 and pip3
sudo yum install python3 -y
sudo yum install python3-pip -y

# Install Flask and pymysql
sudo pip3 install flask pymysql boto3

# Clone your Flask application repository from GitHub
#git clone <your-github-repo-url>

# Navigate to the cloned repository directory
cd <your-repo-directory>

# Create a Flask application script using a here document
cat <<EOF > flask_app.py
from flask import Flask, request, render_template
import pymysql
import boto3

app = Flask(__name__)

def get_db_connection():
    # Initialize AWS SDK
    session = boto3.session.Session()
    ssm_client = session.client('ssm')

    # Fetch database details from Parameter Store
    db_host = ssm_client.get_parameter(Name='/test/db_endpoint', WithDecryption=True)['Parameter']['Value']
    db_user = ssm_client.get_parameter(Name='/test/db_user', WithDecryption=True)['Parameter']['Value']
    db_password = ssm_client.get_parameter(Name='/test/db_password', WithDecryption=True)['Parameter']['Value']
    # db_name = ssm_client.get_parameter(Name='/your/parameter/store/db_name', WithDecryption=True)['Parameter']['Value']

    #return pymysql.connect(host=db_host, user=db_user, password=db_password, db=db_name)
    return pymysql.connect(host=db_host, user=db_user, password=db_password)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        connection = get_db_connection()
        cursor = connection.cursor()
        
        query = "SELECT * FROM users WHERE username=%s AND password=%s"
        cursor.execute(query, (username, password))
        
        user = cursor.fetchone()
        
        if user:
            return "Login Successful!"
        else:
            return "Invalid credentials. Please try again."
        
        cursor.close()
        connection.close()
    
    return render_template('login.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

    @app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        connection = get_db_connection()
        cursor = connection.cursor()
        
        query = "INSERT INTO users (username, password) VALUES (%s, %s)"
        cursor.execute(query, (username, password))
        
        connection.commit()
        cursor.close()
        connection.close()
        
        flash('Registration successful. Please log in.')
        return redirect(url_for('login'))
    
    return render_template('register.html')
EOF

# Run the Flask application in the background
nohup python3 flask_app.py > app.log 2>&1 &
