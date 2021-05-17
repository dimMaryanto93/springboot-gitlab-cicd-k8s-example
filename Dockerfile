FROM openjdk:8-jre
MAINTAINER Dimas Maryanto <software.dimas_m@icloud.com>

# ENTRYPOINT ["java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "/usr/share/applications/application.jar"]

EXPOSE 8080

ARG JAR_FILE
ADD target/${JAR_FILE} /usr/share/applications/application.jar

ADD target/classes/application.yml /usr/share/applications/application.yml

VOLUME /usr/share/applications/
