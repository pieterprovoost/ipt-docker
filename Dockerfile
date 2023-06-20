FROM ubuntu:23.04
EXPOSE 8080

VOLUME /usr/local/ipt/data

RUN apt-get update
RUN apt-get install -y --allow-unauthenticated wget unzip openjdk-8-jdk

RUN wget -P /usr/local/ipt https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.90/bin/apache-tomcat-8.5.90.tar.gz \
	&& tar -xvzf /usr/local/ipt/apache-tomcat-8.5.90.tar.gz -C /usr/local/ipt \
	&& wget -P /usr/local/ipt/apache-tomcat-8.5.90/webapps https://repository.gbif.org/repository/releases/org/gbif/ipt/2.7.3/ipt-2.7.3.war \ 
	&& rm -r /usr/local/ipt/apache-tomcat-8.5.90/webapps/ROOT \
	&& unzip /usr/local/ipt/apache-tomcat-8.5.90/webapps/ipt-2.7.3.war -d /usr/local/ipt/apache-tomcat-8.5.90/webapps/ROOT \
	&& echo "/usr/local/ipt/data" > /usr/local/ipt/apache-tomcat-8.5.90/webapps/ROOT/WEB-INF/datadir.location

CMD /usr/local/ipt/apache-tomcat-8.5.90/bin/catalina.sh run
