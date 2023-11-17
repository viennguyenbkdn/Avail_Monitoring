#!/bin/bash

echo -e "
\e[42mBriefly introduction:\e[0m
- The script is used to setup monitoring tool of your Avail Validator node.
- All collected metrics will be output Prometheus and Grafana
"

systemctl list-units --type=service --state=running | grep -i avaiil > /dev/null
if [ $? -eq 0 ] ; then
        Avail_systemd=$(systemctl list-units --type=service --state=running | grep -i avail | awk '{print $1}');
        sed -i.bak -e  's/^\(ExecStart.*\)\\/\1 \-\-prometheus\-external \\/g' /etc/systemd/system/${Avail_systemd}
        systemctl daemon-reload
        systemctl restart $Avail_systemd
else
        docker ps | grep -i avail > /dev/null
        if [ $? -eq 0 ]; then
                Avail_container=$(docker ps | grep -i thuyuyen | awk '{print $NF}');
                cd $HOME;
                docker cp ${Avail_container}:/entrypoint.sh . > /dev/null
                sleep 1;
                sed -i.bak -e "s/\(--chain=\${DA_CHAIN}\)/\1 --prometheus-external /g" ./entrypoint.sh
                sleep 1;
                docker cp ./entrypoint.sh ${Avail_container}:/entrypoint.sh > /dev/null
                docker restart $Avail_container > /dev/null
        fi
fi



cd $HOME
git clone https://github.com/viennguyenbkdn/Avail_Monitoring
cd $HOME/Avail_Monitoring;
sleep 1;

HOST_IP=$(curl -s -4 ipconfig.io/ip);
sleep 1;
sed -i.bak -e "s/^HOST_IP=.*/HOST_IP=$HOST_IP/g" $HOME/Avail_Monitoring/.env
sed -i.bak -e "s/HOST_IP/$HOST_IP/g" $HOME/Avail_Monitoring/prometheus/prometheus.yml
sleep 1;

docker compose up -d;
sleep 15;

docker compose down;
sleep 15;

chmod -R 777 $HOME/Avail_Monitoring/*
sleep 3;
docker compose up -d;
sleep 3;

PORT_GRAFANA=$(sed -n 's/^PORT_GRAFANA=\(.*\)/\1/p' $HOME/Avail_Monitoring/.env) 


echo -e "\n\033[0;32mYou have finished installation of monitoring DA node\033[0m"
echo -e "\nLogin Grafana link: \033[0;31mhttp://$HOST_IP:$PORT_GRAFANA\033[0m"
