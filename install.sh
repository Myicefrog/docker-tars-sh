#!/bin/bash

MachineIp=$(ip addr | grep inet | grep ${INET_NAME} | awk '{print $2;}' | sed 's|/.*$||')
MachineName=$(cat /etc/hosts | grep ${MachineIp} | awk '{print $2}')

prepare_mysql(){
	echo "begin to init mysql database ...."

	##Tars数据库环境初始化
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} -e "grant all on *.* to 'tars'@'%' identified by '${DBTarsPass}' with grant option;"
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} -e "grant all on *.* to 'tars'@'localhost' identified by '${DBTarsPass}' with grant option;"
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} -e "grant all on *.* to 'tars'@'${MachineName}' identified by '${DBTarsPass}' with grant option;"
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} -e "grant all on *.* to 'tars'@'${MachineIp}' identified by '${DBTarsPass}' with grant option;"
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} -e "flush privileges;"

	sed -i "s/192.168.2.131/${MachineIp}/g" `grep 192.168.2.131 -rl /root/sql/*`
	sed -i "s/db.tars.com/${DBIP}/g" `grep db.tars.com -rl /root/sql/*`
	cd /root/sql/
	sed -i "s/proot@appinside/h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} /g" `grep proot@appinside -rl ./exec-sql.sh`
	
	chmod u+x /root/sql/exec-sql.sh
	
	/root/sql/exec-sql.sh

	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/t_tars_files.sql
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/tarsconfig.sql
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/tarsnotify.sql
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/tarspatch.sql
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/tarslog.sql
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/tarsstat.sql
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/tarsproperty.sql
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/tarsquerystat.sql
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars < /root/sql/tarsqueryproperty.sql

}

install_base_services(){
	echo "base services ...."
	
	##框架基础服务包
	cd /root/
	mv t*.tgz /data

	# 安装 tarsnotify、tarsstat、tarsproperty、tarslog、tarsquerystat、tarsqueryproperty
	rm -rf /usr/local/app/tars/tarsnotify && mkdir -p /usr/local/app/tars/tarsnotify/bin && mkdir -p /usr/local/app/tars/tarsnotify/conf && mkdir -p /usr/local/app/tars/tarsnotify/data
	rm -rf /usr/local/app/tars/tarsstat && mkdir -p /usr/local/app/tars/tarsstat/bin && mkdir -p /usr/local/app/tars/tarsstat/conf && mkdir -p /usr/local/app/tars/tarsstat/data
	rm -rf /usr/local/app/tars/tarsproperty && mkdir -p /usr/local/app/tars/tarsproperty/bin && mkdir -p /usr/local/app/tars/tarsproperty/conf && mkdir -p /usr/local/app/tars/tarsproperty/data
	rm -rf /usr/local/app/tars/tarslog && mkdir -p /usr/local/app/tars/tarslog/bin && mkdir -p /usr/local/app/tars/tarslog/conf && mkdir -p /usr/local/app/tars/tarslog/data
	rm -rf /usr/local/app/tars/tarsquerystat && mkdir -p /usr/local/app/tars/tarsquerystat/bin && mkdir -p /usr/local/app/tars/tarsquerystat/conf && mkdir -p /usr/local/app/tars/tarsquerystat/data
	rm -rf /usr/local/app/tars/tarsqueryproperty && mkdir -p /usr/local/app/tars/tarsqueryproperty/bin && mkdir -p /usr/local/app/tars/tarsqueryproperty/conf && mkdir -p /usr/local/app/tars/tarsqueryproperty/data

	if [ ${MOUNT_DATA} = true ];
	then
		mkdir -p /data/tarsconfig_data && rm -rf /usr/local/app/tars/tarsconfig/data && ln -s /data/tarsconfig_data /usr/local/app/tars/tarsconfig/data
		mkdir -p /data/tarsnode_data && rm -rf /usr/local/app/tars/tarsnode/data && ln -s /data/tarsnode_data /usr/local/app/tars/tarsnode/data
		mkdir -p /data/tarspatch_data && rm -rf /usr/local/app/tars/tarspatch/data && ln -s /data/tarspatch_data /usr/local/app/tars/tarspatch/data
		mkdir -p /data/tarsregistry_data && rm -rf /usr/local/app/tars/tarsregistry/data && ln -s /data/tarsregistry_data /usr/local/app/tars/tarsregistry/data
		mkdir -p /data/tars_patchs && cp -Rf /usr/local/app/patchs/* /data/tars_patchs/ && rm -rf /usr/local/app/patchs && ln -s /data/tars_patchs /usr/local/app/patchs
	fi

	cd /data/ && tar zxf tarsnotify.tgz && mv /data/tarsnotify/tarsnotify /usr/local/app/tars/tarsnotify/bin/ && rm -rf /data/tarsnotify
	echo '#!/bin/sh' > /usr/local/app/tars/tarsnotify/bin/tars_start.sh
	echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/app/tars/tarsnotify/bin/:/usr/local/app/tars/tarsnode/data/lib/' >> /usr/local/app/tars/tarsnotify/bin/tars_start.sh
	echo '/usr/local/app/tars/tarsnotify/bin/tarsnotify --config=/usr/local/app/tars/tarsnotify/conf/tars.tarsnotify.config.conf  &' >> /usr/local/app/tars/tarsnotify/bin/tars_start.sh
	chmod 755 /usr/local/app/tars/tarsnotify/bin/tars_start.sh
	echo 'tarsnotify/bin/tars_start.sh;' >> /usr/local/app/tars/tars_install.sh
	cp /root/confs/tars.tarsnotify.config.conf /usr/local/app/tars/tarsnotify/conf/

	cd /data/ && tar zxf tarsstat.tgz && mv /data/tarsstat/tarsstat /usr/local/app/tars/tarsstat/bin/ && rm -rf /data/tarsstat
	echo '#!/bin/sh' > /usr/local/app/tars/tarsstat/bin/tars_start.sh
	echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/app/tars/tarsstat/bin/:/usr/local/app/tars/tarsnode/data/lib/' >> /usr/local/app/tars/tarsstat/bin/tars_start.sh
	echo '/usr/local/app/tars/tarsstat/bin/tarsstat --config=/usr/local/app/tars/tarsstat/conf/tars.tarsstat.config.conf  &' >> /usr/local/app/tars/tarsstat/bin/tars_start.sh
	chmod 755 /usr/local/app/tars/tarsstat/bin/tars_start.sh
	echo 'tarsstat/bin/tars_start.sh;' >> /usr/local/app/tars/tars_install.sh
	cp /root/confs/tars.tarsstat.config.conf /usr/local/app/tars/tarsstat/conf/

	cd /data/ && tar zxf tarsproperty.tgz && mv /data/tarsproperty/tarsproperty /usr/local/app/tars/tarsproperty/bin/ && rm -rf /data/tarsproperty
	echo '#!/bin/sh' > /usr/local/app/tars/tarsproperty/bin/tars_start.sh
	echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/app/tars/tarsproperty/bin/:/usr/local/app/tars/tarsnode/data/lib/' >> /usr/local/app/tars/tarsproperty/bin/tars_start.sh
	echo '/usr/local/app/tars/tarsproperty/bin/tarsproperty --config=/usr/local/app/tars/tarsproperty/conf/tars.tarsproperty.config.conf  &' >> /usr/local/app/tars/tarsproperty/bin/tars_start.sh
	chmod 755 /usr/local/app/tars/tarsproperty/bin/tars_start.sh
	echo 'tarsproperty/bin/tars_start.sh;' >> /usr/local/app/tars/tars_install.sh
	cp /root/confs/tars.tarsproperty.config.conf /usr/local/app/tars/tarsproperty/conf/

	cd /data/ && tar zxf tarslog.tgz && mv /data/tarslog/tarslog /usr/local/app/tars/tarslog/bin/ && rm -rf /data/tarslog
	echo '#!/bin/sh' > /usr/local/app/tars/tarslog/bin/tars_start.sh
	echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/app/tars/tarslog/bin/:/usr/local/app/tars/tarsnode/data/lib/' >> /usr/local/app/tars/tarslog/bin/tars_start.sh
	echo '/usr/local/app/tars/tarslog/bin/tarslog --config=/usr/local/app/tars/tarslog/conf/tars.tarslog.config.conf  &' >> /usr/local/app/tars/tarslog/bin/tars_start.sh
	chmod 755 /usr/local/app/tars/tarslog/bin/tars_start.sh
	echo 'tarslog/bin/tars_start.sh;' >> /usr/local/app/tars/tars_install.sh
	cp /root/confs/tars.tarslog.config.conf /usr/local/app/tars/tarslog/conf/

	cd /data/ && tar zxf tarsquerystat.tgz && mv /data/tarsquerystat/tarsquerystat /usr/local/app/tars/tarsquerystat/bin/ && rm -rf /data/tarsquerystat
	echo '#!/bin/sh' > /usr/local/app/tars/tarsquerystat/bin/tars_start.sh
	echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/app/tars/tarsquerystat/bin/:/usr/local/app/tars/tarsnode/data/lib/' >> /usr/local/app/tars/tarsquerystat/bin/tars_start.sh
	echo '/usr/local/app/tars/tarsquerystat/bin/tarsquerystat --config=/usr/local/app/tars/tarsquerystat/conf/tars.tarsquerystat.config.conf  &' >> /usr/local/app/tars/tarsquerystat/bin/tars_start.sh
	chmod 755 /usr/local/app/tars/tarsquerystat/bin/tars_start.sh
	echo 'tarsquerystat/bin/tars_start.sh;' >> /usr/local/app/tars/tars_install.sh
	cp /root/confs/tars.tarsquerystat.config.conf /usr/local/app/tars/tarsquerystat/conf/

	cd /data/ && tar zxf tarsqueryproperty.tgz && mv /data/tarsqueryproperty/tarsqueryproperty /usr/local/app/tars/tarsqueryproperty/bin/ && rm -rf /data/tarsqueryproperty
	echo '#!/bin/sh' > /usr/local/app/tars/tarsqueryproperty/bin/tars_start.sh
	echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/app/tars/tarsqueryproperty/bin/:/usr/local/app/tars/tarsnode/data/lib/' >> /usr/local/app/tars/tarsqueryproperty/bin/tars_start.sh
	echo '/usr/local/app/tars/tarsqueryproperty/bin/tarsqueryproperty --config=/usr/local/app/tars/tarsqueryproperty/conf/tars.tarsqueryproperty.config.conf  &' >> /usr/local/app/tars/tarsqueryproperty/bin/tars_start.sh
	chmod 755 /usr/local/app/tars/tarsqueryproperty/bin/tars_start.sh
	echo 'tarsqueryproperty/bin/tars_start.sh;' >> /usr/local/app/tars/tars_install.sh
	cp /root/confs/tars.tarsqueryproperty.config.conf /usr/local/app/tars/tarsqueryproperty/conf/

	##核心基础服务配置修改
	cd /usr/local/app/tars

	sed -i "s/dbhost.*=.*192.168.2.131/dbhost = ${DBIP}/g" `grep dbhost -rl ./*`
	sed -i "s/192.168.2.131/${MachineIp}/g" `grep 192.168.2.131 -rl ./*`
	sed -i "s/db.tars.com/${DBIP}/g" `grep db.tars.com -rl ./*`
	sed -i "s/dbport.*=.*3306/dbport = ${DBPort}/g" `grep dbport -rl /usr/local/app/tars/*`
	sed -i "s/registry.tars.com/${MachineIp}/g" `grep registry.tars.com -rl ./*`
	sed -i "s/web.tars.com/${MachineIp}/g" `grep web.tars.com -rl ./*`
	# 修改Mysql里tars用户密码
	sed -i "s/tars2015/${DBTarsPass}/g" `grep tars2015 -rl ./*`

	chmod u+x tars_install.sh
	./tars_install.sh

	chmod u+x tarspatch/util/init.sh
	./tarspatch/util/init.sh

}

build_web_mgr(){
	echo "web manager ...."

	mkdir -p /data/logs
	rm -rf /root/.pm2
	mkdir -p /root/.pm2
	ln -s /data/logs /root/.pm2/logs
	
	cd /usr/local/tarsweb/
	sed -i "s/registry.tars.com/${MachineIp}/g" `grep registry.tars.com -rl ./config/*`
	sed -i "s/db.tars.com/${DBIP}/g" `grep db.tars.com -rl ./config/*`
	sed -i "s/3306/${DBPort}/g" `grep 3306 -rl ./config/*`
	sed -i "s/tars2015/${DBTarsPass}/g" `grep tars2015 -rl ./config/*`
	sed -i "s/DEBUG/INFO/g" `grep DEBUG -rl ./config/*`

	if [ ${ENABLE_LOGIN} = true ];
	then
		echo "Enable Login"
		sed -i "s/enableLogin: false/enableLogin: true/g" ./config/loginConf.js
		sed -i "s/\/\/ let loginConf/let loginConf/g" ./app.js
		sed -i "s/\/\/ loginConf.ignore/loginConf.ignore/g" ./app.js
		sed -i "s/\/\/ app.use(loginMidware/app.use(loginMidware/g" ./app.js
	fi

	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} -e "create database db_tars_web"
	mysql -h${DBIP} -P${DBPort} -u${DBUser} -p${DBPassword} db_tars_web < /usr/local/tarsweb/sql/db_tars_web.sql
}


prepare_mysql

install_base_services

build_web_mgr
