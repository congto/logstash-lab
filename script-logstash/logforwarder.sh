#!/bin/bash
# Script cai dat logstash forwarder cho CLIENT
#####################
# Nguoi lam: CongTo	
# Ngay: 30.11.2014
#####################

# Khai bao bien

# Thay IP hop ly voi may ban
IP_SRV_LOG=172.16.69.94

echo "##### Chuan bi cai dat #####"
echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list

sudo apt-get update
sudo apt-get install logstash-forwarder

sleep 7
echo "##### Cau hinh khoi dong logstash cung OS #####"
cd /etc/init.d/; sudo wget https://raw.github.com/elasticsearch/logstash-forwarder/master/logstash-forwarder.init -O logstash-forwarder
sudo chmod +x logstash-forwarder
sudo update-rc.d logstash-forwarder defaults


# Luu y, buoc nay dung scp day tu may Log Server sang theo cu phap
scp /etc/pki/tls/certs/logstash-forwarder.crt user@server_private_IP:/tmp

sleep 3
echo "##### Copy cert cho Logstash Forwarder #####"
sudo mkdir -p /etc/pki/tls/certs
sudo cp /tmp/logstash-forwarder.crt /etc/pki/tls/certs/

#########
sleep 3
echo "##### Tao file cau hinh cho Logstash Forwader #####"

cat << EOF >>  /etc/logstash-forwarder
{
  "network": {
    "servers": [ "$IP_SRV_LOG:5000" ],
    "timeout": 15,
    "ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt"
  },
  "files": [
    {
      "paths": [
        "/var/log/syslog",
        "/var/log/auth.log"
       ],
      "fields": { "type": "syslog" }
    }
   ]
}
EOF

sleep 5

echo " ##### Khoi dong lai Logstash Forwarder #####"
sudo service logstash-forwarder restart
