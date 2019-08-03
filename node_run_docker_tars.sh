sudo docker run -d -it --name node-tars  --env MOUNT_DATA=true --env DBIP=192.168.128.139 --env DBPort=3306 --env DBUser=root --env DBPassword=password --env MASTER=192.168.128.139 -v /data:/data --net=host --env INET_NAME=ens33 zxjt/tarsnode:v1 

