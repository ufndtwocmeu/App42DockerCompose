FROM ubuntu:12.04 AS builder

RUN apt-get -qq update && \
    apt-get -qq -y install openjdk-6-jdk && \
    apt-get -qq -y install maven2 && \
    apt-get -qq -y install git && \
    mkdir /data && \
    cd /data && \
    git clone https://github.com/shephertz/App42PaaS-Java-MySQL-Sample.git

RUN rm -rf /data/App42PaaS-Java-MySQL-Sample/pom.xml
ADD pom.xml /data/App42PaaS-Java-MySQL-Sample/

RUN rm -rf /data/App42PaaS-Java-MySQL-Sample/WebContent/Config.properties
ADD Config.properties /data/App42PaaS-Java-MySQL-Sample/WebContent/

RUN cd /data/App42PaaS-Java-MySQL-Sample && \
    mvn package


FROM tomcat:6 AS prod
COPY --from=builder /data/App42PaaS-Java-MySQL-Sample/target/App42PaaS-Java-MySQL-Sample-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/
COPY --from=builder /data/App42PaaS-Java-MySQL-Sample/target/App42PaaS-Java-MySQL-Sample-0.0.1-SNAPSHOT.war /usr/local/tomcat/ROOT/
COPY --from=builder /data/App42PaaS-Java-MySQL-Sample/WebContent/. /usr/local/tomcat/ROOT/
EXPOSE 8080
CMD ["catalina.sh", "run"]