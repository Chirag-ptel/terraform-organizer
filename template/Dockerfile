FROM --platform=linux/amd64 maven:latest AS build
COPY pom.xml ./
COPY src ./src
RUN mkdir ./target
RUN mvn -f ./pom.xml clean package
# ARG JAR_FILE=target/spring-boot-2-rest-service-basic-0.0.1-SNAPSHOT.jar
# ADD ${JAR_FILE} app.jar
FROM --platform=linux/amd64 openjdk:18
COPY --from=build  ./target/spring-boot-2-rest-service-basic-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]