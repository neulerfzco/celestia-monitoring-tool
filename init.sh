#!/bin/bash

read -p "Enter the IP address of the Prometheus target: " target_ip
read -p "Enter the SSH username for the target: " ssh_username
read -p "Enter the path to the SSH private key (optional, press Enter to skip): " ssh_private_key

# Install node_exporter via SSH
if [ -z "$ssh_private_key" ]; then
  ssh_command="ssh $ssh_username@$target_ip"
else
  ssh_command="ssh -i $ssh_private_key $ssh_username@$target_ip"
fi

$ssh_command 'curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz'
$ssh_command 'tar xzf node_exporter-1.2.2.linux-amd64.tar.gz'
$ssh_command 'sudo cp node_exporter-1.2.2.linux-amd64/node_exporter /usr/local/bin/'
$ssh_command 'sudo useradd --no-create-home --shell /bin/false node_exporter'
$ssh_command 'sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter'

# Create a systemd service for node_exporter
$ssh_command 'sudo tee /etc/systemd/system/node_exporter.service' > /dev/null << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Start and enable the node_exporter service
$ssh_command 'sudo systemctl daemon-reload'
$ssh_command 'sudo systemctl start node_exporter'
$ssh_command 'sudo systemctl enable node_exporter'

# Update the prometheus.yaml file with the target IP
cat << EOF > prometheus.yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: node_exporter
    static_configs:
      - targets: ['$target_ip:9100']
  - job_name: celestia-appd
    static_configs:
      - targets: ['$target_ip:26660']
EOF

echo "Node Exporter installed as a systemd service on $target_ip and populated the prometheus.yaml with 'node exporter' and 'celestia-appd' metrics."

