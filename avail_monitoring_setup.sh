#!/bin/bash

echo -e "
\e[42mBriefly introduction:\e[0m
- The script is used to setup monitoring tool of your Avail Validator node.
- All collected metrics will be output Prometheus and Grafana
"


cd $HOME
git clone https://github.com/viennguyenbkdn/Avail_Monitoring
cd $HOME/Avail_Monitoring;
sleep 1;

HOST_IP=$(curl -s ipinfo.io/ip);
sed -i.bak -e "s/^HOST_IP=.*/HOST_IP=$HOST_IP/g" $HOME/Avail_Monitoring/.env
sed -i.bak -e "s/HOST_IP/$HOST_IP/g" $HOME/Avail_Monitoring/prometheus/prometheus.yml

docker compose up -d;
sleep 1;
docker compose down;
sleep 1;

chmod -R 777 $HOME/Avail_Monitoring/*
docker compose up -d;
sleep 3;

PORT_GRAFANA=$(sed -n 's/^PORT_GRAFANA=\(.*\)/\1/p' $HOME/Avail_Monitoring/.env) 


echo -e "\n\033[0;32mYou have finished installation of monitoring DA node\033[0m"
echo -e "\nLogin Grafana link: \033[0;31mhttp://$HOST_IP:$PORT_GRAFANA\033[0m"
