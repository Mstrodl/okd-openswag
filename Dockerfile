FROM docker.io/eclipse-temurin:8-jdk-focal as builder

RUN apt update && apt install git -y

COPY ./OpenComputers /OpenComputers
WORKDIR /OpenComputers
RUN ./gradlew build devJar

COPY ./openswag /openswag
WORKDIR /openswag
RUN ./gradlew build

RUN rm /openswag/build/libs/*-dev.jar \
  /OpenComputers/build/libs/*-api.jar \
  /OpenComputers/build/libs/*-dev.jar \
  /OpenComputers/build/libs/*-sources.jar \
  /OpenComputers/build/libs/*-javadoc.jar

FROM docker.io/eclipse-temurin:8-jdk-focal

WORKDIR /app
VOLUME /app/world
COPY ./eula.txt /app/eula.txt
RUN wget https://launcher.mojang.com/v1/objects/886945bfb2b978778c3a0288fd7fab09d315b25f/server.jar -O /app/minecraft_server.1.12.2.jar && \
  wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2860/forge-1.12.2-14.23.5.2860-installer.jar -O /tmp/installer.jar && \
  java -jar /tmp/installer.jar --installServer && \
  rm /tmp/installer.jar && \
  mkdir /app/mods

COPY --from=builder /OpenComputers/build/libs/*.jar /openswag/build/libs/*.jar /app/mods

RUN chown -R root:0 /app && \
  chmod -R g+rw /app

CMD java -jar /app/forge-*.jar -Dcom.mojang.eula.agree=true
