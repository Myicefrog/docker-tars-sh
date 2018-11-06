sudo docker run -d -it --name node-tars  --env MOUNT_DATA=true --env DBIP=192.168.79.134 --env DBPort=3306 --env DBUser=root --env DBPassword=password --net=host --env INET_NAME=ens33 --env MASTER=192.168.79.134 -v /data:/data  zxjt/tarsnode:v1 

