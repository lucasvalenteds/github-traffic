FROM openjdk:11

WORKDIR /wiremock

ARG wiremock_version=2.27.2

RUN wget --quiet --output-document=wiremock.jar https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/"$wiremock_version"/wiremock-standalone-"$wiremock_version".jar

COPY ./request_traffic_200.json /wiremock/mappings/

ENV PORT 8080

CMD ["java", "-jar", "wiremock.jar", "--port=8080", "--verbose"]
