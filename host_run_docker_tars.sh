sudo docker run -d -it --name host-tars  --env MOUNT_DATA=true --env DBIP=192.168.128.139 --env DBPort=3306 --env DBUser=root --env DBPassword=password -p 3000:3000 -v /data:/data tarscloud/tars:dev

