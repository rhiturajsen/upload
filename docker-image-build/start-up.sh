#!/bin/bash
/opt/tomcat/bin/catalina.sh start
cd /opt/metricbeat-7.6.0-linux-x86_64 && ./metricbeat -e

