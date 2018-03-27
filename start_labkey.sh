#!/bin/bash

TOMCAT=$(ls / | grep -o "apache.*[^tar.gz]" | uniq )
LABKEY=$(ls / | grep -o "LabKey.*[^tar.gz]") 

if  [ -d /labkey_data/"$LABKEY"/postgresql ]
then
    echo "Database directory exists"
else 
    echo "Creating database directory in persistent volume"
    mkdir /labkey_data/"$LABKEY"
    rsync -avq /var/lib/postgresql /labkey_data/"$LABKEY"
    cd /etc/postgresql/9.6/main/ 
    sed -i 's/data_directory=\/var\/lib\/postgresql\/9.6\/main/data_directory=\/labkey_data\/'"$LABKEY"'/g' postgresql.conf
fi

if [ -d /labkey_data/"$LABKEY"/labkey ]
then 
    echo "File repository directory exists"
else 
    echo "Creating file repository in persistent volume"
    mkdir /labkey_data/"$LABKEY"/labkey
    cp /"$LABKEY".tar.gz /labkey_data/"$LABKEY"/labkey/"$LABKEY".tar.gz
    cd /labkey_data/"$LABKEY"/labkey/
    tar xzf "$LABKEY".tar.gz
    cd /labkey_data/"$LABKEY"/labkey/"$LABKEY"/tomcat-lib
    files=$(ls)
    for i in $files; do cp $i /"$TOMCAT"/lib/$i; done
    chown -R root /labkey_data/"$LABKEY"/labkey
    cd ..
    sed -i 's/@@appDocBase@@/\/labkey_data\/'"$LABKEY"'\/labkey\/'"$LABKEY"'\/labkeywebapp/g' labkey.xml
    sed -i 's/@@jdbcUser@@/labkey/g' labkey.xml
    sed -i 's/@@jdbcPassword@@/docker/g' labkey.xml
    cp /labkey_data/"$LABKEY"/labkey/"$LABKEY"/labkey.xml /"$TOMCAT"/conf/Catalina/localhost/labkey.xml
fi

cd /"$TOMCAT"/bin

bash /etc/init.d/postgresql start

bash startup.sh

running=0
PID=$(ps ax | grep bootstrap.jar | grep catalina)
if [ -n "$PID" ]
then
    sleep 10
    while [ ${running} -eq 0 ]
    do
        PID=$(ps ax | grep bootstrap.jar | grep catalina)
        if [ -n "$PID" ]
        then
            sleep 10
            running=0
        else
            running=1
            break
        fi
    done
else
    running=1
fi

exit running
