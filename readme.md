## Celestia appd monitoring tool 

This repository aims to simplify as much as possible the monitoring setup of a celestia validator / consensus full node.

### plug-and-play feature

- `init.sh` : install the node_exporter.service to the validator instance + setup the prometheus.yaml file accordingly. 
- grafana dashboards and datasources provisioning: no extra setup needed, the dashboards are already created at startup. 

## CMDS

```
git clone https://github.com/neulerfzco/celestia-monitoring-tool.git
cd celestia-monitoring-tool
./init.sh  
docker-compose up -d 
```