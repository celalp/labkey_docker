# labkey 17.3 install docker on ubuntu 16.04
# will have instructions about how to make it work with other veriosn as well



# OS

FROM ubuntu:16.04

# change vars here
ENV POSTGRES_VER=9.6 
ENV JAVA_VER=8 
ENV TOMCAT_VER=8 
ENV TOMCAT_SUBVER=5.29

ENV LABKEY_VER=18.1  
ENV LABKEY_SUBVER=57017.17 
ENV LABKEY_FULLVER="$LABKEY_VER"-"$LABKEY_SUBVER" 


RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install curl --yes && \
    apt-get install libxml2 --yes && \
    apt-get install git --yes && \
    apt-get install libcurl4-openssl-dev --yes && \
    apt-get install libssl-dev --yes && \
    apt-get install libxml2-dev --yes && \
    apt-get install wget --yes && \
    apt-get install sed --yes


#postgres installation
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update  --yes
RUN apt-get install postgresql-"$POSTGRES_VER" --yes

# java installation
RUN apt-get install software-properties-common --yes && \
    echo oracle-java"$JAVA_VER"-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java"$JAVA_VER"-installer
    

#tomcat installation maybe wget this?
RUN  wget http://apache.mirror.iweb.ca/tomcat/tomcat-"$TOMCAT_VER"/v"$TOMCAT_VER"."$TOMCAT_SUBVER"/bin/apache-tomcat-"$TOMCAT_VER"."$TOMCAT_SUBVER".tar.gz
RUN  tar xzf apache-tomcat-"$TOMCAT_VER"."$TOMCAT_SUBVER".tar.gz 
  
USER postgres
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER labkey WITH SUPERUSER PASSWORD 'docker';"

USER root
#maybe scripts for third party stuff expecially R


#wget gets 403 need to svn installs a whole bunch of stuff I dont need
# just gonna use COPY here for simplicity
COPY ./LabKey"$LABKEY_FULLVER"-community-bin.tar.gz /
COPY ./start_labkey.sh /apache-tomcat-"$TOMCAT_VER"."$TOMCAT_SUBVER"/bin

RUN cd ..&&\ 
    mkdir apache-tomcat-"$TOMCAT_VER"."$TOMCAT_SUBVER"/conf/Catalina && \
    mkdir apache-tomcat-"$TOMCAT_VER"."$TOMCAT_SUBVER"/conf/Catalina/localhost


EXPOSE 8080
WORKDIR apache-tomcat-"$TOMCAT_VER"."$TOMCAT_SUBVER"/bin

VOLUME /labkey_data

CMD bash start_labkey.sh

