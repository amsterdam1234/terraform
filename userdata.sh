#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo yum install stress
echo "<h1>Hello World from $(hostname -f)</h1>" | sudo tee /var/www/html/index.html

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
