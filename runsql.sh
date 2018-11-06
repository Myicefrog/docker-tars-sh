sudo docker run --name tar-mysql -e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 -v /home/luguang/demo/tars-docker/mysqldata:/var/lib/mysql mysql:5.7 --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

