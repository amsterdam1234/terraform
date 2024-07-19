#!/bin/bash

# Update system and install required packages
sudo yum update -y
sudo yum install -y httpd wget stress

# Start and enable Apache HTTP Server
sudo systemctl start httpd
sudo systemctl enable httpd

# Create a simple HTML page
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html

# Set Node Exporter version
NODE_EXPORTER_VERSION="v1.5.0"

# Download and extract Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/$NODE_EXPORTER_VERSION/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvf node_exporter-1.5.0.linux-amd64.tar.gz

# Move Node Exporter binary and clean up
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.5.0.linux-amd64*

# Create a systemd service file for Node Exporter
echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/node_exporter.service

# Reload systemd and start Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Set Prometheus version
PROMETHEUS_VERSION="2.37.0"

# Download and extract Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
tar xvf prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz

# Move Prometheus binaries and clean up
sudo mv prometheus-$PROMETHEUS_VERSION.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-$PROMETHEUS_VERSION.linux-amd64/promtool /usr/local/bin/
rm -rf prometheus-$PROMETHEUS_VERSION.linux-amd64*

# Create Prometheus configuration directory and set up configuration file
sudo mkdir -p /etc/prometheus /var/lib/prometheus /etc/prometheus/consoles /etc/prometheus/console_libraries

cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'  # Name of the job
    ec2_sd_configs:
      - region: us-east-1  # AWS region to look for EC2 instances
        port: 9100  # Port where Node Exporter is running on the instances
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Name]  # Use the 'Name' tag of the instances
        regex: omer-instance  # Match instances with 'Name' tag equal to 'omer-instance'
        action: keep  # Keep only the instances that match the regex

  - job_name: 'node_exporter_local'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Start Prometheus in the background using nohup
nohup /usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries >> /var/log/prometheus.log 2>&1 &

# Ensure proper permissions for the Prometheus data directory
sudo chown -R ec2-user:ec2-user /var/lib/prometheus
