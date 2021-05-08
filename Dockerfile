FROM mozilla/sbt:8u232_1.4.5 as build

WORKDIR /app

COPY project project
COPY src src
COPY build.sbt build.sbt

RUN sbt assembly


FROM openjdk:8-jdk

ENV BROKER CHANGE_IT
ENV TOPIC CHANGE_IT
ENV GROUP_ID CHANGE_IT

WORKDIR /app
COPY --from=build /app/target/scala-2.13/queue-hello-world-assembly-0.1.jar /app

CMD java -jar /app/queue-hello-world-assembly-0.1.jar $BROKER $TOPIC $GROUP_ID
