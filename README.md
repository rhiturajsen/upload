Install JDK 1.8, docker, Minikube & kubectl
============================================

setenforce 0

yum in stall -y docker java-1.8.0-openjdk 
yum install -y docker
systemctl enable --now docker
systemctl status docker

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64   && chmod +x minikube
install minikube /usr/bin/
minikube start --vm-driver=none

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl
chmod +x ./kubectl


Install ELK Stack along with Nginx Reverse Proxy
=================================================

cat <<EOF >> /etc/yum.repos.d/elasticsearch.repo
[Elasticsearch-7]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install elasticsearch kibana logstash nginx -y

systemctl enabe --now elasticsearch
systemctl enable --now kibana

Nginx Reverse Proxy config file for kibana and elasticsearch
=================================================================

[root@ip-172-31-93-167 centos]# cat /etc/nginx/conf.d/kibana.conf
server {
    listen 8090;
    server_name haptik-tomcat.example.com;
    location / {
        proxy_pass http://localhost:5601;
    }
}

[root@ip-172-31-93-167 centos]# cat /etc/nginx/conf.d/es.conf
server {
    listen 8082;
    server_name haptik-tomcat.example.com;
    location / {
        proxy_pass http://localhost:9200;
    }
}



[root@ip-172-31-93-167 centos]# cat /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;

}

Configure logstash for accepting logs from filebeat
=====================================================

[root@ip-172-31-93-167 centos]# cat /etc/logstash/conf.d/logstash-input.conf
input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}

Start logstash & nginx reverse proxy
=========================================

systemctl enable --now logstash
systemctl enable --now nginx


==================================================================================================================================
=                                                                                                                                =
=                       Application Deployment in kubernetes and using nginx as ingress controller                               =
=                                                                                                                                =
=                                                                                                                                =
==================================================================================================================================





Build docker image (tomcat app is embeded with the images as assignment did not ask for using other deployment tool)
====================================================================================================================

cd /haptik-docker-application/docker-image-build

docker build -t haptik-tomcat:v1 .


Nginx ingress controller deployment
====================================

cd /haptik-docker-application/kubernetes-deployment/nginx-controller

kubectl apply -f ns-and-sa.yaml
kubectl apply -f rbac.yaml
kubectl apply -f default-server-secret.yaml
kubectl apply -f nginx-config.yaml
kubectl apply -f nginx-ingress.yaml


Deploy tomcat application in kuberenetes
=========================================

cd /haptik-docker-application/kubernetes-deployment/tomcat-application

kubectl apply -f rbac-haptik-tomcat.yaml
kubectl apply -f config-map-for-filebeat.yaml
kubectl apply -f config-map-for-metricbeat.yaml
kubectl apply -f haptik-tomcat.yaml
kubectl apply -f ingress-rule.yaml





