# labkey_docker
Dockerfile for Labkey 18.1 others can be installed just by changing the version names

### Pre-Reqs
You need the labkey source files from their website and have it in the same directory

### Docker

### Volume
you need to create a volume using 
```
sudo docker volume create labkey_data
```
The volume is hard-coded in the start_labkey.sh file. If you want to rename the volume also need to rename in the sh file and the dockerfile

you can then run the docker file for the first time

```
sudo docker run -it -p 8080:8080 celalp/labkey181:latest
```

After the intial run and file set up labkey should be running in localhost:8080/labkey. 
If you want to access the persistent data you need to restart the docker container either using it's hash id or random docker name

you can get those with 
```
sudo docker ps -a
```
Then you can restart the container with 
```
sudo docker restart [dockerid]
```
