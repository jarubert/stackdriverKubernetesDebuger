# Start with a base image containing Java runtime
FROM openjdk:8u212-jdk-slim

# Add Maintainer Info
LABEL maintainer="jeferson.rubert@gmail.com"

# Add a volume pointing to /tmp
VOLUME /tmp

# Make port 8080 available to the world outside this container
EXPOSE 8080

# The application's jar file
ARG JAR_FILE=target/codestate-0.0.1-SNAPSHOT.jar

# Add the application's jar to the container
ADD ${JAR_FILE} codestate.jar

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

# Create a directory for the Debugger. Add and unzip the agent in the directory.
RUN  mkdir /opt/cdbg && \
     wget -qO- https://storage.googleapis.com/cloud-debugger/compute-java/debian-wheezy/cdbg_java_agent_gce.tar.gz | \
     tar xvz -C /opt/cdbg

# Start the agent when the app is deployed.
#RUN java -agentpath:/opt/cdbg/cdbg_java_agent.so \
#    -Dcom.google.cdbg.module=codestate \
#    -Dcom.google.cdbg.version=0.0.1 \
#    -jar codestate.jar
# codestatebkend:latest

# Run the jar file 
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom", "-agentpath:/opt/cdbg/cdbg_java_agent.so", " -Dcom.google.cdbg.module=codestatebkend", "-Dcom.google.cdbg.version=latest", "-jar","/codestate.jar"]
