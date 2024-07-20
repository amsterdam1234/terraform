#!/bin/bash
# Update and install required packages
sudo yum update -y

# Update and install required packages
sudo yum install -y wget

# Set Node Exporter version
NODE_EXPORTER_VERSION="v1.5.0"

# Download Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/$NODE_EXPORTER_VERSION/node_exporter-1.5.0.linux-amd64.tar.gz

# Extract the Node Exporter tarball
tar xvf node_exporter-1.5.0.linux-amd64.tar.gz

# Run Node Exporter in the background using nohup
nohup ./node_exporter-1.5.0.linux-amd64/node_exporter >> /var/log/nodeexporter.log 2>&1 &

#installing  stress
sudo yum install -y stress

#installing flask app
yum install -y git python3-pip
pip3 install flask

# Clone the Flask project from your repository
sudo git clone https://github.com/amsterdam1234/terraformLandingPage.git /home/ec2-user/terraformLandingPage

# Navigate to the project directory
cd /home/ec2-user/terraformLandingPage

# Install the required Python packages
sudo pip3 install -r requirements.txt

# Start the Flask application
export FLASK_APP=app.py
#make sure to change the host to the private ip of the instance and port to 80
sudo flask run --host=0.0.0.0 --port=80