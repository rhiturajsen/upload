FROM docker.io/centos
RUN yum install -y java-1.8.0-openjdk.x86_64
WORKDIR /opt

RUN curl -LO http://apachemirror.wuchna.com/tomcat/tomcat-9/v9.0.31/bin/apache-tomcat-9.0.31.tar.gz
RUN tar -xvzf apache-tomcat-9.0.31.tar.gz
RUN mv apache-tomcat-9.0.31 tomcat
RUN chmod +x ./tomcat/bin/catalina.sh
RUN ln -s ./tomcat/bin/catalina.sh /usr/bin/tomcat

RUN curl -LO https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.6.0-linux-x86_64.tar.gz
RUN tar -xvzf metricbeat-7.6.0-linux-x86_64.tar.gz


ADD ./jolokia.yml /opt/metricbeat-7.6.0-linux-x86_64/modules.d/jolokia.yml
ADD ./tomcat.yml /opt/metricbeat-7.6.0-linux-x86_64/modules.d/tomcat.yml
ADD ./tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
ADD ./jolokia.war /opt/tomcat/webapps
ADD ./webapp.war /opt/tomcat/webapps
ADD ./start-up.sh /usr/bin/
RUN chmod +x /usr/bin/start-up.sh 

EXPOSE 8080

CMD ["/usr/bin/start-up.sh"]
