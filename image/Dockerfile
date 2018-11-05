FROM tarscloud/tars:dev

WORKDIR /root/

VOLUME ["/data"]
	
##拷贝资源
COPY install.sh /root/init/
COPY t_server_notifys.sql /root/sql
ENTRYPOINT [ "/sbin/entrypoint.sh", "start" ]

#Expose ports
EXPOSE 3000
EXPOSE 80
