docker run -d -it --name host-tars  --env MOUNT_DATA=true --env DBIP=192.168.128.128 --env DBPort=13306 --env DBUser=root --env DBPassword=password -p 3000:3000 --net=host --env INET_NAME=ens33 tarscloud/tars

