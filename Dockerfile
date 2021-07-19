ARG JDK_VERSION=11-oraclelinux8

FROM openjdk:${JDK_VERSION}
LABEL maintainer="Dimas Maryanto <software.dimas_m@icloud.com>"

# Created user & folder
RUN groupadd www-data && \
adduser -r -g www-data www-data

# Create folder & give access to read and write
ENV FILE_UPLOAD_STORED=/var/lib/spring-boot/data
RUN mkdir -p ${FILE_UPLOAD_STORED} && \
chmod -R 777 ${FILE_UPLOAD_STORED}/

# set working directory
WORKDIR /usr/local/share/applications
# set user
USER www-data

ARG JAR_FILE="springboot-k8s-example-0.0.1-SNAPSHOT.jar"
# copy file from local to images then rename to spring-boot.jar
ADD --chown=www-data:www-data target/$JAR_FILE spring-boot.jar

ENV APPLICATION_PORT=8080
ENV DATABASE_USER=postgres
ENV DATABASE_PASSWORD=postgres
ENV DATABASE_HOST=localhost
ENV DATABASE_NAME=postgres
ENV DATABASE_PORT=5432
ENV FLYWAY_ENABLED=true

# define volume for documentation
VOLUME ${FILE_UPLOAD_STORED}/

# reqired command to run application
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "spring-boot.jar"]
# set default command params
CMD ["--server.port=${APPLICATION_PORT}"]

# Health check every 5 minutes and set timeout 3 seconds using curl
EXPOSE ${APPLICATION_PORT}
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost:${APPLICATION_PORT}/actuator || exit 1
