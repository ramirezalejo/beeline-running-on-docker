#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
RUN mkdir -p /usr/share/man/man1 && \
    apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get install -y ant && \
    apt-get clean && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f &&  \
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/ && \
    apt-get install -y wget && \
    cd /home && \
    mkdir hadoop && \
    wget https://archive.apache.org/dist/hadoop/core/hadoop-2.5.1/hadoop-2.5.1.tar.gz  && \
    tar -xvzf hadoop-2.5.1.tar.gz  -C /home/hadoop/  && \
    cd /home  && \
    mkdir hive  && \
    wget https://archive.apache.org/dist/hive/hive-1.2.1/apache-hive-1.2.1-bin.tar.gz  && \
    tar -xvzf apache-hive-1.2.1-bin.tar.gz -C /home/hive/  && \
    export HADOOP_HOME=/home/hadoop/hadoop-2.5.1  && \
    export HIVE_HOME=/home/hive/apache-hive-1.2.1-bin/  && \
    export PATH=$PATH:$HIVE_HOME/bin:$HADOOP_HOME:$JAVA_HOME;
ENV JAVA_HOME "/usr/lib/jvm/java-11-openjdk-amd64/"
ENV HADOOP_HOME "/home/hadoop/hadoop-2.5.1"
ENV HIVE_HOME "/home/hive/apache-hive-1.2.1-bin/"
ENV PATH "$PATH:$HIVE_HOME/bin:$HADOOP_HOME:$JAVA_HOME"

#RUN echo "HADOOP_HOME=/home/hadoop/hadoop-2.5.1" >>  /root/.bashrc
#RUN echo "HIVE_HOME=/home/hive/apache-hive-1.2.1-bin/" >>  /root/.bashrc
#RUN echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/" >>  /root/.bashrc
#RUN echo "PATH=$PATH:$HIVE_HOME/bin:$HADOOP_HOME:$JAVA_HOME" >>  /root/.bashrc

EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src

COPY ["DataConsumption.Services/DataConsumption.Services.csproj", "DataConsumption.Services/"]
RUN dotnet restore "DataConsumption/DataConsumption.csproj"
COPY . .
WORKDIR "/src/DataConsumption"
RUN dotnet build "DataConsumption.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DataConsumption.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DataConsumption.dll"]

